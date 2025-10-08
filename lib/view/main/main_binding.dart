import 'package:dashboard_test/view/dashboard/dashboard_controller.dart';
import 'package:get/get.dart';

import '../categories/controllers/categories_controller.dart';
import '../orders/controllers/orders_controller.dart';
import '../products/controllers/products_controller.dart';
import '../users/controllers/users_controller.dart';
import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<OrdersController>(() => OrdersController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
