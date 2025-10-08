// controllers/profile_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final profiles = <Profile>[].obs;
  final isLoading = false.obs;
  final selectedProfile = Rxn<Profile>();

  final searchQuery = ''.obs;
  final selectedRole = 'all'.obs;
  final selectedStatus = 'all'.obs;

  // Roles and Statuses constants
  static const List<String> roles = ['admin', 'customer'];
  static const List<String> statuses = ['active', 'banned'];

  @override
  void onInit() {
    super.onInit();
    fetchAllProfiles();
  }

  List<Profile> get filteredUsers {
    List<Profile> filtered = profiles;

    // التصفية حسب البحث
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (user) =>
                (user.fullName?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ??
                    false) ||
                (user.email.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                )) ||
                (user.phone?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    // التصفية حسب الدور
    if (selectedRole.value != 'all') {
      filtered = filtered
          .where((user) => user.role == selectedRole.value)
          .toList();
    }

    // التصفية حسب الحالة
    if (selectedStatus.value != 'all') {
      filtered = filtered
          .where((user) => user.status == selectedStatus.value)
          .toList();
    }

    return filtered;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setSelectedRole(String role) {
    selectedRole.value = role;
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }

  // جلب جميع الملفات الشخصية مع البريد الإلكتروني
  Future<void> fetchAllProfiles() async {
    try {
      isLoading(true);

      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      profiles.assignAll(
        (response as List).map((item) => Profile.fromJson(item)).toList(),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب الملفات الشخصية: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // جلب ملف شخصي بواسطة ID مع البريد الإلكتروني
  Future<Profile?> getProfileById(String id) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            *,
            auth_users:auth.users(email)
          ''')
          .eq('id', id)
          .single();

      final profileData = Map<String, dynamic>.from(response);

      // استخراج البريد الإلكتروني
      if (response['auth_users'] != null && response['auth_users'] is List) {
        final authData = response['auth_users'] as List;
        if (authData.isNotEmpty) {
          profileData['email'] = authData[0]['email'];
        }
      }

      return Profile.fromJson(profileData);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب الملف الشخصي: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // إنشاء ملف شخصي جديد
  Future<void> createProfile(Profile profile) async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('profiles')
          .insert(profile.toJson())
          .select()
          .single();

      final newProfile = Profile.fromJson(response);
      profiles.insert(0, newProfile);

      Get.snackbar(
        'نجاح',
        'تم إنشاء الملف الشخصي بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إنشاء الملف الشخصي: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // تحديث ملف شخصي
  Future<void> updateProfile(String id, Profile updatedProfile) async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('profiles')
          .update(updatedProfile.toJson())
          .eq('id', id)
          .select()
          .single();

      final profile = Profile.fromJson(response);
      final index = profiles.indexWhere((p) => p.id == id);
      if (index != -1) {
        profiles[index] = profile;
      }

      Get.snackbar(
        'نجاح',
        'تم تحديث الملف الشخصي بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الملف الشخصي: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // تحديث دور المستخدم
  Future<void> updateUserRole(String id, String newRole) async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('profiles')
          .update({'role': newRole})
          .eq('id', id)
          .select()
          .single();

      final updatedProfile = Profile.fromJson(response);
      final index = profiles.indexWhere((p) => p.id == id);
      if (index != -1) {
        profiles[index] = updatedProfile;
      }

      Get.snackbar(
        'نجاح',
        'تم تحديث دور المستخدم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث دور المستخدم: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // ✅ تحديث حالة المستخدم (الحظر/الفك)
  Future<void> toggleUserStatus(String id) async {
    try {
      isLoading(true);

      // الحصول على الحالة الحالية
      final currentProfile = profiles.firstWhere((p) => p.id == id);
      final newStatus = currentProfile.status == 'active' ? 'banned' : 'active';

      final response = await _supabase
          .from('profiles')
          .update({'status': newStatus})
          .eq('id', id)
          .select()
          .single();

      final updatedProfile = Profile.fromJson(response);
      final index = profiles.indexWhere((p) => p.id == id);
      if (index != -1) {
        profiles[index] = updatedProfile;
      }

      final statusText = newStatus == 'banned' ? 'حظر' : 'فك الحظر';
      Get.snackbar(
        'نجاح',
        'تم $statusText المستخدم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تغيير حالة المستخدم: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // ✅ حظر مستخدم
  Future<void> banUser(String id) async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('profiles')
          .update({'status': 'banned'})
          .eq('id', id)
          .select()
          .single();

      final updatedProfile = Profile.fromJson(response);
      final index = profiles.indexWhere((p) => p.id == id);
      if (index != -1) {
        profiles[index] = updatedProfile;
      }

      Get.snackbar(
        'نجاح',
        'تم حظر المستخدم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حظر المستخدم: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // ✅ فك حظر مستخدم
  Future<void> unbanUser(String id) async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('profiles')
          .update({'status': 'active'})
          .eq('id', id)
          .select()
          .single();

      final updatedProfile = Profile.fromJson(response);
      final index = profiles.indexWhere((p) => p.id == id);
      if (index != -1) {
        profiles[index] = updatedProfile;
      }

      Get.snackbar(
        'نجاح',
        'تم فك حظر المستخدم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في فك حظر المستخدم: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // البحث في الملفات الشخصية
  List<Profile> searchProfiles(String query) {
    if (query.isEmpty) return profiles;

    return profiles
        .where(
          (profile) =>
              (profile.fullName?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (profile.phone?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (profile.email.toLowerCase().contains(query.toLowerCase())) ||
              (profile.address?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  // تصفية الملفات الشخصية حسب الدور
  List<Profile> filterByRole(String role) {
    if (role.isEmpty) return profiles;
    return profiles.where((profile) => profile.role == role).toList();
  }

  // تصفية الملفات الشخصية حسب الحالة
  List<Profile> filterByStatus(String status) {
    if (status.isEmpty) return profiles;
    return profiles.where((profile) => profile.status == status).toList();
  }

  // اختيار ملف شخصي
  void selectProfile(Profile profile) {
    selectedProfile.value = profile;
  }

  // إلغاء اختيار الملف الشخصي
  void clearSelectedProfile() {
    selectedProfile.value = null;
  }

  // الحصول على إحصائيات المستخدمين
  Map<String, int> getUserStats() {
    final total = profiles.length;
    final admins = profiles.where((p) => p.role == 'admin').length;
    final customers = profiles.where((p) => p.role == 'customer').length;
    final active = profiles.where((p) => p.status == 'active').length;
    final banned = profiles.where((p) => p.status == 'banned').length;

    return {
      'total': total,
      'admins': admins,
      'customers': customers,
      'active': active,
      'banned': banned,
    };
  }

  // ✅ الحصول على المستخدمين النشطين فقط
  List<Profile> get activeUsers {
    return profiles.where((p) => p.status == 'active').toList();
  }

  // ✅ الحصول على المستخدمين المحظورين فقط
  List<Profile> get bannedUsers {
    return profiles.where((p) => p.status == 'banned').toList();
  }

  // ✅ التحقق إذا كان المستخدم محظوراً
  bool isUserBanned(String id) {
    final profile = profiles.firstWhereOrNull((p) => p.id == id);
    return profile?.status == 'banned';
  }

  // ✅ الحصول على عدد المستخدمين المحظورين
  int get bannedUsersCount {
    return profiles.where((p) => p.status == 'banned').length;
  }
}
