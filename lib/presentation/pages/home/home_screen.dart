import 'dart:async';
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
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
        viewModel.watchAll();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
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
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.hotEvents.length,
                            itemBuilder: (context, index) {
                              final EventDetailModel event = viewModel.hotEvents[index];
                              final String imageUrl = event.bannerURL ?? AppImage.banner_2;
                              return Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: RankedEventCard(
                                  imageUrl: imageUrl,
                                  rank: index + 1,
                                  onTap: () {
                                    context.push(RouterPath.event_detail,extra: event);
                                  },
                                ),
                              );
                            },
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
                        SizedBox(
                          height: 300,
                          child: ListView.separated(
                            separatorBuilder: (context, index) => SizedBox(width: 10),
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.events.length,
                            itemBuilder: (context, index) {
                              final EventDetailModel event = viewModel.events[index];
                              final String imageUrl = event.bannerURL ?? AppImage.banner_2;
                              return EventCard(
                                imageUrl: imageUrl,
                                title:event.title,
                                price: event.minTicketPrice.toString(),
                                date: event.startTime.toString(),
                                onTap: () {
                                  context.push(RouterPath.event_detail,extra: event);
                                },
                              );
                            },
                          ),
                        ),
                        ...viewModel.eventsByCategory.entries.map((entry) {
                          final categoryName = entry.key;
                          final events = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    categoryName,
                                    style: AppTextStyles.title2.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {

                                    },
                                    child: Row(
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: events.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.8,
                                ),
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return EventCard(
                                    height: 100,
                                    width: 200,
                                    imageUrl: event.bannerURL ?? AppImage.banner_1,
                                    title: event.title,
                                    price: event.minTicketPrice != null
                                        ? event.minTicketPrice.toString()
                                        : 'Miễn phí',
                                    date: event.startTime.toString(),
                                    onTap: () {
                                      context.push(RouterPath.event_detail,extra: event);
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: 30),
                            ],
                          );
                        }).toList(),
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
