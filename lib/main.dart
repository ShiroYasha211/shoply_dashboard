import 'package:dashboard_test/core/bindings/initial_binding.dart';
import 'package:dashboard_test/core/services/supabase_service.dart';
import 'package:dashboard_test/routes/app_pages.dart';
import 'package:dashboard_test/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shoply Dashboard',
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
