import 'dart:io';

import 'package:dashboard_test/view/products/widgets/product_filter.dart';
import 'package:dashboard_test/view/products/widgets/product_header.dart';
import 'package:dashboard_test/view/products/widgets/product_list.dart';
import 'package:dashboard_test/view/products/widgets/product_state_cards.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';
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
              style: TextStyle(color: AppColors.white, fontSize: 14),
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
          ...controller.categories.map(
            (category) => DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            ),
          ),
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
          ...controller.subcategories.map(
            (subcategory) => DropdownMenuItem(
              value: subcategory.id,
              child: Text(subcategory.name),
            ),
          ),
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

    // تحديد حجم الدايلوج حسب نوع الجهاز
    final isMobile = Get.width < 768;
    final dialogWidth = isMobile ? Get.width * 0.95 : 600.0;
    final dialogHeight = isMobile ? Get.height * 0.9 : 700.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBrown,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        'إضافة منتج جديد',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: isMobile ? 18 : 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Column(
                    children: [
                      // صورة المنتج
                      _buildImageUploadSection(
                        selectedImage: selectedImage,
                        onImageSelected: (image) => selectedImage = image,
                        isUploading: isUploading,
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 16 : 24),

                      // معلومات المنتج
                      _buildProductInfoSection(
                        nameController: nameController,
                        descriptionController: descriptionController,
                        priceController: priceController,
                        stockController: stockController,
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 16 : 24),

                      // الفئة والتصنيف الفرعي
                      _buildCategoryFilterForAdding(
                        isMobile: isMobile,
                        controller,
                        selectedCategory: (value) {
                          selectedCategoryId = value;
                        },
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildSubcategoryFilterForAdding(
                        isMobile: isMobile,
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
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: isMobile
                    ? Column(
                        children: [
                          // زر الإضافة في الموبايل
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => _handleAddProduct(
                                        controller,
                                        nameController,
                                        descriptionController,
                                        priceController,
                                        stockController,
                                        selectedCategoryId,
                                        selectedSubcategoryId,
                                        selectedImage,
                                        isUploading,
                                      ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBrown,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'إضافة المنتج',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // زر الإلغاء في الموبايل
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: AppColors.primaryBrown,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
                                  color: AppColors.primaryBrown,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // زر الإلغاء في الديسكتوب
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: AppColors.primaryBrown,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
                                  color: AppColors.primaryBrown,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // زر الإضافة في الديسكتوب
                          Expanded(
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => _handleAddProduct(
                                        controller,
                                        nameController,
                                        descriptionController,
                                        priceController,
                                        stockController,
                                        selectedCategoryId,
                                        selectedSubcategoryId,
                                        selectedImage,
                                        isUploading,
                                      ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBrown,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'إضافة المنتج',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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

  // دالة منفصلة للتعامل مع إضافة المنتج
  Future<void> _handleAddProduct(
    ProductController controller,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController priceController,
    TextEditingController stockController,
    String? selectedCategoryId,
    String? selectedSubcategoryId,
    File? selectedImage,
    bool isUploading,
  ) async {
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
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await ImageUploadService.uploadImage(
          selectedImage,
          fileName,
        );
      }

      final newProduct = ProductModel(
        id: '',
        subcategoryId: selectedSubcategoryId,
        name: nameController.text,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        price: double.parse(priceController.text),
        stockQuantity: int.parse(stockController.text),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await controller.addProduct(newProduct);
      isUploading = false;

      // إغلاق الدايلوج بعد الإضافة الناجحة
      if (!controller.isLoading.value) {
        Get.back();
      }
    }
  }

  // دالة التحقق من صحة البيانات
  bool _validateProductForm(
    String name,
    String price,
    String stock,
    String? categoryId,
    String? subcategoryId,
  ) {
    if (name.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال اسم المنتج',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (price.isEmpty || double.tryParse(price) == null) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال سعر صحيح',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (stock.isEmpty || int.tryParse(stock) == null) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال كمية صحيحة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (categoryId == null) {
      Get.snackbar(
        'خطأ',
        'يرجى اختيار الفئة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (subcategoryId == null ||
        subcategoryId.isEmpty ||
        subcategoryId == '' ||
        subcategoryId == 'null' ||
        subcategoryId == 'all') {
      Get.snackbar(
        'خطأ',
        'يرجى اختيار التصنيف الفرعي',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // نسخة محسنة من دالة رفع الصورة مع دعم الموبايل
  Widget _buildImageUploadSection({
    required File? selectedImage,
    required Function(File) onImageSelected,
    required bool isUploading,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صورة المنتج',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        GestureDetector(
          onTap: () async {
            if (isUploading) return;

            final image = await ImagePicker().pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) {
              onImageSelected(File(image.path));
            }
          },
          child: Container(
            width: double.infinity,
            height: isMobile ? 120 : 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: isUploading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.primaryBrown,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'جاري رفع الصورة...',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_rounded,
                        size: isMobile ? 32 : 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'انقر لاختيار صورة',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      selectedImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfoSection({
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController priceController,
    required TextEditingController stockController,
    bool isMobile = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات المنتج',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // اسم المنتج
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'اسم المنتج *',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.shopping_bag_outlined),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 14 : 16,
            ),
          ),
          style: TextStyle(fontSize: isMobile ? 14 : 16),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // وصف المنتج
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'وصف المنتج',
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.description_outlined),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 14 : 16,
            ),
          ),
          maxLines: isMobile ? 2 : 3,
          style: TextStyle(fontSize: isMobile ? 14 : 16),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // السعر والكمية
        isMobile
            ? Column(
                children: [
                  // السعر في الموبايل
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'السعر *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money_rounded),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // الكمية في الموبايل
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              )
            : Row(
                children: [
                  // السعر في الديسكتوب
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'السعر *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money_rounded),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // الكمية في الديسكتوب
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      decoration: const InputDecoration(
                        labelText: 'الكمية *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

        // معلومات إضافية
        Container(
          margin: EdgeInsets.only(top: isMobile ? 8 : 12),
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: isMobile ? 16 : 18,
                color: Colors.blue.shade600,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Text(
                  'الحقول المميزة بـ * إلزامية',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
