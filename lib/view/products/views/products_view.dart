import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/image_upload_service.dart';
import '../../../themes/app_theme.dart';
import '../controllers/products_controller.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      init: ProductController(),
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

                    // Stats Cards
                    _buildStatsCards(controller, sizingInformation),

                    SizedBox(height: isMobile ? 16 : 24),

                    // Filters
                    _buildFilters(controller, sizingInformation),

                    SizedBox(height: isMobile ? 16 : 24),

                    // Products Grid/List
                    Expanded(
                      child: _buildProductsList(controller, sizingInformation),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddProductDialog(controller),
            backgroundColor: AppColors.primaryGreen,
            icon: const Icon(Icons.add, color: AppColors.white, size: 24),
            label: const Text(
              'إضافة منتج',
              style: const TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ProductController controller, bool isMobile) {
    return Row(
      children: [
        Text(
          'إدارة المنتجات',
          style: TextStyle(
            fontSize: isMobile ? 20 : 28,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        const Spacer(),
        // View Mode Toggle
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => controller.isGridView.value = true,
                  icon: Icon(
                    Icons.grid_view,
                    size: isMobile ? 18 : 24,
                    color: controller.isGridView.value
                        ? AppColors.primaryGreen
                        : AppColors.darkGray,
                  ),
                  tooltip: 'عرض شبكي',
                ),
                IconButton(
                  onPressed: () => controller.isGridView.value = false,
                  icon: Icon(
                    Icons.list,
                    size: isMobile ? 18 : 24,
                    color: !controller.isGridView.value
                        ? AppColors.primaryGreen
                        : AppColors.darkGray,
                  ),
                  tooltip: 'عرض قائمة',
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: isMobile ? 8 : 16),
        ElevatedButton.icon(
          onPressed: controller.fetchAllProducts,
          icon: Icon(Icons.refresh, size: isMobile ? 16 : 18),
          label: Text('تحديث', style: TextStyle(fontSize: isMobile ? 12 : 14)),
        ),
      ],
    );
  }

  Widget _buildStatsCards(
    ProductController controller,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
    final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;
    final stats = controller.getProductStats();

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'إجمالي المنتجات',
                  value: stats['total']?.toString() ?? '0',
                  icon: Icons.inventory_2,
                  color: AppColors.primaryGreen,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  title: 'في المخزون',
                  value: stats['in_stock']?.toString() ?? '0',
                  icon: Icons.check_circle,
                  color: AppColors.success,
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
                  title: 'مخزون منخفض',
                  value: stats['low_stock']?.toString() ?? '0',
                  icon: Icons.warning,
                  color: AppColors.warning,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  title: 'نفد المخزون',
                  value: stats['out_of_stock']?.toString() ?? '0',
                  icon: Icons.error,
                  color: AppColors.error,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'إجمالي المنتجات',
              value: stats['total']?.toString() ?? '0',
              icon: Icons.inventory_2,
              color: AppColors.primaryGreen,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              title: 'في المخزون',
              value: stats['in_stock']?.toString() ?? '0',
              icon: Icons.check_circle,
              color: AppColors.success,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              title: 'مخزون منخفض',
              value: stats['low_stock']?.toString() ?? '0',
              icon: Icons.warning,
              color: AppColors.warning,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              title: 'نفد المخزون',
              value: stats['out_of_stock']?.toString() ?? '0',
              icon: Icons.error,
              color: AppColors.error,
              isMobile: isMobile,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'إجمالي المنتجات',
            value: stats['total']?.toString() ?? '0',
            icon: Icons.inventory_2,
            color: AppColors.primaryGreen,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'في المخزون',
            value: stats['in_stock']?.toString() ?? '0',
            icon: Icons.check_circle,
            color: AppColors.success,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'مخزون منخفض',
            value: stats['low_stock']?.toString() ?? '0',
            icon: Icons.warning,
            color: AppColors.warning,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'نفد المخزون',
            value: stats['out_of_stock']?.toString() ?? '0',
            icon: Icons.error,
            color: AppColors.error,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isMobile,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isMobile ? 20 : 24),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 4 : 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(
    ProductController controller,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
    final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          children: [
            if (isMobile) ...[
              _buildSearchField(controller, isMobile),
              const SizedBox(height: 12),
              _buildCategoryFilter(controller, isMobile),
              const SizedBox(height: 12),
              _buildSubcategoryFilter(controller, isMobile),
              const SizedBox(height: 12),
              _buildStockFilter(controller, isMobile),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildSearchField(controller, isMobile),
                  ),
                  SizedBox(width: isTablet ? 12 : 16),
                  Expanded(child: _buildCategoryFilter(controller, isMobile)),
                  SizedBox(width: isTablet ? 12 : 16),
                  Expanded(
                    child: _buildSubcategoryFilter(controller, isMobile),
                  ),
                  SizedBox(width: isTablet ? 12 : 16),
                  Expanded(child: _buildStockFilter(controller, isMobile)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ProductController controller, bool isMobile) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedCategory.value,
        decoration: InputDecoration(
          labelText: 'الفئة',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 16 : 20,
          ),
        ),
        items: [
          const DropdownMenuItem(value: 'all', child: Text('جميع الفئات')),
          ...controller.categories
              .map(
                (category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
              .toList(),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setSelectedCategory(value);
          }
        },
      ),
    );
  }

  Widget _buildSubcategoryFilter(ProductController controller, bool isMobile) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedSubcategory.value,
        decoration: InputDecoration(
          labelText: 'التصنيف الفرعي',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 16 : 20,
          ),
        ),
        items: [
          DropdownMenuItem(
            value: 'all',
            child: Text(
              controller.selectedCategory.value == 'all'
                  ? 'اختر الفئة أولاً'
                  : 'جميع التصنيفات الفرعية',
            ),
          ),
          ...controller.subcategories
              .map(
                (subcategory) => DropdownMenuItem(
                  value: subcategory.id,
                  child: Text(subcategory.name),
                ),
              )
              .toList(),
        ],
        onChanged: controller.selectedCategory.value == 'all'
            ? null
            : (value) {
                if (value != null) {
                  controller.setSelectedSubcategory(value);
                }
              },
      ),
    );
  }

  Widget _buildCategoryFilterForAdding(
    ProductController controller, {
    Function? selectedCategory,
    required bool isMobile,
  }) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedCategoryForAddingProduct.value,
        decoration: InputDecoration(
          labelText: 'الفئة',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 16 : 20,
          ),
        ),
        items: [
          const DropdownMenuItem(value: 'all', child: Text('جميع الفئات')),
          ...controller.categories
              .map(
                (category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
              .toList(),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setSelectedCategoryForAdding(value);
            selectedCategory?.call(value);
          }
        },
      ),
    );
  }

  Widget _buildSubcategoryFilterForAdding(
    ProductController controller, {
    Function? selectedSubcategory,
    required bool isMobile,
  }) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedSubcategory.value,
        decoration: InputDecoration(
          labelText: 'التصنيف الفرعي',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 16 : 20,
          ),
        ),
        items: [
          DropdownMenuItem(
            value: 'all',
            child: Text(
              controller.selectedCategory.value == 'all'
                  ? 'اختر الفئة أولاً'
                  : 'جميع التصنيفات الفرعية',
            ),
          ),
          ...controller.subcategories
              .map(
                (subcategory) => DropdownMenuItem(
                  value: subcategory.id,
                  child: Text(subcategory.name),
                ),
              )
              .toList(),
        ],
        onChanged: controller.selectedCategory.value == 'all'
            ? null
            : (value) {
                if (value != null) {
                  selectedSubcategory?.call(value);
                }
              },
      ),
    );
  }

  Widget _buildSearchField(ProductController controller, bool isMobile) {
    return TextField(
      onChanged: controller.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'بحث عن منتج...',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
    );
  }

  Widget _buildStockFilter(ProductController controller, bool isMobile) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.stockFilter.value,
        decoration: InputDecoration(
          labelText: 'حالة المخزون',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 16 : 20,
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('جميع المنتجات')),
          DropdownMenuItem(value: 'in_stock', child: Text('متوفر في المخزون')),
          DropdownMenuItem(value: 'low_stock', child: Text('مخزون منخفض')),
          DropdownMenuItem(value: 'out_of_stock', child: Text('نفد المخزون')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.setStockFilter(value);
          }
        },
      ),
    );
  }

  Widget _buildProductsList(
    ProductController controller,
    SizingInformation sizingInfo,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        );
      }

      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return const Center(
          child: Text(
            'لا توجد منتجات',
            style: TextStyle(fontSize: 18, color: AppColors.darkGray),
          ),
        );
      }

      if (controller.isGridView.value) {
        return _buildGridView(controller, sizingInfo, products);
      } else {
        return _buildListView(controller, products, sizingInfo);
      }
    });
  }

  Widget _buildGridView(
    ProductController controller,
    SizingInformation sizingInfo,
    List<ProductModel> products,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
    final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;

    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 8 : 16,
        mainAxisSpacing: isMobile ? 8 : 16,
        childAspectRatio: isMobile ? 0.7 : (isTablet ? 0.8 : 0.75),
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, controller, isMobile);
      },
    );
  }

  Widget _buildListView(
    ProductController controller,
    List<ProductModel> products,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductListItem(product, controller, isMobile);
      },
    );
  }

  Widget _buildProductCard(
    ProductModel product,
    ProductController controller,
    bool isMobile,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                color: AppColors.lightGray,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: AppColors.darkGray,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: AppColors.darkGray,
                        ),
                      ),
              ),
            ),
          ),

          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 12 : 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isMobile ? 2 : 4),

                  // Category
                  Text(
                    product.categoryName ?? 'بدون تصنيف',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: AppColors.darkGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isMobile ? 4 : 8),

                  // Price and Stock
                  Row(
                    children: [
                      Text(
                        'ر.ي ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 14 : 16,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 4 : 6,
                          vertical: isMobile ? 1 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.isInStock
                              ? product.isLowStock
                                    ? AppColors.warning.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.stockQuantity.toString(),
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 10,
                            color: product.isInStock
                                ? product.isLowStock
                                      ? AppColors.warning
                                      : AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 4 : 8),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showEditProductDialog(controller, product),
                          icon: Icon(Icons.edit, size: isMobile ? 14 : 16),
                          label: Text(
                            'تعديل',
                            style: TextStyle(fontSize: isMobile ? 10 : 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            side: const BorderSide(
                              color: AppColors.primaryGreen,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 6 : 8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 4 : 8),
                      IconButton(
                        onPressed: () {
                          _showDeleteConfirmation(controller, product);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: isMobile ? 18 : 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(
    ProductModel product,
    ProductController controller,
    bool isMobile,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: isMobile ? 60 : 80,
              height: isMobile ? 60 : 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.lightGray,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          color: AppColors.darkGray,
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: AppColors.darkGray,
                      ),
              ),
            ),

            SizedBox(width: isMobile ? 8 : 16),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    '${product.categoryName ?? ''} ${product.subcategoryName != null ? '- ${product.subcategoryName}' : ''}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: AppColors.darkGray,
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 8),
                  Row(
                    children: [
                      Text(
                        'ر.ي ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: isMobile ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.isInStock
                              ? product.isLowStock
                                    ? AppColors.warning.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'المخزون: ${product.stockQuantity}',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: product.isInStock
                                ? product.isLowStock
                                      ? AppColors.warning
                                      : AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: isMobile ? 8 : 16),

            // Actions
            Column(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showEditProductDialog(controller, product),
                  icon: Icon(Icons.edit, size: isMobile ? 14 : 16),
                  label: Text(
                    'تعديل',
                    style: TextStyle(fontSize: isMobile ? 10 : 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 12,
                      vertical: isMobile ? 6 : 8,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 8),
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmation(controller, product);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.error,
                    size: isMobile ? 18 : 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    ProductController controller,
    ProductModel product,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف منتج'),
        content: Text(
          'هل تريد حذف "${product.name}"؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              controller.deleteProduct(product.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(ProductController controller) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    String? selectedCategoryId;
    String? selectedSubcategoryId;
    File? selectedImage;
    bool isUploading = false;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'إضافة منتج جديد',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // صورة المنتج
                      _buildImageUploadSection(
                        selectedImage: selectedImage,
                        onImageSelected: (image) => selectedImage = image,
                        isUploading: isUploading,
                      ),
                      const SizedBox(height: 24),

                      // معلومات المنتج
                      _buildProductInfoSection(
                        nameController: nameController,
                        descriptionController: descriptionController,
                        priceController: priceController,
                        stockController: stockController,
                      ),
                      const SizedBox(height: 24),

                      // الفئة والتصنيف الفرعي
                      _buildCategoryFilterForAdding(
                        isMobile: false,
                        controller,
                        selectedCategory: (value) {
                          selectedCategoryId = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSubcategoryFilterForAdding(
                        isMobile: false,
                        controller,
                        selectedSubcategory: (value) {
                          selectedSubcategoryId = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.primaryGreen),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(color: AppColors.primaryGreen),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  if (_validateProductForm(
                                    nameController.text,
                                    priceController.text,
                                    stockController.text,
                                    selectedCategoryId,
                                    selectedSubcategoryId,
                                  )) {
                                    isUploading = true;

                                    String? imageUrl;
                                    if (selectedImage != null) {
                                      final fileName =
                                          'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                      imageUrl =
                                          await ImageUploadService.uploadImage(
                                            selectedImage!,
                                            fileName,
                                          );
                                    }

                                    final newProduct = ProductModel(
                                      id: '',
                                      subcategoryId: selectedSubcategoryId,
                                      name: nameController.text,
                                      description:
                                          descriptionController.text.isEmpty
                                          ? null
                                          : descriptionController.text,
                                      price: double.parse(priceController.text),
                                      stockQuantity: int.parse(
                                        stockController.text,
                                      ),
                                      imageUrl: imageUrl,
                                      createdAt: DateTime.now(),
                                    );

                                    await controller.addProduct(newProduct);
                                    isUploading = false;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'إضافة المنتج',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProductDialog(
    ProductController controller,
    ProductModel product,
  ) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(
      text: product.description ?? '',
    );
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final stockController = TextEditingController(
      text: product.stockQuantity.toString(),
    );

    String? selectedCategoryId;
    String? selectedSubcategoryId = product.subcategoryId;
    File? selectedImage;
    String? currentImageUrl = product.imageUrl;
    bool isUploading = false;

    // البحث عن الفئة الحالية للمنتج
    if (product.subcategoryId != null) {
      for (var category in controller.categories) {
        if (category.subcategories != null) {
          final subcategory = category.subcategories!.firstWhere(
            (sub) => sub.id == product.subcategoryId,
            orElse: () => Subcategory(
              id: '',
              categoryId: '',
              name: '',
              createdAt: DateTime.now(),
            ),
          );
          if (subcategory.id.isNotEmpty) {
            selectedCategoryId = category.id;
            break;
          }
        }
      }
    }

    // جلب التصنيفات الفرعية للفئة الحالية
    if (selectedCategoryId != null) {
      controller.fetchSubcategoriesByCategory(selectedCategoryId);
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 700),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'تعديل المنتج',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // صورة المنتج
                      _buildImageUploadSection(
                        selectedImage: selectedImage,
                        currentImageUrl: currentImageUrl,
                        onImageSelected: (image) => selectedImage = image,
                        onImageRemoved: () {
                          selectedImage = null;
                          currentImageUrl = null;
                        },
                        isUploading: isUploading,
                      ),
                      const SizedBox(height: 24),

                      // معلومات المنتج
                      _buildProductInfoSection(
                        nameController: nameController,
                        descriptionController: descriptionController,
                        priceController: priceController,
                        stockController: stockController,
                      ),
                      const SizedBox(height: 24),

                      // الفئة والتصنيف الفرعي
                      _buildCategoryFilterForAdding(
                        isMobile: false,
                        controller,
                        selectedCategory: (value) {
                          selectedCategoryId = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSubcategoryFilterForAdding(
                        isMobile: false,
                        controller,
                        selectedSubcategory: (value) {
                          selectedSubcategoryId = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.warning),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: const TextStyle(color: AppColors.warning),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  if (_validateProductForm(
                                    nameController.text,
                                    priceController.text,
                                    stockController.text,
                                    selectedCategoryId,
                                    selectedSubcategoryId,
                                  )) {
                                    isUploading = true;

                                    String? imageUrl = currentImageUrl;

                                    // إذا تم اختيار صورة جديدة، قم برفعها
                                    if (selectedImage != null) {
                                      final fileName =
                                          'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                      imageUrl =
                                          await ImageUploadService.uploadImage(
                                            selectedImage!,
                                            fileName,
                                          );

                                      // حذف الصورة القديمة إذا كانت موجودة
                                      if (currentImageUrl != null &&
                                          currentImageUrl != imageUrl) {
                                        await ImageUploadService.deleteImage(
                                          currentImageUrl!,
                                        );
                                      }
                                    }

                                    // إذا تم إزالة الصورة، احذفها من التخزين
                                    if (currentImageUrl == null &&
                                        product.imageUrl != null) {
                                      await ImageUploadService.deleteImage(
                                        product.imageUrl!,
                                      );
                                    }

                                    final updatedProduct = product.copyWith(
                                      subcategoryId: selectedSubcategoryId,
                                      name: nameController.text,
                                      description:
                                          descriptionController.text.isEmpty
                                          ? null
                                          : descriptionController.text,
                                      price: double.parse(priceController.text),
                                      stockQuantity: int.parse(
                                        stockController.text,
                                      ),
                                      imageUrl: imageUrl,
                                    );

                                    await controller.updateProduct(
                                      product.id,
                                      updatedProduct,
                                    );
                                    isUploading = false;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'حفظ التعديلات',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دوال مساعدة للـ Dialogs
  Widget _buildImageUploadSection({
    required File? selectedImage,
    required Function(File) onImageSelected,
    required bool isUploading,
    String? currentImageUrl, // إضافة للمنتج الحالي
    Function()? onImageRemoved, // إضافة لإزالة الصورة
  }) {
    final hasImage = selectedImage != null || currentImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'صورة المنتج',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            if (hasImage) ...[
              const Spacer(),
              TextButton.icon(
                onPressed: onImageRemoved,
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('إزالة الصورة'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isUploading
              ? null
              : () async {
                  Get.bottomSheet(
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('اختيار من المعرض'),
                            onTap: () async {
                              Get.back();
                              final image =
                                  await ImageUploadService.pickImageFromGallery();
                              if (image != null) {
                                onImageSelected(image);
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('التقاط صورة'),
                            onTap: () async {
                              Get.back();
                              final image =
                                  await ImageUploadService.pickImageFromCamera();
                              if (image != null) {
                                onImageSelected(image);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: hasImage ? Colors.transparent : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Stack(
              children: [
                // عرض الصورة المختارة أو الحالية
                if (selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      selectedImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                else if (currentImageUrl != null && currentImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: currentImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error),
                      ),
                    ),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'انقر لرفع صورة المنتج',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اسحب الصورة هنا أو انقر للاختيار',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                // زر التعديل يظهر عند وجود صورة
                if (hasImage)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isUploading) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
          const SizedBox(height: 4),
          const Text(
            'جاري رفع الصورة...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildProductInfoSection({
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController priceController,
    required TextEditingController stockController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات المنتج',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم المنتج *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.shopping_bag),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'وصف المنتج',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'السعر *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'الكمية *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _validateProductForm(
    String name,
    String price,
    String stock,
    String? categoryId,
    String? subcategoryId,
  ) {
    if (name.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم المنتج');
      return false;
    }

    if (price.isEmpty || double.tryParse(price) == null) {
      Get.snackbar('خطأ', 'يرجى إدخال سعر صحيح');
      return false;
    }

    if (stock.isEmpty || int.tryParse(stock) == null) {
      Get.snackbar('خطأ', 'يرجى إدخال كمية صحيحة');
      return false;
    }

    if (categoryId == null) {
      Get.snackbar('خطأ', 'يرجى اختيار الفئة الرئيسية');
      return false;
    }

    if (subcategoryId == null) {
      Get.snackbar('خطأ', 'يرجى اختيار التصنيف الفرعي');
      return false;
    }

    return true;
  }
}
