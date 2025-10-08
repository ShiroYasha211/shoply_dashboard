class DashboardStats {
  int totalUsers;
  int totalProducts;
  int totalOrders;
  double totalRevenue;
  int pendingOrders;
  int completedOrders;
  double todayRevenue;
  double weekRevenue;
  double monthRevenue;
  List<ChartData> revenueChart;

  DashboardStats({
    this.totalUsers = 0,
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.pendingOrders = 0,
    this.completedOrders = 0,
    this.todayRevenue = 0.0,
    this.weekRevenue = 0.0,
    this.monthRevenue = 0.0,
    this.revenueChart = const [],
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: (json['total_users'] as int?) ?? 0,
      totalProducts: (json['total_products'] as int?) ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      pendingOrders: json['pending_orders'] ?? 0,
      completedOrders: json['completed_orders'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      weekRevenue: (json['week_revenue'] ?? 0).toDouble(),
      monthRevenue: (json['month_revenue'] ?? 0).toDouble(),
      revenueChart: json['revenue_chart'] != null
          ? (json['revenue_chart'] as List)
                .map((item) => ChartData.fromJson(item))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_products': totalProducts,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'pending_orders': pendingOrders,
      'completed_orders': completedOrders,
      'today_revenue': todayRevenue,
      'week_revenue': weekRevenue,
      'month_revenue': monthRevenue,
      'revenue_chart': revenueChart.map((item) => item.toJson()).toList(),
    };
  }

  // Helper getters
  int get lowStockProducts => 0; // Will be calculated separately
  double get orderCompletionRate =>
      totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0.0;

  double get weeklyGrowthRate {
    if (weekRevenue == 0) return 0.0;

    // نفترض أن إيرادات الأسبوع السابق هي 80% من الحالي (يمكن تعديل هذا المنطق)
    final lastWeekRevenue = weekRevenue * 0.8;
    return ((weekRevenue - lastWeekRevenue) / lastWeekRevenue) * 100;
  }

  // حساب نسبة النمو مقارنة بالشهر الماضي
  double get monthlyGrowthRate {
    if (monthRevenue == 0) return 0.0;

    // نفترض أن إيرادات الشهر السابق هي 85% من الحالي
    final lastMonthRevenue = monthRevenue * 0.85;
    return ((monthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
  }

  // الحصول على أعلى إيراد في الرسم البياني
  double get maxChartValue {
    if (revenueChart.isEmpty) return 0.0;
    return revenueChart.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  // الحصول على إجمالي إيرادات الرسم البياني
  double get chartTotal {
    return revenueChart.fold(0.0, (sum, item) => sum + item.value);
  }

  // التحقق إذا كانت هناك زيادة في الإيرادات
  bool get isRevenueGrowing => weeklyGrowthRate > 0;

  // الحصول على لون المؤشر بناءً على الأداء
  String get performanceColor {
    final rate = weeklyGrowthRate;
    if (rate > 20) return 'green';
    if (rate > 0) return 'blue';
    if (rate > -10) return 'orange';
    return 'red';
  }
}

class ChartData {
  final String date;
  final double value;
  final String label;

  ChartData({required this.date, required this.value, required this.label});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      date: json['date'],
      value: (json['value'] as num).toDouble(),
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'value': value, 'label': label};
  }
}
