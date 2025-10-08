// controllers/categories_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/category_model.dart';
import '../../../themes/app_theme.dart';

class CategoryController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final categories = <Category>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCategories();
  }

  Future<void> fetchAllCategories() async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('categories')
          .select('''
            *,
            subcategories (*)
          ''')
          .order('created_at', ascending: false);

      categories.assignAll(
        (response as List).map((item) => Category.fromJson(item)).toList(),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب الفئات: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> addCategory(String name) async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('categories')
          .insert({'name': name})
          .select('''
            *,
            subcategories (*)
          ''')
          .single();

      final newCategory = Category.fromJson(response);
      categories.insert(0, newCategory);

      Get.snackbar(
        'نجاح',
        'تم إضافة الفئة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة الفئة: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateCategory(String id, String name) async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('categories')
          .update({'name': name})
          .eq('id', id)
          .select('''
            *,
            subcategories (*)
          ''')
          .single();

      final updatedCategory = Category.fromJson(response);
      final index = categories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        categories[index] = updatedCategory;
      }

      Get.snackbar(
        'نجاح',
        'تم تحديث الفئة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الفئة: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading(true);
      await _supabase.from('categories').delete().eq('id', id);

      categories.removeWhere((cat) => cat.id == id);

      Get.snackbar(
        'نجاح',
        'تم حذف الفئة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // استخدام PostgrestException للتحقق الدقيق من نوع الخطأ
      if (e is PostgrestException) {
        _handleDeleteError(e);
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في حذف الفئة: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading(false);
    }
  }

  void _handleDeleteError(PostgrestException e) {
    final errorMessage = e.message.toLowerCase();
    final errorCode = e.code?.toLowerCase() ?? '';

    // التحقق من أخطاء المفتاح الخارجي
    if (errorCode == '23503' ||
        errorMessage.contains('foreign key') ||
        errorMessage.contains('violates foreign key') ||
        errorMessage.contains('still referenced')) {
      Get.defaultDialog(
        title: 'لا يمكن الحذف',
        titleStyle: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.bold,
        ),
        content: const Column(
          children: [
            Icon(Icons.error_outline, size: 50, color: AppColors.error),
            SizedBox(height: 16),
            Text(
              'لا يمكن حذف هذه الفئة لأنها مرتبطة بعناصر أخرى في النظام.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'لحذف هذه الفئة، يرجى:',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. نقل أو حذف الفئات الفرعية المرتبطة بها\n'
              '2. نقل أو حذف المنتجات المرتبطة بها\n'
              '3. التأكد من عدم وجود أي عناصر تستخدم هذه الفئة',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('حسناً', style: TextStyle(color: AppColors.white)),
        ),
      );
    } else {
      Get.snackbar(
        'خطأ',
        'فشل في حذف الفئة: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addSubcategory(String categoryId, String name) async {
    try {
      isLoading(true);
      await _supabase
          .from('subcategories')
          .insert({'category_id': categoryId, 'name': name})
          .select()
          .single();

      // تحديث القائمة الرئيسية
      await fetchAllCategories();

      Get.snackbar(
        'نجاح',
        'تم إضافة الفئة المساعدة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة الفئة المساعدة: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateSubcategory(String id, String name) async {
    try {
      isLoading(true);
      await _supabase
          .from('subcategories')
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();

      // تحديث القائمة الرئيسية
      await fetchAllCategories();

      Get.snackbar(
        'نجاح',
        'تم تحديث الفئة المساعدة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الفئة المساعدة: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // ✅ جديد: حذف الفئة الفرعية
  Future<void> deleteSubcategory(String id) async {
    try {
      isLoading(true);
      await _supabase.from('subcategories').delete().eq('id', id);

      // تحديث القائمة الرئيسية
      await fetchAllCategories();

      Get.snackbar(
        'نجاح',
        'تم حذف الفئة المساعدة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // استخدام PostgrestException للتحقق الدقيق من نوع الخطأ
      if (e is PostgrestException) {
        _handleDeleteError(e);
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في حذف الفئة: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading(false);
    }
  }
}
