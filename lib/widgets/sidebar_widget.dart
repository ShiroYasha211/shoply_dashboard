import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../themes/app_theme.dart';
import '../view/main/main_controller.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      builder: (controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.sidebarBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo Section
              _buildLogoSection(controller),

              // Menu Items
              Expanded(child: _buildMenuItems(controller)),

              // Footer
              //_buildFooter(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoSection(MainController controller) {
    return GetX<MainController>(
      builder: (controller) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: controller.isCollapsed ? 70 : 80,
          padding: EdgeInsets.all(controller.isCollapsed ? 12 : 16),
          child: Row(
            mainAxisAlignment: controller.isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Container(
                width: controller.isCollapsed ? 32 : 33,
                height: controller.isCollapsed ? 32 : 40,

                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FontAwesomeIcons.shop,
                  color: AppColors.primaryGreen,
                  size: controller.isCollapsed ? 16 : 20,
                ),
              ),
              if (!controller.isCollapsed) ...[
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Shoply Admin',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems(MainController controller) {
    final menuItems = [
      _MenuItem(Icons.dashboard_outlined, 'الرئيسية', 0),
      _MenuItem(Icons.people_outline, 'المستخدمون', 1),
      _MenuItem(Icons.inventory_2_outlined, 'المنتجات', 2),
      _MenuItem(Icons.category_outlined, 'الفئات', 3),
      _MenuItem(Icons.shopping_cart_outlined, 'الطلبات', 4),
      _MenuItem(Icons.star_outline, 'التقييمات', 5),
      _MenuItem(Icons.notifications_outlined, 'الإشعارات', 6),
      _MenuItem(Icons.settings_outlined, 'الإعدادات', 7),
    ];

    return SingleChildScrollView(
      child: Column(
        children: menuItems.map((item) {
          return _buildMenuItem(
            icon: item.icon,
            title: item.title,
            index: item.index,
            controller: controller,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required MainController controller,
  }) {
    return GetX<MainController>(
      builder: (controller) {
        final isSelected = controller.selectedIndex == index;
        final isCollapsed = controller.isCollapsed;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isCollapsed ? 40 : 44,
          margin: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 1 : 12,
            vertical: isCollapsed ? 1 : 2,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.navigateToPage(index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 8 : 16,
                  vertical: isCollapsed ? 8 : 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.white.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.white.withOpacity(0.8),
                      size: isCollapsed ? 18 : 20,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildFooter(MainController controller) {
  //   return GetX<MainController>(
  //     builder: (controller) {
  //       if (controller.isCollapsed) return const SizedBox.shrink();

  //       return AnimatedContainer(
  //         duration: const Duration(milliseconds: 300),
  //         //height: controller.isCollapsed ? 0 : 80,
  //         padding: EdgeInsets.symmetric(
  //           horizontal: controller.isCollapsed ? 30 : 60,
  //           vertical: controller.isCollapsed ? 30 : 60,
  //         ),
  //         child: Column(
  //           children: [
  //             Divider(color: AppColors.white.withOpacity(0.3), height: 1),
  //             const SizedBox(height: 16),
  //             Row(
  //               children: [
  //                 Icon(
  //                   Icons.admin_panel_settings,
  //                   color: AppColors.white.withOpacity(0.6),
  //                   size: 16,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Text(
  //                   'إدارة المتجر',
  //                   style: TextStyle(
  //                     color: AppColors.white.withOpacity(0.6),
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final int index;

  _MenuItem(this.icon, this.title, this.index);
}
