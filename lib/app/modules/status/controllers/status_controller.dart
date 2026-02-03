import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class ReportItem {
  final String? id;
  final String? reportId; // Store report_id separately
  final String title;
  final String? reportType;
  final String status;
  final String description;
  final String date; // date display (e.g., Sep 12, 2022)
  final String? time; // time display (e.g., 09:10:22 PM)
  final List<ActivityLog>? activityLogs;

  ReportItem({
    this.id,
    this.reportId,
    required this.title,
    this.reportType,
    required this.status,
    required this.description,
    required this.date,
    this.time = '',
    this.activityLogs,
  });

  // Factory constructor to create ReportItem from API response
  factory ReportItem.fromJson(Map<String, dynamic> json) {
    // Parse date - handle different date formats
    String dateStr = '';
    String timeStr = '';
    if (json['created_at'] != null) {
      try {
        final date = DateTime.parse(json['created_at'].toString());
        dateStr = _formatDateDisplay(date);
        final hh = date.hour % 12 == 0 ? 12 : date.hour % 12;
        final mm = date.minute.toString().padLeft(2, '0');
        final ss = date.second.toString().padLeft(2, '0');
        final ampm = date.hour >= 12 ? 'PM' : 'AM';
        timeStr = '$hh:$mm:$ss $ampm';
      } catch (e) {
        dateStr = _formatDateString(json['created_at'].toString());
        timeStr = '';
      }
    } else if (json['date'] != null) {
      final rawDate = json['date'].toString();
      try {
        final date = DateTime.parse(rawDate);
        dateStr = _formatDateDisplay(date);
        if (json['time'] != null && json['time'].toString().isNotEmpty) {
          timeStr = json['time'].toString();
        } else {
          final hh = date.hour % 12 == 0 ? 12 : date.hour % 12;
          final mm = date.minute.toString().padLeft(2, '0');
          final ss = date.second.toString().padLeft(2, '0');
          final ampm = date.hour >= 12 ? 'PM' : 'AM';
          timeStr = '$hh:$mm:$ss $ampm';
        }
      } catch (_) {
        dateStr = _formatDateString(rawDate);
        timeStr = json['time']?.toString() ?? '';
      }
    } else {
      dateStr = 'N/A';
      timeStr = json['time']?.toString() ?? '';
    }

    // Map status - handle different status formats
    String status = 'Pending';
    if (json['status'] != null) {
      final statusStr = json['status'].toString();
      final normalized = statusStr.toLowerCase().replaceAll('_', ' ');
      if (normalized.contains('pending')) {
        status = 'Pending';
      } else if (normalized.contains('under review') || normalized.contains('progress')) {
        status = 'Under Review';
      } else if (normalized.contains('under investigation')) {
        status = 'Under Investigation';
      } else if (normalized.contains('verified')) {
        status = 'Verified';
      } else if (normalized.contains('closed by penality')) {
        status = 'Closed by penality';
      } else if (normalized.contains('closed by pollutant not found')) {
        status = 'Closed by pollutant not found';
      } else if (normalized.contains('completed') || normalized.contains('closed') || normalized.contains('complete')) {
        status = 'Complete';
      } else if (normalized.contains('rejected')) {
        status = 'Rejected';
      } else {
        status = statusStr;
      }
    }

    // Extract pollution category - handle both string and object formats
    String pollutionCategory = 'Pollution';
    if (json['pollution_category'] != null) {
      if (json['pollution_category'] is Map) {
        pollutionCategory = json['pollution_category']['pollution_category']?.toString() ?? 
                           json['pollution_category']['name']?.toString() ?? 
                           'Pollution';
      } else {
        pollutionCategory = json['pollution_category'].toString();
      }
    } else if (json['category'] != null) {
      pollutionCategory = json['category'].toString();
    } else if (json['report_type'] != null) {
      pollutionCategory = json['report_type'].toString();
    }

    // Extract description - ensure it's a clean string
    String descriptionText = 'No description available';
    if (json['detail'] != null) {
      descriptionText = json['detail'].toString();
    } else if (json['description'] != null) {
      descriptionText = json['description'].toString();
    } else if (json['details'] != null) {
      descriptionText = json['details'].toString();
    }

    // Parse activity logs if present
    final List<ActivityLog> logs = [];
    if (json['activity_logs'] is List) {
      for (final log in json['activity_logs']) {
        if (log is Map<String, dynamic>) {
          logs.add(ActivityLog.fromJson(log));
        }
      }
    }

    return ReportItem(
      id: json['complaint_id']?.toString() ?? 
          json['id']?.toString() ?? 
          json['complaintId']?.toString(),
      reportId: json['report_id']?.toString(), // Store report_id separately
      title: json['title']?.toString() ?? 
             json['report_id']?.toString() ??
             pollutionCategory,
      reportType: pollutionCategory,
      status: status,
      description: descriptionText,
      date: dateStr,
      time: timeStr,
      activityLogs: logs,
    );
  }

  static String _getMonthAbbrev(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Format DateTime to "Mon d, yyyy"
  static String _formatDateDisplay(DateTime date) {
    return '${_getMonthAbbrev(date.month)} ${date.day}, ${date.year}';
  }

  // Best-effort formatter for string dates; strips trailing time if present.
  static String _formatDateString(String raw) {
    if (raw.isEmpty) return 'N/A';
    // Try parsing directly
    final parsed = DateTime.tryParse(raw) ?? DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (parsed != null) {
      return _formatDateDisplay(parsed);
    }
    // Try to extract "Month day, year" from strings with time
    final reg = RegExp(r'([A-Za-z]+)\s+(\d{1,2}),\s*(\d{4})');
    final m = reg.firstMatch(raw);
    if (m != null) {
      return '${m.group(1)} ${m.group(2)}, ${m.group(3)}';
    }
    // Fallback: strip anything after first time separator
    if (raw.contains(':')) {
      final parts = raw.split(' ');
      // keep up to the token before the first token containing ':'
      final trimmed = parts.takeWhile((p) => !p.contains(':')).join(' ');
      if (trimmed.isNotEmpty) return trimmed;
    }
    return raw;
  }
}

class ActivityLog {
  final String? activityLogId;
  final String? userId;
  final String? oldStatus;
  final String? newStatus;
  final String? description;
  final String? createdAt;

  ActivityLog({
    this.activityLogId,
    this.userId,
    this.oldStatus,
    this.newStatus,
    this.description,
    this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      activityLogId: json['activity_log_id']?.toString() ?? json['id']?.toString(),
      userId: json['user_id']?.toString(),
      oldStatus: json['old_status']?.toString(),
      newStatus: json['new_status']?.toString() ?? json['newStatus']?.toString(),
      description: json['description']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }
}
class StatusController extends GetxController {
  // simple counter left for possible future use
  final count = 0.obs;

  /// Current selected filter (All, Pending, In Progress, Completed, Rejected)
  var selectedFilter = 'All'.obs;

  /// All reports (fetched from API)
  final RxList<ReportItem> allReports = <ReportItem>[].obs;

  /// Filtered reports exposed to the view
  final RxList<ReportItem> filteredReports = <ReportItem>[].obs;

  /// Loading state
  var isLoading = false.obs;

  /// Error message
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchComplaints();
  }

  /// Fetch complaints from API and filter by current user ID
  Future<void> fetchComplaints() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final storage = Get.find<GetStorage>();
      final userId = storage.read('userId') ?? storage.read('user_id');
      
      if (userId == null) {
        errorMessage.value = 'User not logged in. Please login to view your complaints.';
        isLoading.value = false;
        return;
      }

      final httpClient = Get.find<DioClient>().dio;
      final token = storage.read('auth_token');

      // Fetch complaints for the current user from API
      final response = await httpClient.get(
        ApiConstants.complaintsByCustomerEndpoint(userId.toString()),
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'accept': '*/*',
          },
        ),
      );
      print('Complaints API Response: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print('Complaints Data: $data');
        // Handle different response formats
        List<dynamic> complaintsList = [];
        
        if (data is List) {
          complaintsList = data;
        } else if (data is Map) {
          // Check for nested data first (API returns {success: true, count: 36, data: [...]})
          if (data['data'] is List) {
            complaintsList = data['data'];
          } else if (data['complaints'] is List) {
            complaintsList = data['complaints'];
          } else {
            // Single complaint object
            complaintsList = [data];
          }
        }

        // Convert to ReportItem list (API already returns only this user's complaints)
        allReports.assignAll(
          complaintsList.map((json) => ReportItem.fromJson(
            json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)
          )).toList(),
        );

        // Initialize filtered list
        applyFilter();
      } else {
        errorMessage.value = 'Failed to fetch complaints. Please try again.';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // No complaints found - this is okay, just show empty list
        allReports.clear();
        applyFilter();
      } else {
        errorMessage.value = e.response?.data?['message']?.toString() ?? 
                            e.message ?? 
                            'Failed to fetch complaints. Please check your connection.';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh complaints
  Future<void> refreshComplaints() async {
    await fetchComplaints();
  }

  void increment() => count.value++;

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }

  void applyFilter() {
    final f = selectedFilter.value;
    if (f == 'All') {
      filteredReports.assignAll(allReports);
    } else {
      filteredReports.assignAll(allReports.where((r) => r.status == f));
    }
  }

  /// Fetch a single complaint by ID (includes activity logs)
  Future<ReportItem?> fetchComplaintById(String complaintId) async {
    try {
      final storage = Get.find<GetStorage>();
      final token = storage.read('auth_token');
      
      if (token == null) {
        return null;
      }

      final httpClient = Get.find<DioClient>().dio;

      final response = await httpClient.get(
        ApiConstants.complaintByIdEndpoint(complaintId),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Handle different response formats
        Map<String, dynamic> complaintData;
        if (data is Map) {
          if (data['data'] is Map) {
            complaintData = Map<String, dynamic>.from(data['data']);
          } else {
            complaintData = Map<String, dynamic>.from(data);
          }
        } else {
          return null;
        }

        return ReportItem.fromJson(complaintData);
      }
      return null;
    } on DioException catch (e) {
      print('Error fetching complaint by ID: ${e.message}');
      return null;
    } catch (e) {
      print('Error fetching complaint by ID: ${e.toString()}');
      return null;
    }
  }
  
  Future<ReportItem?> fetchComplaintByReportId(String reportId) async {
    try {
      final storage = Get.find<GetStorage>();
      final token = storage.read('auth_token');

      final httpClient = Get.find<DioClient>().dio;

      final response = await httpClient.get(
        ApiConstants.complaintByReportId(reportId),
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print('Complaint by reportId response: $data');

        // Normalize possible shapes: {data: {...}}, {complaint: {...}}, list, or direct object
        Map<String, dynamic>? complaint;

        if (data is Map) {
          if (data['data'] is Map) {
            complaint = Map<String, dynamic>.from(data['data']);
          } else if (data['complaint'] is Map) {
            complaint = Map<String, dynamic>.from(data['complaint']);
          } else if (data.isNotEmpty) {
            complaint = Map<String, dynamic>.from(data);
          }
        } else if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map<String, dynamic>) {
            complaint = first;
          } else if (first is Map) {
            complaint = Map<String, dynamic>.from(first);
          }
        }

        if (complaint == null || complaint.isEmpty) return null;
        return ReportItem.fromJson(complaint);
      }
      return null;
    } on DioException catch (e) {
      print('Error fetching complaint by Report ID: ${e.response?.statusCode} ${e.message}');
      return null;
    } catch (e) {
      print('Error fetching complaint by Report ID: ${e.toString()}');
      return null;
    }
  }

}
