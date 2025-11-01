import 'dart:async';
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/injection/injection.dart'; // Import getIt
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_text_styles.dart';
import 'package:event_go/core/widgets/event_card.dart';
import 'package:event_go/core/widgets/location_card.dart';
import 'package:event_go/core/widgets/trending_card.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      padding: false,
      autoDispose: false,
      viewModelBuilder: () => getIt<HomeViewModel>(),
      onModelReady: (viewModel) {
        viewModel.startAutoSlide(_pageController!);
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('EventGo'),
            backgroundColor: Color(0xFF596DC3),
            actions: [
              IconButton(
                onPressed: () {
                  context.push(RouterPath.search);
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  silde_Show(viewModel),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔥 Sự kiện xu hướng',
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                RankedEventCard(
                                  imageUrl: AppImage.banner_1,
                                  rank: 1,
                                ),
                                RankedEventCard(
                                  imageUrl: AppImage.banner_2,
                                  rank: 2,
                                ),
                                RankedEventCard(
                                  imageUrl: AppImage.banner_3,
                                  rank: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Dành cho bạn',
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              EventCard(
                                imageUrl: AppImage.banner_1,
                                title:
                                    "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                                price: 'Từ 570.000đ',
                                date: '13 tháng 12, 2025',
                                onTap: () {
                                  context.push(RouterPath.event_detail);
                                },
                              ),
                              SizedBox(width: 10),
                              EventCard(
                                imageUrl: AppImage.banner_2,
                                title:
                                    "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                                price: 'Từ 570.000đ',
                                date: '13 tháng 12, 2025',
                              ),
                              SizedBox(width: 10),
                              EventCard(
                                imageUrl: AppImage.banner_3,
                                title:
                                    "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                                price: 'Từ 570.000đ',
                                date: '13 tháng 12, 2025',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nhạc sống',
                              style: AppTextStyles.title2.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Xem thêm',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: AppColors.grey,
                                  weight: 700,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
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
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                            EventCard(
                              height: 100,
                              width: 200,
                              imageUrl: AppImage.banner_2,
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                            EventCard(
                              height: 100,
                              width: 200,
                              imageUrl: AppImage.banner_3,
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                            EventCard(
                              height: 100,
                              width: 200,
                              imageUrl: AppImage.banner_4,
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sân khấu & Nghệ thuật',
                              style: AppTextStyles.title2.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Xem thêm',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: AppColors.grey,
                                  weight: 700,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
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
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                            EventCard(
                              height: 100,
                              width: 200,
                              imageUrl: AppImage.banner_2,
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                            EventCard(
                              height: 100,
                              width: 200,
                              imageUrl: AppImage.banner_3,
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                            EventCard(
                              height: 100,
                              width: 200,
                              imageUrl: AppImage.banner_4,
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thể loại khác',
                              style: AppTextStyles.title2.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Xem thêm',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: AppColors.grey,
                                  weight: 700,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
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
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                            EventCard(
                              height: 100,
                              width: 200,
                              imageUrl: AppImage.banner_2,
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                            EventCard(
                              height: 100,
                              width: 200,
                              imageUrl: AppImage.banner_3,
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                            EventCard(
                              height: 100,
                              width: 200,
                              imageUrl: AppImage.banner_4,
                              title:
                                  "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                              price: 'Từ 570.000đ',
                              date: '13 tháng 12, 2025',
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Chọn địa điểm ',
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              LocationCard(
                                imageUrl: AppImage.location_hn,
                                locationName: 'Hà Nội',
                              ),
                              SizedBox(width: 10),
                              LocationCard(
                                imageUrl: AppImage.location_hcm,
                                locationName: 'Hồ Chí Minh',
                              ),
                              SizedBox(width: 10),
                              LocationCard(
                                imageUrl: AppImage.location_dalat,
                                locationName: 'Đà Lạt',
                              ),
                              SizedBox(width: 10),
                              LocationCard(
                                imageUrl: AppImage.location_other,
                                locationName: 'Vị trí khác',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget silde_Show(HomeViewModel viewModel) {
    return Container(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: viewModel.boadingData.length,
        onPageChanged: (value) {
          viewModel.onPageChanged(value);
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    viewModel.boadingData[index]['image']!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(viewModel.boadingData.length, (i) {
                    return Container(
                      height: 8.0,
                      margin: EdgeInsets.only(right: 5),
                      width: viewModel.currentIndex == i ? 20 : 8,
                      decoration: BoxDecoration(
                        color: viewModel.currentIndex == i
                            ? AppColors.primary
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
