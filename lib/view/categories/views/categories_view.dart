import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../data/models/category_model.dart';
import '../controllers/categories_controller.dart';
import '../../../themes/app_theme.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.put(CategoryController());

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
                // Header - مضغوط للهاتف
                _buildHeader(controller, isMobile),
                SizedBox(height: isMobile ? 12 : 20),

                // Search and Filters
                // _buildSearchAndFilters(controller, isMobile),
                // SizedBox(height: isMobile ? 12 : 20),

                // Categories List
                Expanded(child: _buildCategoriesContent(controller, isMobile)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          final isMobile =
              sizingInformation.deviceScreenType == DeviceScreenType.mobile;

          return FloatingActionButton(
            onPressed: () => _showAddCategoryDialog(controller),
            backgroundColor: AppColors.primaryBrown,
            child: Icon(
              Icons.add,
              color: AppColors.white,
              size: isMobile ? 20 : 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(CategoryController controller, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isMobile ? 'الفئات' : 'إدارة الفئات',
              style: TextStyle(
                fontSize: isMobile ? 18 : 28,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const Spacer(),
            // إحصائيات صغيرة على الهاتف
            if (isMobile)
              Obx(() {
                return Text(
                  '${controller.categories.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            if (!isMobile)
              ElevatedButton.icon(
                onPressed: controller.fetchAllCategories,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('تحديث'),
              ),
          ],
        ),
        // إحصائيات للشاشات الكبيرة
        if (!isMobile)
          Obx(() {
            final totalCategories = controller.categories.length;
            final totalSubcategories = controller.categories.fold(
              0,
              (sum, category) => sum + (category.subcategories?.length ?? 0),
            );

            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$totalCategories فئة • $totalSubcategories فئة فرعية',
                style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
              ),
            );
          }),
      ],
    );
  }

  // Widget _buildSearchAndFilters(CategoryController controller, bool isMobile) {
  //   return Card(
  //     elevation: 1,
  //     child: Padding(
  //       padding: EdgeInsets.all(isMobile ? 10 : 16),
  //       child: TextField(
  //         onChanged: (value) {
  //           // يمكن إضافة دالة بحث هنا إذا كانت موجودة في الـ Controller
  //         },
  //         decoration: InputDecoration(
  //           hintText: 'ابحث عن فئة...',
  //           prefixIcon: const Icon(Icons.search),
  //           border: const OutlineInputBorder(),
  //           contentPadding: EdgeInsets.symmetric(
  //             horizontal: isMobile ? 12 : 16,
  //             vertical: isMobile ? 12 : 16,
  //           ),
  //           isDense: true,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCategoriesContent(CategoryController controller, bool isMobile) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBrown),
        );
      }

      if (controller.categories.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: AppColors.darkGray,
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد فئات',
                style: TextStyle(fontSize: 16, color: AppColors.darkGray),
              ),
              SizedBox(height: 8),
              Text(
                'انقر على + لإضافة فئة جديدة',
                style: TextStyle(fontSize: 14, color: AppColors.darkGray),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return _buildCategoryCard(category, controller, isMobile);
        },
      );
    });
  }

  Widget _buildCategoryCard(
    Category category,
    CategoryController controller,
    bool isMobile,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      elevation: 1,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 4 : 8,
        ),
        leading: Container(
          width: isMobile ? 36 : 40,
          height: isMobile ? 36 : 40,
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.category,
            color: AppColors.primaryBrown,
            size: isMobile ? 16 : 20,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${category.subcategories?.length ?? 0} فئة فرعية',
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: isMobile ? 11 : 13,
              ),
            ),
            Text(
              'أنشئت: ${DateFormat('dd/MM/yyyy').format(category.createdAt)}',
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: isMobile ? 10 : 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.lightGray,
          icon: Icon(Icons.more_vert, size: isMobile ? 18 : 20),
          onSelected: (value) {
            if (value == 'edit') {
              _showEditCategoryDialog(controller, category);
            } else if (value == 'delete') {
              _showDeleteConfirmation(controller, category);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('تعديل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'الفئات الفرعية',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                        fontSize: isMobile ? 13 : 15,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showAddSubcategoryDialog(controller, category),
                      icon: Icon(Icons.add, size: isMobile ? 14 : 16),
                      label: Text(
                        isMobile ? 'إضافة' : 'إضافة فئة فرعية',
                        style: TextStyle(fontSize: isMobile ? 11 : 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: isMobile ? 6 : 8,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 8 : 12),

                if (category.subcategories != null &&
                    category.subcategories!.isNotEmpty)
                  ...category.subcategories!.map(
                    (subcategory) => _buildSubcategoryItem(
                      subcategory,
                      controller,
                      isMobile,
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'لا توجد فئات فرعية',
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryItem(
    Subcategory subcategory,
    CategoryController controller,
    bool isMobile,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 2 : 4),
      elevation: 0,
      color: AppColors.lightGray,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 4 : 8,
        ),
        leading: Icon(
          Icons.subdirectory_arrow_right,
          color: AppColors.primaryBrown,
          size: isMobile ? 16 : 18,
        ),
        title: Text(
          subcategory.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isMobile ? 13 : 14,
          ),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(subcategory.createdAt),
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: AppColors.darkGray,
          ),
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.lightGray,
          icon: Icon(Icons.more_vert, size: isMobile ? 16 : 18),
          onSelected: (value) {
            if (value == 'edit') {
              _showEditSubcategoryDialog(controller, subcategory);
            } else if (value == 'delete') {
              _showDeleteSubcategoryConfirmation(controller, subcategory);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('تعديل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(CategoryController controller) {
    final nameController = TextEditingController();
    final isMobile = Get.width < 768;
    final dialogWidth = isMobile ? Get.width * 0.95 : 450.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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
                      Icons.category_rounded,
                      color: Colors.white,
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        'إضافة فئة جديدة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: isMobile ? 18 : 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  children: [
                    // Icon Section
                    Container(
                      width: isMobile ? 70 : 80,
                      height: isMobile ? 70 : 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrown.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_circle_rounded,
                        size: isMobile ? 35 : 40,
                        color: AppColors.primaryBrown,
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Instruction Text
                    Text(
                      'أدخل اسم الفئة الجديدة',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Text(
                      'سيتم إنشاء فئة جديدة يمكنك إضافة تصنيفات فرعية لها لاحقاً',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Text Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم الفئة',
                        hintText: 'أدخل اسم الفئة هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBrown,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isMobile ? 14 : 16,
                        ),
                        prefixIcon: Icon(
                          Icons.category_rounded,
                          color: Colors.grey.shade500,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: AppColors.charcoal,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          controller.addCategory(value.trim());
                          Get.back();
                        }
                      },
                    ),
                    SizedBox(height: isMobile ? 8 : 12),

                    // Validation Message
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryBrown,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'جاري إضافة الفئة...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: isMobile
                    ? Column(
                        children: [
                          // Add Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (nameController.text
                                            .trim()
                                            .isNotEmpty) {
                                          controller.addCategory(
                                            nameController.text.trim(),
                                          );
                                          Get.back();
                                        } else {
                                          Get.snackbar(
                                            'خطأ',
                                            'يرجى إدخال اسم الفئة',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBrown,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'إضافة الفئة',
                                      style: TextStyle(
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
                          // Cancel Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
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
                          // Cancel Button - Desktop
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Add Button - Desktop
                          Expanded(
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (nameController.text
                                            .trim()
                                            .isNotEmpty) {
                                          controller.addCategory(
                                            nameController.text.trim(),
                                          );
                                          Get.back();
                                        } else {
                                          Get.snackbar(
                                            'خطأ',
                                            'يرجى إدخال اسم الفئة',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBrown,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'إضافة الفئة',
                                      style: TextStyle(
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
      barrierDismissible: true,
    );
  }

  void _showEditCategoryDialog(
    CategoryController controller,
    Category category,
  ) {
    final nameController = TextEditingController(text: category.name);
    final isMobile = Get.width < 768;
    final dialogWidth = isMobile ? Get.width * 0.95 : 450.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        'تعديل الفئة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: isMobile ? 18 : 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  children: [
                    // Icon Section
                    Container(
                      width: isMobile ? 70 : 80,
                      height: isMobile ? 70 : 80,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: isMobile ? 35 : 40,
                        color: AppColors.warning,
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Current Category Info
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue.shade600,
                            size: isMobile ? 18 : 20,
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الفئة الحالية',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 14,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ID: ${category.id}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 12,
                                    color: Colors.grey.shade500,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Instruction Text
                    Text(
                      'قم بتعديل اسم الفئة',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Text(
                      'سيتم تحديث اسم الفئة في جميع المنتج المرتبطة بها',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Text Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم الفئة الجديد',
                        hintText: 'أدخل الاسم الجديد للفئة...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.warning,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isMobile ? 14 : 16,
                        ),
                        prefixIcon: Icon(
                          Icons.category_rounded,
                          color: Colors.grey.shade500,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: AppColors.charcoal,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          controller.updateCategory(category.id, value.trim());
                          Get.back();
                        }
                      },
                    ),
                    SizedBox(height: isMobile ? 8 : 12),

                    // Warning Message
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: isMobile ? 16 : 18,
                            color: Colors.orange.shade600,
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: Text(
                              'سيؤثر هذا التغيير على جميع المنتجات في هذه الفئة',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                color: Colors.orange.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 12),

                    // Validation Message
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'جاري تحديث الفئة...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: isMobile
                    ? Column(
                        children: [
                          // Update Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (nameController.text
                                            .trim()
                                            .isNotEmpty) {
                                          if (nameController.text.trim() !=
                                              category.name) {
                                            controller.updateCategory(
                                              category.id,
                                              nameController.text.trim(),
                                            );
                                            Get.back();
                                          } else {
                                            Get.snackbar(
                                              'ملاحظة',
                                              'لم تقم بتغيير اسم الفئة',
                                              backgroundColor: Colors.blue,
                                              colorText: Colors.white,
                                            );
                                          }
                                        } else {
                                          Get.snackbar(
                                            'خطأ',
                                            'يرجى إدخال اسم الفئة',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'حفظ التغييرات',
                                      style: TextStyle(
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
                          // Cancel Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
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
                          // Cancel Button - Desktop
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Update Button - Desktop
                          Expanded(
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (nameController.text
                                            .trim()
                                            .isNotEmpty) {
                                          if (nameController.text.trim() !=
                                              category.name) {
                                            controller.updateCategory(
                                              category.id,
                                              nameController.text.trim(),
                                            );
                                            Get.back();
                                          } else {
                                            Get.snackbar(
                                              'ملاحظة',
                                              'لم تقم بتغيير اسم الفئة',
                                              backgroundColor: Colors.blue,
                                              colorText: Colors.white,
                                            );
                                          }
                                        } else {
                                          Get.snackbar(
                                            'خطأ',
                                            'يرجى إدخال اسم الفئة',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'حفظ التغييرات',
                                      style: TextStyle(
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
      barrierDismissible: true,
    );
  }

  void _showAddSubcategoryDialog(
    CategoryController controller,
    Category category,
  ) {
    final nameController = TextEditingController();
    final isMobile = Get.width < 768;
    final dialogWidth = isMobile ? Get.width * 0.95 : 450.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      color: Colors.white,
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        'إضافة تصنيف فرعي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: isMobile ? 18 : 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  children: [
                    // Parent Category Info
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_rounded,
                            color: Colors.blue.shade600,
                            size: isMobile ? 18 : 20,
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الفئة الرئيسية',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 14,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ID: ${category.id}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 12,
                                    color: Colors.grey.shade500,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Icon Section
                    Container(
                      width: isMobile ? 70 : 80,
                      height: isMobile ? 70 : 80,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_circle_rounded,
                        size: isMobile ? 35 : 40,
                        color: Colors.green.shade600,
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Instruction Text
                    Text(
                      'أدخل اسم التصنيف الفرعي الجديد',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Text(
                      'سيتم إنشاء تصنيف فرعي جديد ضمن الفئة "${category.name}"',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Text Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم التصنيف الفرعي',
                        hintText: 'أدخل اسم التصنيف الفرعي هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green.shade600,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isMobile ? 14 : 16,
                        ),
                        prefixIcon: Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          color: Colors.grey.shade500,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: AppColors.charcoal,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          controller.addSubcategory(category.id, value.trim());
                          Get.back();
                        }
                      },
                    ),
                    SizedBox(height: isMobile ? 8 : 12),

                    // Info Message
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: isMobile ? 16 : 18,
                            color: Colors.green.shade600,
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: Text(
                              'يمكنك إضافة المنتجات لهذا التصنيف الفرعي بعد إنشائه',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                color: Colors.green.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 12),

                    // Validation Message
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'جاري إضافة التصنيف الفرعي...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: isMobile
                    ? Column(
                        children: [
                          // Add Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (nameController.text
                                            .trim()
                                            .isNotEmpty) {
                                          controller.addSubcategory(
                                            category.id,
                                            nameController.text.trim(),
                                          );
                                          Get.back();
                                        } else {
                                          Get.snackbar(
                                            'خطأ',
                                            'يرجى إدخال اسم التصنيف الفرعي',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'إضافة التصنيف',
                                      style: TextStyle(
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
                          // Cancel Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
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
                          // Cancel Button - Desktop
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Add Button - Desktop
                          Expanded(
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (nameController.text
                                            .trim()
                                            .isNotEmpty) {
                                          controller.addSubcategory(
                                            category.id,
                                            nameController.text.trim(),
                                          );
                                          Get.back();
                                        } else {
                                          Get.snackbar(
                                            'خطأ',
                                            'يرجى إدخال اسم التصنيف الفرعي',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'إضافة التصنيف',
                                      style: TextStyle(
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
      barrierDismissible: true,
    );
  }

  void _showDeleteConfirmation(
    CategoryController controller,
    Category category,
  ) {
    final isMobile = Get.width < 768;
    final dialogWidth = isMobile ? Get.width * 0.95 : 450.0;
    final hasSubcategories =
        category.subcategories != null && category.subcategories!.isNotEmpty;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: isMobile ? 70 : 80,
                      height: isMobile ? 70 : 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        size: isMobile ? 35 : 40,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    // Title
                    Text(
                      'حذف الفئة',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  children: [
                    // Category Info
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          // Category Icon
                          Container(
                            width: isMobile ? 50 : 60,
                            height: isMobile ? 50 : 60,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.category_rounded,
                              color: Colors.red,
                              size: isMobile ? 24 : 28,
                            ),
                          ),
                          SizedBox(width: isMobile ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.charcoal,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${category.id}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                    color: Colors.grey.shade500,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (hasSubcategories)
                                  Text(
                                    '${category.subcategories!.length} تصنيف فرعي',
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 14,
                                      color: Colors.orange.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Warning Message
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: isMobile ? 20 : 24,
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تنبيه مهم',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'هذا الإجراء لا يمكن التراجع عنه. سيتم حذف الفئة بشكل دائم من النظام.',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                    color: Colors.red.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isMobile ? 12 : 16),

                    // Subcategories Warning
                    if (hasSubcategories)
                      Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Colors.orange.shade700,
                              size: isMobile ? 18 : 20,
                            ),
                            SizedBox(width: isMobile ? 8 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تحذير: تحتوي على تصنيفات فرعية',
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'سيتم حذف جميع التصنيفات الفرعية والمنتجات المرتبطة بها أيضاً',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      color: Colors.orange.shade600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Additional Info
                    Container(
                      margin: EdgeInsets.only(top: isMobile ? 12 : 16),
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: isMobile ? 14 : 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'سيتم حذف جميع البيانات المرتبطة بهذه الفئة',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: isMobile
                    ? Column(
                        children: [
                          // Delete Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                controller.deleteCategory(category.id);
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 14 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    size: isMobile ? 18 : 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'حذف الفئة',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Cancel Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 14 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'إلغاء الحذف',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Cancel Button - Desktop
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 14 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'إلغاء الحذف',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Delete Button - Desktop
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.deleteCategory(category.id);
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 14 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    size: isMobile ? 18 : 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'حذف الفئة',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
      barrierDismissible: true,
    );
  }

  void _showEditSubcategoryDialog(
    CategoryController controller,
    Subcategory subcategory,
  ) {
    final nameController = TextEditingController(text: subcategory.name);
    final isMobile = Get.width < 768;
    final dialogWidth = isMobile ? Get.width * 0.95 : 450.0;

    // البحث عن الفئة الرئيسية
    String? parentCategoryName;
    for (var category in controller.categories) {
      if (category.id == subcategory.categoryId) {
        parentCategoryName = category.name;
        break;
      }
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: isMobile ? 16 : 20,
                    ),
                    SizedBox(width: isMobile ? 2 : 6),
                    Expanded(
                      child: Text(
                        'تعديل التصنيف الفرعي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: isMobile ? 18 : 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  children: [
                    // Icon Section
                    Container(
                      width: isMobile ? 70 : 80,
                      height: isMobile ? 70 : 80,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: isMobile ? 35 : 40,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Current Subcategory Info
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        children: [
                          // Parent Category
                          Row(
                            children: [
                              Icon(
                                Icons.category_rounded,
                                color: Colors.blue.shade600,
                                size: isMobile ? 16 : 18,
                              ),
                              SizedBox(width: isMobile ? 8 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الفئة الرئيسية',
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      parentCategoryName ?? 'غير معروف',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 8 : 12),
                          // Current Name
                          Row(
                            children: [
                              Icon(
                                Icons.subdirectory_arrow_right_rounded,
                                color: Colors.blue.shade600,
                                size: isMobile ? 16 : 18,
                              ),
                              SizedBox(width: isMobile ? 8 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الاسم الحالي',
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      subcategory.name,
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 4 : 6),
                          // ID
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.grey.shade500,
                                size: isMobile ? 14 : 16,
                              ),
                              SizedBox(width: isMobile ? 8 : 12),
                              Text(
                                'ID: ${subcategory.id}',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  color: Colors.grey.shade500,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Instruction Text
                    Text(
                      'قم بتعديل اسم التصنيف الفرعي',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Text(
                      'سيتم تحديث اسم التصنيف الفرعي في جميع المنتجات المرتبطة به',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Text Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم التصنيف الفرعي الجديد',
                        hintText: 'أدخل الاسم الجديد للتصنيف الفرعي...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.orange.shade600,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isMobile ? 14 : 16,
                        ),
                        prefixIcon: Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          color: Colors.grey.shade500,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: AppColors.charcoal,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty &&
                            value.trim() != subcategory.name) {
                          controller.updateSubcategory(
                            subcategory.id,
                            value.trim(),
                          );
                          Get.back();
                        }
                      },
                    ),
                    SizedBox(height: isMobile ? 8 : 12),

                    // Warning Message
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: isMobile ? 16 : 18,
                            color: Colors.orange.shade600,
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: Text(
                              'سيؤثر هذا التغيير على جميع المنتجات في هذا التصنيف الفرعي',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                color: Colors.orange.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 5 : 9),

                    // Validation Message
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.orange.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'جاري تحديث التصنيف الفرعي...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox(height: 0, width: 0);
                    }),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: isMobile
                    ? Column(
                        children: [
                          // Update Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (nameController.text
                                            .trim()
                                            .isNotEmpty) {
                                          if (nameController.text.trim() !=
                                              subcategory.name) {
                                            controller.updateSubcategory(
                                              subcategory.id,
                                              nameController.text.trim(),
                                            );
                                            Get.back();
                                          } else {
                                            Get.snackbar(
                                              'ملاحظة',
                                              'لم تقم بتغيير اسم التصنيف الفرعي',
                                              backgroundColor: Colors.blue,
                                              colorText: Colors.white,
                                            );
                                          }
                                        } else {
                                          Get.snackbar(
                                            'خطأ',
                                            'يرجى إدخال اسم التصنيف الفرعي',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'حفظ التغييرات',
                                      style: TextStyle(
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
                          // Cancel Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
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
                          // Cancel Button - Desktop
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Update Button - Desktop
                          Expanded(
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (nameController.text
                                            .trim()
                                            .isNotEmpty) {
                                          if (nameController.text.trim() !=
                                              subcategory.name) {
                                            controller.updateSubcategory(
                                              subcategory.id,
                                              nameController.text.trim(),
                                            );
                                            Get.back();
                                          } else {
                                            Get.snackbar(
                                              'ملاحظة',
                                              'لم تقم بتغيير اسم التصنيف الفرعي',
                                              backgroundColor: Colors.blue,
                                              colorText: Colors.white,
                                            );
                                          }
                                        } else {
                                          Get.snackbar(
                                            'خطأ',
                                            'يرجى إدخال اسم التصنيف الفرعي',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'حفظ التغييرات',
                                      style: TextStyle(
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
      barrierDismissible: true,
    );
  }

  void _showDeleteSubcategoryConfirmation(
    CategoryController controller,
    Subcategory subcategory,
  ) {
    final isMobile = Get.width < 768;
    final dialogWidth = isMobile ? Get.width * 0.95 : 450.0;

    // البحث عن الفئة الرئيسية
    String? parentCategoryName;
    for (var category in controller.categories) {
      if (category.id == subcategory.categoryId) {
        parentCategoryName = category.name;
        break;
      }
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: isMobile ? 70 : 80,
                      height: isMobile ? 70 : 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        size: isMobile ? 25 : 30,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    // Title
                    Text(
                      'حذف التصنيف الفرعي',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(isMobile ? 15 : 19),
                child: Column(
                  children: [
                    // Subcategory Info
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          // Parent Category
                          Row(
                            children: [
                              Icon(
                                Icons.category_rounded,
                                color: Colors.blue.shade600,
                                size: isMobile ? 15 : 17,
                              ),
                              SizedBox(width: isMobile ? 5 : 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الفئة الرئيسية',
                                      style: TextStyle(
                                        fontSize: isMobile ? 8 : 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      parentCategoryName ?? 'غير معروف',
                                      style: TextStyle(
                                        fontSize: isMobile ? 10 : 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 10 : 14),
                          // Subcategory Details
                          Row(
                            children: [
                              // Subcategory Icon
                              Container(
                                width: isMobile ? 50 : 60,
                                height: isMobile ? 50 : 60,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  color: Colors.red,
                                  size: isMobile ? 20 : 24,
                                ),
                              ),
                              SizedBox(width: isMobile ? 8 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subcategory.name,
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.charcoal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'ID: ${subcategory.id}',
                                      style: TextStyle(
                                        fontSize: isMobile ? 8 : 12,
                                        color: Colors.grey.shade500,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'تم الإنشاء: ${DateFormat('dd/MM/yyyy').format(subcategory.createdAt)}',
                                      style: TextStyle(
                                        fontSize: isMobile ? 11 : 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isMobile ? 10 : 14),

                    // Warning Message
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: isMobile ? 14 : 18,
                          ),
                          SizedBox(width: isMobile ? 6 : 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تنبيه مهم',
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'هذا الإجراء لا يمكن التراجع عنه. سيتم حذف التصنيف الفرعي بشكل دائم من النظام.',
                                  style: TextStyle(
                                    fontSize: isMobile ? 8 : 10,
                                    color: Colors.red.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isMobile ? 12 : 16),

                    // Products Warning
                    Container(
                      padding: EdgeInsets.all(isMobile ? 8 : 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.orange.shade700,
                            size: isMobile ? 14 : 16,
                          ),
                          SizedBox(width: isMobile ? 4 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تحذير: تأثير على المنتجات',
                                  style: TextStyle(
                                    fontSize: isMobile ? 8 : 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'سيتم حذف جميع المنتجات المرتبطة بهذا التصنيف الفرعي أيضاً',
                                  style: TextStyle(
                                    fontSize: isMobile ? 7 : 12,
                                    color: Colors.orange.shade600,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Additional Info
                    Container(
                      margin: EdgeInsets.only(top: isMobile ? 12 : 16),
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: isMobile ? 14 : 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'سيتم حذف جميع البيانات المرتبطة بهذا التصنيف الفرعي',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: isMobile
                    ? Column(
                        children: [
                          // Delete Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                controller.deleteSubcategory(subcategory.id);
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 14 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    size: isMobile ? 18 : 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'حذف التصنيف',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Cancel Button - Mobile
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 14 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'إلغاء الحذف',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Cancel Button - Desktop
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 14 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'إلغاء الحذف',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Delete Button - Desktop
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.deleteSubcategory(subcategory.id);
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 14 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    size: isMobile ? 18 : 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'حذف التصنيف',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
      barrierDismissible: true,
    );
  }
}
