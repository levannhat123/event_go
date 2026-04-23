import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:event_go/core/base/base_view_model.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/data/models/category/category_model.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/domain/usecase/event/watch_all_events_usecase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends BaseViewModel {
  final WatchAllEventsUsecase watchAllEventsUsecase;
  HomeViewModel(this.watchAllEventsUsecase) {
    loadRecentSearches();
    fetchCategories();
  }
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

  List<EventDetailModel> _events = [];
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

  FirebaseFirestore get _db => FirebaseFirestore.instance;

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
    _subscription?.cancel();
    super.dispose();
  }
}