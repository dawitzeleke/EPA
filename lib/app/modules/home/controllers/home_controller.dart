// lib/app/modules/home/controllers/home_controller.dart
import 'package:eprs/data/models/news_model.dart';
import 'package:eprs/domain/usecases/get_news_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/core/network/dio_client.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'package:dio/dio.dart' as dio;
import '../../status/controllers/status_controller.dart';
import '../../status/views/status_detail_view.dart';

class HomeController extends GetxController {
  // === USER INFO (from GetStorage) ===
  final GetNewsUseCase getNewsUseCase;
  final RxString userName = 'Guest'.obs;
  final RxString phoneNumber = ''.obs;
  final RxInt currentCarouselIndex = 0.obs;
  final RxBool isNewsLoading = true.obs;

  HomeController({required this.getNewsUseCase});
  // Carousel controller lives on the HomeController so it is not recreated
  // every time the widget tree rebuilds. This prevents leaking controller
  // instances and preserves carousel state across rebuilds.
  final CarouselSliderController carouselCtrl = CarouselSliderController();

  // === Carousel Data ===
  final List<String> imageUrls = [
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
    'assets/image4.png',
  ];

  final Map<String, String> imageCaptions = {
    'assets/image1.png': 'It was pointed out foreign employment is developing a system',
    'assets/image2.png': 'New benefits outlined for employment',
    'assets/image3.png': 'Training programs launched',
    'assets/image4.png': 'Progress in employment system',
  };

  final Map<String, String> imageDates = {
    'assets/image1.png': 'Nov 19',
    'assets/image2.png': 'Nov 18',
    'assets/image3.png': 'Nov 17',
    'assets/image4.png': 'Nov 16',
  };

  final Map<String, String> imageCities = {
    'assets/image1.png': 'Addis Ababa',
    'assets/image2.png': 'Addis Ababa',
    'assets/image3.png': 'Addis Ababa',
    'assets/image4.png': 'Addis Ababa',
  };
String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}

 
  // === Getters ===
  final box = Get.find<GetStorage>();
  
  // === Pollution Categories ===
  final RxMap<String, String> pollutionCategories = <String, String>{}.obs; // Map of category name to ID
  
  // === Report ID Search ===
  final reportIdController = TextEditingController();
  var isSearchingReport = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
    _listenToUserChanges();
    fetchNews();
  }
  
 Future<void> fetchNews() async {
  try {
    isNewsLoading.value = true;
    
    final List<NewsModel> newsList =
        await getNewsUseCase.execute();

    // if (newsList.isEmpty) {
    //   return;
    // }
    // Clear mock data
    imageUrls.clear();
    imageCaptions.clear();
    imageDates.clear();

    print("🔄 Here comes imageUrls: $imageUrls");
    for (final news in newsList) {
      final imageUrl = news.getImageUrl(ApiConstants.fileBaseUrl);
      if (imageUrl.isEmpty) continue;

      imageUrls.add(imageUrl);
      print("Here comes imageUrls: $imageUrls");
      imageCaptions[imageUrl] = news.title.isNotEmpty ? news.title : 'No title';
      final date = news.createdAt;
      final localDate = date.toLocal();
      imageDates[imageUrl] =
          '${_monthName(localDate.month)} ${localDate.day}, ${localDate.year}';
        }

    currentCarouselIndex.value = 0;

    print('✅ Loaded ${imageUrls.length} news items');
  } catch (e, stackTrace) {
    print('❌ Error fetching news: $e');
    print('Stack trace: $stackTrace');
    Get.snackbar(
      'Error',
      _cleanErrorMessage(e),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isNewsLoading.value = false;
  }
}


  // Get pollution category ID by name (handles various formats)
  String? getPollutionCategoryId(String categoryName) {
    print('🔍 Looking up pollution category for: "$categoryName"');
    
    // Normalize the input
    final normalized = categoryName.toLowerCase().trim();
    
    // Try direct lookup first
    var id = pollutionCategories[normalized];
    
    // If not found, try with capitalized first letter
    if (id == null && normalized.isNotEmpty) {
      final capitalized = normalized[0].toUpperCase() + normalized.substring(1);
      id = pollutionCategories[capitalized];
    }
    
    // If still not found, try exact match (case-insensitive)
    if (id == null) {
      for (var key in pollutionCategories.keys) {
        if (key.toLowerCase() == normalized) {
          id = pollutionCategories[key];
          break;
        }
      }
    }
    
    print('   Result: ${id != null ? "✅ Found ID: $id" : "❌ Not found"}');
    print('   Available categories: ${pollutionCategories.keys.toList()}');
    
    return id;
  }

  // FIXED: Load user from GetStorage (safe & fast)
  void _loadUserFromStorage() {
    userName.value = box.read('username') ?? box.read('full_name') ?? 'Guest';
    phoneNumber.value = box.read('phone') ?? '';

    // Optional: Welcome toast
    if (userName.value != 'Guest') {
      Future.delayed(const Duration(seconds: 1), () {
        Get.snackbar(
          'Welcome back!',
          userName.value,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      });
    }
  }

  // Keep the home header in sync when profile storage updates (e.g., after edit profile)
  void _listenToUserChanges() {
    box.listenKey('username', (value) {
      userName.value = (value ?? box.read('full_name') ?? 'Guest').toString();
    });
    box.listenKey('full_name', (value) {
      userName.value = (value ?? box.read('username') ?? 'Guest').toString();
    });
  }

 


 
  // === LOGOUT ===
  void logout() {
    box.erase();
    userName.value = 'Guest';
    phoneNumber.value = '';
    Get.offAllNamed('/splash');
  }

  // === SEARCH REPORT BY ID ===
  Future<void> searchReportById(String reportId) async {
    if (reportId.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a report ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isSearchingReport.value = true;

    try {
      final storage = Get.find<GetStorage>();
      final userId = storage.read('userId') ?? storage.read('user_id');
      final token = storage.read('auth_token');

      if (userId == null || token == null) {
        Get.snackbar(
          'Error',
          'Please login to search for reports',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isSearchingReport.value = false;
        return;
      }

      final httpClient = Get.find<DioClient>().dio;

      // Fetch all complaints and find the one with matching report_id
      final response = await httpClient.get(
        ApiConstants.complaintsEndpoint,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> complaintsList = [];
        
        if (data is List) {
          complaintsList = data;
        } else if (data is Map) {
          if (data['data'] is List) {
            complaintsList = data['data'];
          } else if (data['complaints'] is List) {
            complaintsList = data['complaints'];
          }
        }

        // Find complaint with matching report_id that belongs to current user
        dynamic foundComplaint;
        try {
          foundComplaint = complaintsList.firstWhere(
            (complaint) {
              if (complaint is! Map) return false;
              final complaintReportId = complaint['report_id']?.toString() ?? '';
              final complaintCustomerId = complaint['customer_id']?.toString();
              
              // Match report_id and verify it belongs to current user
              return complaintReportId.toLowerCase().trim() == reportId.toLowerCase().trim() &&
                     complaintCustomerId == userId.toString();
            },
          );
        } catch (e) {
          foundComplaint = null;
        }

        if (foundComplaint != null) {
          // Convert to ReportItem and navigate to detail view
          final reportItem = ReportItem.fromJson(
            foundComplaint is Map<String, dynamic> 
                ? foundComplaint 
                : Map<String, dynamic>.from(foundComplaint)
          );
          
          // Navigate to status detail view
          reportIdController.clear();
          Get.to(() => StatusDetailView(report: reportItem));
        } else {
          Get.snackbar(
            'Not Found',
            'Report ID not found or you do not have access to this report',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to search for report. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on dio.DioException catch (e) {
      Get.snackbar(
        'Error',
        _cleanErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        _cleanErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSearchingReport.value = false;
    }
  }

  String _cleanErrorMessage(Object error) {
    if (error is dio.DioException) {
      final data = error.response?.data;
      if (data is Map) {
        for (final key in ['message', 'msg', 'detail', 'error']) {
          final value = data[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
      final msg = error.message;
      if (msg != null && msg.trim().isNotEmpty) return msg.trim();
    }

    final text = error.toString();
    final cleaned = text
        .replaceAll('Exception: ', '')
        .replaceAll(RegExp(r'^DioException[^:]*:\s*'), '')
        .trim();
    return cleaned.isEmpty ? 'Something went wrong' : cleaned;
  }

}

// === MODELS ===

