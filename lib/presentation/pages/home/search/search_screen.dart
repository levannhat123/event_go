import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
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
            title: Text('Tìm Kiếm'),
            centerTitle: true,
            backgroundColor: Color(0xFF596DC3),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
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
                  hintText: 'Nhập từ khóa',
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
                SizedBox(height: 10),

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
                        height: 32,
                        decoration: BoxDecoration(
                          color: viewModel.isDateFilterActive
                              ? AppColors.green // Màu xanh khi active
                              : Color(0xFF515158),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.white,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Center(
                                child: Text(
                                  viewModel.selectedDateText,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
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
                    SizedBox(width: 10),
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
                        height: 32,
                        decoration: BoxDecoration(
                          color: viewModel.isMainFilterActive
                              ? AppColors.green // Màu xanh khi active
                              : Color(0xFF515158),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_alt_sharp,
                                color: AppColors.white,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Center(
                                child: Text(
                                  'Bộ lọc',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
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
            SizedBox(height: 10),
            Text(
              'Tìm kiếm gần đây',
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
          SizedBox(height: 10),
          Text(
            'Xu hướng tìm kiếm',
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
          SizedBox(height: 20),
          Text(
            'Khám phá theo thể loại',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CategoryCard(
                  title: 'Nhạc sống',
                  imagePath: AppImage.music_category,
                  onTap: () {
                    print('Nhấn vào Nhạc sống');
                  },
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: 'Sân khấu & Nghệ thuật',
                  imagePath: AppImage.film_category,
                  onTap: () {
                    print('Nhấn vào Sân khấu');
                  },
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: 'Thể Thao',
                  imagePath: AppImage.sport_category,
                  onTap: () {
                    print('Nhấn vào Thể Thao');
                  },
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: 'Khác',
                  imagePath: AppImage.other_category,
                  onTap: () {
                    print('Nhấn vào Khác');
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Khám phá theo thành phố',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CategoryCard(
                  title: 'Hà Nội',
                  imagePath: AppImage.hn_location,
                  onTap: () {
                    print('Nhấn vào Hà Nội');
                  },
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: 'TP Hồ Chí Minh',
                  imagePath: AppImage.hcm_location,
                  onTap: () {
                    print('Nhấn vào TP HCM');
                  },
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: 'Đà Lạt',
                  imagePath: AppImage.dalat_location,
                  onTap: () {
                    print('Nhấn vào Đà Lạt');
                  },
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: ' Vị trí khác',
                  imagePath: AppImage.other_location,
                  onTap: () {
                    print('Nhấn vào Vị trí khác');
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Gợi ý dành cho bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: viewModel.events.length,
            itemBuilder: (context, index) {
              final event = viewModel.events[index];
              final date = event.startTime != null
                  ? FormatPrice.formatDate(event.startTime.toString())
                  : 'Sắp diễn ra';
              return EventCard(
                height: 100,
                width: 200,
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
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchResults(HomeViewModel viewModel) {
    if (viewModel.searchResults.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy kết quả nào.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.only(top: 10), // Thêm padding cho lưới
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8, // Tỷ lệ này bạn có thể điều chỉnh
      ),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final event = viewModel.searchResults[index];
        final date = event.startTime != null
            ? FormatPrice.formatDate(event.startTime.toString())
            : 'Sắp diễn ra';
        return EventCard(
          height: 100,
          width: 200,
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
      labelStyle: TextStyle(color: Colors.white, fontSize: 14),
      deleteIcon: Icon(Icons.close, color: Colors.white, size: 18),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: StadiumBorder(),
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
          'Miễn phí',
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
      padding: const EdgeInsets.only(top: 10.0),
      child: Wrap(
        spacing: 8.0, // Khoảng cách ngang giữa các chip
        runSpacing: 4.0, // Khoảng cách dọc nếu xuống dòng
        children: chips,
      ),
    );
  }
}
