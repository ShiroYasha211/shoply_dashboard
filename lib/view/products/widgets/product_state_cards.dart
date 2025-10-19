import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../themes/app_theme.dart';
import '../controllers/products_controller.dart';

class ProductStateCards extends StatelessWidget {
  const ProductStateCards({
    super.key,
    required this.controller,
    required this.sizingInfo,
  });

  final ProductController controller;
  final SizingInformation sizingInfo;

  @override
  Widget build(BuildContext context) {
    return _buildStatsCards(controller, sizingInfo);
  }

  Widget _buildStatsCards(
    ProductController controller,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
    final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;
    final stats = controller.getProductStats();

    if (isMobile) {
      return SizedBox(
        height: 85, // ارتفاع مناسب للهاتف
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const SizedBox(width: 8), // مسافة من الحافة
            _buildStatCard(
              title: 'الإجمالي',
              value: stats['total']?.toString() ?? '0',
              icon: Icons.inventory_2,
              color: AppColors.primaryBrown,
              isMobile: isMobile,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              title: 'متوفر',
              value: stats['in_stock']?.toString() ?? '0',
              icon: Icons.check_circle,
              color: AppColors.success,
              isMobile: isMobile,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              title: 'منخفض',
              value: stats['low_stock']?.toString() ?? '0',
              icon: Icons.warning,
              color: AppColors.warning,
              isMobile: isMobile,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              title: 'نفد',
              value: stats['out_of_stock']?.toString() ?? '0',
              icon: Icons.error,
              color: AppColors.error,
              isMobile: isMobile,
            ),
            const SizedBox(width: 8), // مسافة من الحافة
          ],
        ),
      );
    }

    // للحاسوب والتابلت - تصميم مضغوط
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: isTablet ? 2.5 : 3.0,
      children: [
        _buildStatCard(
          title: 'الإجمالي',
          value: stats['total']?.toString() ?? '0',
          icon: Icons.inventory_2,
          color: AppColors.primaryBrown,
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'متوفر',
          value: stats['in_stock']?.toString() ?? '0',
          icon: Icons.check_circle,
          color: AppColors.success,
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'منخفض',
          value: stats['low_stock']?.toString() ?? '0',
          icon: Icons.warning,
          color: AppColors.warning,
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'نفد',
          value: stats['out_of_stock']?.toString() ?? '0',
          icon: Icons.error,
          color: AppColors.error,
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? 120 : null, // عرض ثابت للهاتف
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 12), // زيادة padding للهاتف
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الأيقونة
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isMobile ? 18 : 18, // حجم مناسب للهاتف
                ),
              ),

              SizedBox(width: isMobile ? 8 : 8),

              // القيمة والعنوان
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 4 : 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 12, // حجم مناسب للهاتف
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
