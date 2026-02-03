/// API constants for the application
class ApiConstants {
  // Base URL - Update this with your actual backend URL
  static const String baseUrl = 'https://cleanethiopia.epa.gov.et/api/';
  static const String fileBaseUrl = '/';
  // static const String baseUrl = 'http://10.179.217.61:5000/api/';
  
  // Authentication endpoints
  static const String loginEndpoint = 'customer-accounts/login';
  static const String logoutEndpoint = 'auth/logout';
  static const String registerEndpoint = 'customer-accounts';
  static const String verifyOtpEndpoint = 'customer-accounts/verify-otp';
  static const String resendOtpEndpoint = 'customer-accounts/resend-otp';
    // Guest report OTP endpoints (full URLs; bypass baseUrl prefix)
    static const String requestReportOtpEndpoint =
      'guest/request-otp';
    static const String verifyReportOtpEndpoint =
      'guest/verify-otp';
  
  // Location endpoints (full URLs using baseUrl)
  static const String regionsEndpoint = '${baseUrl}regions';
  static const String citiesEndpoint = '${baseUrl}cities';
  // zones endpoint can be queried as '${zonesByRegionEndpoint}/region/{regionId}'
  static const String zonesByRegionEndpoint = '${baseUrl}zones/region';
  // woredas endpoint can be queried as '${woredasByLocationEndpoint}/location/{zoneId}'
  static const String woredasByLocationEndpoint = '${baseUrl}woredas/location';

  static const String subCitiesEndpoint = '${baseUrl}sub-cities';
  
  // Pollution categories endpoint
  static const String pollutionCategoriesEndpoint = '${baseUrl}pollution-categories';
  
  // Complaints endpoint
  static const String complaintsEndpoint = '${baseUrl}complaints';
  // Get complaints by customer id
  static String complaintsByCustomerEndpoint(String customerId) => '${baseUrl}complaints/get_by_customer_id/$customerId';
  static String complaintByIdEndpoint(String complaintId) => '${baseUrl}complaints/$complaintId';
  static String complaintByReportId(String reportId) => '${baseUrl}complaints/get_by_report_id/$reportId';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String officesEndpoint = '${baseUrl}epa-office-locations';
  
  // Awareness endpoint
  static const String awarenessEndpoint = '${baseUrl}awareness';

  // Sound areas endpoint
  static const String soundAreasEndpoint = '${baseUrl}sound-areas';


  //News endpoint
  static const String newsEndpoint = '${baseUrl}news';

  // Update profile endpoint
  static String updateProfileEndpoint(String id) => '${baseUrl}customer-accounts/update/$id';
}

