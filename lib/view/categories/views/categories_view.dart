import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/category_model.dart';
import '../controllers/categories_controller.dart';
import '../../../themes/app_theme.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.put(CategoryController());
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'إدارة الفئات',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: controller.fetchAllCategories,
                  icon: Icon(Icons.refresh, size: isMobile ? 16 : 18),
                  label: Text(
                    'تحديث',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 24),

            // Categories List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  );
                }

                if (controller.categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد فئات',
                      style: TextStyle(fontSize: 18, color: AppColors.darkGray),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return _buildCategoryCard(category, controller, isMobile);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(controller),
        backgroundColor: AppColors.primaryGreen,
        icon: Icon(Icons.add, color: AppColors.white, size: isMobile ? 18 : 24),
        label: Text(
          'إضافة فئة',
          style: TextStyle(
            color: AppColors.white,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    Category category,
    CategoryController controller,
    bool isMobile,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: AppColors.veryLightGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.category,
            color: AppColors.primaryGreen,
            size: isMobile ? 18 : 24,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        subtitle: Text(
          'تاريخ الإنشاء: ${DateFormat('dd/MM/yyyy').format(category.createdAt)}',
          style: TextStyle(
            color: AppColors.darkGray,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditCategoryDialog(controller, category);
            } else if (value == 'delete') {
              _showDeleteConfirmation(controller, category);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: isMobile ? 14 : 16),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text('تعديل', style: TextStyle(fontSize: isMobile ? 12 : 14)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    size: isMobile ? 14 : 16,
                    color: AppColors.error,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text(
                    'حذف',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الفئات الفرعية:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 8),

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
                  Text(
                    'لا توجد فئات فرعية',
                    style: TextStyle(
                      color: AppColors.darkGray,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),

                SizedBox(height: isMobile ? 8 : 12),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showAddSubcategoryDialog(controller, category),
                  icon: Icon(Icons.add, size: isMobile ? 14 : 16),
                  label: Text(
                    'إضافة فئة فرعية',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: isMobile ? 8 : 12,
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 2 : 4),
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.subdirectory_arrow_right,
            color: AppColors.primaryGreen,
            size: isMobile ? 14 : 16,
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Text(
              subcategory.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
          Text(
            DateFormat('dd/MM/yyyy').format(subcategory.createdAt),
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: isMobile ? 14 : 16),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditSubcategoryDialog(controller, subcategory);
              } else if (value == 'delete') {
                _showDeleteSubcategoryConfirmation(controller, subcategory);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: isMobile ? 14 : 16),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      'تعديل',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      size: isMobile ? 14 : 16,
                      color: AppColors.error,
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      'حذف',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(CategoryController controller) {
    TextEditingController nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة فئة جديدة'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة',
            border: OutlineInputBorder(),
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
    TextEditingController nameController = TextEditingController(
      text: category.name,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('تعديل الفئة'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة',
            border: OutlineInputBorder(),
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
    TextEditingController nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة فئة فرعية'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة الفرعية',
            border: OutlineInputBorder(),
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

  // باقي الدوال بدون تغيير (للحفاظ على التناسق)
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
    TextEditingController nameController = TextEditingController(
      text: subcategory.name,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('تعديل الفئة الفرعية'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة الفرعية',
            border: OutlineInputBorder(),
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
