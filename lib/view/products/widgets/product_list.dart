import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/image_upload_service.dart';
import '../../../themes/app_theme.dart';
import '../controllers/products_controller.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    super.key,
    required this.controller,
    required this.sizingInfo,
  });
  final ProductController controller;
  final SizingInformation sizingInfo;

  @override
  Widget build(BuildContext context) {
    return _buildProductsList(controller, sizingInfo);
  }

  Widget _buildProductsList(
    ProductController controller,
    SizingInformation sizingInfo,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return _buildEmptyState();
      }

      if (controller.isGridView.value) {
        return _buildGridView(controller, sizingInfo, products);
      } else {
        return _buildListView(controller, products, sizingInfo);
      }
    });
  }

  Widget _buildLoadingState() {
    return const Center(
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري تحميل المنتجات...',
            style: const TextStyle(fontSize: 16, color: AppColors.darkGray),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.lightGray,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد منتجات',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'قم بإضافة منتجات جديدة لعرضها هنا',
            style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(
    ProductController controller,
    SizingInformation sizingInfo,
    List<ProductModel> products,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
    final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;

    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    final spacing = isMobile ? 8.0 : 12.0;

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: isMobile ? 0.75 : 0.8,
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
    final spacing = isMobile ? 8.0 : 12.0;

    return ListView.builder(
      padding: EdgeInsets.all(spacing),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: _buildProductListItem(product, controller, isMobile),
        );
      },
    );
  }

  Widget _buildProductCard(
    ProductModel product,
    ProductController controller,
    bool isMobile,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showProductDetails(controller, product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Badge
            Stack(
              children: [
                // Image Container
                Container(
                  height: isMobile ? 120 : 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: AppColors.lightGray,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: _buildProductImage(product),
                  ),
                ),

                // Stock Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildStockBadge(product, isMobile),
                ),
              ],
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name and Category
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : 14,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          product.categoryName ?? 'بدون تصنيف',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            color: AppColors.darkGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Price and Actions
                    Column(
                      children: [
                        // Price
                        Row(
                          children: [
                            Text(
                              '${product.price.toStringAsFixed(2)} ر.ي',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14 : 16,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${product.stockQuantity}',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: AppColors.darkGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isMobile ? 6 : 8),

                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.edit_outlined,
                                label: 'تعديل',
                                color: AppColors.primaryGreen,
                                onPressed: () =>
                                    _showEditProductDialog(controller, product),
                                isMobile: isMobile,
                              ),
                            ),
                            SizedBox(width: isMobile ? 4 : 6),
                            _buildIconButton(
                              icon: Icons.delete_outlined,
                              color: AppColors.error,
                              onPressed: () =>
                                  _showDeleteConfirmation(controller, product),
                              isMobile: isMobile,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(
    ProductModel product,
    ProductController controller,
    bool isMobile,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showProductDetails(controller, product),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            children: [
              // Product Image
              Stack(
                children: [
                  Container(
                    width: isMobile ? 60 : 80,
                    height: isMobile ? 60 : 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.lightGray,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildProductImage(product),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: _buildStockBadge(product, isMobile),
                  ),
                ],
              ),

              SizedBox(width: isMobile ? 12 : 16),

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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Text(
                      product.categoryName ?? 'بدون تصنيف',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        color: AppColors.darkGray,
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 8),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} ر.ي',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 10,
                            vertical: isMobile ? 4 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStockColor(product).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getStockColor(product).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            product.stockQuantity.toString(),
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: _getStockColor(product),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: isMobile ? 8 : 12),

              // Actions
              Column(
                children: [
                  _buildIconButton(
                    icon: Icons.edit_outlined,
                    color: AppColors.primaryGreen,
                    onPressed: () =>
                        _showEditProductDialog(controller, product),
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  _buildIconButton(
                    icon: Icons.delete_outlined,
                    color: AppColors.error,
                    onPressed: () =>
                        _showDeleteConfirmation(controller, product),
                    isMobile: isMobile,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: product.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.lightGray,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.inventory_2_outlined, color: AppColors.darkGray),
      );
    }
    return const Icon(
      Icons.inventory_2_outlined,
      color: AppColors.darkGray,
      size: 40,
    );
  }

  Widget _buildStockBadge(ProductModel product, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStockColor(product),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStockText(product),
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 8 : 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isMobile ? 14 : 16),
      label: Text(label, style: TextStyle(fontSize: isMobile ? 10 : 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: isMobile ? 18 : 20),
        color: color,
        padding: EdgeInsets.all(isMobile ? 6 : 8),
        iconSize: isMobile ? 18 : 20,
      ),
    );
  }

  Color _getStockColor(ProductModel product) {
    if (!product.isInStock) return AppColors.error;
    if (product.isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  String _getStockText(ProductModel product) {
    if (!product.isInStock) return 'نفد';
    if (product.isLowStock) return 'منخفض';
    return 'متوفر';
  }

  void _showProductDetails(ProductController controller, ProductModel product) {
    // تفاصيل المنتج يمكن إضافتها لاحقاً
    Get.dialog(
      AlertDialog(
        title: Text(product.name),
        content: Text('تفاصيل المنتج: ${product.description ?? "لا يوجد وصف"}'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
        ],
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
}
