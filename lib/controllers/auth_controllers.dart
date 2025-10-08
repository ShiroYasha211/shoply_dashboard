import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  final _isLoading = false.obs;
  final _isLoggedIn = false.obs;
  final _currentUser = Rxn<User>();
  final _userProfile = Rxn<Map<String, dynamic>>();
  final _authError = Rxn<String>();

  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  User? get currentUser => _currentUser.value;
  Map<String, dynamic>? get userProfile => _userProfile.value;
  bool get isAdmin => _userProfile.value?['role'] == 'admin';

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
    _listenToAuthChanges();
  }

  void _checkAuthStatus() {
    final session = SupabaseService.client.auth.currentSession;
    if (session != null) {
      _currentUser.value = session.user;
      _isLoggedIn.value = true;
      _loadUserProfile();
    }
  }

  void _listenToAuthChanges() {
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          _currentUser.value = session?.user;
          _isLoggedIn.value = true;
          _loadUserProfile();
          break;
        case AuthChangeEvent.signedOut:
          _currentUser.value = null;
          _userProfile.value = null;
          _isLoggedIn.value = false;
          Get.offAllNamed(Routes.LOGIN);
          break;
        default:
          break;
      }
    });
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser.value == null) return;

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', _currentUser.value!.id)
          .single();

      _userProfile.value = response;
    } catch (e) {
      print('خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading.value = true;

      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // تحقق من أن المستخدم مدير
        final profile = await SupabaseService.client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();

        if (profile['role'] != 'admin') {
          await signOut();
          Get.snackbar(
            'خطأ في الدخول',
            'ليس لديك صلاحية للدخول إلى لوحة التحكم',
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
          return false;
        }

        Get.offAllNamed(Routes.MAIN);
        Get.snackbar(
          'تم تسجيل الدخول بنجاح',
          'مرحباً بك في لوحة التحكم',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        return true;
      }
      return false;
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      _handleError(errorMessage);
      return false;
    } on TimeoutException {
      _handleError('انتهت المهلة في تسجيل الدخول');
      return false;
    } catch (e) {
      Get.snackbar(
        'خطأ في تسجيل الدخول',
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    }
  }

  String _getAuthErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (message.contains('Email not confirmed')) {
      return 'البريد الإلكتروني غير مفعل';
    } else if (message.contains('Too many requests')) {
      return 'محاولات تسجيل دخول كثيرة، حاول مرة أخرى لاحقاً';
    } else {
      return 'خطأ في المصادقة: $message';
    }
  }

  void _handleError(String error) {
    _authError.value = error;
    Get.snackbar(
      'خطأ',
      error,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 5),
    );
    print('Auth Error: $error');
  }
}
