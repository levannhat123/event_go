import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:event_go/data/models/category/category_model.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_go/core/base/base_view_model.dart';
import 'package:event_go/core/config/zalo_pay_config.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/data/models/event/ticket_type_model.dart';
import 'package:event_go/domain/usecase/event/watch_all_events_usecase.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/vnpay_flutter.dart';

enum CaptchaResult { success, fail, lockedOut }

class HomeViewModel extends BaseViewModel {
  final WatchAllEventsUsecase watchAllEventsUsecase;
  HomeViewModel(this.watchAllEventsUsecase) {
    loadRecentSearches();
    fetchCategories();
  }
  final String _emailJSServiceID = 'service_ylcyotg';
  final String _emailJSTemplateID = 'template_w5qexdc';
  final String _emailJSPublicKey = 'eU0EwYJSkgAxSxz3K';
  final String _vnpTmnCode = '0MS82K1F';
  final String _vnpHashKey = '3906YDIHHGXTRHO8NW2UKIC6ZLJX4O20';
  final String _vnpUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Timer? _timer;

  final List<Map<String, String>> boadingData = [
    {"image": AppImage.banner_1},
    {"image": AppImage.banner_2},
    {"image": AppImage.banner_3},
    {"image": AppImage.banner_4},
  ];

  void onPageChanged(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void startAutoSlide(PageController pageController) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      int nextIndex = _currentIndex + 1;
      if (nextIndex >= boadingData.length) {
        nextIndex = 0;
      }
      if (pageController.hasClients) {
        pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        onPageChanged(nextIndex);
      }
    });
  }

  final List<String> trendingTopics = [
    'soobin',
    'gdragon',
    'waterbomb',
    'ntpmm',
  ];

  String _selectedDateText = 'Tất cả các ngày';
  String get selectedDateText => _selectedDateText;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedQuickButtonIndex;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  int? get selectedQuickButtonIndex => _selectedQuickButtonIndex;
  DateTime? get rangeStart => _rangeStart;
  DateTime? get rangeEnd => _rangeEnd;

  void initCalendar() {
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _rangeStart = null;
    _rangeEnd = null;
    _selectedQuickButtonIndex = 0;
  }

  void selectQuickButton(int index) {
    _selectedQuickButtonIndex = index;
    _selectedDay = null;
    _rangeStart = null;
    _rangeEnd = null;
    final now = DateTime.now();
    switch (index) {
      case 0:
        break;
      case 1:
        _focusedDay = DateTime(now.year, now.month, 1);
        _selectedDay = now;
        break;
      case 2:
        final tomorrow = now.add(const Duration(days: 1));
        _focusedDay = DateTime(tomorrow.year, tomorrow.month, 1);
        _selectedDay = tomorrow;
        break;
      case 3:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final friday = startOfWeek.add(const Duration(days: 4));
        final sunday = startOfWeek.add(const Duration(days: 6));
        _focusedDay = DateTime(friday.year, friday.month, 1);
        _rangeStart = friday;
        _rangeEnd = sunday;
        break;
      case 4:
        final startOfRange = DateTime(now.year, now.month, now.day);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        _focusedDay = DateTime(now.year, now.month, 1);
        _rangeStart = startOfRange;
        _rangeEnd = endOfMonth;
        break;
    }
    notifyListeners();
  }

  void previousMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    _selectedDay = null;
    _rangeStart = null;
    _rangeEnd = null;
    _selectedQuickButtonIndex = null;
    notifyListeners();
  }

  void nextMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    _selectedDay = null;
    _rangeStart = null;
    _rangeEnd = null;
    _selectedQuickButtonIndex = null;
    notifyListeners();
  }

  void onDaySelected(DateTime cellDate, bool isCurrentMonth) {
    if (!isCurrentMonth) {
      _focusedDay = DateTime(cellDate.year, cellDate.month, 1);
    }
    _selectedDay = cellDate;
    _rangeStart = null;
    _rangeEnd = null;
    _selectedQuickButtonIndex = null;
    notifyListeners();
  }

  void resetCalendar() {
    _selectedDay = null;
    _rangeStart = null;
    _rangeEnd = null;
    _focusedDay = DateTime.now();
    _selectedQuickButtonIndex = 0;
    notifyListeners();
  }

  List<int> _getDaysInMonth(int year, int month) {
    final DateTime lastDayOfMonth = DateTime(year, month + 1, 0);
    return List.generate(lastDayOfMonth.day, (index) => index + 1);
  }

  List<int> generateCalendarDays(int year, int month) {
    final List<int> days = [];
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int weekdayOfFirstDay = firstDayOfMonth.weekday;
    final int offset = (weekdayOfFirstDay - 1);
    final int daysInPreviousMonth = DateTime(year, month, 0).day;
    for (int i = offset - 1; i >= 0; i--) {
      days.add(daysInPreviousMonth - i);
    }
    days.addAll(_getDaysInMonth(year, month));
    final int remainingSlots = 42 - days.length;
    for (int i = 1; i <= remainingSlots; i++) {
      days.add(i);
    }
    return days;
  }

  String _selectedLocation = 'Toàn quốc';
  bool _isFree = false;
  final Set<String> _selectedCategories = {};
  String get selectedLocation => _selectedLocation;
  bool get isFree => _isFree;
  Set<String> get selectedCategories => _selectedCategories;
  final List<String> filterLocations = [
    'Toàn quốc',
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Lạt',
    'Vị trí khác',
  ];
  void initFilter() {
    _selectedLocation = _appliedLocation;
    _isFree = _appliedIsFree;
    _selectedCategories.clear();
    _selectedCategories.addAll(_appliedCategories);
  }

  void selectLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void toggleFree(bool value) {
    _isFree = value;
    notifyListeners();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void resetFilter() {
    _selectedLocation = 'Toàn quốc';
    _isFree = false;
    _selectedCategories.clear();
    _appliedLocation = 'Toàn quốc';
    _appliedIsFree = false;
    _appliedCategories.clear();

    _applyFilters();
    notifyListeners();
  }

  void applyFilterSheet() {
    _appliedLocation = _selectedLocation;
    _appliedIsFree = _isFree;
    _appliedCategories.clear();
    _appliedCategories.addAll(_selectedCategories);
    _applyFilters();
  }

  int _captchaFailCount = 0;
  DateTime? _lockoutEndTime;
  bool _isExpanded = false;
  String? _captchaErrorText;
  String _currentCaptchaImage = AppImage.logo;
  String get currentCaptchaImage => _currentCaptchaImage;
  void refreshCaptchaImage() {
    _currentCaptchaImage = getRandomCaptchaImage();
    notifyListeners();
  }

  final List<String> _captchaImages = [
    AppImage.catcha_1,
    AppImage.catcha_2,
    AppImage.catcha_3,
    AppImage.catcha_4,
    AppImage.catcha_5,
  ];
  bool get isExpanded => _isExpanded;
  String? get captchaErrorText => _captchaErrorText;
  bool get isLockedOut =>
      _lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!);
  int get lockoutRemainingSeconds {
    if (!isLockedOut) return 0;
    return _lockoutEndTime!.difference(DateTime.now()).inSeconds + 1;
  }

  String getRandomCaptchaImage() {
    final random = Random();
    return _captchaImages[random.nextInt(_captchaImages.length)];
  }

  void initEventDetail() {
    _isExpanded = false;
    _captchaFailCount = 0;
    _lockoutEndTime = null;
    _captchaErrorText = null;
    _currentCaptchaImage = getRandomCaptchaImage();
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
    } else {
      _captchaFailCount++;
      if (_captchaFailCount >= 5) {
        _lockoutEndTime = DateTime.now().add(const Duration(minutes: 1));
        _captchaFailCount = 0;
        _captchaErrorText = null;
        notifyListeners();
        return CaptchaResult.lockedOut;
      } else {
        _captchaErrorText =
            'Xác minh không đúng! (Thử lại: $_captchaFailCount/5)';
        notifyListeners();
        return CaptchaResult.fail;
      }
    }
  }

  final PanelController panelController = PanelController();
  final Map<int, int> _ticketQuantities = {};
  String _zpTransToken = "";
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );
  void initBooking() {
    _ticketQuantities.clear();
  }

  String get zpTransToken => _zpTransToken;
  NumberFormat get currencyFormat => _currencyFormat;
  int getQuantity(int index) {
    return _ticketQuantities[index] ?? 0;
  }

  double get grandTotal {
    double total = 0;
    if (event == null) {
      return 0;
    }
    final List<TicketTypeModel>? tickets = event!.ticketType;
    print('123tickets: ${tickets?.length}');
    if (tickets == null) {
      return 0;
    }
    _ticketQuantities.forEach((index, quantity) {
      if (index < tickets.length) {
        final ticketPrice = tickets[index].price ?? 0;
        total += ticketPrice * quantity;
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

  void incrementTicket(int index) {
    final int currentQuantity = getQuantity(index);
    _updateQuantity(index, currentQuantity + 1);
  }

  void decrementTicket(int index) {
    final int currentQuantity = getQuantity(index);
    if (currentQuantity > 0) {
      _updateQuantity(index, currentQuantity - 1);
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<String?> createPaymentOrder() async {
    setLoading(true);
    int amount = grandTotal.toInt();
    if (amount < 1000 || amount > 10000000) {
      _zpTransToken = "Invalid Amount";
      setLoading(false);
      return null;
    }
    try {
      var result = await createOrder(amount);
      if (result != null) {
        _zpTransToken = result.zptranstoken;
        setLoading(false);
        return _zpTransToken;
      } else {
        setLoading(false);
        return null;
      }
    } catch (e) {
      _zpTransToken = "Error: $e";
      setLoading(false);
      return null;
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Timer? _paymentTimer;
  Duration _timeRemaining = const Duration(minutes: 10, seconds: 00);
  String _selectedPaymentMethod = 'zalopay';
  String _paymentToken = "";
  String get formattedTimeRemaining {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(_timeRemaining.inMinutes.remainder(60));
    String seconds = twoDigits(_timeRemaining.inSeconds.remainder(60));
    return "$minutes : $seconds";
  }

  String get selectedPaymentMethod => _selectedPaymentMethod;

  void initPaymentScreen(
    String token,
    BuildContext context, {
    VoidCallback? onTimerExpired,
  }) {
    _paymentToken = token;
    _timeRemaining = const Duration(minutes: 10, seconds: 00);
    _paymentTimer?.cancel();
    _paymentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds == 0) {
        timer.cancel();
        initBooking();
        notifyListeners();
        onTimerExpired?.call();
        if (context.mounted) {
          context.pop();
        }
      } else {
        _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        notifyListeners();
      }
    });
  }

  void disposePaymentTimer() {
    _paymentTimer?.cancel();
  }

  void selectPaymentMethod(String method) {
    if (_selectedPaymentMethod != method) {
      _selectedPaymentMethod = method;
      notifyListeners();
    }
  }

  Future<dynamic> handlePayment(BuildContext context) async {
    clearError();
    if (_selectedPaymentMethod == 'zalopay') {
      FlutterZaloPayStatus status = await _processZaloPayPayment();

      if (status == FlutterZaloPayStatus.success) {
        String? orderId = await saveOrderToFirebase('completed');
        if (orderId != null) {
          final email = userEmail;
          if (event != null && email != null) {
            sendOrderEmailWithQR(
              orderId,
              email,
              event!.title,
            ).catchError((e) {});
          }
          initBooking();
          notifyListeners();
        }
      } else if (status == FlutterZaloPayStatus.failed) {
        await saveOrderToFirebase('failed');
      } else if (status == FlutterZaloPayStatus.cancelled) {
        await saveOrderToFirebase('cancelled');
      }
      return status;
    } else if (_selectedPaymentMethod == 'vnpay') {
      _processVNPayPayment(context);
      return null;
    } else {
      setError("Phương thức thanh toán chưa được hỗ trợ");
      return null;
    }
  }

  Future<FlutterZaloPayStatus> _processZaloPayPayment() async {
    final event = await FlutterZaloPaySdk.payOrder(zpToken: _paymentToken);
    return event;
  }

  List<EventDetailModel> _events = [];
  EventDetailModel? event;
  List<EventDetailModel> get events => _events;
  StreamSubscription<List<EventDetailModel>>? _subscription;
  List<EventDetailModel> _hotEvents = [];
  List<EventDetailModel> get hotEvents => _hotEvents;
  Map<String, List<EventDetailModel>> _eventsByCategory = {};
  Map<String, List<EventDetailModel>> get eventsByCategory => _eventsByCategory;

  bool _isInitialized = false;
  void watchAll() {
    if (_isInitialized) return;
    _isInitialized = true;
    _subscription?.cancel();
    setBusy(true);
    clearError();

    try {
      _subscription = watchAllEventsUsecase.call().listen(
        (list) async {
          final mappedEvents = list.map((event) {
            return event.copyWith(
              status: calculateEventStatus(
                startTime: event.startTime,
                endTime: event.endTime,
              ),
            );
          }).toList();

          mappedEvents.sort((a, b) {
            final aStart = a.startTime ?? DateTime(1900);
            final bStart = b.startTime ?? DateTime(1900);
            return bStart.compareTo(aStart);
          });

          _events = mappedEvents;
          final soldMap = await _getSoldTicketsByEvent();
          _hotEvents =
              List<EventDetailModel>.from(
                  _events,
                ).where((event) => event.status != 'COMPLETED').toList()
                ..sort((a, b) {
                  final aSold = soldMap[a.id] ?? 0;
                  final bSold = soldMap[b.id] ?? 0;
                  return bSold.compareTo(aSold);
                });

          _hotEvents = _hotEvents.take(5).toList();
          final allCategories = groupBy(
            _events,
            (EventDetailModel e) => e.categories?.name ?? 'Khác',
          );

          const desiredCategories = [
            'Nhạc sống',
            'Thể thao',
            'Sân khấu nghệ thuật',
            'Khác',
          ];

          _eventsByCategory = Map.fromEntries(
            allCategories.entries.where(
              (entry) => desiredCategories.contains(entry.key),
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
    } catch (e) {
      setError('Failed to start watching events: ${e.toString()}');
      setBusy(false);
    }
  }

  List<EventDetailModel> get upcomingAndActiveEvents {
    return _events.where((event) {
      return event.status == 'ACTIVE' || event.status == 'INACTIVE';
    }).toList();
  }

  String? get userEmail {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.email;
  }

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;
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
    final orderData = {
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
      final docRef = await _db
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .add(orderData);
      final String orderId = docRef.id;
      if (paymentStatus == 'completed') {
        await _db.collection('tickets').doc(orderId).set(orderData);
      }
      return docRef.id;
    } catch (e) {
      setError("Lỗi lưu đơn hàng: ${e.toString()}. Vui lòng liên hệ hỗ trợ.");
      return null;
    }
  }

  Future<String> processCheckIn(String orderId) async {
    final ticketRef = _db.collection('tickets').doc(orderId);

    try {
      final String message = await _db.runTransaction((transaction) async {
        final ticketDoc = await transaction.get(ticketRef);
        if (!ticketDoc.exists) {
          return "LỖI: Vé không hợp lệ hoặc không tồn tại.";
        }
        final data = ticketDoc.data();
        if (data == null) {
          return "LỖI: Không thể đọc dữ liệu vé.";
        }
        if (data['paymentStatus'] != 'completed') {
          return "LỖI: Vé này chưa hoàn tất thanh toán.";
        }
        final checkinStatus = data['checkinStatus'];
        if (checkinStatus == 'completed') {
          final timestamp = data['checkinTimestamp'] as Timestamp?;
          final timeStr = timestamp != null
              ? DateFormat('HH:mm dd/MM/yyyy').format(timestamp.toDate())
              : 'không rõ';
          return "LỖI: Vé này ĐÃ ĐƯỢC CHECK-IN lúc $timeStr.";
        }
        transaction.update(ticketRef, {
          'checkinStatus': 'completed',
          'checkinTimestamp': FieldValue.serverTimestamp(),
        });
        final email = data['userEmail'] ?? 'Khách';
        return "THÀNH CÔNG: Check-in cho [$email] thành công!";
      });
      return message;
    } catch (e) {
      print("Lỗi transaction check-in: $e");
      return "LỖI HỆ THỐNG: Đã xảy ra lỗi. Vui lòng thử lại.";
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? get ordersStream {
    if (_userId == null) {
      print("Không thể lấy order stream: UserID is null.");
      return null;
    }
    try {
      return _db
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print("Lỗi khi lấy orders stream: $e");
      return null;
    }
  }

  Future<void> sendOrderEmailWithQR(
    String orderId,
    String userEmail,
    String eventName,
  ) async {
    final dio = Dio();
    try {
      final String qrCodeData = orderId;
      final String qrCodeUrl =
          'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$qrCodeData';

      final templateParams = {
        'email': userEmail,
        'order_id': orderId,
        'event_name': eventName,
        'qr_code_url': qrCodeUrl,
      };
      final url = 'https://api.emailjs.com/api/v1.0/email/send';
      final data = {
        'service_id': _emailJSServiceID,
        'template_id': _emailJSTemplateID,
        'user_id': _emailJSPublicKey,
        'template_params': templateParams,
      };
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'origin': 'http://localhost',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Gửi email xác nhận đơn hàng thành công.');
      } else {
        print(
          'Gửi email thất bại. Status: ${response.statusCode}, Body: ${response.data}',
        );
      }
    } on DioException catch (e) {
      print(
        'Lỗi khi gửi email (DioException): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('Lỗi khi gửi email (unknown): $e');
    }
  }

  final TextEditingController searchController = TextEditingController();

  List<EventDetailModel> _searchResults = [];
  List<EventDetailModel> get searchResults => _searchResults;

  static const String _recentSearchesKey = 'recent_searches';

  List<String> recentSearches = [];
  Future<void> loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
      notifyListeners();
    } catch (e) {
      print("Lỗi khi tải lịch sử tìm kiếm: $e");
    }
  }

  Future<void> addRecentSearch(String query) async {
    if (query.isEmpty) {
      return;
    }

    final String lowercaseQuery = query.toLowerCase();

    recentSearches.removeWhere((item) => item.toLowerCase() == lowercaseQuery);
    recentSearches.insert(0, query);
    const int maxSize = 5;
    if (recentSearches.length > maxSize) {
      recentSearches = recentSearches.sublist(0, maxSize);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, recentSearches);
    } catch (e) {
      print("Lỗi khi lưu lịch sử tìm kiếm: $e");
    }
    notifyListeners();
  }

  Future<void> removeRecentSearch(String query) async {
    recentSearches.removeWhere(
      (item) => item.toLowerCase() == query.toLowerCase(),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, recentSearches);
    } catch (e) {
      print("Lỗi khi xóa 1 mục lịch sử tìm kiếm: $e");
    }
    notifyListeners();
  }

  String _appliedSearchQuery = '';
  DateTime? _appliedSelectedDay;
  DateTime? _appliedRangeStart;
  DateTime? _appliedRangeEnd;
  bool _appliedIsAllDays = true;

  bool get isFilterActive {
    return _appliedSearchQuery.isNotEmpty ||
        !_appliedIsAllDays ||
        _appliedLocation != 'Toàn quốc' ||
        _appliedIsFree ||
        _appliedCategories.isNotEmpty;
  }

  void _applyFilters() {
    List<EventDetailModel> filteredEvents = List.from(_events);
    if (_appliedSearchQuery.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        final title = event.title.toLowerCase();
        final venue = (event.venue ?? '').toLowerCase();
        final query = _appliedSearchQuery.toLowerCase();
        return title.contains(query) || venue.contains(query);
      }).toList();
    }
    if (!_appliedIsAllDays) {
      if (_appliedSelectedDay != null) {
        filteredEvents = filteredEvents.where((event) {
          if (event.startTime == null) return false;
          final eventDate = event.startTime!;
          return eventDate.year == _appliedSelectedDay!.year &&
              eventDate.month == _appliedSelectedDay!.month &&
              eventDate.day == _appliedSelectedDay!.day;
        }).toList();
      } else if (_appliedRangeStart != null && _appliedRangeEnd != null) {
        final rangeEndMidnight = _appliedRangeEnd!.add(const Duration(days: 1));
        filteredEvents = filteredEvents.where((event) {
          if (event.startTime == null) return false;
          final eventDate = event.startTime!;
          return !eventDate.isBefore(_appliedRangeStart!) &&
              eventDate.isBefore(rangeEndMidnight);
        }).toList();
      }
    }
    if (_appliedLocation != 'Toàn quốc') {
      if (_appliedLocation == 'Vị trí khác') {
        final mainLocations = ['hà nội', 'hồ chí minh', 'đà lạt'];
        filteredEvents = filteredEvents.where((event) {
          final venue = (event.locationId ?? '').toLowerCase();
          return !mainLocations.any((loc) => venue.contains(loc));
        }).toList();
      } else {
        filteredEvents = filteredEvents.where((event) {
          final venue = (event.locationId ?? '').toLowerCase();
          return venue.contains(_appliedLocation.toLowerCase());
        }).toList();
      }
    }
    if (_appliedIsFree) {
      filteredEvents = filteredEvents
          .where((event) => (event.isFree ?? false) == true)
          .toList();
    }
    if (_appliedCategories.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        final eventCategory = event.categories?.name;
        if (eventCategory == null) return false;
        return _appliedCategories.contains(eventCategory);
      }).toList();
    }
    _searchResults = filteredEvents;
    notifyListeners();
  }

  void searchEvents(String query) {
    _appliedSearchQuery = query.trim();
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    _appliedSearchQuery = '';
    _applyFilters();
  }

  void updateDateFilter(Map<String, dynamic>? result) {
    if (result != null) {
      _appliedIsAllDays = result['isAllDays'] as bool;
      _appliedSelectedDay = result['selectedDay'] as DateTime?;
      _appliedRangeStart = result['rangeStart'] as DateTime?;
      _appliedRangeEnd = result['rangeEnd'] as DateTime?;
      if (_appliedIsAllDays) {
        _selectedDateText = 'Tất cả các ngày';
      } else if (_appliedSelectedDay != null) {
        _selectedDateText = DateFormat(
          'dd/MM/yyyy',
        ).format(_appliedSelectedDay!);
      } else if (_appliedRangeStart != null && _appliedRangeEnd != null) {
        _selectedDateText =
            '${DateFormat('dd/MM').format(_appliedRangeStart!)} - ${DateFormat('dd/MM').format(_appliedRangeEnd!)}';
      }
    } else {
      _appliedIsAllDays = true;
      _appliedSelectedDay = null;
      _appliedRangeStart = null;
      _appliedRangeEnd = null;
      _selectedDateText = 'Tất cả các ngày';
    }

    _applyFilters();
  }

  List<CategoryModel> _fetchedCategories = [];
  List<CategoryModel> get fetchedCategories => _fetchedCategories;
  Future<void> fetchCategories() async {
    _fetchedCategories = await getAllCategories();
    notifyListeners();
  }

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _db.collection('categories').get();
      final categories = snapshot.docs.map((doc) {
        return CategoryModel.fromJson(doc.data());
      }).toList();

      return categories;
    } catch (e) {
      print("Lỗi khi lấy categories: $e");
      return [];
    }
  }

  String _appliedLocation = 'Toàn quốc';
  bool _appliedIsFree = false;
  final Set<String> _appliedCategories = {};
  bool get appliedIsAllDays => _appliedIsAllDays;
  String get appliedLocation => _appliedLocation;
  bool get appliedIsFree => _appliedIsFree;
  Set<String> get appliedCategories => _appliedCategories;
  void removeDateFilter() {
    _appliedIsAllDays = true;
    _appliedSelectedDay = null;
    _appliedRangeStart = null;
    _appliedRangeEnd = null;
    _selectedDateText = 'Tất cả các ngày';
    _applyFilters();
    notifyListeners();
  }

  void removeLocationFilter() {
    _appliedLocation = 'Toàn quốc';
    _applyFilters();
  }

  void removePriceFilter() {
    _appliedIsFree = false;
    _applyFilters();
  }

  void removeCategoryFilter(String categoryName) {
    _appliedCategories.remove(categoryName);
    _applyFilters();
  }

  bool get isDateFilterActive {
    return !_appliedIsAllDays;
  }

  bool get isMainFilterActive {
    return _appliedLocation != 'Toàn quốc' ||
        _appliedIsFree ||
        _appliedCategories.isNotEmpty;
  }

  void resetAllFiltersAndSearch() {
    searchController.clear();
    _appliedSearchQuery = '';
    _appliedIsAllDays = true;
    _appliedSelectedDay = null;
    _appliedRangeStart = null;
    _appliedRangeEnd = null;
    _selectedDateText = 'Tất cả các ngày';
    _appliedLocation = 'Toàn quốc';
    _appliedIsFree = false;
    _appliedCategories.clear();
    _applyFilters();
    notifyListeners();
  }

  void selectCategoryAndSearch(String categoryName) {
    resetAllFiltersAndSearch();
    if (!appliedCategories.contains(categoryName)) {
      appliedCategories.add(categoryName);
    }
    searchController.clear();
    _applyFilters();
    notifyListeners();
  }

  void selectLocationAndSearch(String locationName) {
    resetAllFiltersAndSearch();
    _appliedLocation = locationName;
    searchController.clear();
    _applyFilters();
    notifyListeners();
  }

  String calculateEventStatus({
    required DateTime? startTime,
    required DateTime? endTime,
  }) {
    final now = DateTime.now();

    if (startTime == null || endTime == null) {
      return 'INACTIVE';
    }

    if (now.isBefore(startTime)) {
      return 'INACTIVE';
    }

    if (now.isAfter(endTime)) {
      return 'COMPLETED';
    }

    return 'ACTIVE';
  }

  void _processVNPayPayment(BuildContext context) {
    if (event == null) return;
    final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: _vnpUrl,
      version: '2.1.0',
      tmnCode: _vnpTmnCode,
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      orderInfo: 'Thanh toan ve: ${event!.title}',
      amount: grandTotal,
      returnUrl: 'https://vnpay.vn/return',
      ipAdress: '192.168.1.1',
      vnpayHashKey: _vnpHashKey,
      vnPayHashType: VNPayHashType.HMACSHA512,
    );

    print("VNPAY URL: $paymentUrl");
    VNPAYFlutter.instance.show(
      context: context,
      paymentUrl: paymentUrl,
      onPaymentSuccess: (params) async {
        print("VNPAY Success: $params");
        setLoading(true);
        String? orderId = await saveOrderToFirebase('completed');
        setLoading(false);

        if (orderId != null) {
          final email = userEmail;
          if (email != null && email.contains('@')) {
            sendOrderEmailWithQR(
              orderId,
              email,
              event!.title,
            ).catchError((e) {});
          }
          initBooking();
          notifyListeners();
          if (context.mounted) {
            context.pushReplacement(
              '/payment-result',
              extra: {
                'isSuccess': true,
                'message':
                    'Bạn đã thanh toán vé thành công! Vé đã được gửi tới email của bạn.',
                'transactionId':
                    params['vnp_TransactionNo'] ?? orderId ?? 'Unknown',
              },
            );
          }
        }
      },
      onPaymentError: (params) async {
        setLoading(true);
        await saveOrderToFirebase('failed');
        setLoading(false);
        String errorMsg = getVnPayMessage(params['vnp_ResponseCode'] ?? '99');
        if (context.mounted) {
          context.push(
            '/payment-result',
            extra: {
              'isSuccess': false,
              'message': errorMsg,
              'transactionId': params['vnp_TransactionNo'] ?? 'Giao dịch lỗi',
            },
          );
        }

        setError("Thanh toán VNPAY thất bại hoặc bị hủy.");
      },
    );
  }

  Future<Map<String, int>> _getSoldTicketsByEvent() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .where('paymentStatus', isEqualTo: 'completed')
        .get();

    final Map<String, int> soldMap = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final eventId = data['eventId'] as String?;
      final List tickets = data['tickets'] ?? [];

      if (eventId == null) continue;

      int totalQty = 0;
      for (final t in tickets) {
        totalQty += (t['quantity'] ?? 0) as int;
      }

      soldMap[eventId] = (soldMap[eventId] ?? 0) + totalQty;
    }

    return soldMap;
  }

  @override
  void dispose() {
    _timer?.cancel();
    searchController.dispose();
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
