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
          child: CircularProgressIndicator(color: AppColors.primaryBrown),
        );
      }

      final users = controller.filteredUsers;

      if (users.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: AppColors.darkGray),
              SizedBox(height: 16),
              Text(
                'لا يوجد مستخدمين',
                style: const TextStyle(fontSize: 16, color: AppColors.darkGray),
              ),
              SizedBox(height: 8),
              Text(
                'جرب تغيير عوامل التصفية',
                style: TextStyle(fontSize: 14, color: AppColors.darkGray),
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
              backgroundColor: AppColors.lightGray,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      color: AppColors.primaryBrown,
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
              color: AppColors.lightGray,
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (value) =>
                  _handleMobileUserAction(value, user, controller),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'change_role',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, size: 16),
                      SizedBox(width: 8),
                      Text('تغيير الدور'),
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
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16),
                      SizedBox(width: 8),
                      Text('عرض التفاصيل'),
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
                      backgroundColor: AppColors.lightGray,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              color: AppColors.primaryBrown,
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
                        ? AppColors.primaryBrown.withOpacity(0.1)
                        : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role == 'admin' ? 'مدير' : 'عميل',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.role == 'admin'
                          ? AppColors.primaryBrown
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
                            : AppColors.primaryBrown,
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
                      color: AppColors.lightGray,
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

  void _showChangeRoleDialog(ProfileController controller, Profile user) {
    final newRole = user.role == 'admin' ? 'customer' : 'admin';
    final roleText = newRole == 'admin' ? 'مدير' : 'عميل';
    final currentRoleText = user.role == 'admin' ? 'مدير' : 'عميل';
    final icon = newRole == 'admin' ? Icons.admin_panel_settings : Icons.person;
    final color = newRole == 'admin' ? Colors.orange : Colors.blue;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 340,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 30, color: color),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      'تغيير الدور',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // User info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName ?? user.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Role change visualization
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Current role
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                user.role == 'admin'
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                size: 24,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentRoleText,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'الدور الحالي',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),

                        // Arrow
                        Column(
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                        // New role
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, size: 24, color: color),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              roleText,
                              style: TextStyle(
                                fontSize: 14,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'الدور الجديد',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Warning message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.orange.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'سيتم تغيير صلاحيات المستخدم فور التأكيد',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Confirm Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.updateUserRole(user.id, newRole);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'تأكيد التغيير',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.swap_horiz_rounded, size: 18),
                          ],
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
      barrierDismissible: true,
    );
  }

  void _showToggleStatusDialog(ProfileController controller, Profile user) {
    final newStatus = user.status == 'active' ? 'banned' : 'active';
    final actionText = newStatus == 'banned' ? 'حظر' : 'فك الحظر';
    final statusText = newStatus == 'banned' ? 'محظور' : 'نشط';
    final icon = newStatus == 'banned'
        ? Icons.block_rounded
        : Icons.check_circle_rounded;
    final color = newStatus == 'banned' ? Colors.red : Colors.green;
    final currentStatusText = user.status == 'active' ? 'نشط' : 'محظور';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 360,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 35, color: color),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      actionText == 'حظر' ? 'حظر المستخدم' : 'فك حظر المستخدم',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // User info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: user.status == 'active'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              user.status == 'active'
                                  ? Icons.person_rounded
                                  : Icons.block_rounded,
                              color: user.status == 'active'
                                  ? Colors.green
                                  : Colors.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName ?? user.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: user.status == 'active'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: user.status == 'active'
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              currentStatusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: user.status == 'active'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Status change visualization
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: color,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  actionText == 'حظر'
                                      ? 'سيتم حظر هذا المستخدم'
                                      : 'سيتم فك حظر هذا المستخدم',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  actionText == 'حظر'
                                      ? 'لن يتمكن من تسجيل الدخول أو استخدام الخدمة حتى يتم فك الحظر'
                                      : 'سيتمكن من تسجيل الدخول واستخدام الخدمة بشكل طبيعي',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Status change arrow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currentStatusText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: color,
                            size: 20,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Buttons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Action Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (newStatus == 'banned') {
                            controller.banUser(user.id);
                          } else {
                            controller.unbanUser(user.id);
                          }
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              actionText == 'حظر'
                                  ? Icons.block_rounded
                                  : Icons.lock_open_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              actionText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
      barrierDismissible: true,
    );
  }

  void _showUserDetails(ProfileController controller, Profile user) {
    final roleText = user.role == 'admin' ? 'مدير' : 'عميل';
    final statusText = user.status == 'active' ? 'نشط' : 'محظور';
    final statusColor = user.status == 'active' ? Colors.green : Colors.red;
    final roleColor = user.role == 'admin' ? Colors.orange : Colors.blue;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // User Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        user.role == 'admin'
                            ? Icons.admin_panel_settings_rounded
                            : Icons.person_rounded,
                        size: 30,
                        color: roleColor,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName ?? 'بدون اسم',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Personal Information Section
                      _buildSectionHeader(
                        icon: Icons.person_outline_rounded,
                        title: 'المعلومات الشخصية',
                      ),
                      _buildUserDetailCard(
                        items: [
                          _buildDetailItemWithIcon(
                            icon: Icons.person_rounded,
                            label: 'الاسم الكامل',
                            value: user.fullName ?? 'غير محدد',
                            iconColor: Colors.blue,
                          ),
                          _buildDetailItemWithIcon(
                            icon: Icons.phone_rounded,
                            label: 'رقم الهاتف',
                            value: user.phone ?? 'غير محدد',
                            iconColor: Colors.green,
                          ),
                          _buildDetailItemWithIcon(
                            icon: Icons.location_on_rounded,
                            label: 'العنوان',
                            value: user.address ?? 'غير محدد',
                            iconColor: Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Account Information Section
                      _buildSectionHeader(
                        icon: Icons.account_circle_rounded,
                        title: 'معلومات الحساب',
                      ),
                      _buildUserDetailCard(
                        items: [
                          _buildDetailItemWithIcon(
                            icon: Icons.email_rounded,
                            label: 'البريد الإلكتروني',
                            value: user.email,
                            iconColor: Colors.purple,
                          ),
                          _buildDetailItemWithIcon(
                            icon: Icons.workspace_premium_rounded,
                            label: 'الدور',
                            value: roleText,
                            iconColor: roleColor,
                            valueColor: roleColor,
                          ),
                          _buildDetailItemWithIcon(
                            icon: Icons.calendar_today_rounded,
                            label: 'تاريخ التسجيل',
                            value: DateFormat(
                              'dd/MM/yyyy - HH:mm',
                            ).format(user.createdAt),
                            iconColor: Colors.teal,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User ID
                    // Text(
                    //   'ID: ${user.id}',
                    //   style: TextStyle(
                    //     fontSize: 8,
                    //     color: Colors.grey.shade500,
                    //     fontFamily: 'monospace',
                    //   ),
                    // ),

                    // Close Button
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.charcoal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'إغلاق',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.close_rounded, size: 18),
                          ],
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
      barrierDismissible: true,
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.charcoal),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailCard({required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildDetailItemWithIcon({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.charcoal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
