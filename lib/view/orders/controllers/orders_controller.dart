import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/order_model.dart';

class OrdersController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final selectedOrder = Rxn<OrderModel>();

  // فلاتر البحث والتصفية
  final searchQuery = ''.obs;
  final selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
  }

  // جلب جميع الطلبات مع بيانات المستخدم والعناصر

  Future<void> fetchAllOrders() async {
    try {
      isLoading(true);

      final response = await _supabase
          .from('orders')
          .select('''
            *,
            profiles!user_id (*),
            order_items (
              *,
              products (*)
            )
          ''')
          .order('created_at', ascending: false);

      orders.assignAll(
        response.map((item) => OrderModel.fromJson(item)).toList(),
      );

      update(); // ✅ إضافة تحديث للإحصائيات
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب الطلبات: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // تحديث حالة الطلب
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      isLoading(true);

      final response = await _supabase
          .from('orders')
          .update({'status': newStatus.value})
          .eq('id', orderId)
          .select('''
            *,
            profiles!user_id (*),
            order_items (
              *,
              products (*)
            )
          ''')
          .single();

      final updatedOrder = OrderModel.fromJson(response);
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        orders[index] = updatedOrder;
      }

      update(); // ✅ تحديث للإحصائيات
      Get.snackbar(
        'نجاح',
        'تم تحديث حالة الطلب إلى ${newStatus.displayName}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث حالة الطلب: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading(false);
    }
  }

  // حذف طلب - معدل بشكل صحيح
  Future<bool> deleteOrder(String orderId) async {
    try {
      isLoading(true);

      // استخدام transaction لحذف الطلب وعناصره
      final result = await _supabase.rpc(
        'delete_order_with_items',
        params: {'order_id': orderId},
      );

      if (result != null) {
        orders.removeWhere((order) => order.id == orderId);
        update(); // ✅ تحديث للإحصائيات

        Get.snackbar(
          'نجاح',
          'تم حذف الطلب بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      // إذا فشلت الـ RPC، نستخدم الطريقة التقليدية
      return await _deleteOrderTraditional(orderId);
    } finally {
      isLoading(false);
    }
  }

  // الطريقة التقليدية لحذف الطلب
  Future<bool> _deleteOrderTraditional(String orderId) async {
    try {
      // حذف عناصر الطلب أولاً
      await _supabase.from('order_items').delete().eq('order_id', orderId);

      // ثم حذف الطلب
      await _supabase.from('orders').delete().eq('id', orderId);

      orders.removeWhere((order) => order.id == orderId);
      update(); // ✅ تحديث للإحصائيات

      Get.snackbar(
        'نجاح',
        'تم حذف الطلب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      if (_isForeignKeyError(e)) {
        Get.snackbar(
          'لا يمكن الحذف',
          'لا يمكن حذف هذا الطلب لأنه مرتبط بعمليات أخرى',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في حذف الطلب: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }
  }

  // دوال البحث والتصفية
  List<OrderModel> get filteredOrders {
    try {
      List<OrderModel> filtered = List<OrderModel>.from(orders);

      // التصفية حسب البحث
      if (searchQuery.isNotEmpty) {
        final searchTerm = searchQuery.value.toLowerCase();
        filtered = filtered.where((order) {
          return order.user?.fullName?.toLowerCase().contains(searchTerm) ??
              false ||
                  order.id.toLowerCase().contains(searchTerm) ||
                  (order.user?.email.toLowerCase().contains(searchTerm) ??
                      false);
        }).toList();
      }

      // التصفية حسب الحالة
      if (selectedStatus.value != 'all') {
        filtered = filtered
            .where((order) => order.status.value == selectedStatus.value)
            .toList();
      }

      return filtered;
    } catch (e) {
      print('خطأ في تصفية الطلبات: $e');
      return List<OrderModel>.from(orders);
    }
  }

  // دوال إدارة الفلاتر
  void setSearchQuery(String query) {
    searchQuery.value = query.trim();
    update();
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
    update();
  }

  // إحصائيات الطلبات - يتم تحديثها تلقائياً
  int get totalOrders => orders.length;
  int get pendingOrders =>
      orders.where((o) => o.status == OrderStatus.pending).length;
  int get shippedOrders =>
      orders.where((o) => o.status == OrderStatus.shipped).length;
  int get deliveredOrders =>
      orders.where((o) => o.status == OrderStatus.delivered).length;
  int get canceledOrders =>
      orders.where((o) => o.status == OrderStatus.canceled).length;

  // الحصول على إجمالي الإيرادات من الطلبات المكتملة فقط
  double get totalRevenue {
    try {
      return orders
          .where((order) => order.status == OrderStatus.delivered)
          .fold(0.0, (sum, order) => sum + order.totalPrice);
    } catch (e) {
      return 0.0;
    }
  }

  // دوال التحكم بحالة الطلب
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.canceled);
  }

  Future<bool> shipOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.shipped);
  }

  Future<bool> deliverOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.delivered);
  }

  // إعادة تعيين الفلاتر
  void resetFilters() {
    searchQuery.value = '';
    selectedStatus.value = 'all';
    update();
  }

  // دالة التحديث
  Future<void> refreshOrders() async {
    await fetchAllOrders();
  }

  // التحقق من أخطاء المفتاح الخارجي
  bool _isForeignKeyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('foreign key') ||
        errorStr.contains('23503') ||
        errorStr.contains('violates foreign key');
  }

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    // التحقق من صحة orderId
    if (orderId.isEmpty) {
      print('❌ orderId فارغ');
      return [];
    }

    try {
      print('🔍 جلب عناصر الطلب: ${orderId.substring(0, 8)}...');

      // الاستعلام المبسط
      final response = await _supabase
          .from('order_items')
          .select('''
          id, order_id, product_id, quantity, price,
          products:product_id (id, name, description, price, image_url)
        ''')
          .eq('order_id', orderId);

      // معالجة النتيجة
      if (response.isNotEmpty) {
        final items = response
            .map((item) {
              try {
                return OrderItemModel.fromJson(item);
              } catch (e) {
                print('⚠️ خطأ في تحويل العنصر: $e - البيانات: $item');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<OrderItemModel>()
            .toList();

        print('✅ تم جلب ${items.length} عنصر بنجاح');
        return items;
      } else {
        print('ℹ️ لا توجد عناصر للطلب');
        return [];
      }
    } catch (e) {
      print('❌ خطأ في جلب عناصر الطلب: $e');

      // عدم عرض snackbar هنا (يتم التعامل معه في الواجهة)
      return [];
    }
  }

  Future<OrderModel?> getOrderWithItems(String orderId) async {
    try {
      final response = await _supabase.rpc(
        'get_order_with_items',
        params: {'order_id': orderId},
      );

      if (response != null) {
        // معالجة البيانات المرجعة من RPC
        final orderData = Map<String, dynamic>.from(response);
        return OrderModel.fromJson(orderData);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب الطلب عبر RPC: $e');
      return await getOrderWithItems(orderId); // الرجوع للطريقة العادية
    }
  }

  // حساب إجمالي عناصر الطلب
  double calculateOrderTotal(List<OrderItemModel> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // الحصول على عدد العناصر في الطلب
  int getItemsCount(List<OrderItemModel> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
