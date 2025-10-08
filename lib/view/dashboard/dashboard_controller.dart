// controllers/dashboard_mport 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/dashboard_stats_model.dart';
import '../orders/controllers/orders_controller.dart';
import '../products/controllers/products_controller.dart';
import '../users/controllers/users_controller.dart';

class DashboardController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final dashboardStats = DashboardStats().obs;
  final isLoading = false.obs;
  final selectedPeriod = 'week'.obs; // week, month, year

  // حقق في الكونترولرات الأخرى
  final OrdersController _ordersController = Get.find<OrdersController>();
  final ProductController _productController = Get.find<ProductController>();
  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();

    // الاستماع لتحديثات الكونترولرات الأخرى
    ever(_ordersController.orders, (_) => _updateStatsFromControllers());
    ever(_productController.products, (_) => _updateStatsFromControllers());
    ever(_profileController.profiles, (_) => _updateStatsFromControllers());
  }

  // جلب إحصائيات Dashboard
  Future<void> fetchDashboardStats() async {
    try {
      isLoading(true);

      // جلب البيانات من الكونترولرات الحالية
      _updateStatsFromControllers();

      // جلب البيانات الإضافية من السيرفر
      await _fetchRevenueData();
      await _fetchChartData();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب إحصائيات Dashboard: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // تحديث الإحصائيات من الكونترولرات الحالية
  Future<void> _updateStatsFromControllers() async {
    try {
      // الانتظار حتى تحميل جميع البيانات
      await Future.wait([
        if (_ordersController.orders.isEmpty)
          _ordersController.fetchAllOrders(),
        if (_productController.products.isEmpty)
          _productController.fetchAllProducts(),
        if (_profileController.profiles.isEmpty)
          _profileController.fetchAllProfiles(),
      ]);

      //final stats = dashboardStats.value;

      dashboardStats.update((val) {
        val?.totalUsers = _profileController.profiles.length;
        val?.totalProducts = _productController.products.length;
        val?.totalOrders = _ordersController.orders.length;
        val?.totalRevenue = _ordersController.totalRevenue;
        val?.pendingOrders = _ordersController.pendingOrders;
        val?.completedOrders = _ordersController.deliveredOrders;
      });
    } catch (e) {
      print('خطأ في تحديث الإحصائيات من الكونترولرات: $e');
    }
  }

  // جلب بيانات الإيرادات
  Future<void> _fetchRevenueData() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = now.subtract(const Duration(days: 7));
      final monthStart = DateTime(now.year, now.month, 1);

      // إيرادات اليوم
      final todayRevenueResponse = await _supabase
          .from('orders')
          .select('total_price')
          .eq('status', 'delivered')
          .gte('created_at', todayStart.toIso8601String());

      final todayRevenue = todayRevenueResponse.fold<double>(
        0.0,
        (sum, item) => sum + (item['total_price'] as num).toDouble(),
      );

      // إيرادات الأسبوع
      final weekRevenueResponse = await _supabase
          .from('orders')
          .select('total_price')
          .eq('status', 'delivered')
          .gte('created_at', weekStart.toIso8601String());

      final weekRevenue = weekRevenueResponse.fold<double>(
        0.0,
        (sum, item) => sum + (item['total_price'] as num).toDouble(),
      );

      // إيرادات الشهر
      final monthRevenueResponse = await _supabase
          .from('orders')
          .select('total_price')
          .eq('status', 'delivered')
          .gte('created_at', monthStart.toIso8601String());

      final monthRevenue = monthRevenueResponse.fold<double>(
        0.0,
        (sum, item) => sum + (item['total_price'] as num).toDouble(),
      );

      dashboardStats.update((val) {
        val?.todayRevenue = todayRevenue;
        val?.weekRevenue = weekRevenue;
        val?.monthRevenue = monthRevenue;
      });
    } catch (e) {
      print('خطأ في جلب بيانات الإيرادات: $e');
    }
  }

  // جلب بيانات الرسم البياني
  Future<void> _fetchChartData() async {
    try {
      final period = selectedPeriod.value;
      DateTime startDate;
      String groupBy;

      switch (period) {
        case 'week':
          startDate = DateTime.now().subtract(const Duration(days: 7));
          groupBy = 'DAY';
          break;
        case 'month':
          startDate = DateTime.now().subtract(const Duration(days: 30));
          groupBy = 'WEEK';
          break;
        case 'year':
          startDate = DateTime.now().subtract(const Duration(days: 365));
          groupBy = 'MONTH';
          break;
        default:
          startDate = DateTime.now().subtract(const Duration(days: 7));
          groupBy = 'DAY';
      }

      // استخدام RPC function في Supabase للحصول على بيانات مجمعة
      final response = await _supabase.rpc(
        'get_revenue_by_period',
        params: {
          'start_date': startDate.toIso8601String(),
          'group_by': groupBy,
        },
      );

      final chartData = (response as List).map((item) {
        return ChartData(
          date: item['period'],
          value: (item['revenue'] as num).toDouble(),
          label: _formatChartLabel(item['period'], period),
        );
      }).toList();

      dashboardStats.update((val) {
        val?.revenueChart = chartData;
      });
    } catch (e) {
      print('خطأ في جلب بيانات الرسم البياني: $e');
      // استخدام الطريقة البديلة إذا فشلت الـ RPC
      await _fetchChartDataAlternative();
    }
  }

  String _formatChartLabel(String period, String selectedPeriod) {
    if (selectedPeriod == 'week') {
      final date = DateTime.parse(period);
      return '${date.day}/${date.month}';
    } else if (selectedPeriod == 'month') {
      return 'أسبوع $period';
    } else {
      final month = int.parse(period);
      return _getMonthName(month);
    }
  }

  Future<void> _fetchChartDataAlternative() async {
    try {
      final period = selectedPeriod.value;
      DateTime startDate;

      switch (period) {
        case 'week':
          startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case 'year':
          startDate = DateTime.now().subtract(const Duration(days: 365));
          break;
        default:
          startDate = DateTime.now().subtract(const Duration(days: 7));
      }

      final response = await _supabase
          .from('orders')
          .select('created_at, total_price')
          .eq('status', 'delivered')
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: true);

      final chartData = _processChartData(response, period);

      dashboardStats.update((val) {
        val?.revenueChart = chartData;
      });
    } catch (e) {
      print('خطأ في جلب بيانات الرسم البياني البديلة: $e');
    }
  }

  // معالجة بيانات الرسم البياني
  List<ChartData> _processChartData(List<dynamic> data, String period) {
    final Map<String, double> groupedData = {};

    for (var item in data) {
      final date = DateTime.parse(item['created_at']);
      final amount = (item['total_price'] as num).toDouble();

      String key;
      // ignore: unused_local_variable
      String label;

      switch (period) {
        case 'week':
          key = '${date.day}/${date.month}';
          label = '${date.day}/${date.month}';
          break;
        case 'month':
          key = 'أسبوع ${((date.day - 1) ~/ 7) + 1}';
          label = 'أسبوع ${((date.day - 1) ~/ 7) + 1}';
          break;
        case 'year':
          key = '${date.month}/${date.year}';
          label = _getMonthName(date.month);
          break;
        default:
          key = '${date.day}/${date.month}';
          label = '${date.day}/${date.month}';
      }

      groupedData[key] = (groupedData[key] ?? 0.0) + amount;
    }

    return groupedData.entries.map((entry) {
      return ChartData(date: entry.key, value: entry.value, label: entry.key);
    }).toList();
  }

  String _getMonthName(int month) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }

  // تغيير الفترة الزمنية للرسم البياني
  void setSelectedPeriod(String period) {
    selectedPeriod.value = period;
    _fetchChartData();
  }

  // حساب نسبة النمو
  double get growthRate {
    final stats = dashboardStats.value;
    if (stats.revenueChart.length < 2) return 0.0;

    final current = stats.revenueChart.last.value;
    final previous = stats.revenueChart[stats.revenueChart.length - 2].value;

    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  // الحصول على عدد المنتجات منخفضة المخزون
  int get lowStockProducts {
    return _productController.products.where((p) => p.isLowStock).length;
  }

  // متوسط قيمة الطلب
  double get averageOrderValue {
    final stats = dashboardStats.value;
    return stats.totalOrders > 0 ? stats.totalRevenue / stats.totalOrders : 0.0;
  }

  // نسبة إكمال الطلبات
  double get orderCompletionRate {
    final stats = dashboardStats.value;
    return stats.totalOrders > 0
        ? (stats.completedOrders / stats.totalOrders) * 100
        : 0.0;
  }

  // تحديث البيانات
  Future<void> refreshData() async {
    await fetchDashboardStats();
  }

  // إحصائيات سريعة للبطاقات
  Map<String, dynamic> get quickStats {
    final stats = dashboardStats.value;

    return {
      'totalRevenue': stats.totalRevenue,
      'totalOrders': stats.totalOrders,
      'totalUsers': stats.totalUsers,
      'totalProducts': stats.totalProducts,
      'pendingOrders': stats.pendingOrders,
      'completedOrders': stats.completedOrders,
      'lowStockProducts': lowStockProducts,
      'todayRevenue': stats.todayRevenue,
      'growthRate': growthRate,
      'averageOrderValue': averageOrderValue,
      'orderCompletionRate': orderCompletionRate,
    };
  }
}
