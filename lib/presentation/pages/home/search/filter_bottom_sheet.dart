import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.size20),
              topRight: Radius.circular(AppSizes.size20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildDivider(),
                const SizedBox(height: AppSpacing.space24),
                _buildSectionTitle(context.appLocaleLanguage.location),
                ...viewModel.filterLocations
                    .map((location) => _buildRadioListItem(location, viewModel))
                    .toList(),
                const SizedBox(height: AppSpacing.space12),
                _buildDivider(),
                const SizedBox(height: AppSpacing.space12),
                _buildPriceSection(viewModel,context),
                const SizedBox(height: AppSpacing.space12),
                _buildDivider(),
                const SizedBox(height: AppSpacing.space12),
                _buildSectionTitle(context.appLocaleLanguage.category),
                _buildCategoryChips(viewModel),
                const SizedBox(height: AppSpacing.space32),
                _buildFooterButtons(context, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: AppSpacing.space40),
        Text(
          context.appLocaleLanguage.filterButton,
          style: TextStyle(
            fontSize: AppSizes.size18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: AppColors.grey),
          onPressed: () => context.pop(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppSizes.size16,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildRadioListItem(String title, HomeViewModel viewModel) {
    final bool isSelected = viewModel.selectedLocation == title;
    return InkWell(
      onTap: () {
        viewModel.selectLocation(title);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
        child: Row(
          children: [
            Container(
              width: AppSizes.size20,
              height: AppSizes.size20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey,
                  width: AppSizes.size2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: AppSizes.size10,
                        height: AppSizes.size10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.space12),
            Text(title, style: TextStyle(fontSize: AppSizes.size16, color: AppColors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.colorFFDDDDE3, height: AppSpacing.space1);
  }

  Widget _buildPriceSection(HomeViewModel viewModel,BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(context.appLocaleLanguage.price),
        Row(
          children: [
            Text(
              context.appLocaleLanguage.free,
              style: TextStyle(fontSize: AppSizes.size16, color: AppColors.black),
            ),
            const SizedBox(width: AppSpacing.space8),
            Switch(
              value: viewModel.isFree,
              onChanged: (value) {
                viewModel.toggleFree(value);
              },
              activeColor: AppColors.lightGray,
              activeTrackColor: AppColors.textGreenOnOrderBook,
              inactiveThumbColor: AppColors.lightGray,
              inactiveTrackColor: AppColors.neutralGray,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChips(HomeViewModel viewModel) {
    return Wrap(
      spacing: AppSpacing.space8,
      runSpacing: AppSpacing.space4,
      // Sửa: Dùng 'fetchedCategories' (List<CategoryModel>)
      children: viewModel.fetchedCategories.map((category) {
        // Sửa: Lấy tên từ 'category.name'
        final bool isSelected = viewModel.selectedCategories.contains(
          category.name,
        );
        return FilterChip(
          label: Text(category.name),
          selected: isSelected,
          onSelected: (bool selected) {
            // Sửa: Lấy tên từ 'category.name'
            viewModel.toggleCategory(category.name);
          },
          selectedColor: AppColors.primary.withOpacity(0.4),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.black,
          ),
          backgroundColor: AppColors.white,
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooterButtons(BuildContext context, HomeViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: AppElevatedButton(
            text: context.appLocaleLanguage.resetButton,
            onPressed: () {
              viewModel.resetFilter();
            },
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
            onPressed: () {
              viewModel.applyFilterSheet();
              context.pop();
            },
            height: AppSizes.size45,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.size4),
            ),
            textColor: AppColors.white,
            color: AppColors.primary,
            fontSize: AppSizes.size15,
            borderColor: AppColors.transparent,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}
