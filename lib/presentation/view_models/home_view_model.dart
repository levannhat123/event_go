import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:event_go/data/models/category/category_model.dart';
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

enum CaptchaResult { success, fail, lockedOut }

class HomeViewModel extends BaseViewModel {
  final WatchAllEventsUsecase watchAllEventsUsecase;
  HomeViewModel(this.watchAllEventsUsecase){
    loadRecentSearches();
    fetchCategories();
  }
  final String _emailJSServiceID = 'service_ylcyotg';
  final String _emailJSTemplateID = 'template_w5qexdc';
  final String _emailJSPublicKey = 'eU0EwYJSkgAxSxz3K';

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
    AppImage.logo,
    AppImage.banner_1,
    AppImage.banner_2,
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
    if (amount < 1000 || amount > 1000000) {
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
  Duration _timeRemaining = const Duration(minutes: 1, seconds: 38);
  String _selectedPaymentMethod = 'zalopay';
  String _paymentToken = "";
  String get formattedTimeRemaining {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(_timeRemaining.inMinutes.remainder(60));
    String seconds = twoDigits(_timeRemaining.inSeconds.remainder(60));
    return "$minutes : $seconds";
  }

  String get selectedPaymentMethod => _selectedPaymentMethod;

  void initPaymentScreen(String token, BuildContext context,
      {VoidCallback? onTimerExpired}) {
    _paymentToken = token;
    _timeRemaining = const Duration(minutes: 1, seconds: 38);
    _paymentTimer?.cancel();
    _paymentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds == 0) {
        timer.cancel();
        initBooking();
        notifyListeners();
        onTimerExpired?.call();
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

  Future<FlutterZaloPayStatus> handlePayment() async {
    clearError();
    FlutterZaloPayStatus status;
    if (_selectedPaymentMethod == 'zalopay') {
      status = await _processZaloPayPayment();
    } else {
      status = FlutterZaloPayStatus.failed;
    }

    String? orderId;
    if (status == FlutterZaloPayStatus.success) {
      orderId = await saveOrderToFirebase('completed');
      if (orderId != null) {
        final email = userEmail;
        if (event != null && email != null && email.contains('@')) {
          sendOrderEmailWithQR(orderId, email, event!.title)
              .catchError((e) {
          });
        } else {
          print(
              'Không gửi email: Email không hợp lệ hoặc người dùng không đăng nhập ($email)');
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

  void watchAll() {
    _subscription?.cancel();
    setBusy(true);
    clearError();
    try {
      _subscription = watchAllEventsUsecase.call().listen(
            (list) {
          _events = list;
          _hotEvents = list.where((event) => event.isHot == true).toList();
          final allCategories = groupBy(
            list,
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
          Future.microtask(() {
            notifyListeners();
          });
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
    };
    try {
      final docRef = await _db
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .add(orderData);
      return docRef.id;
    } catch (e) {
      setError("Lỗi lưu đơn hàng: ${e.toString()}. Vui lòng liên hệ hỗ trợ.");
      return null;
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
      String orderId, String userEmail, String eventName) async {
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
            'origin': 'http://localhost'
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Gửi email xác nhận đơn hàng thành công.');
      } else {
        print(
            'Gửi email thất bại. Status: ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      print('Lỗi khi gửi email (DioException): ${e.response?.data ?? e.message}');
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
    recentSearches.removeWhere((item) => item.toLowerCase() == query.toLowerCase());

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
  bool _appliedIsAllDays = true; // Mặc định là 'Tất cả các ngày'

  // Biến này sẽ quyết định UI hiển thị "Khám phá" hay "Kết quả"
  bool get isFilterActive {
    return _appliedSearchQuery.isNotEmpty ||
        !_appliedIsAllDays || // Có lọc ngày
        _appliedLocation != 'Toàn quốc' || // <-- Thêm dòng này
        _appliedIsFree || // <-- Thêm dòng này
        _appliedCategories.isNotEmpty; // <-- Thêm dòng này
  }
  // [THÊM MỚI] Hàm lọc trung tâm
  void _applyFilters() {
    // 1. Bắt đầu với danh sách đầy đủ
    List<EventDetailModel> filteredEvents = List.from(_events);

    // 2. Lọc theo Text Query (nếu có)
    if (_appliedSearchQuery.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        final title = event.title.toLowerCase();
        final venue = (event.venue ?? '').toLowerCase();
        final query = _appliedSearchQuery.toLowerCase();
        return title.contains(query) || venue.contains(query);
      }).toList();
    }

    // 3. Lọc theo Ngày (nếu có)
    if (!_appliedIsAllDays) {
      if (_appliedSelectedDay != null) {
        // Lọc theo ngày cụ thể
        filteredEvents = filteredEvents.where((event) {
          if (event.startTime == null) return false;
          // Chỉ so sánh Năm-Tháng-Ngày
          final eventDate = event.startTime!;
          return eventDate.year == _appliedSelectedDay!.year &&
              eventDate.month == _appliedSelectedDay!.month &&
              eventDate.day == _appliedSelectedDay!.day;
        }).toList();
      } else if (_appliedRangeStart != null && _appliedRangeEnd != null) {
        // Lọc theo khoảng ngày
        final rangeEndMidnight = _appliedRangeEnd!.add(const Duration(days: 1));

        filteredEvents = filteredEvents.where((event) {
          if (event.startTime == null) return false;
          final eventDate = event.startTime!;
          return !eventDate.isBefore(_appliedRangeStart!) &&
              eventDate.isBefore(rangeEndMidnight);
        }).toList();
      }
    }

    // 4. [THÊM LOGIC LỌC MỚI]
    // Lọc địa điểm
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

    // Lọc miễn phí
    if (_appliedIsFree) {
      filteredEvents = filteredEvents
          .where((event) => (event.isFree ?? false) == true)
          .toList();
    }

    // Lọc thể loại
    if (_appliedCategories.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        final eventCategory = event.categories?.name;
        if (eventCategory == null) return false;
        // Kiểm tra xem category của event có nằm trong danh sách đã chọn không
        return _appliedCategories.contains(eventCategory);
      }).toList();
    }

    // 5. Cập nhật kết quả cuối cùng
    _searchResults = filteredEvents;
    notifyListeners();
  }
  void searchEvents(String query) {
    _appliedSearchQuery = query.trim();
    _applyFilters(); // Gọi hàm lọc trung tâm
  }

  // [THAY THẾ] Hàm này
  void clearSearch() {
    searchController.clear();
    _appliedSearchQuery = '';
    _applyFilters(); // Gọi hàm lọc trung tâm
  }

  // [THAY THẾ] Hàm này
  void updateDateFilter(Map<String, dynamic>? result) {
    if (result != null) {
      // Cập nhật trạng thái bộ lọc ĐÃ ÁP DỤNG
      _appliedIsAllDays = result['isAllDays'] as bool;
      _appliedSelectedDay = result['selectedDay'] as DateTime?;
      _appliedRangeStart = result['rangeStart'] as DateTime?;
      _appliedRangeEnd = result['rangeEnd'] as DateTime?;

      // Cập nhật văn bản hiển thị
      if (_appliedIsAllDays) {
        _selectedDateText = 'Tất cả các ngày';
      } else if (_appliedSelectedDay != null) {
        _selectedDateText = DateFormat('dd/MM/yyyy').format(_appliedSelectedDay!);
      } else if (_appliedRangeStart != null && _appliedRangeEnd != null) {
        _selectedDateText =
        '${DateFormat('dd/MM').format(_appliedRangeStart!)} - ${DateFormat('dd/MM').format(_appliedRangeEnd!)}';
      }
    } else {
      // Nếu người dùng đóng sheet (result == null), reset về mặc định
      _appliedIsAllDays = true;
      _appliedSelectedDay = null;
      _appliedRangeStart = null;
      _appliedRangeEnd = null;
      _selectedDateText = 'Tất cả các ngày';
    }

    _applyFilters(); // Gọi hàm lọc trung tâm
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
    // Cập nhật lại text của nút
    _selectedDateText = 'Tất cả các ngày';
    _applyFilters();
    notifyListeners(); // Cần notify để cập nhật text trên nút
  }

  /// Gỡ bỏ bộ lọc địa điểm
  void removeLocationFilter() {
    _appliedLocation = 'Toàn quốc';
    _applyFilters();
  }

  /// Gỡ bỏ bộ lọc giá (miễn phí)
  void removePriceFilter() {
    _appliedIsFree = false;
    _applyFilters();
  }

  /// Gỡ bỏ một thể loại cụ thể
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
    // 1. Reset text search
    searchController.clear(); // Xóa chữ trong ô text
    _appliedSearchQuery = '';

    // 2. Reset bộ lọc ngày
    _appliedIsAllDays = true;
    _appliedSelectedDay = null;
    _appliedRangeStart = null;
    _appliedRangeEnd = null;
    _selectedDateText = 'Tất cả các ngày'; // Reset text của nút

    // 3. Reset các bộ lọc chính
    _appliedLocation = 'Toàn quốc';
    _appliedIsFree = false;
    _appliedCategories.clear();

    // 4. Áp dụng bộ lọc (rỗng) để xóa kết quả tìm kiếm
    _applyFilters();

    // 5. Thông báo cho UI (SearchScreen) cập nhật lại (ví dụ: màu nút)
    notifyListeners();
  }
  @override
  void dispose() {
    _timer?.cancel();
    searchController.dispose();
    super.dispose();
  }
}

