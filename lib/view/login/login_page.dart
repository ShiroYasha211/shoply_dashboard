import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/icons/main_logo.png', height: 250),

                      const SizedBox(height: 2),
                      Text(
                        'لوحة تحكم المدراء',
                        style: Get.textTheme.bodyLarge?.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        validator: controller.validateEmail,
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          hintText: 'admin@Asaloz.com',
                          prefixIcon: const Icon(FontAwesomeIcons.envelope),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Get.theme.colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      Obx(
                        () => TextFormField(
                          controller: controller.passwordController,
                          obscureText: !controller.isPasswordVisible,
                          validator: controller.validatePassword,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: const Icon(FontAwesomeIcons.lock),
                            suffixIcon: IconButton(
                              onPressed: controller.togglePasswordVisibility,

                              icon: Icon(
                                controller.isPasswordVisible
                                    ? FontAwesomeIcons.eyeSlash
                                    : FontAwesomeIcons.eye,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Get.theme.colorScheme.surface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: controller.authController.isLoading
                                ? null
                                : controller.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Get.theme.colorScheme.primary,
                              foregroundColor: Get.theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.authController.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info Text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.circleInfo,
                              size: 16,
                              color: Get.theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'هذه الصفحة مخصصة للمدراء فقط',
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color:
                                      Get.theme.colorScheme.onPrimaryContainer,
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
            ),
          ),
        ),
      ),
    );
  }
}
