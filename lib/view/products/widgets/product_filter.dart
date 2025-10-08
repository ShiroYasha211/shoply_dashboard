import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../themes/app_theme.dart';
import '../controllers/products_controller.dart';

class ProductFilter extends StatelessWidget {
  const ProductFilter({
    super.key,
    required this.controller,
    required this.sizingInfo,
  });

  final ProductController controller;
  final SizingInformation sizingInfo;

  @override
  Widget build(BuildContext context) {
    return _buildFilters(controller, sizingInfo);
  }

  Widget _buildFilters(
    ProductController controller,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
    final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;

    if (isMobile) {
      return _buildMobileFilter(controller, isMobile);
    } else {
      return _buildDesktopFilter(controller, isMobile, isTablet);
    }
  }

  Widget _buildMobileFilter(ProductController controller, bool isMobile) {
    return Obx(
      () => Column(
        children: [
          // زر تحكم لإظهار/إخفاء الفلتر
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListTile(
              dense: true,
              leading: Icon(
                controller.isFilterExpanded.value
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              title: const Text(
                'فلترة المنتجات',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                controller.isFilterExpanded.value
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 20,
              ),
              onTap: () {
                controller.toggleFilterExpanded();
              },
            ),
          ),

          // الفلتر (يظهر/يختفي)
          if (controller.isFilterExpanded.value) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildSearchField(controller, isMobile),
                    const SizedBox(height: 8),
                    _buildCategoryFilter(controller, isMobile),
                    const SizedBox(height: 8),
                    _buildSubcategoryFilter(controller, isMobile),
                    const SizedBox(height: 8),
                    _buildStockFilter(controller, isMobile),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopFilter(
    ProductController controller,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 10 : 12),
        child: Row(
          children: [
            // حقل البحث يأخذ مساحة أكبر
            Expanded(flex: 3, child: _buildSearchField(controller, isMobile)),
            SizedBox(width: isTablet ? 10 : 12),

            // باقي الفلاتر تأخذ مساحة متساوية
            Expanded(
              flex: 2,
              child: _buildCategoryFilter(controller, isMobile),
            ),
            SizedBox(width: isTablet ? 8 : 10),

            Expanded(
              flex: 2,
              child: _buildSubcategoryFilter(controller, isMobile),
            ),
            SizedBox(width: isTablet ? 8 : 10),

            Expanded(flex: 2, child: _buildStockFilter(controller, isMobile)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ProductController controller, bool isMobile) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedCategory.value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'الفئة',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 12,
            vertical: isMobile ? 12 : 14,
          ),
          isDense: true,
        ),
        items: [
          const DropdownMenuItem(value: 'all', child: Text('الكل')),
          ...controller.categories
              .map(
                (category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setSelectedCategory(value);
          }
        },
      ),
    );
  }

  Widget _buildSubcategoryFilter(ProductController controller, bool isMobile) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedSubcategory.value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'التصنيف الفرعي',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 12,
            vertical: isMobile ? 12 : 14,
          ),
          isDense: true,
        ),
        items: [
          DropdownMenuItem(
            value: 'all',
            child: Text(
              controller.selectedCategory.value == 'all'
                  ? 'اختر الفئة'
                  : 'الكل',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...controller.subcategories
              .map(
                (subcategory) => DropdownMenuItem(
                  value: subcategory.id,
                  child: Text(
                    subcategory.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ],
        onChanged: controller.selectedCategory.value == 'all'
            ? null
            : (value) {
                if (value != null) {
                  controller.setSelectedSubcategory(value);
                }
              },
      ),
    );
  }

  Widget _buildSearchField(ProductController controller, bool isMobile) {
    return TextField(
      onChanged: controller.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'ابحث عن منتج...',
        prefixIcon: const Icon(Icons.search, size: 20),
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 12 : 14,
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildStockFilter(ProductController controller, bool isMobile) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.stockFilter.value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'المخزون',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 12,
            vertical: isMobile ? 12 : 14,
          ),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('الكل')),
          DropdownMenuItem(value: 'in_stock', child: Text('متوفر')),
          DropdownMenuItem(value: 'low_stock', child: Text('منخفض')),
          DropdownMenuItem(value: 'out_of_stock', child: Text('نفد')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setStockFilter(value);
          }
        },
      ),
    );
  }
}
