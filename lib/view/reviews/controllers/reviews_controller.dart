import 'package:get/get.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/product_model.dart';

class ReviewsController extends GetxController {
  final _isLoading = true.obs;
  final _reviews = <Review>[].obs;
  final _selectedRating = 'all'.obs;

  bool get isLoading => _isLoading.value;
  List<Review> get reviews => _reviews;
  String get selectedRating => _selectedRating.value;

  List<Review> get filteredReviews {
    if (_selectedRating.value == 'all') {
      return _reviews;
    }

    return _reviews.where((review) {
      return review.rating.toString() == _selectedRating.value;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      _isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      _reviews.value = _getMockReviews();
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ في تحميل التقييمات');
    } finally {
      _isLoading.value = false;
    }
  }

  void setSelectedRating(String rating) {
    _selectedRating.value = rating;
  }

  void deleteReview(String reviewId) {
    _reviews.removeWhere((review) => review.id == reviewId);
    Get.snackbar('نجح', 'تم حذف التقييم بنجاح');
  }

  List<Review> _getMockReviews() {
    return [
      // Review(
      //   id: '1',
      //   userId: 'user-1',
      //   productId: 'product-1',
      //   rating: 5,
      //   comment: 'منتج رائع وجودة عالية جداً. أنصح به بشدة!',
      //   createdAt: DateTime.now().subtract(const Duration(days: 2)),
      //   user: Profile(
      //     id: 'user-1',
      //     fullName: 'أحمد محمد',
      //     email: 'ahmed@example.com',
      //     role: 'customer',
      //     createdAt: DateTime.now(),
      //   ),
      //   product: ProductModel(
      //     id: 'product-1',
      //     subcategoryId: 'sub-1',
      //     name: 'هاتف ذكي iPhone 15',
      //     price: 3999.99,
      //     stockQuantity: 25,
      //     createdAt: DateTime.now(),
      //   ),
      // ),
      // Review(
      //   id: '2',
      //   userId: 'user-2',
      //   productId: 'product-2',
      //   rating: 4,
      //   comment: 'منتج جيد ولكن يمكن تحسين التغليف.',
      //   createdAt: DateTime.now().subtract(const Duration(days: 5)),
      //   user: Profile(
      //     id: 'user-2',
      //     fullName: 'فاطمة علي',
      //     email: 'fatima@example.com',
      //     role: 'customer',
      //     createdAt: DateTime.now(),
      //   ),
      //   product: ProductModel(
      //     id: 'product-2',
      //     subcategoryId: 'sub-2',
      //     name: 'قميص قطني',
      //     price: 99.99,
      //     stockQuantity: 15,
      //     createdAt: DateTime.now(),
      //   ),
      // ),
      // Review(
      //   id: '3',
      //   userId: 'user-3',
      //   productId: 'product-1',
      //   rating: 2,
      //   comment: 'لم يعجبني كثيراً. الجودة أقل من المتوقع.',
      //   createdAt: DateTime.now().subtract(const Duration(days: 10)),
      //   user: Profile(
      //     id: 'user-3',
      //     fullName: 'عمر حسن',
      //     email: 'omar@example.com',
      //     role: 'customer',
      //     createdAt: DateTime.now(),
      //   ),
      //   product: ProductModel(
      //     id: 'product-1',
      //     subcategoryId: 'sub-1',
      //     name: 'هاتف ذكي iPhone 15',
      //     price: 3999.99,
      //     stockQuantity: 25,
      //     createdAt: DateTime.now(),
      //   ),
      // ),
    ];
  }
}
