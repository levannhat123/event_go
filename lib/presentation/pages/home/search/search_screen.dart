import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/core/widgets/text_field.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/pages/home/search/calendar_bottom_sheet.dart';
import 'package:event_go/presentation/pages/home/category_card.dart';
import 'package:event_go/presentation/pages/home/search/filter_bottom_sheet.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/event_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void dispose() {
    // Lấy viewModel từ getIt (vì nó là autoDispose: false)
    final viewModel = getIt<HomeViewModel>();

    // Gọi hàm reset tổng
    viewModel.resetAllFiltersAndSearch();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      autoDispose: false,
      padding: false,
      viewModelBuilder: () => getIt<HomeViewModel>(),
      builder: (context, viewModel, child) {
        final bool isSearchingText = viewModel.searchController.text.isNotEmpty;
        final bool isDisplayingResults = viewModel.isFilterActive;
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.searchTitle),
            centerTitle: true,
            backgroundColor: Color(0xFF596DC3),
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.space10),
            child: Column(
              // Layout chính là Column
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: viewModel.searchController,
                  onChanged: (query) {
                    viewModel.searchEvents(query);
                  },
                  onFieldSubmitted: (query) {
                    viewModel.addRecentSearch(query);
                  },
                  hintText: AppStrings.searchHint,
                  borderColor: AppColors.transparent,
                  fillColor: AppColors.transparent,
                  focusedBorderColor: AppColors.transparent,
                  enabledBorderColor: AppColors.transparent,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: isSearchingText
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.white),
                          onPressed: viewModel.clearSearch,
                        )
                      : null,
                  shadowColor: AppColors.transparent,
                  textColor: Colors.white,
                ),
                Divider(thickness: 1, color: AppColors.primary),
                const SizedBox(height: AppSpacing.space10),

                // --- CÁC NÚT LỌC ---
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        viewModel.initCalendar();
                        var result =
                            await showModalBottomSheet<Map<String, dynamic>?>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (sheetContext) {
                                return ChangeNotifierProvider.value(
                                  value: viewModel,
                                  child: const CalendarBottomSheet(),
                                );
                              },
                            );
                        viewModel.updateDateFilter(result);
                      },
                      child: Container(
                        height: AppSizes.size32,
                        decoration: BoxDecoration(
                          color: viewModel.isDateFilterActive
                              ? AppColors.green // Màu xanh khi active
                              : Color(0xFF515158),
                          borderRadius: BorderRadius.circular(AppSizes.size16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.white,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Center(
                                child: Text(
                                  viewModel.selectedDateText,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space10),
                    InkWell(
                      onTap: () {
                        viewModel.initFilter();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (sheetContext) {
                            return ChangeNotifierProvider.value(
                              value: viewModel,
                              child: FilterBottomSheet(),
                            );
                          },
                        );
                      },
                      child: Container(
                        height: AppSizes.size32,
                        decoration: BoxDecoration(
                          color: viewModel.isMainFilterActive
                              ? AppColors.green // Màu xanh khi active
                              : Color(0xFF515158),
                          borderRadius: BorderRadius.circular(AppSizes.size16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_alt_sharp,
                                color: AppColors.white,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Center(
                                child: Text(
                                  AppStrings.filterButton,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildAppliedFilters(viewModel),
                // --- NỘI DUNG THAY ĐỔI (KHÁM PHÁ / KẾT QUẢ) ---
                Expanded(
                  // Dùng Expanded để lấp đầy phần còn lại
                  child: isDisplayingResults
                      ? _buildSearchResults(viewModel) // Hiển thị kết quả
                      : _buildDiscoveryContent(viewModel), // Hiển thị khám phá
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widget cho nội dung khám phá (khi không tìm kiếm) ---
  Widget _buildDiscoveryContent(HomeViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.recentSearches.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space10),
            Text(
              AppStrings.recentSearches,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            ListView.builder(
              itemCount: viewModel.recentSearches.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = viewModel.recentSearches[index];
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.access_time, color: Colors.white70),
                  title: Text(item),
                  trailing: IconButton(
                    icon: Icon(Icons.clear, size: 18, color: Colors.white38),
                    onPressed: () {
                      viewModel.removeRecentSearch(item);
                    },
                  ),
                  onTap: () {
                    viewModel.searchController.text = item;
                    viewModel.searchEvents(item);
                    viewModel.addRecentSearch(item);
                  },
                );
              },
            ),
          ],
          const SizedBox(height: AppSpacing.space10),
          Text(
            AppStrings.trendingSearches,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          ListView.builder(
            itemCount: viewModel.trendingTopics.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = viewModel.trendingTopics[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.trending_up, color: Colors.green),
                title: Text(item),
                onTap: () {
                  viewModel.searchController.text = item;
                  viewModel.searchEvents(item);
                  viewModel.addRecentSearch(item);
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.space20),
          Text(
            AppStrings.exploreByCategory,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CategoryCard(
                  title: AppStrings.liveMusic,
                  imagePath: AppImage.music_category,
                  onTap: () {
                    print('Nhấn vào Nhạc sống');
                  },
                ),
                const SizedBox(width: AppSpacing.space10),
                CategoryCard(
                  title: AppStrings.theaterAndArts,
                  imagePath: AppImage.film_category,
                  onTap: () {
                    print('Nhấn vào Sân khấu');
                  },
                ),
                const SizedBox(width: AppSpacing.space10),
                CategoryCard(
                  title: AppStrings.sports,
                  imagePath: AppImage.sport_category,
                  onTap: () {
                    print('Nhấn vào Thể Thao');
                  },
                ),
                const SizedBox(width: AppSpacing.space10),
                CategoryCard(
                  title: AppStrings.other,
                  imagePath: AppImage.other_category,
                  onTap: () {
                    print('Nhấn vào Khác');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          Text(
            AppStrings.exploreByCity,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CategoryCard(
                  title: AppStrings.hanoi,
                  imagePath: AppImage.hn_location,
                  onTap: () {
                    print('Nhấn vào Hà Nội');
                  },
                ),
                const SizedBox(width: AppSpacing.space10),
                CategoryCard(
                  title: AppStrings.hoChiMinh,
                  imagePath: AppImage.hcm_location,
                  onTap: () {
                    print('Nhấn vào TP HCM');
                  },
                ),
                const SizedBox(width: AppSpacing.space10),
                CategoryCard(
                  title: AppStrings.dalat,
                  imagePath: AppImage.dalat_location,
                  onTap: () {
                    print('Nhấn vào Đà Lạt');
                  },
                ),
                const SizedBox(width: AppSpacing.space10),
                CategoryCard(
                  title: AppStrings.otherLocation,
                  imagePath: AppImage.other_location,
                  onTap: () {
                    print('Nhấn vào Vị trí khác');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          Text(
            AppStrings.suggestionsForYou,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: AppSpacing.space10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.space10,
              crossAxisSpacing: AppSpacing.space10,
              childAspectRatio: 0.8,
            ),
            itemCount: viewModel.events.length,
            itemBuilder: (context, index) {
              final event = viewModel.events[index];
              final date = event.startTime != null
                  ? FormatPrice.formatDate(event.startTime.toString())
                  : AppStrings.comingSoon;
              return EventCard(
                height: AppSizes.size100,
                width: AppSizes.size200,
                imageUrl: event.bannerURL ?? AppImage.banner_1,
                title: event.title,
                price: event.minTicketPrice.toString(),
                date: date,
                onTap: () {
                  viewModel.event = event;
                  context.push(RouterPath.event_detail, extra: event);
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.space20),
        ],
      ),
    );
  }

  Widget _buildSearchResults(HomeViewModel viewModel) {
    if (viewModel.searchResults.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noResultsFound,
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.space10), // Thêm padding cho lưới
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.space10,
        crossAxisSpacing: AppSpacing.space10,
        childAspectRatio: 0.8, // Tỷ lệ này bạn có thể điều chỉnh
      ),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final event = viewModel.searchResults[index];
        final date = event.startTime != null
            ? FormatPrice.formatDate(event.startTime.toString())
            : AppStrings.comingSoon;
        return EventCard(
          height: AppSizes.size100,
          width: AppSizes.size200,
          imageUrl: event.bannerURL ?? AppImage.banner_1,
          title: event.title,
          price: event.minTicketPrice.toString(),
          date: date,
          onTap: () {
            viewModel.event = event;
            context.push(RouterPath.event_detail, extra: event);
          },
        );
      },
    );
  }
  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      backgroundColor: AppColors.green, // Màu giống nút "Bộ lọc"
      labelStyle: const TextStyle(color: Colors.white, fontSize: 14),
      deleteIcon: const Icon(Icons.close, color: Colors.white, size: AppSizes.size18),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space0,
      ),
      shape: const StadiumBorder(),
    );
  }
  // [THÊM HÀM NÀY VÀO _SearchScreenState]
  Widget _buildAppliedFilters(HomeViewModel viewModel) {
    final List<Widget> chips = [];

    // 2. Chip Lọc Địa điểm
    if (viewModel.appliedLocation != 'Toàn quốc') {
      chips.add(
        _buildFilterChip(
          viewModel.appliedLocation,
              () => viewModel.removeLocationFilter(),
        ),
      );
    }

    // 3. Chip Lọc Giá
    if (viewModel.appliedIsFree) {
      chips.add(
        _buildFilterChip(
          AppStrings.free,
              () => viewModel.removePriceFilter(),
        ),
      );
    }

    // 4. Các Chip Lọc Thể loại
    for (String categoryName in viewModel.appliedCategories) {
      chips.add(
        _buildFilterChip(
          categoryName,
              () => viewModel.removeCategoryFilter(categoryName),
        ),
      );
    }

    if (chips.isEmpty) {
      return SizedBox.shrink(); // Không có filter thì không hiển thị gì
    }

    // Dùng Wrap để các chip tự động xuống dòng
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space10),
      child: Wrap(
        spacing: AppSpacing.space8, // Khoảng cách ngang giữa các chip
        runSpacing: AppSpacing.space4, // Khoảng cách dọc nếu xuống dòng
        children: chips,
      ),
    );
  }
}
