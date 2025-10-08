import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../data/models/user_model.dart';
import '../../../themes/app_theme.dart';
import '../controllers/users_controller.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              final isMobile =
                  sizingInformation.deviceScreenType == DeviceScreenType.mobile;
              final isTablet =
                  sizingInformation.deviceScreenType == DeviceScreenType.tablet;

              return Padding(
                padding: EdgeInsets.all(isMobile ? 8 : (isTablet ? 16 : 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - مضغوط للهاتف
                    _buildHeader(controller, isMobile),
                    SizedBox(height: isMobile ? 12 : 20),

                    // Filters
                    _buildFilters(controller, sizingInformation),
                    SizedBox(height: isMobile ? 12 : 20),

                    // Users Table/List
                    Expanded(child: _buildUsersContent(controller, isMobile)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(ProfileController controller, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'المستخدمين',
              style: TextStyle(
                fontSize: isMobile ? 18 : 28,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const Spacer(),
            // إحصائيات صغيرة على الهاتف
            if (isMobile)
              Obx(() {
                final stats = controller.getUserStats();
                return Text(
                  '${stats['total']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            if (!isMobile)
              ElevatedButton.icon(
                onPressed: controller.fetchAllProfiles,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('تحديث'),
              ),
          ],
        ),
        // إحصائيات للشاشات الكبيرة
        if (!isMobile)
          Obx(() {
            final stats = controller.getUserStats();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${stats['total']} مستخدم • ${stats['active']} نشط • ${stats['banned']} محظور',
                style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFilters(
    ProfileController controller,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
    final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;

    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 10 : 16),
        child: isMobile
            ? Column(
                children: [
                  _buildSearchField(controller, isMobile),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildRoleFilter(controller, isMobile)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatusFilter(controller, isMobile)),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildSearchField(controller, isMobile),
                  ),
                  SizedBox(width: isTablet ? 12 : 16),
                  Expanded(
                    flex: 2,
                    child: _buildRoleFilter(controller, isMobile),
                  ),
                  SizedBox(width: isTablet ? 12 : 16),
                  Expanded(
                    flex: 2,
                    child: _buildStatusFilter(controller, isMobile),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchField(ProfileController controller, bool isMobile) {
    return TextField(
      onChanged: controller.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'ابحث عن مستخدم...',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildRoleFilter(ProfileController controller, bool isMobile) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedRole.value,
        decoration: InputDecoration(
          labelText: 'الدور',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 12 : 16,
          ),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('جميع الأدوار')),
          DropdownMenuItem(value: 'customer', child: Text('عملاء')),
          DropdownMenuItem(value: 'admin', child: Text('مدراء')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setSelectedRole(value);
          }
        },
      ),
    );
  }

  Widget _buildStatusFilter(ProfileController controller, bool isMobile) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedStatus.value,
        decoration: InputDecoration(
          labelText: 'الحالة',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 12 : 16,
          ),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
          DropdownMenuItem(value: 'active', child: Text('نشط')),
          DropdownMenuItem(value: 'banned', child: Text('محظور')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setSelectedStatus(value);
          }
        },
      ),
    );
  }

  Widget _buildUsersContent(ProfileController controller, bool isMobile) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        );
      }

      final users = controller.filteredUsers;

      if (users.isEmpty) {
        return const Center(
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.darkGray,
              ),
              const SizedBox(height: 16),
              const Text(
                'لا توجد مستخدمين',
                style: const TextStyle(fontSize: 16, color: AppColors.darkGray),
              ),
              const SizedBox(height: 8),
              const Text(
                'جرب تغيير عوامل التصفية',
                style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
              ),
            ],
          ),
        );
      }

      return isMobile
          ? _buildMobileUsersList(controller, users)
          : _buildDesktopUsersTable(controller, users);
    });
  }

  Widget _buildMobileUsersList(
    ProfileController controller,
    List<Profile> users,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.veryLightGreen,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      color: AppColors.primaryGreen,
                      size: 18,
                    )
                  : null,
            ),
            title: Text(
              user.fullName ?? 'بدون اسم',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: user.role == 'admin'
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role == 'admin' ? 'مدير' : 'عميل',
                        style: TextStyle(
                          fontSize: 10,
                          color: user.role == 'admin'
                              ? Colors.blue
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: user.status == 'active'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.status == 'active' ? 'نشط' : 'محظور',
                        style: TextStyle(
                          fontSize: 10,
                          color: user.status == 'active'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (value) =>
                  _handleMobileUserAction(value, user, controller),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'change_role',
                  child: const Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, size: 16),
                      const SizedBox(width: 8),
                      const Text('تغيير الدور'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: user.status == 'active' ? 'ban' : 'unban',
                  child: Row(
                    children: [
                      Icon(
                        user.status == 'active' ? Icons.block : Icons.lock_open,
                        size: 16,
                        color: user.status == 'active'
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(user.status == 'active' ? 'حظر' : 'فك الحظر'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_details',
                  child: const Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 8),
                      const Text('عرض التفاصيل'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleMobileUserAction(
    String value,
    Profile user,
    ProfileController controller,
  ) {
    switch (value) {
      case 'change_role':
        _showChangeRoleDialog(controller, user);
        break;
      case 'ban':
      case 'unban':
        _showToggleStatusDialog(controller, user);
        break;
      case 'view_details':
        _showUserDetails(controller, user);
        break;
    }
  }

  Widget _buildDesktopUsersTable(
    ProfileController controller,
    List<Profile> users,
  ) {
    return Card(
      elevation: 1,
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 800,
        dataRowHeight: 60,
        headingRowHeight: 50,
        columns: const [
          DataColumn2(label: Text('الاسم'), size: ColumnSize.L),
          DataColumn2(label: Text('البريد الإلكتروني'), size: ColumnSize.L),
          DataColumn2(label: Text('الهاتف'), size: ColumnSize.M),
          DataColumn2(label: Text('الدور'), size: ColumnSize.S),
          DataColumn2(label: Text('الحالة'), size: ColumnSize.S),
          DataColumn2(label: Text('تاريخ التسجيل'), size: ColumnSize.M),
          DataColumn2(label: Text('الإجراءات'), size: ColumnSize.L),
        ],
        rows: users.map((user) {
          return DataRow2(
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.veryLightGreen,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              color: AppColors.primaryGreen,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.fullName ?? 'بدون اسم',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text(user.email, overflow: TextOverflow.ellipsis)),
              DataCell(Text(user.phone ?? 'غير محدد')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.role == 'admin'
                        ? AppColors.primaryGreen.withOpacity(0.1)
                        : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role == 'admin' ? 'مدير' : 'عميل',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.role == 'admin'
                          ? AppColors.primaryGreen
                          : AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.status == 'active'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.status == 'active' ? 'نشط' : 'محظور',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.status == 'active'
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(Text(DateFormat('dd/MM/yyyy').format(user.createdAt))),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.admin_panel_settings,
                        color: user.role == 'admin'
                            ? AppColors.warning
                            : AppColors.primaryGreen,
                        size: 20,
                      ),
                      onPressed: () => _showChangeRoleDialog(controller, user),
                      tooltip: 'تغيير الدور',
                    ),
                    IconButton(
                      icon: Icon(
                        user.status == 'active' ? Icons.block : Icons.lock_open,
                        color: user.status == 'active'
                            ? AppColors.error
                            : AppColors.success,
                        size: 20,
                      ),
                      onPressed: () =>
                          _showToggleStatusDialog(controller, user),
                      tooltip: user.status == 'active' ? 'حظر' : 'فك الحظر',
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'view_details') {
                          _showUserDetails(controller, user);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view_details',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16),
                              SizedBox(width: 8),
                              Text('عرض التفاصيل'),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(
                        Icons.more_vert,
                        color: AppColors.darkGray,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // باقي الدوال تبقى كما هي بدون تغيير
  void _showChangeRoleDialog(ProfileController controller, Profile user) {
    final newRole = user.role == 'admin' ? 'customer' : 'admin';
    final roleText = newRole == 'admin' ? 'مدير' : 'عميل';

    Get.dialog(
      AlertDialog(
        title: const Text('تغيير دور المستخدم'),
        content: Text(
          'هل تريد تغيير دور ${user.fullName ?? user.email} إلى $roleText؟',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              controller.updateUserRole(user.id, newRole);
              Get.back();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showToggleStatusDialog(ProfileController controller, Profile user) {
    final newStatus = user.status == 'active' ? 'banned' : 'active';
    final actionText = newStatus == 'banned' ? 'حظر' : 'فك الحظر';
    final statusText = newStatus == 'banned' ? 'محظور' : 'نشط';

    Get.dialog(
      AlertDialog(
        title: Text('$actionText المستخدم'),
        content: Text(
          'هل تريد $actionText المستخدم ${user.fullName ?? user.email}؟'
          ' سيكون حالة الحساب: $statusText',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (newStatus == 'banned') {
                controller.banUser(user.id);
              } else {
                controller.unbanUser(user.id);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'banned'
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(ProfileController controller, Profile user) {
    Get.dialog(
      AlertDialog(
        title: const Text('تفاصيل المستخدم'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserDetailItem('الاسم الكامل', user.fullName ?? 'غير محدد'),
              _buildUserDetailItem('البريد الإلكتروني', user.email),
              _buildUserDetailItem('الهاتف', user.phone ?? 'غير محدد'),
              _buildUserDetailItem('العنوان', user.address ?? 'غير محدد'),
              _buildUserDetailItem(
                'الدور',
                user.role == 'admin' ? 'مدير' : 'عميل',
              ),
              _buildUserDetailItem(
                'الحالة',
                user.status == 'active' ? 'نشط' : 'محظور',
              ),
              _buildUserDetailItem(
                'تاريخ التسجيل',
                DateFormat('dd/MM/yyyy - HH:mm').format(user.createdAt),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  Widget _buildUserDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.darkGray),
            ),
          ),
        ],
      ),
    );
  }
}
