import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../categories/views/categories_view.dart';
import '../dashboard/dashboard_page.dart';
import '../notifications/views/notifications_view.dart';
import '../orders/views/orders_view.dart';
import '../products/views/products_view.dart';
import '../reviews/views/reviews_view.dart';
import '../users/views/users_view.dart';

class MainController extends GetxController {
  static MainController get instance => Get.find();

  final _selectedIndex = 0.obs;
  final _isCollapsed = false.obs;

  int get selectedIndex => _selectedIndex.value;
  bool get isCollapsed => _isCollapsed.value;

  final List<Widget> pages = [
    DashboardView(),
    const UsersView(),
    const ProductsView(),
    const CategoriesView(),
    const OrdersView(),
    const ReviewsView(),
    const NotificationsView(),
  ];
  Widget get currentPage => pages[selectedIndex];

  void setSelectedIndex(int index) {
    _selectedIndex.value = index;
  }

  void toggleSidebar() {
    _isCollapsed.value = !_isCollapsed.value;
  }

  void collapseSidebar() {
    _isCollapsed.value = true;
  }

  void expandSidebar() {
    _isCollapsed.value = false;
  }

  void navigateToPage(int index) {
    setSelectedIndex(index);
  }
}
