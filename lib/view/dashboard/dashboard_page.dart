// views/dashboard/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;

import '../../data/models/dashboard_stats_model.dart';
import 'dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.find<DashboardController>();

  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isMediumScreen = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue, size: 22),
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading(isSmallScreen);
        }

        final stats = controller.dashboardStats.value;
        final quickStats = controller.quickStats;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقات الإحصائيات الرئيسية
              _buildMainStatsGrid(quickStats, isSmallScreen, isMediumScreen),

              const SizedBox(height: 20),

              // قسم الرسوم البيانية
              _buildChartsSection(stats, isSmallScreen),

              const SizedBox(height: 20),

              // الإحصائيات التفصيلية
              _buildDetailedStats(
                stats,
                quickStats,
                isSmallScreen,
                isMediumScreen,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShimmerLoading(bool isSmallScreen) {
    final crossAxisCount = isSmallScreen ? 2 : 3;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              // شبكة البطاقات
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: List.generate(
                  6,
                  (index) => Container(
                    height: isSmallScreen ? 80 : 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // الرسم البياني
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatsGrid(
    Map<String, dynamic> stats,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    final crossAxisCount = isSmallScreen ? 4 : (isMediumScreen ? 4 : 6);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isSmallScreen ? 0.9 : 1.1,
      children: [
        _buildModernStatCard(
          title: 'الإيرادات',
          value: '${stats['totalRevenue'].toStringAsFixed(0)}',
          subtitle: 'ريال',
          icon: Icons.attach_money_rounded,
          color: Colors.green,
          gradient: const LinearGradient(
            colors: [Color(0xFF00B894), Color(0xFF00D2A5)],
          ),
          isSmallScreen: isSmallScreen,
        ),
        _buildModernStatCard(
          title: 'الطلبات',
          value: _formatNumber(stats['totalOrders']),
          subtitle: 'طلب',
          icon: Icons.shopping_cart_rounded,
          color: Colors.blue,
          gradient: const LinearGradient(
            colors: [Color(0xFF0984E3), Color(0xFF74B9FF)],
          ),
          isSmallScreen: isSmallScreen,
        ),
        _buildModernStatCard(
          title: 'المستخدمين',
          value: _formatNumber(stats['totalUsers']),
          subtitle: 'مستخدم',
          icon: Icons.people_alt_rounded,
          color: Colors.orange,
          gradient: const LinearGradient(
            colors: [Color(0xFFE17055), Color(0xFFFFA07A)],
          ),
          isSmallScreen: isSmallScreen,
        ),
        _buildModernStatCard(
          title: 'المنتجات',
          value: _formatNumber(stats['totalProducts']),
          subtitle: 'منتج',
          icon: Icons.inventory_2_rounded,
          color: Colors.purple,
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          ),
          isSmallScreen: isSmallScreen,
        ),
        if (crossAxisCount > 3) ...[
          _buildModernStatCard(
            title: 'قيد الانتظار',
            value: _formatNumber(stats['pendingOrders']),
            subtitle: 'طلب',
            icon: Icons.pending_actions_rounded,
            color: Colors.amber,
            gradient: const LinearGradient(
              colors: [Color(0xFFFDCB6E), Color(0xFFFFEAA7)],
            ),
            isSmallScreen: isSmallScreen,
          ),
          _buildModernStatCard(
            title: 'الإكمال',
            value: '${stats['orderCompletionRate'].toStringAsFixed(1)}%',
            subtitle: 'نسبة',
            icon: Icons.check_circle_rounded,
            color: Colors.teal,
            gradient: const LinearGradient(
              colors: [Color(0xFF00CEC9), Color(0xFF81ECEC)],
            ),
            isSmallScreen: isSmallScreen,
          ),
        ],
      ],
    );
  }

  String _formatNumber(dynamic number) {
    if (number is int) {
      if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      }
      return number.toString();
    }
    return number.toString();
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ),
                if (title == 'قيد الانتظار' &&
                    int.parse(value.replaceAll('K', '')) > 0)
                  badges.Badge(
                    badgeContent: Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 8 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const SizedBox(width: 20, height: 20),
                  ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isSmallScreen ? 8 : 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(DashboardStats stats, bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تحليل الإيرادات',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedPeriod.value,

                        items: const [
                          DropdownMenuItem(value: 'week', child: Text('أسبوع')),
                          DropdownMenuItem(value: 'month', child: Text('شهر')),
                          DropdownMenuItem(value: 'year', child: Text('سنة')),
                        ],
                        onChanged: (value) =>
                            controller.setSelectedPeriod(value!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRevenueChart(stats, isSmallScreen),
            const SizedBox(height: 16),
            _buildChartLegend(stats, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(DashboardStats stats, bool isSmallScreen) {
    if (stats.revenueChart.isEmpty) {
      return SizedBox(
        height: isSmallScreen ? 180 : 200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'لا توجد بيانات متاحة',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: isSmallScreen ? 180 : 200,
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          labelRotation: -45,
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: TextStyle(fontSize: isSmallScreen ? 10 : 12),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compactCurrency(
            locale: Get.locale?.languageCode ?? 'ar',
            symbol: 'ر.ي',
          ),
          majorGridLines: const MajorGridLines(width: 1, color: Colors.grey),
          labelStyle: TextStyle(fontSize: isSmallScreen ? 10 : 12),
        ),
        series: <CartesianSeries>[
          ColumnSeries<ChartData, String>(
            dataSource: stats.revenueChart,
            xValueMapper: (ChartData data, _) => data.label,
            yValueMapper: (ChartData data, _) => data.value,
            color: const Color(0xFF0984E3),
            borderRadius: BorderRadius.circular(4),
            dataLabelSettings: DataLabelSettings(
              isVisible: !isSmallScreen,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(fontSize: isSmallScreen ? 8 : 10),
            ),
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x : point.y ريال',
        ),
      ),
    );
  }

  Widget _buildChartLegend(DashboardStats stats, bool isSmallScreen) {
    final total = stats.chartTotal;
    final maxValue = stats.maxChartValue;
    final growth = stats.weeklyGrowthRate;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          'الإجمالي',
          '${total.toStringAsFixed(0)} ريال',
          Colors.blue,
          isSmallScreen: isSmallScreen,
        ),
        _buildLegendItem(
          'الأعلى',
          '${maxValue.toStringAsFixed(0)} ريال',
          Colors.green,
          isSmallScreen: isSmallScreen,
        ),
        _buildLegendItem(
          'النمو',
          '${growth.toStringAsFixed(1)}%',
          growth >= 0 ? Colors.green : Colors.red,
          icon: growth >= 0 ? Icons.trending_up : Icons.trending_down,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String title,
    String value,
    Color color, {
    IconData? icon,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Row(
          children: [
            if (icon != null)
              Icon(icon, size: isSmallScreen ? 14 : 16, color: color),
            if (icon != null) const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(
    DashboardStats stats,
    Map<String, dynamic> quickStats,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    final crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 3 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات تفصيلية',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: isSmallScreen ? 1.4 : 1.8,
          children: [
            _buildDetailCard(
              icon: Icons.today_rounded,
              title: 'إيرادات اليوم',
              value: '${stats.todayRevenue.toStringAsFixed(0)} ريال',
              color: Colors.green,
              isSmallScreen: isSmallScreen,
            ),
            _buildDetailCard(
              icon: Icons.date_range_rounded,
              title: 'إيرادات الأسبوع',
              value: '${stats.weekRevenue.toStringAsFixed(0)} ريال',
              color: Colors.blue,
              isSmallScreen: isSmallScreen,
            ),
            _buildDetailCard(
              icon: Icons.calendar_today_rounded,
              title: 'إيرادات الشهر',
              value: '${stats.monthRevenue.toStringAsFixed(0)} ريال',
              color: Colors.purple,
              isSmallScreen: isSmallScreen,
            ),
            _buildDetailCard(
              icon: Icons.analytics_rounded,
              title: 'متوسط الطلب',
              value:
                  '${quickStats['averageOrderValue'].toStringAsFixed(0)} ريال',
              color: Colors.orange,
              isSmallScreen: isSmallScreen,
            ),
            if (crossAxisCount > 2) ...[
              _buildDetailCard(
                icon: stats.isRevenueGrowing
                    ? Icons.trending_up
                    : Icons.trending_down,
                title: 'معدل النمو',
                value: '${stats.weeklyGrowthRate.toStringAsFixed(1)}%',
                color: stats.isRevenueGrowing ? Colors.teal : Colors.red,
                isSmallScreen: isSmallScreen,
              ),
              _buildDetailCard(
                icon: Icons.warning_amber_rounded,
                title: 'منخفضة المخزون',
                value: '${quickStats['lowStockProducts']} منتج',
                color: Colors.amber,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: isSmallScreen ? 16 : 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
}
