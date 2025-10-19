import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/app_theme.dart';
import '../controllers/products_controller.dart';

class ProductHeader extends StatelessWidget {
  const ProductHeader({
    super.key,
    required this.controller,
    required this.isMobile,
  });
  final ProductController controller;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return _buildHeader(controller, isMobile, context);
  }
}

Widget _buildHeader(
  ProductController controller,
  bool isMobile,
  BuildContext context,
) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 12 : 16,
      vertical: isMobile ? 6 : 12,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // العنوان مع أيقونة
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: isMobile ? 20 : 24,
              color: AppColors.primaryBrown,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'إدارة المنتجات',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),

        const Spacer(),

        // زر عرض الشبكة/القائمة
        if (!isMobile) _buildViewModeToggle(controller, isMobile),

        // مسافة متجاوبة
        SizedBox(width: isMobile ? 12 : 20),

        // زر التحديث مع تحسينات
        _buildRefreshButton(controller, isMobile, context),

        // في حالة الجوال، نضع زر العرض في سطر جديد
        if (isMobile) ...[
          const SizedBox(width: 12),
          _buildViewModeToggle(controller, isMobile),
        ],
      ],
    ),
  );
}

Widget _buildViewModeToggle(ProductController controller, bool isMobile) {
  return Obx(
    () => Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          // زر العرض الشبكي
          _buildToggleButton(
            icon: Icons.grid_view,
            isActive: controller.isGridView.value,
            onPressed: () => controller.isGridView.value = true,
            tooltip: 'عرض شبكي',
            isMobile: isMobile,
          ),

          // فاصل
          Container(
            width: 1,
            height: isMobile ? 20 : 24,
            color: AppColors.lightGray,
          ),

          // زر العرض القائمة
          _buildToggleButton(
            icon: Icons.list,
            isActive: !controller.isGridView.value,
            onPressed: () => controller.isGridView.value = false,
            tooltip: 'عرض قائمة',
            isMobile: isMobile,
          ),
        ],
      ),
    ),
  );
}

Widget _buildToggleButton({
  required IconData icon,
  required bool isActive,
  required VoidCallback onPressed,
  required String tooltip,
  required bool isMobile,
}) {
  return Container(
    decoration: BoxDecoration(
      color: isActive
          ? AppColors.primaryBrown.withOpacity(0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: isMobile ? 18 : 20,
        color: isActive ? AppColors.primaryBrown : AppColors.darkGray,
      ),
      tooltip: tooltip,
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      constraints: BoxConstraints(
        minWidth: isMobile ? 36 : 40,
        minHeight: isMobile ? 36 : 40,
      ),
    ),
  );
}

Widget _buildRefreshButton(
  ProductController controller,
  bool isMobile,
  BuildContext context,
) {
  return Obx(
    () => ElevatedButton.icon(
      onPressed: controller.isLoading.value
          ? null
          : controller.fetchAllProducts,
      icon: controller.isLoading.value
          ? SizedBox(
              width: isMobile ? 14 : 16,
              height: isMobile ? 14 : 16,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.refresh, size: isMobile ? 16 : 18),
      label: Text(
        controller.isLoading.value ? 'جاري التحديث...' : 'تحديث',
        style: TextStyle(
          fontSize: isMobile ? 12 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
  );
}
