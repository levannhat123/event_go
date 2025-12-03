import 'dart:async';
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/injection/injection.dart'; // Import getIt
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/constants/app_text_styles.dart';
import 'package:event_go/core/widgets/event_card.dart';
import 'package:event_go/core/widgets/location_card.dart';
import 'package:event_go/core/widgets/trending_card.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';

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
            title: Text(AppStrings.appName),
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
              padding: EdgeInsets.only(bottom: AppSpacing.space30),
              child: Column(
                children: [
                  silde_Show(viewModel),
                  SizedBox(height: AppSizes.size20),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.trendingEventsTitle,
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppSizes.size20),
                        SizedBox(
                          height: AppSizes.size140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.hotEvents.length,
                            itemBuilder: (context, index) {
                              final EventDetailModel event =
                                  viewModel.hotEvents[index];
                              final String imageUrl =
                                  event.bannerURL ?? AppImage.banner_2;
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: AppSpacing.space10,
                                ),
                                child: RankedEventCard(
                                  imageUrl: imageUrl,
                                  rank: index + 1,
                                  onTap: () {
                                    context.push(
                                      RouterPath.event_detail,
                                      extra: event,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: AppSpacing.space20),
                        Text(
                          AppStrings.recommendedForYouTitle,
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.space20),
                        SizedBox(
                          height: AppSizes.size300,
                          child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                SizedBox(width: AppSizes.size10),
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.events.length,
                            itemBuilder: (context, index) {
                              final EventDetailModel event =
                                  viewModel.events[index];
                              final String imageUrl =
                                  event.bannerURL ?? AppImage.banner_2;
                              return EventCard(
                                imageUrl: imageUrl,
                                title: event.title,
                                price: event.minTicketPrice.toString(),
                                date: event.startTime.toString(),
                                onTap: () {
                                  context.push(
                                    RouterPath.event_detail,
                                    extra: event,
                                  );
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    categoryName,
                                    style: AppTextStyles.title2.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        Text(
                                          AppStrings.seeMore,
                                          style: TextStyle(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                        SizedBox(width: AppSpacing.space4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: AppSizes.size14,
                                          color: AppColors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.space20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: events.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: 0.8,
                                    ),
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return EventCard(
                                    height: AppSizes.size100,
                                    width: AppSizes.size200,
                                    imageUrl:
                                        event.bannerURL ?? AppImage.banner_1,
                                    title: event.title,
                                    price: event.minTicketPrice != null
                                        ? event.minTicketPrice.toString()
                                        : AppStrings.free,
                                    date: event.startTime.toString(),
                                    onTap: () {
                                      context.push(
                                        RouterPath.event_detail,
                                        extra: event,
                                      );
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: AppSpacing.space30),
                            ],
                          );
                        }).toList(),
                        SizedBox(height: AppSpacing.space20),
                        Text(
                          AppStrings.chooseLocationTitle,
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.space20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              LocationCard(
                                imageUrl: AppImage.location_hn,
                                locationName: AppStrings.hanoi,
                              ),
                              SizedBox(width: AppSpacing.space10),
                              LocationCard(
                                imageUrl: AppImage.location_hcm,
                                locationName: AppStrings.hoChiMinh,
                              ),
                              SizedBox(width: AppSpacing.space10),
                              LocationCard(
                                imageUrl: AppImage.location_dalat,
                                locationName: AppStrings.dalat,
                              ),
                              SizedBox(width: AppSpacing.space10),
                              LocationCard(
                                imageUrl: AppImage.location_other,
                                locationName: AppStrings.otherLocation,
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
      height: AppSizes.size400,
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
                  borderRadius: BorderRadius.circular(AppSizes.size8.r),
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
                      height: AppSizes.size8,
                      margin: EdgeInsets.only(right: AppSpacing.space5),
                      width: viewModel.currentIndex == i ? AppSizes.size20 : AppSizes.size8,
                      decoration: BoxDecoration(
                        color: viewModel.currentIndex == i
                            ? AppColors.primary
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(AppSizes.size4.r),
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
