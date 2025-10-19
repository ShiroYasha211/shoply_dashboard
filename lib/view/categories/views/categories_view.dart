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

  Widget _buildSearchAndFilters(CategoryController controller, bool isMobile) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 10 : 16),
        child: TextField(
          onChanged: (value) {
            // يمكن إضافة دالة بحث هنا إذا كانت موجودة في الـ Controller
          },
          decoration: InputDecoration(
            hintText: 'ابحث عن فئة...',
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }

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
    final isMobile = MediaQuery.of(Get.context!).size.width < 600;

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة فئة جديدة'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'اسم الفئة',
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isMobile ? 12 : 16,
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.addCategory(nameController.text.trim());
                Get.back();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(
    CategoryController controller,
    Category category,
  ) {
    final nameController = TextEditingController(text: category.name);
    final isMobile = MediaQuery.of(Get.context!).size.width < 600;

    Get.dialog(
      AlertDialog(
        title: const Text('تعديل الفئة'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'اسم الفئة',
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isMobile ? 12 : 16,
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.updateCategory(
                  category.id,
                  nameController.text.trim(),
                );
                Get.back();
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog(
    CategoryController controller,
    Category category,
  ) {
    final nameController = TextEditingController();
    final isMobile = MediaQuery.of(Get.context!).size.width < 600;

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة فئة فرعية'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'اسم الفئة الفرعية',
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isMobile ? 12 : 16,
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.addSubcategory(
                  category.id,
                  nameController.text.trim(),
                );
                Get.back();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    CategoryController controller,
    Category category,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف فئة'),
        content: Text(
          'هل تريد حذف فئة "${category.name}"؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              controller.deleteCategory(category.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showEditSubcategoryDialog(
    CategoryController controller,
    Subcategory subcategory,
  ) {
    final nameController = TextEditingController(text: subcategory.name);
    final isMobile = MediaQuery.of(Get.context!).size.width < 600;

    Get.dialog(
      AlertDialog(
        title: const Text('تعديل الفئة الفرعية'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'اسم الفئة الفرعية',
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isMobile ? 12 : 16,
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.updateSubcategory(
                  subcategory.id,
                  nameController.text.trim(),
                );
                Get.back();
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSubcategoryConfirmation(
    CategoryController controller,
    Subcategory subcategory,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف فئة فرعية'),
        content: Text(
          'هل تريد حذف الفئة الفرعية "${subcategory.name}"؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              controller.deleteSubcategory(subcategory.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
