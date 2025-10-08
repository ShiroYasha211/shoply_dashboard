import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/models/user_model.dart';

enum NotificationType { general, personal }

class NotificationsController extends GetxController {
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxBool _isLoading = false.obs;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  List<NotificationModel> get notifications => _notifications.toList();
  bool get isLoading => _isLoading.value;

  final selectedNotificationType = NotificationType.general.obs;
  final selectedUser = Rxn<Profile>();
  final notificationFilter = 'all'.obs;
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    super.onClose();
  }

  // تحميل الإشعارات من Supabase
  Future<void> loadNotifications() async {
    try {
      _isLoading.value = true;

      final response = await _supabase
          .from('notifications')
          .select('''
            *,
            profiles:user_id (
              id,
              full_name,
              email
            )
          ''')
          .order('created_at', ascending: false);

      if (response != null && response is List) {
        final List<NotificationModel> loadedNotifications = [];

        for (final item in response) {
          try {
            loadedNotifications.add(NotificationModel.fromJson(item));
          } catch (e) {
            print('Error parsing notification: $e');
          }
        }

        _notifications.assignAll(loadedNotifications);
      }
    } on PostgrestException catch (e) {
      Get.snackbar(
        'خطأ في قاعدة البيانات',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الإشعارات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // إرسال إشعار جديد إلى Supabase
  Future<void> sendNotification() async {
    try {
      if (titleController.text.isEmpty || messageController.text.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'يرجى ملء جميع الحقول',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      _isLoading.value = true;

      final Map<String, dynamic> notificationData = {
        'title': titleController.text,
        'message': messageController.text,
        'is_read': false,
        'user_id': null, // إشعار عام (لجميع المستخدمين)
      };

      final response = await _supabase
          .from('notifications')
          .insert(notificationData)
          .select('''
            *,
            profiles:user_id (
              id,
              full_name,
              email
            )
          ''')
          .single();

      if (response != null) {
        final newNotification = NotificationModel.fromJson(response);
        _notifications.insert(0, newNotification);

        // مسح الحقول بعد الإرسال
        titleController.clear();
        messageController.clear();

        Get.snackbar(
          'نجاح',
          'تم إرسال الإشعار بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on PostgrestException catch (e) {
      Get.snackbar(
        'خطأ في قاعدة البيانات',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في إرسال الإشعار',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // إرسال إشعار لمستخدم محدد
  Future<void> sendNotificationToUser(String userId) async {
    try {
      if (titleController.text.isEmpty || messageController.text.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'يرجى ملء جميع الحقول',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      _isLoading.value = true;

      final Map<String, dynamic> notificationData = {
        'title': titleController.text,
        'message': messageController.text,
        'is_read': false,
        'user_id': userId, // إشعار لمستخدم محدد
      };

      final response = await _supabase
          .from('notifications')
          .insert(notificationData)
          .select('''
            *,
            profiles:user_id (
              id,
              full_name,
              email
            )
          ''')
          .single();

      if (response != null) {
        final newNotification = NotificationModel.fromJson(response);
        _notifications.insert(0, newNotification);

        titleController.clear();
        messageController.clear();

        Get.snackbar(
          'نجاح',
          'تم إرسال الإشعار للمستخدم بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on PostgrestException catch (e) {
      Get.snackbar(
        'خطأ في قاعدة البيانات',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في إرسال الإشعار',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // حذف إشعار من Supabase
  Future<void> deleteNotification(String notificationId) async {
    try {
      _isLoading.value = true;

      await _supabase.from('notifications').delete().eq('id', notificationId);

      _notifications.removeWhere(
        (notification) => notification.id == notificationId,
      );

      Get.snackbar(
        'نجاح',
        'تم حذف الإشعار بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on PostgrestException catch (e) {
      Get.snackbar(
        'خطأ في قاعدة البيانات',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف الإشعار',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // تحديث حالة القراءة
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      // تحديث البيانات المحلية
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updatedNotification = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          isRead: true,
          createdAt: _notifications[index].createdAt,
          user: _notifications[index].user,
        );
        _notifications[index] = updatedNotification;
      }
    } on PostgrestException catch (e) {
      print('Error marking as read: ${e.message}');
    }
  }

  // الحصول على عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  void setNotificationType(NotificationType type) {
    selectedNotificationType.value = type;
    if (type == NotificationType.general) {
      selectedUser.value = null;
    }
  }

  void setSelectedUser(Profile? user) {
    selectedUser.value = user;
  }

  void setNotificationFilter(String filter) {
    notificationFilter.value = filter;
  }

  List<NotificationModel> get filteredNotifications {
    if (notificationFilter.value == 'all') return notifications;
    if (notificationFilter.value == 'general') {
      return notifications.where((n) => n.isGeneral).toList();
    }
    return notifications.where((n) => !n.isGeneral).toList();
  }
}
