// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const MAIN = _Paths.MAIN;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const USERS = _Paths.USERS;
  static const PRODUCTS = _Paths.PRODUCTS;
  static const CATEGORIES = _Paths.CATEGORIES;
  static const ORDERS = _Paths.ORDERS;
  static const REVIEWS = _Paths.REVIEWS;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const MAIN = '/main';
  static const DASHBOARD = '/dashboard';
  static const USERS = '/users';
  static const PRODUCTS = '/products';
  static const CATEGORIES = '/categories';
  static const ORDERS = '/orders';
  static const REVIEWS = '/reviews';
  static const NOTIFICATIONS = '/notifications';
  static const SETTINGS = '/settings';
}
