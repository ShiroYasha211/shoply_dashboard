import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../controllers/orders_controller.dart';
import '../../../data/models/order_model.dart';
import '../../../themes/app_theme.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrdersController>(
      init: OrdersController(),
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
                padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 16 : 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(controller, isMobile),

                    SizedBox(height: isMobile ? 16 : 24),

                    // // Stats Cards
                    // _buildStatsCards(controller, sizingInformation),

                    // SizedBox(height: isMobile ? 16 : 24),

                    // // Filters
                    // _buildFilters(controller, sizingInformation),

                    // SizedBox(height: isMobile ? 16 : 24),
                    _buildCollapsibleSection(
                      controller,
                      sizingInformation,
                      isMobile,
                    ),

                    // Orders Table
                    Expanded(child: _buildOrdersTable(controller, isMobile)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCollapsibleSection(
    OrdersController controller,
    SizingInformation sizingInfo,
    bool isMobile,
  ) {
    return Obx(
      () => Column(
        children: [
          // زر التحكم في الطي/الفرد
          _buildCollapseToggle(controller, isMobile),

          // المحتوى (يظهر/يختفي)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: controller.areWidgetsCollapsed.value
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      SizedBox(height: isMobile ? 16 : 20),

                      // Stats Cards
                      _buildStatsCards(controller, sizingInfo),

                      SizedBox(height: isMobile ? 16 : 20),

                      // Filters
                      _buildFilters(controller, sizingInfo),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapseToggle(OrdersController controller, bool isMobile) {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 4 : 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryBrown.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller.areWidgetsCollapsed.value
                  ? Icons.expand_more
                  : Icons.expand_less,
              color: AppColors.primaryBrown,
              size: isMobile ? 18 : 20,
            ),
          ),
          title: Text(
            controller.areWidgetsCollapsed.value
                ? 'إظهار الإحصائيات والفلترة'
                : 'إخفاء الإحصائيات والفلترة',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: controller.areWidgetsCollapsed.value
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller.areWidgetsCollapsed.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              size: isMobile ? 16 : 18,
              color: controller.areWidgetsCollapsed.value
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
          onTap: () {
            controller.toggleWidgetsCollapse();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(OrdersController controller, bool isMobile) {
    return Row(
      children: [
        Text(
          'إدارة الطلبات',
          style: TextStyle(
            fontSize: isMobile ? 20 : 28,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: controller.refreshOrders,
          icon: Icon(Icons.refresh, size: isMobile ? 16 : 18),
          label: Text('تحديث', style: TextStyle(fontSize: isMobile ? 12 : 14)),
        ),
      ],
    );
  }

  Widget _buildStatsCards(
    OrdersController controller,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
    final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الطلبات',
                  controller.totalOrders.toString(),
                  AppColors.primaryBrown,
                  isMobile: isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: _buildStatCard(
                  'معلقة',
                  controller.pendingOrders.toString(),
                  AppColors.warning,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'في الطريق',
                  controller.shippedOrders.toString(),
                  AppColors.info,
                  isMobile: isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: _buildStatCard(
                  'مكتملة',
                  controller.deliveredOrders.toString(),
                  AppColors.success,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'ملغية',
                  controller.canceledOrders.toString(),
                  AppColors.error,
                  isMobile: isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(child: _buildRevenueCard(controller, isMobile)),
            ],
          ),
        ],
      );
    }

    if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الطلبات',
                  controller.totalOrders.toString(),
                  AppColors.primaryBrown,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'معلقة',
                  controller.pendingOrders.toString(),
                  AppColors.warning,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'في الطريق',
                  controller.shippedOrders.toString(),
                  AppColors.info,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'مكتملة',
                  controller.deliveredOrders.toString(),
                  AppColors.success,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'ملغية',
                  controller.canceledOrders.toString(),
                  AppColors.error,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildRevenueCard(controller, isMobile)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'إجمالي الطلبات',
            controller.totalOrders.toString(),
            AppColors.primaryBrown,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'معلقة',
            controller.pendingOrders.toString(),
            AppColors.warning,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'في الطريق',
            controller.shippedOrders.toString(),
            AppColors.info,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'مكتملة',
            controller.deliveredOrders.toString(),
            AppColors.success,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'ملغية',
            controller.canceledOrders.toString(),
            AppColors.error,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildRevenueCard(controller, isMobile)),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color, {
    required bool isMobile,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8 : 12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(OrdersController controller, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8 : 12),
        child: Column(
          children: [
            Text(
              'ر.ي ${controller.totalRevenue.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              'إجمالي الإيرادات\n(طلبات مكتملة فقط)',
              style: TextStyle(
                fontSize: isMobile ? 8 : 10,
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(
    OrdersController controller,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
    final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: isMobile
            ? Column(
                children: [
                  _buildSearchField(controller, isMobile),
                  SizedBox(height: isMobile ? 12 : 16),
                  _buildStatusFilter(controller, isMobile),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildSearchField(controller, isMobile),
                  ),
                  SizedBox(width: isTablet ? 12 : 16),
                  Expanded(child: _buildStatusFilter(controller, isMobile)),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchField(OrdersController controller, bool isMobile) {
    return TextField(
      onChanged: controller.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'بحث باسم العميل أو رقم الطلب...',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
    );
  }

  Widget _buildStatusFilter(OrdersController controller, bool isMobile) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedStatus.value,
        decoration: InputDecoration(
          labelText: 'حالة الطلب',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 16 : 20,
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
          DropdownMenuItem(value: 'pending', child: Text('معلق')),
          DropdownMenuItem(value: 'shipped', child: Text('تم الشحن')),
          DropdownMenuItem(value: 'delivered', child: Text('تم التسليم')),
          DropdownMenuItem(value: 'canceled', child: Text('ملغي')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setSelectedStatus(value);
          }
        },
      ),
    );
  }

  Widget _buildOrdersTable(OrdersController controller, bool isMobile) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBrown),
        );
      }

      final orders = controller.filteredOrders;

      if (orders.isEmpty) {
        return const Center(
          child: Text(
            'لا توجد طلبات',
            style: TextStyle(fontSize: 18, color: AppColors.darkGray),
          ),
        );
      }

      return Card(
        child: DataTable2(
          columnSpacing: isMobile ? 8 : 12,
          horizontalMargin: isMobile ? 8 : 12,
          minWidth: isMobile ? 600 : 800,
          dataRowHeight: isMobile ? 60 : 70,
          headingRowHeight: isMobile ? 50 : 60,
          columns: [
            DataColumn2(
              label: Text(
                'رقم الطلب',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text(
                'العميل',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text(
                'المبلغ',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text(
                'الحالة',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text(
                'التاريخ',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text(
                'الإجراءات',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              size: ColumnSize.L,
            ),
          ],
          rows: orders.map((order) {
            return DataRow2(
              cells: [
                DataCell(
                  Tooltip(
                    message: order.id,
                    child: Text(
                      '#${order.id.substring(0, 8)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        order.user?.fullName ?? 'غير محدد',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                      if (order.user?.email != null)
                        Text(
                          order.user!.email,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: AppColors.darkGray,
                          ),
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    'ر.ي ${order.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBrown,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: isMobile ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.statusDisplayName,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    order.createdAt != null
                        ? DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(order.createdAt!)
                        : 'غير محدد',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
                DataCell(_buildOrderActions(controller, order, isMobile)),
              ],
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildOrderActions(
    OrdersController controller,
    OrderModel order,
    bool isMobile,
  ) {
    final canShowStatusMenu =
        order.canShip || order.canDeliver || order.canCancel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر عرض التفاصيل
        IconButton(
          onPressed: () => _showOrderDetails(order),
          icon: Icon(Icons.visibility, size: isMobile ? 18 : 20),
          tooltip: 'عرض التفاصيل',
          color: AppColors.primaryBrown,
        ),

        // قائمة تغيير الحالة (تظهر فقط إذا كان هناك خيارات متاحة)
        if (canShowStatusMenu)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'shipped') {
                _showStatusConfirmation(controller, order, OrderStatus.shipped);
              } else if (value == 'delivered') {
                _showStatusConfirmation(
                  controller,
                  order,
                  OrderStatus.delivered,
                );
              } else if (value == 'canceled') {
                _showStatusConfirmation(
                  controller,
                  order,
                  OrderStatus.canceled,
                );
              }
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];

              if (order.canShip) {
                items.add(
                  PopupMenuItem(
                    value: 'shipped',
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: isMobile ? 14 : 16,
                          color: AppColors.info,
                        ),
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          'تغيير إلى "في الطريق"',
                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (order.canDeliver) {
                items.add(
                  PopupMenuItem(
                    value: 'delivered',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: isMobile ? 14 : 16,
                          color: AppColors.success,
                        ),
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          'تغيير إلى "مكتمل"',
                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (order.canCancel) {
                items.add(
                  PopupMenuItem(
                    value: 'canceled',
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          size: isMobile ? 14 : 16,
                          color: AppColors.error,
                        ),
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          'إلغاء الطلب',
                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
            child: Icon(
              Icons.more_vert,
              color: AppColors.darkGray,
              size: isMobile ? 18 : 20,
            ),
          ),

        // زر حذف الطلب
        IconButton(
          onPressed: () => _showDeleteConfirmation(controller, order),
          icon: Icon(Icons.delete, size: isMobile ? 18 : 20),
          tooltip: 'حذف الطلب',
          color: AppColors.error,
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.shipped:
        return AppColors.info;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.canceled:
        return AppColors.error;
    }
  }

  void _showStatusConfirmation(
    OrdersController controller,
    OrderModel order,
    OrderStatus newStatus,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('تغيير حالة الطلب'),
        content: Text(
          'هل تريد تغيير حالة الطلب #${order.id.substring(0, 8)} إلى "${newStatus.displayName}"؟',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              controller.updateOrderStatus(order.id, newStatus);
              Get.back();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(OrdersController controller, OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف الطلب'),
        content: Text(
          'هل تريد حذف الطلب #${order.id.substring(0, 8)}؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              controller.deleteOrder(order.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    final OrdersController controller = Get.find<OrdersController>();
    final isMobile = Get.context != null
        ? MediaQuery.of(Get.context!).size.width < 600
        : false;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: isMobile ? double.infinity : 700,
          constraints: BoxConstraints(maxHeight: isMobile ? 600 : 800),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: FutureBuilder<List<OrderItemModel>>(
            future: controller.getOrderItems(order.id),
            builder: (context, snapshot) {
              final bool isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final List<OrderItemModel> orderItems = snapshot.data ?? [];
              final double orderTotal = controller.calculateOrderTotal(
                orderItems,
              );
              final int totalItemsCount = controller.getItemsCount(orderItems);

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'فاتورة الطلب #${order.id.substring(0, 8)}',
                                style: TextStyle(
                                  fontSize: isMobile ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: isMobile ? 2 : 4),
                              Text(
                                'تاريخ الطلب: ${order.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!) : 'غير محدد'}',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.close, size: isMobile ? 20 : 24),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 12 : 16),

                    if (isLoading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBrown,
                          ),
                        ),
                      ),
                    ] else ...[
                      // Customer & Order Info in Cards
                      isMobile
                          ? Column(
                              children: [
                                // Customer Info
                                Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'معلومات العميل',
                                          style: TextStyle(
                                            fontSize: isMobile ? 14 : 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: isMobile ? 8 : 12),
                                        _buildDetailRow(
                                          'الاسم:',
                                          order.user?.fullName ?? 'غير محدد',
                                          isMobile: isMobile,
                                        ),
                                        _buildDetailRow(
                                          'البريد الإلكتروني:',
                                          order.user?.email ?? 'غير محدد',
                                          isMobile: isMobile,
                                        ),
                                        _buildDetailRow(
                                          'الهاتف:',
                                          order.user?.phone ?? 'غير محدد',
                                          isMobile: isMobile,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: isMobile ? 8 : 16),

                                // Order Info
                                Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'معلومات الطلب',
                                          style: TextStyle(
                                            fontSize: isMobile ? 14 : 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: isMobile ? 8 : 12),
                                        _buildDetailRow(
                                          'حالة الطلب:',
                                          order.statusDisplayName,
                                          isMobile: isMobile,
                                        ),
                                        _buildDetailRow(
                                          'عدد العناصر:',
                                          '$totalItemsCount عنصر',
                                          isMobile: isMobile,
                                        ),
                                        _buildDetailRow(
                                          'الإجمالي:',
                                          'ر.ي ${orderTotal.toStringAsFixed(2)}',
                                          isMobile: isMobile,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                // Customer Info
                                Expanded(
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        isMobile ? 12 : 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'معلومات العميل',
                                            style: TextStyle(
                                              fontSize: isMobile ? 14 : 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: isMobile ? 8 : 12),
                                          _buildDetailRow(
                                            'الاسم:',
                                            order.user?.fullName ?? 'غير محدد',
                                            isMobile: isMobile,
                                          ),
                                          _buildDetailRow(
                                            'البريد الإلكتروني:',
                                            order.user?.email ?? 'غير محدد',
                                            isMobile: isMobile,
                                          ),
                                          _buildDetailRow(
                                            'الهاتف:',
                                            order.user?.phone ?? 'غير محدد',
                                            isMobile: isMobile,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 8 : 16),

                                // Order Info
                                Expanded(
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        isMobile ? 12 : 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'معلومات الطلب',
                                            style: TextStyle(
                                              fontSize: isMobile ? 14 : 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: isMobile ? 8 : 12),
                                          _buildDetailRow(
                                            'حالة الطلب:',
                                            order.statusDisplayName,
                                            isMobile: isMobile,
                                          ),
                                          _buildDetailRow(
                                            'عدد العناصر:',
                                            '$totalItemsCount عنصر',
                                            isMobile: isMobile,
                                          ),
                                          _buildDetailRow(
                                            'الإجمالي:',
                                            'ر.ي ${orderTotal.toStringAsFixed(2)}',
                                            isMobile: isMobile,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // باقي الكود يبقى كما هو مع إضافة isMobile حيث يحتاج
                      // Order Items Section
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تفاصيل الفاتورة',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: isMobile ? 8 : 12),

                              // ... باقي الكود بدون تغيير مع إضافة isMobile للمسافات
                              if (orderItems.isNotEmpty) ...[
                                // Table Header
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 8 : 12,
                                    horizontal: isMobile ? 6 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGray,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'المنتج',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 12 : 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'السعر',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 12 : 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'الكمية',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 12 : 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'المجموع',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 12 : 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Order Items List
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: orderItems.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = orderItems[index];
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: isMobile ? 8 : 12,
                                        horizontal: isMobile ? 6 : 8,
                                      ),
                                      child: Row(
                                        children: [
                                          // Product Info
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.product?.name ??
                                                      'منتج محذوف',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: isMobile
                                                        ? 12
                                                        : 14,
                                                  ),
                                                ),
                                                if (item.product?.description !=
                                                    null)
                                                  Text(
                                                    item.product!.description!,
                                                    style: TextStyle(
                                                      fontSize: isMobile
                                                          ? 10
                                                          : 12,
                                                      color: AppColors.darkGray,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                if (item
                                                        .product
                                                        ?.categoryName !=
                                                    null)
                                                  Text(
                                                    'الفئة: ${item.product!.categoryName!}',
                                                    style: TextStyle(
                                                      fontSize: isMobile
                                                          ? 9
                                                          : 11,
                                                      color: AppColors.darkGray,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          // Price
                                          Expanded(
                                            child: Text(
                                              'ر.ي ${item.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: isMobile ? 12 : 14,
                                              ),
                                            ),
                                          ),

                                          // Quantity
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isMobile
                                                        ? 6
                                                        : 8,
                                                    vertical: isMobile ? 1 : 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .primaryBrown
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    item.quantity.toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors
                                                          .primaryBrown,
                                                      fontSize: isMobile
                                                          ? 11
                                                          : 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Total
                                          Expanded(
                                            child: Text(
                                              'ر.ي ${item.totalPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryBrown,
                                                fontSize: isMobile ? 12 : 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                // Total Section
                                Container(
                                  margin: EdgeInsets.only(
                                    top: isMobile ? 12 : 16,
                                  ),
                                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGray,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      // Subtotal
                                      _buildInvoiceRow(
                                        'المجموع الفرعي:',
                                        'ر.ي ${orderTotal.toStringAsFixed(2)}',
                                        isMobile: isMobile,
                                      ),
                                      SizedBox(height: isMobile ? 6 : 8),

                                      // Total
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: isMobile ? 6 : 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                        child: _buildInvoiceRow(
                                          'المبلغ الإجمالي:',
                                          'ر.ي ${orderTotal.toStringAsFixed(2)}',
                                          isTotal: true,
                                          isMobile: isMobile,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 48,
                                          color: AppColors.darkGray,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'لا توجد عناصر في هذا الطلب',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.darkGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 16 : 24),

                      // Status & Actions
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          child: Row(
                            children: [
                              // Status Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 10 : 12,
                                  vertical: isMobile ? 4 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    order.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.statusDisplayName,
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontWeight: FontWeight.w500,
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // Close Button
                              ElevatedButton(
                                onPressed: () => Get.back(),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 24 : 32,
                                    vertical: isMobile ? 10 : 12,
                                  ),
                                ),
                                child: Text(
                                  'إغلاق الفاتورة',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(
    String label,
    String value, {
    bool isTotal = false,
    required bool isMobile,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? (isMobile ? 14 : 16) : (isMobile ? 12 : 14),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? (isMobile ? 16 : 18) : (isMobile ? 12 : 14),
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primaryBrown : AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  // دالة مساعدة لعرض التفاصيل
  Widget _buildDetailRow(String label, String value, {required bool isMobile}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 2 : 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isMobile ? 80 : 100,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                  fontSize: isMobile ? 11 : 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isMobile ? 11 : 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
