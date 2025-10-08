// services/image_upload_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final ImagePicker _imagePicker = ImagePicker();

  // رفع صورة إلى Supabase Storage
  static Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      final fileBytes = await imageFile.readAsBytes();

      await _supabase.storage
          .from('products') // اسم الـ bucket في Supabase
          .upload(
            'images/$fileName', // المسار في التخزين
            fileBytes as File,
            fileOptions: const FileOptions(upsert: true),
          );

      // الحصول على رابط Public URL
      final publicUrl = _supabase.storage
          .from('products')
          .getPublicUrl('images/$fileName');

      return publicUrl;
    } catch (e) {
      print('خطأ في رفع الصورة: $e');
      return null;
    }
  }

  // اختيار صورة من المعرض
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('خطأ في اختيار الصورة: $e');
      return null;
    }
  }

  // التقاط صورة من الكاميرا
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('خطأ في التقاط الصورة: $e');
      return null;
    }
  }

  // حذف صورة من التخزين
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // استخراج اسم الملف من الـ URL
      final fileName = imageUrl.split('/').last;
      await _supabase.storage.from('products').remove(['images/$fileName']);

      return true;
    } catch (e) {
      print('خطأ في حذف الصورة: $e');
      return false;
    }
  }
}
