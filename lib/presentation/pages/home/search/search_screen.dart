import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/widgets/text_field.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/pages/home/search/calendar_bottom_sheet.dart';
import 'package:event_go/presentation/pages/home/category_card.dart';
import 'package:event_go/presentation/pages/home/search/filter_bottom_sheet.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/event_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    // Bọc UI bằng BaseView
    return BaseView<HomeViewModel>(
      autoDispose: false,
      padding: false,
      viewModelBuilder: () => getIt<HomeViewModel>(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Tìm Kiếm'),
            centerTitle: true,
            backgroundColor: Color(0xFF596DC3),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: viewModel.searchController,
                    hintText: 'Nhập từ khóa',
                    borderColor: AppColors.transparent,
                    fillColor: AppColors.transparent,
                    focusedBorderColor: AppColors.transparent,
                    enabledBorderColor: AppColors.transparent,
                    prefixIcon: const Icon(Icons.search),
                    shadowColor: AppColors.transparent,
                    textColor: Colors.white,
                  ),
                  Divider(thickness: 1, color: AppColors.primary),
                  SizedBox(height: 10),
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
                            color: Color(0xFF515158),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
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
                            color: Color(0xFF515158),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
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
                        onTap: () => print('Bạn đã chọn: $item'),
                      );
                    },
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
                        leading: const Icon(
                          Icons.trending_up,
                          color: Colors.green,
                        ),
                        title: Text(item),
                        onTap: () => print('Bạn đã chọn: $item'),
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
                            print('Nhấn vào Nhạc sống');
                          },
                        ),
                        SizedBox(width: 10),
                        CategoryCard(
                          title: 'TP Hồ Chí Minh',
                          imagePath: AppImage.hcm_location,
                          onTap: () {
                            print('Nhấn vào Sân khấu');
                          },
                        ),
                        SizedBox(width: 10),
                        CategoryCard(
                          title: 'Đà Lạt',
                          imagePath: AppImage.dalat_location,
                          onTap: () {
                            print('Nhấn vào Thể Thao');
                          },
                        ),
                        SizedBox(width: 10),
                        CategoryCard(
                          title: ' Vị trí khác',
                          imagePath: AppImage.other_location,
                          onTap: () {
                            print('Nhấn vào Khác');
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
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8,
                    children: [
                      EventCard(
                        height: 100,
                        width: 200,
                        imageUrl: AppImage.banner_1,
                        title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                        price: 'Từ 570.000đ',
                        date: '13 tháng 12, 2025',
                      ),
                      EventCard(
                        height: 100,
                        width: 200,
                        imageUrl: AppImage.banner_2,
                        title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                        price: 'Từ 570.000đ',
                        date: '13 tháng 12, 2025',
                      ),
                      EventCard(
                        height: 100,
                        width: 200,
                        imageUrl: AppImage.banner_3,
                        title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                        price: 'Từ 570.000đ',
                        date: '13 tháng 12, 2025',
                      ),
                      EventCard(
                        height: 100,
                        width: 200,
                        imageUrl: AppImage.banner_4,
                        title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                        price: 'Từ 570.000đ',
                        date: '13 tháng 12, 2025',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
