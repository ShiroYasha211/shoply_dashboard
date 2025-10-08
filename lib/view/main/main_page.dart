import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../themes/app_theme.dart';
import '../../../widgets/sidebar_widget.dart';
import '../../controllers/auth_controllers.dart';
import 'main_controller.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isMobile =
            sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        final isTablet =
            sizingInformation.deviceScreenType == DeviceScreenType.tablet;
        final isDesktop =
            sizingInformation.deviceScreenType == DeviceScreenType.desktop;

        return Scaffold(
          body: Obx(
            () => GetBuilder<MainController>(
              init: MainController(),
              builder: (controller) {
                return Row(
                  children: [
                    // Sidebar - يظهر في الأجهزة غير المحمولة
                    if (!isMobile)
                      Obx(
                        () => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: controller.isCollapsed
                              ? (isTablet ? 60 : 70)
                              : (isTablet ? 200 : 250),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border(
                              right: BorderSide(color: Colors.grey[300]!),
                            ),
                            boxShadow: [
                              if (!isDesktop)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(2, 0),
                                ),
                            ],
                          ),
                          child: const SidebarWidget(),
                        ),
                      ),

                    // Main Content Area
                    Expanded(
                      child: Column(
                        children: [
                          // Top App Bar
                          _buildTopAppBar(
                            context,
                            isMobile,
                            isTablet,
                            isDesktop,
                          ),

                          // Content Area
                          Expanded(child: Obx(() => controller.currentPage)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Mobile Drawer
          ),
          drawer: isMobile ? const Drawer(child: SidebarWidget()) : null,
        );
      },
    );
  }

  Widget _buildTopAppBar(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final authController = Get.find<AuthController>();
    final appBarHeight = isMobile ? 70.0 : (isTablet ? 80.0 : 85.0);

    return Container(
      height: appBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu Button - يظهر في الجوال والتابلت
          if (isMobile || isTablet)
            Container(
              margin: EdgeInsets.only(left: isMobile ? 0 : 8),
              child: IconButton(
                icon: Icon(
                  isMobile ? Icons.menu : Icons.menu_open,
                  size: isMobile ? 20 : 24,
                  color: AppColors.charcoal,
                ),
                onPressed: () {
                  if (isMobile) {
                    Scaffold.of(context).openDrawer();
                  } else {
                    Get.find<MainController>().toggleSidebar();
                  }
                },
              ),
            ),

          // Collapse Button - يظهر في الديسكتوب فقط
          if (isDesktop)
            GetBuilder<MainController>(
              builder: (controller) => IconButton(
                icon: Icon(
                  controller.isCollapsed ? Icons.menu_open : Icons.menu,
                  size: 24,
                  color: AppColors.charcoal,
                ),
                onPressed: controller.toggleSidebar,
              ),
            ),

          SizedBox(width: isMobile ? 12 : 16),

          // Page Title
          Expanded(
            child: Text(
              'لوحة التحكم',
              style: TextStyle(
                fontSize: isMobile ? 18 : (isTablet ? 22 : 24),
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 16),
          // Profile Section
          _buildProfileSection(authController, isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    AuthController authController,
    bool isMobile,
    bool isTablet,
  ) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: AppColors.veryLightGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Avatar
            Container(
              width: isMobile ? 28 : 32,
              height: isMobile ? 28 : 32,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.white,
                size: isMobile ? 14 : 16,
              ),
            ),

            // User Name - يظهر في التابلت والديسكتوب فقط
            if (!isMobile) ...[
              SizedBox(width: isTablet ? 6 : 8),
              Flexible(
                child: Text(
                  authController.userProfile?['full_name'] ?? 'المدير',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal,
                    fontSize: isTablet ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: isTablet ? 4 : 6),
              Icon(
                Icons.arrow_drop_down,
                color: AppColors.darkGray,
                size: isTablet ? 18 : 20,
              ),
            ],
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => [
        // Logout Option
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                FontAwesomeIcons.signOutAlt,
                size: 16,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Text(
                'تسجيل الخروج',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'logout':
            _showLogoutDialog();
            break;
        }
      },
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
