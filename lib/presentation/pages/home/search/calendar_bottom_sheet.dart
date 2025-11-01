import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';

class CalendarBottomSheet extends StatelessWidget {
  const CalendarBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final List<String> weekdays = [
          'T2',
          'T3',
          'T4',
          'T5',
          'T6',
          'T7',
          'CN',
        ];
        final List<int> calendarDays = viewModel.generateCalendarDays(
          viewModel.focusedDay.year,
          viewModel.focusedDay.month,
        );
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
                  const Expanded(
                    child: Text(
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
                  _buildQuickSelectButton(
                    'Tất cả các ngày',
                    viewModel.selectedQuickButtonIndex == 0,
                    () => viewModel.selectQuickButton(0),
                  ),
                  _buildQuickSelectButton(
                    'Hôm nay',
                    viewModel.selectedQuickButtonIndex == 1,
                    () => viewModel.selectQuickButton(1),
                  ),
                  _buildQuickSelectButton(
                    'Ngày mai',
                    viewModel.selectedQuickButtonIndex == 2,
                    () => viewModel.selectQuickButton(2),
                  ),
                  _buildQuickSelectButton(
                    'Cuối tuần này',
                    viewModel.selectedQuickButtonIndex == 3,
                    () => viewModel.selectQuickButton(3),
                  ),
                  _buildQuickSelectButton(
                    'Tháng này',
                    viewModel.selectedQuickButtonIndex == 4,
                    () => viewModel.selectQuickButton(4),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => viewModel.previousMonth(),
                  ),
                  Text(
                    'Tháng ${viewModel.focusedDay.month}, ${viewModel.focusedDay.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => viewModel.nextMonth(),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                  final DateTime firstDayOfMonth = DateTime(
                    viewModel.focusedDay.year,
                    viewModel.focusedDay.month,
                    1,
                  );
                  final int firstDayWeekday = firstDayOfMonth.weekday;
                  final int daysInCurrentMonth = DateTime(
                    viewModel.focusedDay.year,
                    viewModel.focusedDay.month + 1,
                    0,
                  ).day;

                  bool isCurrentMonth = true;
                  if (index < firstDayWeekday - 1) {
                    isCurrentMonth = false;
                  } else if (index >=
                      (firstDayWeekday - 1) + daysInCurrentMonth) {
                    isCurrentMonth = false;
                  }

                  DateTime cellDate;
                  if (isCurrentMonth) {
                    cellDate = DateTime(
                      viewModel.focusedDay.year,
                      viewModel.focusedDay.month,
                      day,
                    );
                  } else if (index < firstDayWeekday - 1) {
                    cellDate = DateTime(
                      viewModel.focusedDay.year,
                      viewModel.focusedDay.month - 1,
                      day,
                    );
                  } else {
                    cellDate = DateTime(
                      viewModel.focusedDay.year,
                      viewModel.focusedDay.month + 1,
                      day,
                    );
                  }

                  return GestureDetector(
                    onTap: () => viewModel.onDaySelected(
                      cellDate,
                      isCurrentMonth,
                    ), // Gọi VM
                    child: Container(
                      color: Colors.transparent,
                      child: _buildDayCell(cellDate, isCurrentMonth, viewModel),
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
                      onPressed: () => viewModel.resetCalendar(),
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
                      onPressed:
                          (viewModel.selectedDay != null ||
                              viewModel.rangeStart != null ||
                              viewModel.selectedQuickButtonIndex == 0)
                          ? () {
                              Navigator.pop(context, {
                                'selectedDay': viewModel.selectedDay,
                                'rangeStart': viewModel.rangeStart,
                                'rangeEnd': viewModel.rangeEnd,
                                'isAllDays':
                                    viewModel.selectedQuickButtonIndex == 0,
                              });
                            }
                          : null,
                      height: 45,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      textColor:
                          (viewModel.selectedDay != null ||
                              viewModel.rangeStart != null ||
                              viewModel.selectedQuickButtonIndex == 0)
                          ? AppColors.white
                          : AppColors.grey,
                      color:
                          (viewModel.selectedDay != null ||
                              viewModel.rangeStart != null ||
                              viewModel.selectedQuickButtonIndex == 0)
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
      },
    );
  }

  Widget _buildQuickSelectButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withOpacity(0.3),
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

  Widget _buildDayCell(
    DateTime cellDate,
    bool isCurrentMonth,
    HomeViewModel viewModel,
  ) {
    final int day = cellDate.day;
    final DateTime now = DateTime.now();
    final bool isToday =
        isCurrentMonth &&
        day == now.day &&
        viewModel.focusedDay.month == now.month &&
        viewModel.focusedDay.year == now.year;

    bool isSelectedSingle = false;
    bool isSelectedStart = false;
    bool isSelectedMiddle = false;
    bool isSelectedEnd = false;

    if (viewModel.selectedQuickButtonIndex == 3 ||
        viewModel.selectedQuickButtonIndex == 4) {
      if (viewModel.rangeStart != null && viewModel.rangeEnd != null) {
        final cellDayOnly = DateTime(
          cellDate.year,
          cellDate.month,
          cellDate.day,
        );
        final startDayOnly = DateTime(
          viewModel.rangeStart!.year,
          viewModel.rangeStart!.month,
          viewModel.rangeStart!.day,
        );
        final endDayOnly = DateTime(
          viewModel.rangeEnd!.year,
          viewModel.rangeEnd!.month,
          viewModel.rangeEnd!.day,
        );

        isSelectedStart = cellDayOnly.isAtSameMomentAs(startDayOnly);
        isSelectedEnd = cellDayOnly.isAtSameMomentAs(endDayOnly);
        isSelectedMiddle =
            cellDayOnly.isAfter(startDayOnly) &&
            cellDayOnly.isBefore(endDayOnly);
      }
    } else if (viewModel.selectedDay != null) {
      isSelectedSingle =
          isCurrentMonth &&
          viewModel.selectedDay!.year == cellDate.year &&
          viewModel.selectedDay!.month == cellDate.month &&
          viewModel.selectedDay!.day == cellDate.day;
    }

    final bool isSelected =
        isSelectedSingle ||
        isSelectedStart ||
        isSelectedMiddle ||
        isSelectedEnd;
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
    if (viewModel.selectedQuickButtonIndex == 3 ||
        viewModel.selectedQuickButtonIndex == 4) {
      if (isSelectedStart) {
        borderRadius = const BorderRadius.horizontal(
          left: Radius.circular(100),
        );
      } else if (isSelectedEnd) {
        borderRadius = const BorderRadius.horizontal(
          right: Radius.circular(100),
        );
      } else if (isSelectedMiddle) {
        borderRadius = BorderRadius.zero;
      }
    }

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: border,
      ),
      child: Text(
        day.toString(),
        style: TextStyle(color: textColor, fontWeight: fontWeight),
      ),
    );
  }
}
