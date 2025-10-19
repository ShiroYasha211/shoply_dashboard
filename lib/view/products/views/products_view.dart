import 'dart:io';

import 'package:dashboard_test/view/products/widgets/product_filter.dart';
import 'package:dashboard_test/view/products/widgets/product_header.dart';
import 'package:dashboard_test/view/products/widgets/product_list.dart';
import 'package:dashboard_test/view/products/widgets/product_state_cards.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

              return Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    ProductHeader(controller: controller, isMobile: isMobile),

                    const SizedBox(height: 10),

                    // Stats Cards
                    // ProductStateCards(
                    //   controller: controller,
                    //   sizingInfo: sizingInformation,
                    // ),

                    // const SizedBox(height: 10),

                    // // Filters
                    // ProductFilter(
                    //   controller: controller,
                    //   sizingInfo: sizingInformation,
                    // ),
                    _buildCollapsibleSection(controller, sizingInformation),

                    const SizedBox(height: 10),

                    // Products Grid/List
                    Expanded(
                      child: ProductList(
                        controller: controller,
                        sizingInfo: sizingInformation,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddProductDialog(controller),
            backgroundColor: AppColors.primaryBrown,
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

  Widget _buildCollapsibleSection(
    ProductController controller,
    SizingInformation sizingInfo,
  ) {
    final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;

    return Obx(
      () => Column(
        children: [
          // زر التحكم في الطي/الفرد
          if (!isMobile) _buildCollapseToggle(controller, sizingInfo),

          // المحتوى (يظهر/يختفي)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: controller.areWidgetsCollapsed.value
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      ProductStateCards(
                        controller: controller,
                        sizingInfo: sizingInfo,
                      ),
                      const SizedBox(height: 10),
                      ProductFilter(
                        controller: controller,
                        sizingInfo: sizingInfo,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapseToggle(
    ProductController controller,
    SizingInformation sizingInfo,
  ) {
    return Obx(
      () => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(
            controller.areWidgetsCollapsed.value
                ? Icons.expand_more
                : Icons.expand_less,
            color: AppColors.primaryBrown,
            size: 20,
          ),
          title: Text(
            controller.areWidgetsCollapsed.value
                ? 'إظهار الإحصائيات والفلترة'
                : 'إخفاء الإحصائيات والفلترة',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(
            controller.areWidgetsCollapsed.value
                ? Icons.visibility_off
                : Icons.visibility,
            size: 18,
            color: AppColors.darkGray,
          ),
          onTap: () {
            controller.toggleWidgetsCollapse();
          },
        ),
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
                  color: AppColors.primaryBrown,
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
                          side: const BorderSide(color: AppColors.primaryBrown),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(color: AppColors.primaryBrown),
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
                            backgroundColor: AppColors.primaryBrown,
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
