import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_storage_key.dart';

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
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.size20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.appLocaleLanguage.selectTime,
                      style: TextStyle(
                        fontSize: AppSizes.size18,
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
              const SizedBox(height: AppSpacing.space16),
              Wrap(
                spacing: AppSpacing.space8,
                runSpacing: AppSpacing.space8,
                children: [
                  _buildQuickSelectButton(
                    context.appLocaleLanguage.allDays,
                    viewModel.selectedQuickButtonIndex == 0,
                    () => viewModel.selectQuickButton(0),
                  ),
                  _buildQuickSelectButton(
                    context.appLocaleLanguage.today,
                    viewModel.selectedQuickButtonIndex == 1,
                    () => viewModel.selectQuickButton(1),
                  ),
                  _buildQuickSelectButton(
                    context.appLocaleLanguage.tomorrow,
                    viewModel.selectedQuickButtonIndex == 2,
                    () => viewModel.selectQuickButton(2),
                  ),
                  _buildQuickSelectButton(
                    context.appLocaleLanguage.thisWeekend,
                    viewModel.selectedQuickButtonIndex == 3,
                    () => viewModel.selectQuickButton(3),
                  ),
                  _buildQuickSelectButton(
                    context.appLocaleLanguage.thisMonth,
                    viewModel.selectedQuickButtonIndex == 4,
                    () => viewModel.selectQuickButton(4),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => viewModel.previousMonth(),
                  ),
                  Text(
                    context.appLocaleLanguage.monthFormat(
                      viewModel.focusedDay.month.toString(), // Tham số {month}
                      viewModel.focusedDay.year.toString(),  // Tham số {year}
                    ),
                    style: const TextStyle(
                      fontSize: AppSizes.size16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => viewModel.nextMonth(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space8),
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
                        color: AppColors.black,
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
                      color: AppColors.transparent,
                      child: _buildDayCell(cellDate, isCurrentMonth, viewModel),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.space16),
              Row(
                children: [
                  Expanded(
                    child: AppElevatedButton(
                      text: context.appLocaleLanguage.resetButton,
                      onPressed: () => viewModel.resetCalendar(),
                      height: AppSizes.size45,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSizes.size4),
                      ),
                      textColor: AppColors.primary,
                      color: AppColors.transparent,
                      fontSize: AppSizes.size15,
                      borderColor: AppColors.primary,
                      splashColor: AppColors.transparent,
                      highlightColor: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: AppElevatedButton(
                      text: context.appLocaleLanguage.applyButton,
                      onPressed:
                          (viewModel.selectedDay != null ||
                              viewModel.rangeStart != null ||
                              viewModel.selectedQuickButtonIndex == 0)
                          ? () {
                              Navigator.pop(context, {
                                AppStorageKey.selectedDay: viewModel.selectedDay,
                                AppStorageKey.rangeStart: viewModel.rangeStart,
                                AppStorageKey.rangeEnd: viewModel.rangeEnd,
                                AppStorageKey.isAllDays:
                                    viewModel.selectedQuickButtonIndex == 0,
                              });
                            }
                          : null,
                      height: AppSizes.size45,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSizes.size4),
                      ),
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
                          : AppColors.colorFFDDDDE3,
                      fontSize: AppSizes.size15,
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.size8),
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
    BorderRadius borderRadius = BorderRadius.circular(AppSizes.size100);
    if (isToday && !isSelected) {
      border = Border.all(color: AppColors.primary, width: AppSizes.size1_5);
    }
    if (viewModel.selectedQuickButtonIndex == 3 ||
        viewModel.selectedQuickButtonIndex == 4) {
      if (isSelectedStart) {
        borderRadius = const BorderRadius.horizontal(
          left: Radius.circular(AppSizes.size100),
        );
      } else if (isSelectedEnd) {
        borderRadius = const BorderRadius.horizontal(
          right: Radius.circular(AppSizes.size100),
        );
      } else if (isSelectedMiddle) {
        borderRadius = BorderRadius.zero;
      }
    }

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
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
