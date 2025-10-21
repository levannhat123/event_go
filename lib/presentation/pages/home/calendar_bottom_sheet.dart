import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:flutter/material.dart';

class CalendarBottomSheet extends StatefulWidget {
  const CalendarBottomSheet({super.key});

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

// --- BẮT ĐẦU THAY THẾ TỪ ĐÂY ---

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedQuickButtonIndex;

  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _rangeStart = null;
    _rangeEnd = null;
    _selectedQuickButtonIndex = 0;
  }

  Widget _buildQuickSelectButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime cellDate, bool isCurrentMonth) {
    final int day = cellDate.day;
    final DateTime now = DateTime.now();
    final bool isToday =
        isCurrentMonth &&
        day == now.day &&
        _focusedDay.month == now.month &&
        _focusedDay.year == now.year;
    bool isSelectedSingle = false;
    bool isSelectedStart = false;
    bool isSelectedMiddle = false;
    bool isSelectedEnd = false;
    if (_selectedQuickButtonIndex == 3 || _selectedQuickButtonIndex == 4) {
      if (_rangeStart != null && _rangeEnd != null) {
        final cellDayOnly = DateTime(cellDate.year, cellDate.month, cellDate.day);
        final startDayOnly = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
        final endDayOnly = DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day);

        isSelectedStart = cellDayOnly.isAtSameMomentAs(startDayOnly);
        isSelectedEnd = cellDayOnly.isAtSameMomentAs(endDayOnly);
        isSelectedMiddle = cellDayOnly.isAfter(startDayOnly) && cellDayOnly.isBefore(endDayOnly);
      }
    } else if (_selectedDay != null) {
      isSelectedSingle =
          isCurrentMonth &&
          _selectedDay!.year == cellDate.year &&
          _selectedDay!.month == cellDate.month &&
          _selectedDay!.day == cellDate.day;
    }
    final bool isSelected =
        isSelectedSingle || isSelectedStart || isSelectedMiddle || isSelectedEnd;
    Color textColor = AppColors.background;
    Color backgroundColor = AppColors.white;
    FontWeight fontWeight = FontWeight.normal;

    if (!isCurrentMonth) {
      textColor = AppColors.grey.withOpacity(0.6);
    }

    if (isSelectedSingle || isSelectedStart || isSelectedEnd) {
      backgroundColor = AppColors.primary;
      textColor = AppColors.white;
      fontWeight = FontWeight.bold;
    } else if (isSelectedMiddle) {
      backgroundColor = AppColors.primary.withOpacity(0.3);
      textColor = AppColors.primary;
      fontWeight = FontWeight.bold;
    } else if (isToday) {
      textColor = AppColors.primary;
      fontWeight = FontWeight.bold;
    }

    Border? border;
    BorderRadius borderRadius = BorderRadius.circular(100);
    if (isToday && !isSelected) {
      border = Border.all(color: AppColors.primary, width: 1.5);
    }
    if (_selectedQuickButtonIndex == 3 || _selectedQuickButtonIndex == 4) {
      if (isSelectedStart) {
        borderRadius = const BorderRadius.horizontal(left: Radius.circular(100));
      } else if (isSelectedEnd) {
        borderRadius = const BorderRadius.horizontal(right: Radius.circular(100));
      } else if (isSelectedMiddle) {
        borderRadius = BorderRadius.zero;
      }
    }

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: borderRadius, border: border),
      child: Text(
        day.toString(),
        style: TextStyle(color: textColor, fontWeight: fontWeight),
      ),
    );
  }

  List<int> _getDaysInMonth(int year, int month) {
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final DateTime lastDayOfMonth = DateTime(year, month + 1, 0);
    return List.generate(lastDayOfMonth.day, (index) => index + 1);
  }

  List<int> _generateCalendarDays(int year, int month) {
    final List<int> days = [];
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int weekdayOfFirstDay = firstDayOfMonth.weekday;

    final int offset = weekdayOfFirstDay - 1;
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

  @override
  Widget build(BuildContext context) {
    final List<String> weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final List<int> calendarDays = _generateCalendarDays(_focusedDay.year, _focusedDay.month);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const Text(
                  'Chọn thời gian',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildQuickSelectButton('Tất cả các ngày', _selectedQuickButtonIndex == 0, () {
                setState(() {
                  _selectedDay = null;
                  _rangeStart = null;
                  _rangeEnd = null;
                  _selectedQuickButtonIndex = 0;
                });
              }),
              _buildQuickSelectButton('Hôm nay', _selectedQuickButtonIndex == 1, () {
                final now = DateTime.now();
                setState(() {
                  _focusedDay = DateTime(now.year, now.month, 1);
                  _selectedDay = now;
                  _rangeStart = null;
                  _rangeEnd = null;
                  _selectedQuickButtonIndex = 1;
                });
              }),
              _buildQuickSelectButton('Ngày mai', _selectedQuickButtonIndex == 2, () {
                final tomorrow = DateTime.now().add(const Duration(days: 1));
                setState(() {
                  _focusedDay = DateTime(tomorrow.year, tomorrow.month, 1);
                  _selectedDay = tomorrow;
                  _rangeStart = null;
                  _rangeEnd = null;
                  _selectedQuickButtonIndex = 2;
                });
              }),
              _buildQuickSelectButton('Cuối tuần này', _selectedQuickButtonIndex == 3, () {
                final now = DateTime.now();
                final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                final friday = startOfWeek.add(const Duration(days: 4));
                final sunday = startOfWeek.add(const Duration(days: 6));

                setState(() {
                  _focusedDay = DateTime(friday.year, friday.month, 1);
                  _selectedDay = null;
                  _rangeStart = friday;
                  _rangeEnd = sunday;
                  _selectedQuickButtonIndex = 3;
                });
              }),
              _buildQuickSelectButton('Tháng này', _selectedQuickButtonIndex == 4, () {
                final now = DateTime.now();
                final startOfRange = DateTime(now.year, now.month, now.day);
                final endOfMonth = DateTime(now.year, now.month + 1, 0);
                setState(() {
                  _focusedDay = DateTime(now.year, now.month, 1);
                  _selectedDay = null; // Xóa _selectedDay
                  _rangeStart = startOfRange; // Dùng RANGE
                  _rangeEnd = endOfMonth;
                  _selectedQuickButtonIndex = 4;
                });
              }),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                    _selectedDay = null;
                    _rangeStart = null;
                    _rangeEnd = null;
                    _selectedQuickButtonIndex = null;
                  });
                },
              ),
              Text(
                'Tháng ${_focusedDay.month}, ${_focusedDay.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                    _selectedDay = null;
                    _rangeStart = null;
                    _rangeEnd = null;
                    _selectedQuickButtonIndex = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: weekdays.length,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  weekdays[index],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              );
            },
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: calendarDays.length,
            itemBuilder: (context, index) {
              final int day = calendarDays[index];
              final DateTime firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
              final int firstDayWeekday = firstDayOfMonth.weekday;
              final int daysInCurrentMonth = DateTime(
                _focusedDay.year,
                _focusedDay.month + 1,
                0,
              ).day;
              bool isCurrentMonth = true;
              if (index < firstDayWeekday - 1) {
                isCurrentMonth = false;
              } else if (index >= (firstDayWeekday - 1) + daysInCurrentMonth) {
                isCurrentMonth = false;
              }
              DateTime cellDate;
              if (isCurrentMonth) {
                cellDate = DateTime(_focusedDay.year, _focusedDay.month, day);
              } else if (index < firstDayWeekday - 1) {
                cellDate = DateTime(_focusedDay.year, _focusedDay.month - 1, day);
              } else {
                cellDate = DateTime(_focusedDay.year, _focusedDay.month + 1, day);
              }
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (!isCurrentMonth) {
                      _focusedDay = DateTime(cellDate.year, cellDate.month, 1);
                    }
                    _selectedDay = cellDate;
                    _rangeStart = null;
                    _rangeEnd = null;
                    _selectedQuickButtonIndex = null;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  child: _buildDayCell(cellDate, isCurrentMonth),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppElevatedButton(
                  text: 'Thiết lập lại',
                  onPressed: () {
                    setState(() {
                      _selectedDay = null;
                      _rangeStart = null;
                      _rangeEnd = null;
                      _focusedDay = DateTime.now();
                      _selectedQuickButtonIndex = 0;
                    });
                  },
                  height: 45,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  textColor: AppColors.primary,
                  color: AppColors.transparent,
                  fontSize: 15.0,
                  borderColor: AppColors.primary,
                  splashColor: AppColors.transparent,
                  highlightColor: AppColors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppElevatedButton(
                  text: 'Áp dụng',
                  onPressed: (_selectedDay != null || _rangeStart != null)
                      ? () {
                          Navigator.pop(context, {
                            'selectedDay': _selectedDay,
                            'rangeStart': _rangeStart,
                            'rangeEnd': _rangeEnd,
                            'isAllDays': _selectedQuickButtonIndex == 0,
                          });
                        }
                      : null,
                  height: 45,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  textColor: (_selectedDay != null || _rangeStart != null)
                      ? AppColors.white
                      : AppColors.grey,
                  color: (_selectedDay != null || _rangeStart != null)
                      ? AppColors.primary
                      : Color(0xFFDDDDE3),
                  fontSize: 15.0,
                  borderColor: AppColors.transparent,
                  splashColor: AppColors.transparent,
                  highlightColor: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
