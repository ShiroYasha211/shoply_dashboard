import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/reviews_controller.dart';
import '../../../themes/app_theme.dart';

class ReviewsView extends StatelessWidget {
  const ReviewsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewsController>(
      init: ReviewsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'إدارة التقييمات',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: controller.loadReviews,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('تحديث'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Filter
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 200,
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          value: controller.selectedRating,
                          decoration: const InputDecoration(
                            labelText: 'تصفية حسب التقييم',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('جميع التقييمات'),
                            ),
                            DropdownMenuItem(value: '5', child: Text('5 نجوم')),
                            DropdownMenuItem(value: '4', child: Text('4 نجوم')),
                            DropdownMenuItem(value: '3', child: Text('3 نجوم')),
                            DropdownMenuItem(value: '2', child: Text('نجمتان')),
                            DropdownMenuItem(
                              value: '1',
                              child: Text('نجمة واحدة'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.setSelectedRating(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Reviews List
                Expanded(
                  child: controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBrown,
                          ),
                        )
                      : Obx(() {
                          final reviews = controller.filteredReviews;

                          if (reviews.isEmpty) {
                            return const Center(
                              child: Text(
                                'لا توجد تقييمات',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              return _buildReviewCard(review, controller);
                            },
                          );
                        }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(review, ReviewsController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.lightGray,
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user?.fullName ?? 'غير محدد',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        review.product?.name ?? 'غير محدد',
                        style: const TextStyle(
                          color: AppColors.darkGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRatingColor(review.rating).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: _getRatingColor(review.rating),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        review.rating.toString(),
                        style: TextStyle(
                          color: _getRatingColor(review.rating),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(controller, review);
                    }
                  },
                  itemBuilder: (context) => [
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
              ],
            ),

            const SizedBox(height: 12),

            // Comment
            if (review.comment != null && review.comment!.isNotEmpty)
              Text(
                review.comment!,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),

            const SizedBox(height: 12),

            // Date
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(review.createdAt),
              style: const TextStyle(fontSize: 12, color: AppColors.darkGray),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) {
      return AppColors.success;
    } else if (rating == 3) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  void _showDeleteConfirmation(ReviewsController controller, review) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف تقييم'),
        content: const Text(
          'هل تريد حذف هلا التقييم؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              controller.deleteReview(review.id);
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
