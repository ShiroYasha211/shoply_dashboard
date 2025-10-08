import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controllers.dart';
import '../../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If not logged in, redirect to login
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    // If logged in but not admin, redirect to login with error
    if (!authController.isAdmin) {
      Get.snackbar(
        'خطأ في الصلاحية',
        'ليس لديك صلاحية للدخول إلى لوحة التحكم',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return const RouteSettings(name: Routes.LOGIN);
    }

    // User is authenticated and is admin, allow access
    return null;
  }
}
