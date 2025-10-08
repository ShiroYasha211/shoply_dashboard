import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';

class ProductController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final products = <ProductModel>[].obs;
  final categories = <Category>[].obs;
  final subcategories = <Subcategory>[].obs;
  final isLoading = false.obs;
  final selectedProduct = Rxn<ProductModel>();

  final isGridView = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'all'.obs;
  final selectedSubcategory = 'all'.obs;
  final stockFilter = 'all'.obs;

  final selectedCategoryForAddingProduct = 'all'.obs;
  final selectedSubcategoryForAddingProduct = 'all'.obs;

  var isFilterExpanded = false.obs;

  void toggleFilterExpanded() {
    isFilterExpanded.value = !isFilterExpanded.value;
  }

  var areWidgetsCollapsed = false.obs;

  void toggleWidgetsCollapse() {
    areWidgetsCollapsed.value = !areWidgetsCollapsed.value;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      isLoading(true);
      await Future.wait([fetchAllProducts(), fetchAllCategories()]);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب البيانات: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAllCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('''
            *,
            subcategories (*)
          ''')
          .order('created_at', ascending: false);

      categories.assignAll(
        (response as List).map((item) => Category.fromJson(item)).toList(),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب الفئات: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchSubcategoriesByCategory(String categoryId) async {
    try {
      subcategories.clear();
      final response = await _supabase
          .from('subcategories')
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        subcategories.assignAll(
          response.map((item) => Subcategory.fromJson(item)).toList(),
        );
      } else {
        // إذا لم توجد تصنيفات فرعية، نترك القائمة فارغة
        subcategories.clear();
        Get.snackbar(
          'ملاحظة',
          'لا توجد تصنيفات فرعية لهذه الفئة',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }

      update();
    } catch (e) {
      print('خطأ في جلب التصنيفات الفرعية: $e');
      subcategories.clear(); // تأكد من أن القائمة فارغة في حالة الخطأ
      update();

      Get.snackbar(
        'خطأ',
        'فشل في جلب التصنيفات الفرعية',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // جلب جميع المنتجات مع الفئات
  Future<void> fetchAllProducts() async {
    try {
      isLoading(true);
      update();
      final response = await _supabase
          .from('products')
          .select('''
            *,
            subcategories (
              name,
              categories (
                name
              )
            )
          ''')
          .order('created_at', ascending: false);

      final List<ProductModel> productList = [];

      for (var item in response as List) {
        final productData = Map<String, dynamic>.from(item);

        if (item['subcategories'] != null) {
          final subcategory = item['subcategories'] as Map<String, dynamic>;
          productData['subcategory_name'] = subcategory['name'];

          if (subcategory['categories'] != null) {
            final category = subcategory['categories'] as Map<String, dynamic>;
            productData['category_name'] = category['name'];
          }
        }

        productList.add(ProductModel.fromJson(productData));
      }

      products.assignAll(productList);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب المنتجات: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
      update();
    }
  }

  // دوال البحث والتصفية
  List<ProductModel> get filteredProducts {
    List<ProductModel> filtered = products;

    // التصفية حسب البحث
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (product) =>
                product.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (product.description?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    // التصفية حسب الفئة
    if (selectedCategory.value != 'all') {
      // هنا سنحتاج لجلب المنتجات حسب الفئة من خلال التصنيفات الفرعية
      final categorySubcategories = categories
          .firstWhere((cat) => cat.id == selectedCategory.value)
          .subcategories;

      if (categorySubcategories != null) {
        final subcategoryIds = categorySubcategories
            .map((sub) => sub.id)
            .toList();
        filtered = filtered
            .where(
              (product) =>
                  product.subcategoryId != null &&
                  subcategoryIds.contains(product.subcategoryId),
            )
            .toList();
      }
    }

    // التصفية حسب التصنيف الفرعي
    if (selectedSubcategory.value != 'all') {
      filtered = filtered
          .where(
            (product) => product.subcategoryId == selectedSubcategory.value,
          )
          .toList();
    }

    // التصفية حسب المخزون
    if (stockFilter.value == 'in_stock') {
      filtered = filtered.where((product) => product.isInStock).toList();
    } else if (stockFilter.value == 'low_stock') {
      filtered = filtered.where((product) => product.isLowStock).toList();
    } else if (stockFilter.value == 'out_of_stock') {
      filtered = filtered.where((product) => product.isOutOfStock).toList();
    }

    return filtered;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    update();
  }

  void setSelectedCategory(String categoryId) {
    selectedCategory.value = categoryId;
    selectedSubcategory.value = 'all'; // إعادة تعيين التصنيف الفرعي

    if (categoryId != 'all') {
      fetchSubcategoriesByCategory(categoryId);
    } else {
      subcategories.clear();
    }

    update();
  }

  void setSelectedCategoryForAdding(String categoryId) {
    selectedCategory.value = categoryId;
    selectedSubcategory.value = 'all'; // إعادة تعيين التصنيف الفرعي

    if (categoryId != 'all') {
      fetchSubcategoriesByCategory(categoryId);
    } else {
      subcategories.clear();
    }

    update();
  }

  void setSelectedSubcategory(String subcategoryId) {
    selectedSubcategory.value = subcategoryId;
    update();
  }

  void setStockFilter(String filter) {
    stockFilter.value = filter;
    update();
  }

  // دوال إدارة المنتجات
  Future<void> addProduct(ProductModel product) async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('products')
          .insert(product.toSupabaseJson())
          .select('''
            *,
            subcategories (
              name,
              categories (
                name
              )
            )
          ''')
          .single();

      final productData = Map<String, dynamic>.from(response);

      if (response['subcategories'] != null) {
        final subcategory = response['subcategories'] as Map<String, dynamic>;
        productData['subcategory_name'] = subcategory['name'];

        if (subcategory['categories'] != null) {
          final category = subcategory['categories'] as Map<String, dynamic>;
          productData['category_name'] = category['name'];
        }
      }

      final newProduct = ProductModel.fromJson(productData);
      products.insert(0, newProduct);

      Get.back(); // إغلاق dialog الإضافة
      Get.snackbar(
        'نجاح',
        'تم إضافة المنتج بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة المنتج: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProduct(String id, ProductModel updatedProduct) async {
    try {
      isLoading(true);
      final response = await _supabase
          .from('products')
          .update(updatedProduct.toSupabaseJson())
          .eq('id', id)
          .select('''
            *,
            subcategories (
              name,
              categories (
                name
              )
            )
          ''')
          .single();

      final productData = Map<String, dynamic>.from(response);

      if (response['subcategories'] != null) {
        final subcategory = response['subcategories'] as Map<String, dynamic>;
        productData['subcategory_name'] = subcategory['name'];

        if (subcategory['categories'] != null) {
          final category = subcategory['categories'] as Map<String, dynamic>;
          productData['category_name'] = category['name'];
        }
      }

      final product = ProductModel.fromJson(productData);
      final index = products.indexWhere((p) => p.id == id);
      if (index != -1) {
        products[index] = product;
      }

      Get.back(); // إغلاق dialog التعديل
      Get.snackbar(
        'نجاح',
        'تم تحديث المنتج بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث المنتج: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // باقي الدوال كما هي...
  Future<void> deleteProduct(String id) async {
    try {
      isLoading(true);
      await _supabase.from('products').delete().eq('id', id);

      products.removeWhere((p) => p.id == id);

      Get.snackbar(
        'نجاح',
        'تم حذف المنتج بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (_isForeignKeyError(e)) {
        Get.snackbar(
          'لا يمكن الحذف',
          'لا يمكن حذف هذا المنتج لأنه مرتبط بطلبات أو عمليات بيع',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في حذف المنتج: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading(false);
    }
  }

  Map<String, int> getProductStats() {
    final total = products.length;
    final inStock = products.where((p) => p.isInStock).length;
    final lowStock = products.where((p) => p.isLowStock).length;
    final outOfStock = products.where((p) => p.isOutOfStock).length;

    return {
      'total': total,
      'in_stock': inStock,
      'low_stock': lowStock,
      'out_of_stock': outOfStock,
    };
  }

  bool _isForeignKeyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('foreign key') ||
        errorStr.contains('23503') ||
        errorStr.contains('violates foreign key');
  }
}
