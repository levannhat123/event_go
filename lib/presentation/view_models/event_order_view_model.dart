import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:event_go/core/base/base_view_model.dart';
import 'package:event_go/core/config/zalo_pay_config.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/domain/usecase/event/watch_all_events_usecase.dart';
import 'package:event_go/domain/usecase/order/create_order_usecase.dart';
import 'package:event_go/domain/usecase/order/get_sold_tickets_by_event_usecase.dart';
import 'package:event_go/domain/usecase/order/send_order_email_usecase.dart';
import 'package:event_go/domain/usecase/order/watch_sold_tickets_by_event_usecase.dart';
import 'package:event_go/domain/usecase/order/watch_user_orders_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../core/config/vnpay_flutter.dart';
import '../../core/constants/app_image.dart';
import '../../routers/router_name.dart';

enum CaptchaResult { success, fail, lockedOut }

class EventOrderViewModel extends BaseViewModel {
  EventOrderViewModel({
    required this.watchAllEventsUsecase,
    required this.watchUserOrdersUsecase,
    required this.createOrderUsecase,
    required this.watchSoldTicketsByEventUsecase,
    required this.getSoldTicketsByEventUsecase,
    required this.sendOrderEmailUsecase,
  });

  final WatchAllEventsUsecase watchAllEventsUsecase;
  final WatchUserOrdersUsecase watchUserOrdersUsecase;
  final CreateOrderUsecase createOrderUsecase;
  final WatchSoldTicketsByEventUsecase watchSoldTicketsByEventUsecase;
  final GetSoldTicketsByEventUsecase getSoldTicketsByEventUsecase;
  final SendOrderEmailUsecase sendOrderEmailUsecase;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;
  String? get userEmail => Supabase.instance.client.auth.currentUser?.email;

  bool _isExpanded = false;
  int _captchaFailCount = 0;
  DateTime? _lockoutEndTime;
  String? _captchaErrorText;
  String _currentCaptchaImage = AppImage.logo;
  final List<String> _captchaImages = [
    AppImage.catcha_1,
    AppImage.catcha_2,
    AppImage.catcha_3,
    AppImage.catcha_4,
    AppImage.catcha_5,
  ];
  Map<String, int> _soldTicketsByName = {};
  StreamSubscription<QuerySnapshot>? _ticketSalesSubscription;

  bool get isExpanded => _isExpanded;
  String? get captchaErrorText => _captchaErrorText;
  String get currentCaptchaImage => _currentCaptchaImage;
  bool get isLockedOut =>
      _lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!);
  int get lockoutRemainingSeconds {
    if (!isLockedOut) return 0;
    return _lockoutEndTime!.difference(DateTime.now()).inSeconds + 1;
  }

  int getSoldQuantity(String ticketName) => _soldTicketsByName[ticketName] ?? 0;

  void initEventDetail(String eventId) {
    _isExpanded = false;
    _captchaFailCount = 0;
    _lockoutEndTime = null;
    _captchaErrorText = null;
    _currentCaptchaImage = getRandomCaptchaImage();
    _soldTicketsByName.clear();
    _listenToTicketSales(eventId);
  }

  void _listenToTicketSales(String eventId) {
    _ticketSalesSubscription?.cancel();
    _ticketSalesSubscription = watchSoldTicketsByEventUsecase
        .call(eventId)
        .listen((snapshot) {
          final Map<String, int> tempMap = {};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final List<dynamic> tickets = data['tickets'] ?? [];
            for (var t in tickets) {
              final String name = t['name'];
              final int qty = (t['quantity'] ?? 0) as int;
              tempMap[name] = (tempMap[name] ?? 0) + qty;
            }
          }
          _soldTicketsByName = tempMap;
          notifyListeners();
        });
  }

  String getRandomCaptchaImage() {
    final random = Random();
    return _captchaImages[random.nextInt(_captchaImages.length)];
  }

  void refreshCaptchaImage() {
    _currentCaptchaImage = getRandomCaptchaImage();
    notifyListeners();
  }

  void toggleDescriptionExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void clearCaptchaError() {
    _captchaErrorText = null;
    notifyListeners();
  }

  CaptchaResult onCaptchaConfirm(bool success) {
    if (success) {
      _captchaFailCount = 0;
      _captchaErrorText = null;
      notifyListeners();
      return CaptchaResult.success;
    }
    _captchaFailCount++;
    if (_captchaFailCount >= 5) {
      _lockoutEndTime = DateTime.now().add(const Duration(minutes: 1));
      _captchaFailCount = 0;
      _captchaErrorText = null;
      notifyListeners();
      return CaptchaResult.lockedOut;
    }
    _captchaErrorText = 'Xác minh không đúng! (Thử lại: $_captchaFailCount/5)';
    notifyListeners();
    return CaptchaResult.fail;
  }

  final PanelController panelController = PanelController();
  final Map<int, int> _ticketQuantities = {};
  String _zpTransToken = "";
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );

  EventDetailModel? event;
  bool _isLoading = false;
  Timer? _paymentTimer;
  Duration _timeRemaining = const Duration(minutes: 10);
  String _selectedPaymentMethod = 'zalopay';
  String _paymentToken = "";

  String get zpTransToken => _zpTransToken;
  NumberFormat get currencyFormat => _currencyFormat;
  bool get isLoading => _isLoading;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  String get formattedTimeRemaining {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(_timeRemaining.inMinutes.remainder(60))} : ${twoDigits(_timeRemaining.inSeconds.remainder(60))}";
  }

  void initBooking() {
    _ticketQuantities.clear();
    notifyListeners();
  }

  int getQuantity(int index) => _ticketQuantities[index] ?? 0;

  double get grandTotal {
    if (event?.ticketType == null) return 0;
    double total = 0;
    _ticketQuantities.forEach((index, quantity) {
      if (index < event!.ticketType!.length) {
        total += (event!.ticketType![index].price ?? 0) * quantity;
      }
    });
    return total;
  }

  bool get hasTickets => grandTotal > 0;

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity < 0) return;
    _ticketQuantities[index] = newQuantity;
    notifyListeners();
  }

  void incrementTicket(int index) =>
      _updateQuantity(index, getQuantity(index) + 1);
  void decrementTicket(int index) {
    final current = getQuantity(index);
    if (current > 0) _updateQuantity(index, current - 1);
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<String?> createPaymentOrder() async {
    setLoading(true);
    int amount = grandTotal.toInt();
    if (amount < 1000 || amount > 10000000) {
      _zpTransToken = "Invalid Amount";
      setLoading(false);
      return null;
    }
    try {
      final result = await createOrder(amount);
      if (result == null) {
        setLoading(false);
        return null;
      }
      _zpTransToken = result.zptranstoken;
      setLoading(false);
      return _zpTransToken;
    } catch (e) {
      _zpTransToken = "Error: $e";
      setLoading(false);
      return null;
    }
  }

  void initPaymentScreen(
    String token,
    BuildContext context, {
    VoidCallback? onTimerExpired,
  }) {
    _paymentToken = token;
    _timeRemaining = const Duration(minutes: 10);
    _paymentTimer?.cancel();
    _paymentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds == 0) {
        timer.cancel();
        initBooking();
        onTimerExpired?.call();
        if (context.mounted) context.pop();
        return;
      }
      _timeRemaining -= const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void disposePaymentTimer() => _paymentTimer?.cancel();

  void selectPaymentMethod(String method) {
    if (_selectedPaymentMethod == method) return;
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  Future<dynamic> handlePayment(BuildContext context) async {
    clearError();
    if (_selectedPaymentMethod == 'zalopay') {
      final status = await FlutterZaloPaySdk.payOrder(zpToken: _paymentToken);
      if (status == FlutterZaloPayStatus.success) {
        final orderId = await saveOrderToFirebase('completed');
        if (orderId != null) {
          final email = userEmail;
          if (event != null && email != null) {
            sendOrderEmailWithQR(
              orderId,
              email,
              event!.title,
            ).catchError((_) {});
          }
          initBooking();
        }
      } else if (status == FlutterZaloPayStatus.failed) {
        await saveOrderToFirebase('failed');
      } else if (status == FlutterZaloPayStatus.cancelled) {
        await saveOrderToFirebase('cancelled');
      }
      return status;
    }
    if (_selectedPaymentMethod == 'vnpay') {
      _processVNPayPayment(context);
      return null;
    }
    setError("Phương thức thanh toán chưa được hỗ trợ");
    return null;
  }

  Future<String?> saveOrderToFirebase(String paymentStatus) async {
    if (event == null) {
      setError("Sự kiện không tồn tại.");
      return null;
    }
    if (_userId == null) {
      setError("Người dùng không tồn tại.");
      return null;
    }
    final allTicketTypes = event!.ticketType;
    if (allTicketTypes == null) {
      setError("Loại vé không tồn tại.");
      return null;
    }

    final List<Map<String, dynamic>> purchasedTickets = [];
    _ticketQuantities.forEach((index, quantity) {
      if (quantity > 0 && index < allTicketTypes.length) {
        final ticket = allTicketTypes[index];
        purchasedTickets.add({
          'name': ticket.name,
          'price': ticket.price ?? 0,
          'quantity': quantity,
        });
      }
    });

    if (purchasedTickets.isEmpty && paymentStatus == 'completed') {
      setError("Không có vé nào được chọn.");
      return null;
    }

    final orderData = <String, dynamic>{
      'userId': _userId,
      'userEmail': userEmail ?? 'Không có email',
      'eventId': event!.id,
      'eventName': event!.title,
      'venue': event!.venue ?? '',
      'tickets': purchasedTickets,
      'totalAmount': grandTotal,
      'paymentMethod': selectedPaymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': FieldValue.serverTimestamp(),
      'checkinStatus': 'pending',
      'checkinTimestamp': null,
      "checkedIn": 0,
    };
    try {
      final orderId = await createOrderUsecase.call(
        userId: _userId!,
        orderData: orderData,
        createGlobalTicket: paymentStatus == 'completed',
      );
      return orderId;
    } catch (e) {
      setError("Lỗi lưu đơn hàng: ${e.toString()}. Vui lòng liên hệ hỗ trợ.");
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? get ordersStream {
    if (_userId == null) return null;
    return watchUserOrdersUsecase.call(_userId!);
  }

  Future<void> sendOrderEmailWithQR(
    String orderId,
    String userEmail,
    String eventName,
  ) async {
    await sendOrderEmailUsecase.call(
      orderId: orderId,
      userEmail: userEmail,
      eventName: eventName,
    );
  }

  void _processVNPayPayment(BuildContext context) {
    if (event == null) return;
    final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: VNPAYFlutter.paymentUrl,
      version: '2.1.0',
      tmnCode: VNPAYFlutter.tmnCode,
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      orderInfo: 'Thanh toan ve: ${event!.title}',
      amount: grandTotal,
      returnUrl: 'https://vnpay.vn/return',
      ipAdress: '192.168.1.1',
      vnpayHashKey: VNPAYFlutter.hashKey,
      vnPayHashType: VNPayHashType.HMACSHA512,
    );
    VNPAYFlutter.instance.show(
      context: context,
      paymentUrl: paymentUrl,
      onPaymentSuccess: (params) async {
        setLoading(true);
        final orderId = await saveOrderToFirebase('completed');
        setLoading(false);
        if (orderId != null) {
          final email = userEmail;
          if (email != null && email.contains('@')) {
            sendOrderEmailWithQR(
              orderId,
              email,
              event!.title,
            ).catchError((_) {});
          }
          initBooking();
          if (context.mounted) {
            context.pushReplacement(
              RouterPath.payment_result,
              extra: {
                'isSuccess': true,
                'message':
                    'Bạn đã thanh toán vé thành công! Vé đã được gửi tới email của bạn.',
                'transactionId': params['vnp_TransactionNo'] ?? orderId,
              },
            );
          }
        }
      },
      onPaymentError: (params) async {
        setLoading(true);
        await saveOrderToFirebase('failed');
        setLoading(false);
        if (context.mounted) {
          context.push(
            RouterPath.payment_result,
            extra: {
              'isSuccess': false,
              'message': getVnPayMessage(params['vnp_ResponseCode'] ?? '99'),
              'transactionId': params['vnp_TransactionNo'] ?? 'Giao dịch lỗi',
            },
          );
        }
        setError("Thanh toán VNPAY thất bại hoặc bị hủy.");
      },
    );
  }

  List<EventDetailModel> _events = [];
  List<EventDetailModel> get events => _events;
  StreamSubscription<List<EventDetailModel>>? _subscription;
  bool _isInitialized = false;

  void watchAll() {
    if (_isInitialized) return;
    _isInitialized = true;
    _subscription?.cancel();
    setBusy(true);
    _subscription = watchAllEventsUsecase.call().listen(
      (list) async {
        _events =
            list
                .map(
                  (e) => e.copyWith(
                    status: calculateEventStatus(
                      startTime: e.startTime,
                      endTime: e.endTime,
                    ),
                  ),
                )
                .toList()
              ..sort(
                (a, b) => (b.startTime ?? DateTime(1900)).compareTo(
                  a.startTime ?? DateTime(1900),
                ),
              );

        final soldMap = await _getSoldTicketsByEvent();
        final hotEvents =
            List<EventDetailModel>.from(
              _events,
            ).where((e) => e.status != 'COMPLETED').toList()..sort(
              (a, b) => (soldMap[b.id] ?? 0).compareTo(soldMap[a.id] ?? 0),
            );

        _hotEvents = hotEvents.take(5).toList();
        _eventsByCategory = Map.fromEntries(
          groupBy(
            _events,
            (EventDetailModel e) => e.categories?.name ?? 'Khác',
          ).entries.where(
            (entry) => const [
              'Nhạc sống',
              'Thể thao',
              'Sân khấu nghệ thuật',
              'Khác',
            ].contains(entry.key),
          ),
        );
        setBusy(false);
        notifyListeners();
      },
      onError: (err) {
        setError('Failed to watch events: ${err.toString()}');
        setBusy(false);
      },
    );
  }

  List<EventDetailModel> _hotEvents = [];
  List<EventDetailModel> get hotEvents => _hotEvents;
  Map<String, List<EventDetailModel>> _eventsByCategory = {};
  Map<String, List<EventDetailModel>> get eventsByCategory => _eventsByCategory;

  List<EventDetailModel> get upcomingAndActiveEvents => _events
      .where((e) => e.status == 'ACTIVE' || e.status == 'INACTIVE')
      .toList();

  String calculateEventStatus({
    required DateTime? startTime,
    required DateTime? endTime,
  }) {
    final now = DateTime.now();
    if (startTime == null || endTime == null) return 'INACTIVE';
    if (now.isBefore(startTime)) return 'INACTIVE';
    if (now.isAfter(endTime)) return 'COMPLETED';
    return 'ACTIVE';
  }

  Future<Map<String, int>> _getSoldTicketsByEvent() async {
    return getSoldTicketsByEventUsecase.call();
  }

  @override
  void dispose() {
    _paymentTimer?.cancel();
    _ticketSalesSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

String getVnPayMessage(String responseCode) {
  switch (responseCode) {
    case '00':
      return 'Giao dịch thành công';
    case '24':
      return 'Bạn đã hủy giao dịch.';
    case '51':
      return 'Tài khoản không đủ số dư.';
    case '11':
      return 'Hết hạn chờ thanh toán.';
    case '13':
      return 'Nhập sai OTP quá quy định.';
    default:
      return 'Giao dịch thất bại (Mã lỗi: $responseCode).';
  }
}
