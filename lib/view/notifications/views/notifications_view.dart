import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/user_model.dart';
import '../../users/controllers/users_controller.dart';
import '../controllers/notifications_controller.dart';
import '../../../themes/app_theme.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: NotificationsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Stats
                    _buildHeader(controller),
                    const SizedBox(height: 24),

                    // Send Notification Form
                    _buildSendNotificationForm(controller, sizingInformation),
                    const SizedBox(height: 24),

                    // Filters and Notifications List
                    Expanded(child: _buildNotificationsSection(controller)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(NotificationsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إدارة الإشعارات',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final total = controller.notifications.length;
          final unread = controller.notifications
              .where((n) => !n.isRead)
              .length;
          final general = controller.notifications
              .where((n) => n.isGeneral)
              .length;
          final personal = controller.notifications
              .where((n) => !n.isGeneral)
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$total إشعار • $unread غير مقروء',
                style: const TextStyle(fontSize: 16, color: AppColors.darkGray),
              ),
              const SizedBox(height: 4),
              Text(
                '$general عام • $personal شخصي',
                style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSendNotificationForm(
    NotificationsController controller,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.primaryBrown),
                SizedBox(width: 8),
                Text(
                  'إرسال إشعار جديد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notification Type Selection
            _buildNotificationTypeSelector(controller),
            const SizedBox(height: 16),

            if (isMobile) ...[
              _buildMobileForm(controller),
            ] else ...[
              _buildDesktopForm(controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeSelector(NotificationsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الإشعار',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildNotificationTypeButton(
                controller: controller,
                type: NotificationType.general,
                icon: Icons.campaign,
                label: 'إشعار عام',
                isSelected:
                    controller.selectedNotificationType ==
                    NotificationType.general,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNotificationTypeButton(
                controller: controller,
                type: NotificationType.personal,
                icon: Icons.person,
                label: 'إشعار شخصي',
                isSelected:
                    controller.selectedNotificationType ==
                    NotificationType.personal,
              ),
            ),
          ],
        ),

        // User Selection for Personal Notifications
        if (controller.selectedNotificationType ==
            NotificationType.personal) ...[
          const SizedBox(height: 16),
          _buildUserSelectionDropdown(controller),
        ],
      ],
    );
  }

  Widget _buildNotificationTypeButton({
    required NotificationsController controller,
    required NotificationType type,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return OutlinedButton(
      onPressed: () => controller.setNotificationType(type),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.primaryBrown.withOpacity(0.1)
            : null,
        side: BorderSide(
          color: isSelected
              ? AppColors.primaryBrown
              : AppColors.darkGray.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.primaryBrown : AppColors.darkGray,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryBrown : AppColors.darkGray,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSelectionDropdown(NotificationsController controller) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (profileController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختر المستخدم',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkGray.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<Profile>(
                value: controller.selectedUser.value,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('اختر مستخدم...'),
                items: profileController.activeUsers.map((user) {
                  return DropdownMenuItem<Profile>(
                    value: user,
                    child: Text(
                      '${user.fullName} - ${user.email}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (Profile? user) {
                  controller.setSelectedUser(user);
                },
              ),
            ),
            if (profileController.isLoading.value) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMobileForm(NotificationsController controller) {
    return Column(
      children: [
        TextField(
          controller: controller.titleController,
          decoration: const InputDecoration(
            labelText: 'عنوان الإشعار',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.messageController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'محتوى الإشعار',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: controller.isLoading
                ? null
                : () => _sendNotification(controller),
            icon: const Icon(Icons.send, size: 20),
            label: controller.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    controller.selectedNotificationType ==
                            NotificationType.general
                        ? 'إرسال للجميع'
                        : 'إرسال للمستخدم',
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrown,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopForm(NotificationsController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller.titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الإشعار',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller.messageController,
                decoration: const InputDecoration(
                  labelText: 'محتوى الإشعار',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: controller.isLoading
                    ? null
                    : () => _sendNotification(controller),
                icon: const Icon(Icons.send, size: 20),
                label: controller.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        controller.selectedNotificationType ==
                                NotificationType.general
                            ? 'إرسال للجميع'
                            : 'إرسال للمستخدم',
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _sendNotification(NotificationsController controller) {
    if (controller.selectedNotificationType == NotificationType.personal) {
      if (controller.selectedUser == null) {
        Get.snackbar(
          'تنبيه',
          'يرجى اختيار مستخدم لإرسال الإشعار الشخصي',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      controller.sendNotificationToUser(controller.selectedUser.value!.id);
    } else {
      controller.sendNotification();
    }
  }

  // باقي الدوال تبقى كما هي (_buildNotificationsSection, _buildFiltersRow, etc.)
  Widget _buildNotificationsSection(NotificationsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFiltersRow(controller),
        const SizedBox(height: 16),
        Expanded(child: _buildNotificationsList(controller)),
      ],
    );
  }

  Widget _buildFiltersRow(NotificationsController controller) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.filter_list,
              color: AppColors.primaryBrown,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'الإشعارات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // فلترة حسب نوع الإشعار
            _buildNotificationFilter(controller),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.isLoading
                  ? null
                  : controller.loadNotifications,
              tooltip: 'تحديث',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationFilter(NotificationsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.darkGray.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: controller.notificationFilter.value,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('جميع الإشعارات')),
          DropdownMenuItem(value: 'general', child: Text('إشعارات عامة')),
          DropdownMenuItem(value: 'personal', child: Text('إشعارات شخصية')),
        ],
        onChanged: (value) => controller.setNotificationFilter(value!),
      ),
    );
  }

  Widget _buildNotificationsList(NotificationsController controller) {
    if (controller.isLoading && controller.notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBrown),
            SizedBox(height: 16),
            Text('جاري تحميل الإشعارات...'),
          ],
        ),
      );
    }

    return Obx(() {
      final notifications = controller.filteredNotifications;

      if (notifications.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 64,
                color: AppColors.darkGray,
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد إشعارات',
                style: TextStyle(fontSize: 18, color: AppColors.darkGray),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadNotifications(),
        color: AppColors.primaryBrown,
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification, controller);
          },
        ),
      );
    });
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    NotificationsController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Icon(
                      notification.isGeneral ? Icons.campaign : Icons.person,
                      color: notification.isRead
                          ? AppColors.darkGray
                          : AppColors.primaryBrown,
                      size: 24,
                    ),
                    if (!notification.isRead)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: notification.isRead
                              ? AppColors.darkGray
                              : AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: notification.isGeneral
                              ? AppColors.info.withOpacity(0.1)
                              : AppColors.primaryBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notification.isGeneral ? 'إشعار عام' : 'إشعار شخصي',
                          style: TextStyle(
                            fontSize: 11,
                            color: notification.isGeneral
                                ? AppColors.info
                                : AppColors.primaryBrown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      notification.timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        _handleMenuAction(value, controller, notification);
                      },
                      itemBuilder: (context) => [
                        if (!notification.isRead)
                          const PopupMenuItem(
                            value: 'mark_read',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.mark_email_read,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                SizedBox(width: 8),
                                Text('تعيين كمقروء'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 16,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'حذف',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification.message,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            if (!notification.isGeneral && notification.user != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.primaryBrown,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'مرسل إلى: ${notification.user!.fullName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
    String value,
    NotificationsController controller,
    NotificationModel notification,
  ) {
    switch (value) {
      case 'mark_read':
        controller.markAsRead(notification.id);
        break;
      case 'delete':
        _showDeleteConfirmation(controller, notification);
        break;
    }
  }

  void _showDeleteConfirmation(
    NotificationsController controller,
    NotificationModel notification,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('حذف إشعار'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذا الإشعار؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              controller.deleteNotification(notification.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
