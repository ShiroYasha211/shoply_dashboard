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
        color: AppColors.lightGray,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu Button - يظهر في الجوال والتابلت
          Row(
            children: [
              if (isMobile || isTablet)
                Builder(
                  builder: (context) {
                    return Container(
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
                    );
                  },
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
            ],
          ),

          // Page Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: Image.asset("assets/icons/small_logo.png"),
              ),
              SizedBox(width: isMobile ? 8 : 16),
              Text(
                'asaloz',
                style: TextStyle(
                  fontSize: isMobile ? 24 : (isTablet ? 28 : 32),
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
      color: AppColors.lightGray,
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
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
                color: AppColors.primaryBrown,
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
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 30,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيتم إغلاق جلسة العمل الحالية',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Buttons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Logout Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.find<AuthController>().signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'تسجيل الخروج',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.logout_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
