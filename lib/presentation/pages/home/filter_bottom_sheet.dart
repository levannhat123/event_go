import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _selectedLocation = 'Toàn quốc';
  bool _isFree = false;
  final Set<String> _selectedCategories = {};

  final List<String> locations = ['Toàn quốc', 'Hồ Chí Minh', 'Hà Nội', 'Đà Lạt', 'Vị trí khác'];

  final List<String> categories = ['Nhạc sống', 'Sân khấu & Nghệ thuật', 'Thể Thao', 'Khác'];

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(),
            _buildDivider(),
            SizedBox(height: 24),
            _buildSectionTitle('Vị trí'),
            ...locations.map((location) => _buildRadioListItem(location)).toList(),
            SizedBox(height: 12),
            _buildDivider(),
            SizedBox(height: 12),
            _buildPriceSection(),
            SizedBox(height: 12),
            _buildDivider(),
            SizedBox(height: 12),
            _buildSectionTitle('Thể loại'),
            _buildCategoryChips(),
            SizedBox(height: 32),
            _buildFooterButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 40),
        Text(
          'Bộ lọc',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildRadioListItem(String title) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocation = title;
        });
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
                  color: _selectedLocation == title ? AppColors.primary : AppColors.grey,
                  width: 2,
                ),
              ),
              child: _selectedLocation == title
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
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

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Giá tiền'),
        Row(
          children: [
            Text('Miễn phí', style: TextStyle(fontSize: 16, color: Colors.black)),
            SizedBox(width: 8),
            Switch(
              value: _isFree,
              onChanged: (value) {
                setState(() {
                  _isFree = value;
                });
              },
                activeColor: AppColors.lightGray,
                activeTrackColor: AppColors.textGreenOnOrderBook,
                inactiveThumbColor: AppColors.lightGray,
                inactiveTrackColor: AppColors.neutralGray,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: categories.map((category) {
        final bool isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
          selectedColor: AppColors.primary.withOpacity(0.4),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.black),
          backgroundColor: AppColors.white,
          shape: StadiumBorder(
            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.grey),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      children: [
        Expanded(
          child: AppElevatedButton(
            text: 'Thiết lập lại',
            onPressed: () {
              setState(() {
                _selectedLocation = 'Toàn quốc';
                _isFree = false;
                _selectedCategories.clear();
              });

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
            },
            height: 45,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            textColor:  AppColors.white,
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
