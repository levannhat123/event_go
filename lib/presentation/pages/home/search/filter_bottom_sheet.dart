import 'package:event_go/core/constants/app_colors.dart';
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
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildDivider(),
                SizedBox(height: 24),
                _buildSectionTitle('Vị trí'),
                ...viewModel.filterLocations
                    .map((location) => _buildRadioListItem(location, viewModel))
                    .toList(),
                SizedBox(height: 12),
                _buildDivider(),
                SizedBox(height: 12),
                _buildPriceSection(viewModel),
                SizedBox(height: 12),
                _buildDivider(),
                SizedBox(height: 12),
                _buildSectionTitle('Thể loại'),
                _buildCategoryChips(viewModel),
                SizedBox(height: 32),
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
        SizedBox(width: 40),
        Text(
          'Bộ lọc',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
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
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Color(0xFFDDDDE3), height: 1);
  }

  Widget _buildPriceSection(HomeViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Giá tiền'),
        Row(
          children: [
            Text(
              'Miễn phí',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(width: 8),
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
      spacing: 8.0,
      runSpacing: 4.0,
      children: viewModel.filterCategories.map((category) {
        final bool isSelected = viewModel.selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (bool selected) {
            viewModel.toggleCategory(category);
          },
          selectedColor: AppColors.primary.withOpacity(0.4),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black,
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
            text: 'Thiết lập lại',
            onPressed: () {
              viewModel.resetFilter();
            },
            height: 45,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            textColor: AppColors.primary,
            color: AppColors.transparent,
            fontSize: 15.0,
            borderColor: AppColors.primary,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppElevatedButton(
            text: 'Áp dụng',
            onPressed: () {
              context.pop();
            },
            height: 45,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            textColor: AppColors.white,
            color: AppColors.primary,
            fontSize: 15.0,
            borderColor: AppColors.transparent,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}
