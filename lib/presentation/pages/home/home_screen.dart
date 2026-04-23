import 'dart:async';
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/injection/injection.dart'; // Import getIt
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/constants/app_text_styles.dart';
import 'package:event_go/core/constants/app_storage_key.dart';
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

  List<Map<String, String>> get locations => [
    {
      AppStorageKey.display: context.appLocaleLanguage.hanoi,
      AppStorageKey.filterValue: AppStrings.hanoi,
      AppStorageKey.image: AppImage.location_hn,
    },
    {
      AppStorageKey.display: context.appLocaleLanguage.hoChiMinh,
      AppStorageKey.filterValue: AppStrings.hoChiMinh,
      AppStorageKey.image: AppImage.location_hcm,
    },
    {
      AppStorageKey.display: context.appLocaleLanguage.dalat,
      AppStorageKey.filterValue: AppStrings.dalat,
      AppStorageKey.image: AppImage.location_dalat,
    },
    {
      AppStorageKey.display: context.appLocaleLanguage.otherLocation,
      AppStorageKey.filterValue: AppStrings.otherLocation,
      AppStorageKey.image: AppImage.location_other,
    },
  ];

  Map<String, String> getCategoryInfo(String dbKey) {
    if (dbKey == AppStrings.liveMusic) {
      return {
        AppStorageKey.display: context.appLocaleLanguage.liveMusic,
        AppStorageKey.image: AppImage.music_category,
      };
    } else if (dbKey == AppStrings.theaterAndArtsSimple) {
      return {
        AppStorageKey.display: context.appLocaleLanguage.theaterAndArtsSimple,
        AppStorageKey.image: AppImage.film_category,
      };
    } else if (dbKey == AppStrings.sportsCategory) {
      return {
        AppStorageKey.display: context.appLocaleLanguage.sports,
        AppStorageKey.image: AppImage.sport_category,
      };
    } else if (dbKey == AppStrings.other) {
      return {
        AppStorageKey.display: context.appLocaleLanguage.other,
        AppStorageKey.image: AppImage.other_category,
      };
    }

    return {
      AppStorageKey.display: dbKey,
      AppStorageKey.image: AppImage.other_category,
    };
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
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.size8.r),
                  child: Image.asset(AppImage.logo, height: AppSizes.size40),
                ),
                SizedBox(width: AppSpacing.space10),
                Text(context.appLocaleLanguage.appName),
              ],
            ),
            backgroundColor: AppColors.homePrimaryBlue,
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
                  recentEventsShow(viewModel),
                  SizedBox(height: AppSizes.size20),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.appLocaleLanguage.trendingEventsTitle,
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
                          context.appLocaleLanguage.recommendedForYouTitle,
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
                            itemCount: viewModel.upcomingAndActiveEvents.length,
                            itemBuilder: (context, index) {
                              final EventDetailModel event =
                                  viewModel.upcomingAndActiveEvents[index];
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
                          final events = entry.value
                              .where(
                                (e) =>
                                    e.status !=
                                    AppStorageKey.completed.toUpperCase(),
                              )
                              .toList();
                          if (events.isEmpty) return const SizedBox.shrink();
                          final categoryName = entry.key;
                          final categoryInfo = getCategoryInfo(categoryName);
                          final displayName =
                              categoryInfo[AppStorageKey.display]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    displayName,
                                    style: AppTextStyles.title2.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      viewModel.selectCategoryAndSearch(
                                        categoryName,
                                      );
                                      context.push(RouterPath.search);
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          context.appLocaleLanguage.seeMore,
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
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: events.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        : context.appLocaleLanguage.free,
                                    date: event.startTime.toString(),
                                    status: event.status,
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
                          context.appLocaleLanguage.chooseLocationTitle,
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.space20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: locations.map((location) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: AppSpacing.space10,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    viewModel.selectLocationAndSearch(
                                      location[AppStorageKey.filterValue]!,
                                    );
                                    context.push(RouterPath.search);
                                  },
                                  child: LocationCard(
                                    imageUrl: location[AppStorageKey.image]!,
                                    locationName:
                                        location[AppStorageKey.display]!,
                                  ),
                                ),
                              );
                            }).toList(),
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

  Widget recentEventsShow(HomeViewModel viewModel) {
    final allEvents =
        viewModel.events
            .where(
              (event) =>
                  event.startTime != null &&
                  event.status != AppStorageKey.completed.toUpperCase(),
            )
            .toList()
          ..sort((a, b) => a.startTime!.compareTo(b.startTime!));
    final recentEvents = allEvents.take(5).toList();
    if (recentEvents.isEmpty) {
      return Container(
        height: AppSizes.size300,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Container(
      height: AppSizes.size300,
      child: PageView.builder(
        controller: _pageController,
        itemCount: recentEvents.length,
        onPageChanged: (value) {
          viewModel.onPageChanged(value);
        },
        itemBuilder: (context, index) {
          final event = recentEvents[index];
          return GestureDetector(
            onTap: () {
              context.push(RouterPath.event_detail, extra: event);
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.size8.r),
                    child: Image.network(
                      event.bannerURL ?? AppImage.banner_1,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          AppImage.banner_1,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.size8.r),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.transparent,
                          AppColors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(recentEvents.length, (i) {
                      return Container(
                        height: AppSizes.size8,
                        margin: EdgeInsets.only(right: AppSpacing.space5),
                        width: viewModel.currentIndex == i
                            ? AppSizes.size20
                            : AppSizes.size8,
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
            ),
          );
        },
      ),
    );
  }
}
