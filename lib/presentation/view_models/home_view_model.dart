import 'dart:async';
import 'dart:math';
import 'package:event_go/core/base/base_view_model.dart';
import 'package:event_go/core/config/zalo_pay_config.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/presentation/pages/home/event/event_booking_screen.dart';
import 'package:event_go/presentation/pages/home/event/widget/ticket_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum CaptchaResult { success, fail, lockedOut }


class HomeViewModel extends BaseViewModel {
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
        // Cập nhật state sau khi animation chạy
        onPageChanged(nextIndex);
      }
    });
  }

  final TextEditingController searchController = TextEditingController();

  final List<String> recentSearches = ['Fan Meeting', 'QUA NHỮNG ÁNH NHÌN'];
  final List<String> trendingTopics = [
    'soobin',
    'gdragon',
    'waterbomb',
    'ntpmm',
  ];

  String _selectedDateText = 'Tất cả các ngày';
  String get selectedDateText => _selectedDateText;

  void updateDateFilter(Map<String, dynamic>? result) {
    if (result != null) {
      bool isAllDays = result['isAllDays'] as bool;
      DateTime? selectedDay = result['selectedDay'] as DateTime?;
      DateTime? rangeStart = result['rangeStart'] as DateTime?;
      DateTime? rangeEnd = result['rangeEnd'] as DateTime?;

      if (isAllDays) {
        _selectedDateText = 'Tất cả các ngày';
      } else if (selectedDay != null) {
        _selectedDateText = DateFormat('dd/MM/yyyy').format(selectedDay);
      } else if (rangeStart != null && rangeEnd != null) {
        _selectedDateText =
            '${DateFormat('dd/MM').format(rangeStart)} - ${DateFormat('dd/MM').format(rangeEnd)}';
      }
    }
    notifyListeners();
  }

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

  // Getters
  String get selectedLocation => _selectedLocation;
  bool get isFree => _isFree;
  Set<String> get selectedCategories => _selectedCategories;

  // Data
  final List<String> filterLocations = [
    'Toàn quốc',
    'Hồ Chí Minh',
    'Hà Nội',
    'Đà Lạt',
    'Vị trí khác',
  ];
  final List<String> filterCategories = [
    'Nhạc sống',
    'Sân khấu & Nghệ thuật',
    'Thể Thao',
    'Khác',
  ];

  // Logic
  void initFilter() {
    _selectedLocation = 'Toàn quốc';
    _isFree = false;
    _selectedCategories.clear();
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
    notifyListeners();
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

  // Data
  final List<String> _captchaImages = [
    AppImage.logo,
    AppImage.banner_1,
    AppImage.banner_2,
  ];
  final String eventFullText = '''
Với không gian được đầu tư hệ thống ánh sáng - âm thanh đẳng cấp quốc tế với sức chứa lên đến 350 người, cùng quầy bar phục vụ cocktail pha chế độc đáo bởi bartender chuyên nghiệp.

Mùa cuối năm, liệu bạn đã sẵn sàng để tâm hồn đắm mình trong giai điệu, để trái tim tan chảy bởi giọng hát cảm xúc của Hương Tràm vào 20g00 - 9/11/2025 (Chủ nhật) tại Cat&Mouse?

Với những ca khúc quen thuộc đạt hàng trăm triệu lượt xem như “Duyên mình lỡ”, “Em gái mưa”, “Cho em gần anh thêm chút nữa”… kết hợp với hệ thống âm thanh Adamson chuẩn quốc tế của Cat&Mouse sẽ tạo nên một đêm diễn sâu lắng và khó quên dành cho bạn.
''';

  // Getters
  bool get isExpanded => _isExpanded;
  String? get captchaErrorText => _captchaErrorText;
  bool get isLockedOut =>
      _lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!);
  int get lockoutRemainingSeconds {
    if (!isLockedOut) return 0;
    return _lockoutEndTime!.difference(DateTime.now()).inSeconds + 1;
  }

  // Methods
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

  final List<TicketData> ticketList = [
    TicketData(
      title: 'Ga-Vé Thường',
      price: '299.000đ',
      priceValue: 299000,
      description:
          'Vé bao gồm: \n- Vé vào cổng sự kiện\n- Quà tặng từ ban tổ chức\n- Voucher ưu đãi từ các đối tác',
      titleColor: Colors.green,
    ),
    TicketData(
      title: 'Ga-Vé VIP',
      price: '599.000đ',
      priceValue: 599000,
      description:
          'Vé bao gồm: \n- Vé vào cổng sự kiện\n- Quà tặng VIP\n- Lối đi riêng\n- Voucher ưu đãi từ các đối tác',
      titleColor: Colors.orange,
    ),
    TicketData(
      title: 'Ga-Vé VVIP',
      price: '999.000đ',
      priceValue: 999000,
      description:
          'Vé bao gồm: \n- Vé vào cổng sự kiện\n- Quà tặng VVIP\n- Lối đi riêng\n- Gặp gỡ nghệ sĩ\n- Voucher ưu đãi từ các đối tác',
      titleColor: Colors.purpleAccent,
    ),
    TicketData(
      title: 'Vé Sinh Viên',
      price: '199.000đ',
      priceValue: 199000,
      description:
          'Vé bao gồm: \n- Vé vào cổng sự kiện\n- (Yêu cầu xuất trình thẻ sinh viên)',
      titleColor: Colors.blueAccent,
    ),
  ];
  final PanelController panelController = PanelController();

  // State chính: Map<index_của_vé, số_lượng>
  final Map<int, int> _ticketQuantities = {};

  // State cho ZaloPay
  String _zpTransToken = "";

  // Utility
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );
  void initBooking() {
    _ticketQuantities.clear();
    // Không cần notifyListeners() vì đây là hàm init
  }

  // --- Getters cho Booking ---
  String get zpTransToken => _zpTransToken;
  NumberFormat get currencyFormat => _currencyFormat;

  // Lấy số lượng của 1 loại vé
  int getQuantity(int index) {
    return _ticketQuantities[index] ?? 0;
  }

  // Lấy tổng tiền của toàn bộ đơn hàng
  double get grandTotal {
    double total = 0;
    _ticketQuantities.forEach((index, quantity) {
      if (index < ticketList.length) {
        total += ticketList[index].priceValue * quantity;
      }
    });
    return total;
  }

  bool get hasTickets => grandTotal > 0;

  // --- Actions cho Booking ---

  // Cập nhật số lượng và thông báo cho UI
  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity < 0) return;
    _ticketQuantities[index] = newQuantity;
    notifyListeners(); // Đây là mấu chốt, thay thế cho setState()
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
  // Logic nghiệp vụ: Tạo đơn hàng ZaloPay
  Future<String?> createPaymentOrder() async {
    setLoading(true); // Dùng hàm từ BaseViewModel

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
        print("zpTransToken $_zpTransToken'.");
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
  Duration _timeRemaining = const Duration(minutes: 11, seconds: 38);
  String _selectedPaymentMethod = 'vnpay'; // Giá trị mặc định
  String _paymentToken = "";

  // --- Getters cho Payment ---

  String get formattedTimeRemaining {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(_timeRemaining.inMinutes.remainder(60));
    String seconds = twoDigits(_timeRemaining.inSeconds.remainder(60));
    return "$minutes : $seconds";
  }

  String get selectedPaymentMethod => _selectedPaymentMethod;

  // --- Actions cho Payment ---

  /// Khởi tạo state cho màn hình thanh toán, bao gồm cả việc bắt đầu timer.
  void initPaymentScreen(String token, BuildContext context) {
    _paymentToken = token;
    print('Token payment (from VM): $_paymentToken');

    // Reset timer về giá trị ban đầu
    _timeRemaining = const Duration(minutes: 11, seconds: 38);
    _paymentTimer?.cancel(); // Hủy bất kỳ timer cũ nào đang chạy

    // Bắt đầu timer mới
    _paymentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds == 0) {
        timer.cancel();
        // Tự động pop khi hết giờ (giữ nguyên logic gốc của bạn)
        if (context.mounted) {
          context.pop();
        }
      } else {
        _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        notifyListeners(); // Cập nhật UI mỗi giây
      }
    });
  }

  /// Phải được gọi từ dispose() của EventPaymentScreen để dừng timer.
  void disposePaymentTimer() {
    _paymentTimer?.cancel();
    print("Payment timer disposed");
  }

  /// Cập nhật phương thức thanh toán được chọn
  void selectPaymentMethod(String method) {
    if (_selectedPaymentMethod != method) {
      _selectedPaymentMethod = method;
      notifyListeners();
    }
  }

  /// Xử lý logic thanh toán và trả về kết quả.
  Future<FlutterZaloPayStatus> handlePayment() async {
    if (_selectedPaymentMethod == 'zalopay') {
      return await _processZaloPayPayment();
    } else if (_selectedPaymentMethod == 'vnpay') {
      return await _processVNPayPayment();
    }
    return FlutterZaloPayStatus.failed;
  }

  Future<FlutterZaloPayStatus> _processZaloPayPayment() async {
    // Dùng token đã lưu để thanh toán
    final event = await FlutterZaloPaySdk.payOrder(zpToken: _paymentToken);
    return event;
  }

  Future<FlutterZaloPayStatus> _processVNPayPayment() async {
    // Logic placeholder
    // Trả về 'failed' để logic ở View có thể bắt và hiển thị thông báo "đang phát triển"
    return FlutterZaloPayStatus.failed;
  }

  @override
  void dispose() {
    _timer?.cancel(); // Dọn dẹp timer slideshow
    searchController.dispose(); // Dọn dẹp controller search
    super.dispose();
  }
}
