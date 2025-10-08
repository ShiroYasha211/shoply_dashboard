import 'package:dashboard_test/view/categories/bindings/categories_binding.dart';
import 'package:dashboard_test/view/categories/views/categories_view.dart';
import 'package:dashboard_test/view/login/login_binding.dart';
import 'package:dashboard_test/view/login/login_page.dart';
import 'package:dashboard_test/view/users/bindings/users_binding.dart';
import 'package:dashboard_test/view/users/views/users_view.dart';
import 'package:get/get.dart';

import '../core/middleware/auth_middleware.dart';
import '../view/dashboard/dashboard_binding.dart';
import '../view/dashboard/dashboard_page.dart';
import '../view/main/main_binding.dart';
import '../view/main/main_page.dart';
import '../view/notifications/bindings/notifications_binding.dart';
import '../view/notifications/views/notifications_view.dart';
import '../view/orders/bindings/orders_binding.dart';
import '../view/orders/views/orders_view.dart';
import '../view/products/bindings/products_binding.dart';
import '../view/products/views/products_view.dart';
import '../view/reviews/bindings/reviews_binding.dart';
import '../view/reviews/views/reviews_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.USERS,
      page: () => const UsersView(),
      binding: UsersBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PRODUCTS,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.CATEGORIES,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.REVIEWS,
      page: () => const ReviewsView(),
      binding: ReviewsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
