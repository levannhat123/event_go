import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/constants/app_storage_key.dart';
import 'package:event_go/core/utils/extension.dart';
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
    final viewModel = getIt<HomeViewModel>();
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
            title: Text(context.appLocaleLanguage.searchTitle),
            centerTitle: true,
            backgroundColor: AppColors.homePrimaryBlue,
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.space10),
            child: Column(
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
                  hintText: context.appLocaleLanguage.searchHint,
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
                  textColor: AppColors.white,
                ),
                Divider(thickness: 1, color: AppColors.primary),
                const SizedBox(height: AppSpacing.space10),

                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        viewModel.initCalendar();
                        var result =
                            await showModalBottomSheet<Map<String, dynamic>?>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppColors.transparent,
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
                              ? AppColors.green
                              : AppColors.colorFF515158,
                          borderRadius: BorderRadius.circular(AppSizes.size16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.white,
                                size: AppSizes.size20,
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Center(
                                child: Text(
                                  viewModel.selectedDateText,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: AppSizes.size14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.white,
                                size: AppSizes.size20,
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
                          backgroundColor: AppColors.transparent,
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
                              ? AppColors.green
                              : AppColors.colorFF515158,
                          borderRadius: BorderRadius.circular(AppSizes.size16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_alt_sharp,
                                color: AppColors.white,
                                size: AppSizes.size20,
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Center(
                                child: Text(
                                  context.appLocaleLanguage.filterButton,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: AppSizes.size14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.white,
                                size: AppSizes.size20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildAppliedFilters(viewModel),
                Expanded(
                  child: isDisplayingResults
                      ? _buildSearchResults(viewModel)
                      : _buildDiscoveryContent(viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscoveryContent(HomeViewModel viewModel) {
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

    final List<Map<String, String>> locations = [
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
    final List<Map<String, String>> cities = [
      {
        AppStorageKey.name: AppStrings.hanoi,
        AppStorageKey.image: AppImage.hn_location,
      },
      {
        AppStorageKey.name: AppStrings.hoChiMinh,
        AppStorageKey.image: AppImage.hcm_location,
      },
      {
        AppStorageKey.name: AppStrings.dalat,
        AppStorageKey.image: AppImage.dalat_location,
      },
      {
        AppStorageKey.name: AppStrings.otherLocation,
        AppStorageKey.image: AppImage.other_location,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.recentSearches.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space10),
            Text(
              context.appLocaleLanguage.recentSearches,
              style: TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.size18,
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
                  leading: Icon(Icons.access_time, color: AppColors.white70),
                  title: Text(item),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: AppSizes.size18,
                      color: Colors.white38,
                    ),
                    onPressed: () => viewModel.removeRecentSearch(item),
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
            context.appLocaleLanguage.trendingSearches,
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size18,
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
                leading: const Icon(Icons.trending_up, color: AppColors.green),
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
            context.appLocaleLanguage.exploreByCategory,
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.eventsByCategory.keys.map((dbKey) {
                final info = getCategoryInfo(dbKey);
                final displayName = info[AppStorageKey.display]!;
                final imagePath = info[AppStorageKey.image]!;

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.space10),
                  child: CategoryCard(
                    title: displayName,
                    imagePath: imagePath,
                    onTap: () {
                      viewModel.selectCategoryAndSearch(dbKey);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.space10),
          Text(
            context.appLocaleLanguage.exploreByCity,
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: locations.map((city) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.space10),
                  child: CategoryCard(
                    title: city[AppStorageKey.display]!,
                    imagePath: city[AppStorageKey.image]!,
                    onTap: () {
                      viewModel.selectLocationAndSearch(
                        city[AppStorageKey.filterValue]!,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.space10),
          Text(
            context.appLocaleLanguage.suggestionsForYou,
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size24,
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
                  : context.appLocaleLanguage.comingSoon;
              return EventCard(
                height: AppSizes.size100,
                width: AppSizes.size200,
                imageUrl: event.bannerURL ?? AppImage.banner_1,
                title: event.title,
                price: event.minTicketPrice.toString(),
                date: date,
                status: event.status,
                onTap: () {
                  // viewModel.event = event;
                  // context.push(RouterPath.event_detail, extra: event);
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
          context.appLocaleLanguage.noResultsFound,
          style: TextStyle(color: AppColors.white70),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.space10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.space10,
        crossAxisSpacing: AppSpacing.space10,
        childAspectRatio: 0.8,
      ),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final event = viewModel.searchResults[index];
        final date = event.startTime != null
            ? FormatPrice.formatDate(event.startTime.toString())
            : context.appLocaleLanguage.comingSoon;
        return EventCard(
          height: AppSizes.size100,
          width: AppSizes.size200,
          imageUrl: event.bannerURL ?? AppImage.banner_1,
          title: event.title,
          price: event.minTicketPrice.toString(),
          date: date,
          status: event.status,
          onTap: () {
            // viewModel.event = event;
            // context.push(RouterPath.event_detail, extra: event);
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      backgroundColor: AppColors.green,
      labelStyle: const TextStyle(color: AppColors.white, fontSize: AppSizes.size14),
      deleteIcon: const Icon(
        Icons.close,
        color: AppColors.white,
        size: AppSizes.size18,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space0,
      ),
      shape: const StadiumBorder(),
    );
  }

  Widget _buildAppliedFilters(HomeViewModel viewModel) {
    final List<Widget> chips = [];
    if (viewModel.appliedLocation != AppStrings.nationwide) {
      chips.add(
        _buildFilterChip(
          viewModel.appliedLocation,
          () => viewModel.removeLocationFilter(),
        ),
      );
    }
    if (viewModel.appliedIsFree) {
      chips.add(
        _buildFilterChip(AppStrings.free, () => viewModel.removePriceFilter()),
      );
    }
    for (String categoryName in viewModel.appliedCategories) {
      chips.add(
        _buildFilterChip(
          categoryName,
          () => viewModel.removeCategoryFilter(categoryName),
        ),
      );
    }

    if (chips.isEmpty) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space10),
      child: Wrap(
        spacing: AppSpacing.space8,
        runSpacing: AppSpacing.space4,
        children: chips,
      ),
    );
  }
}
