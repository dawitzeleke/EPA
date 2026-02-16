import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:eprs/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:noise_meter/noise_meter.dart' as noise_meter;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart' as dio;
import 'package:eprs/core/network/dio_client.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'package:eprs/app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/data/models/sound_area_model.dart';
import 'package:eprs/domain/usecases/get_sound_areas_usecase.dart';
import 'package:eprs/domain/usecases/get_cities_usecase.dart';
import 'package:eprs/core/enums/report_type_enum.dart';
import 'package:eprs/core/utils/secure_log.dart';

class ReportController extends GetxController {
  final GetSoundAreasUseCase getSoundAreasUseCase;
  final GetCitiesUseCase getCitiesUseCase;

  ReportController({
    required this.getSoundAreasUseCase,
    required this.getCitiesUseCase,
  });

  // State
  final count = 0.obs;

  final isInTheSpot =
      Rxn<bool>(); // "Are you in the spot" - null initially (neither selected)
  final hasSelectedLocationOption =
      false.obs; // Track if user has made a selection
  final autoDetectLocation = true.obs;
  final detectedAddress = 'Tap Search Location\nAddis Ababa | N.L | W-1'.obs;

  final selectedRegion = 'Select Region / City Administration'.obs;
  final selectedZone = 'Select Zone / Sub-City'.obs;
  final selectedWoreda = 'Select Woreda'.obs;

  // Sound areas (for sound report type)
  final soundAreas = <SoundAreaModel>[].obs;
  final isLoadingSoundAreas = false.obs;
  final soundAreasError = RxnString();
  final selectedSoundAreaId = RxnString();

// Polution category ID (for non-sound report types)
final pollutionCategoriesError = RxnString();
final isLoadingPollutionCategories = false.obs;

// === Pollution Categories ===
  final selectedPollutionCategoryId = RxnString();
  final RxMap<String, String> pollutionCategories = <String, String>{}.obs;
  final RxMap<String, bool> pollutionCategoryIsSound = <String, bool>{}.obs;
  final RxList<Map<String, String>> pollutionCategoriesSound = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> pollutionCategoriesNormal = <Map<String, String>>[].obs;

  // API-backed location lists (each item: {'id': '...', 'name': '...'})
  final regions = <Map<String, String>>[].obs;
  final cities = <Map<String, String>>[].obs;
  final regionsAndCities = <Map<String, String>>[].obs; // Combined list
  final zones = <Map<String, String>>[].obs;
  final woredas = <Map<String, String>>[].obs;
  final subcities = <Map<String, String>>[].obs;
  final isLoadingRegions = false.obs;
  final isLoadingCities = false.obs;
  final isLoadingZones = false.obs;
  final isLoadingWoredas = false.obs;
  // Store XFile for web compatibility
  // Renamed from pickedImages to force new instance (fixes hot reload type issues)
  final pickedImagesX = <XFile>[].obs;

  // Getter for backward compatibility
  RxList<XFile> get pickedImages => pickedImagesX;

  // Helper to add a file
  void addPickedImage(XFile file) {
    pickedImagesX.add(file);
    // Force update - RxList should auto-update but ensure it does
    pickedImagesX.refresh();
    secureLog(
      '📁 File added to list. Total: ${pickedImagesX.length}, Name: ${file.name}',
    );
  }

  /// Submit any pending guest report after OTP verification.
  Future<void> submitPendingReportAfterOtp({
    required String phone,
    String? token,
  }) async {
    if (_pendingFormData == null) {
      Get.snackbar(
        'No pending report',
        'Please fill out the report again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Ensure phone is attached once
    final hasPhone = _pendingFormData!.fields.any((f) => f.key == 'phone');
    if (!hasPhone) {
      _pendingFormData!.fields.add(MapEntry('phone', phone));
    }

    isSubmitting.value = true;
    try {
      await _submitFormData(
        httpClient: Get.find<DioClient>().dio,
        formData: _pendingFormData!,
        token: token,
        regionToPass: _pendingRegionForSuccess ?? selectedRegion.value,
        isLoggedIn: false,
      );
    } finally {
      _pendingFormData = null;
      _pendingRegionForSuccess = null;
    }
  }

  // Helper to remove a file
  void removePickedImageAt(int index) {
    if (index >= 0 && index < pickedImagesX.length) {
      pickedImagesX.removeAt(index);
    }
  }

  final isDetecting = false.obs;
  final detectionError = RxnString();
  final detectedPosition = Rxn<Position>();

  final phoneOptIn = false.obs;
  final isLoggedIn = false.obs;
  final box = GetStorage();
  // Logged-in user's display name
  final name = ''.obs;

  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();
  final soundPeriod = 'Day'.obs; // 'Day' or 'Night' for sound reports

  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final obscurePhoneNumber = false.obs;
  final phoneError = ''.obs;

  final termsAccepted = false.obs;

  // Report type and pollution category ID
  String reportType = '';
  String? pollutionCategoryId; // Will be set from route arguments

  // Loading state for submission
  final isSubmitting = false.obs;

  // Pending data for guest flow (submit after OTP verification)
  dio.FormData? _pendingFormData;
  String? _pendingRegionForSuccess;

  bool get hasPendingReport => _pendingFormData != null;



  // Public wrapper to keep existing calls working

  // Audio recording state
  late final RecorderController recorderController;
  // Use explicit encoder settings for more reliable recording across devices
  final RecorderSettings recorderSettings = const RecorderSettings(
    androidEncoderSettings: AndroidEncoderSettings(
      androidEncoder: AndroidEncoder.aacLc,
    ),
    iosEncoderSettings: IosEncoderSetting(
      iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
    ),
    sampleRate: 44100,
    bitRate: 128000,
  );
  final isRecording = false.obs;
  final isPaused = false.obs;
  final recordingDuration = Duration.zero.obs;
  final audioFilePath = RxnString();
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;
  Duration _pausedDuration = Duration.zero;
  DateTime? _pauseStartTime;

  // Noise meter state
  noise_meter.NoiseMeter? _noiseMeter;
  StreamSubscription<noise_meter.NoiseReading>? _noiseSubscription;
  final currentDecibel = 0.0.obs; // Current decibel reading
  final maxDecibel = 0.0.obs; // Maximum decibel reading during recording
  final showMinDecibelWarning = false.obs;

  // ----------------------------
  // SOUND AREA DECIBEL RULES
  // ----------------------------
  SoundAreaModel? _getSelectedSoundArea() {
    final selectedId = selectedSoundAreaId.value;
    if (selectedId == null) return null;
    for (final area in soundAreas) {
      if (area.id == selectedId) return area;
    }
    return null;
  }

  double? _resolveMinDecibelForAreaName(String name, {required bool isNight}) {
    final n = name.toLowerCase();

    if (n.contains('residential')) return isNight ? 45 : 55;
    if (n.contains('commercial')) return isNight ? 55 : 65;
    if (n.contains('industrial')) return isNight ? 70 : 75;

    final isPreschool = n.contains('pre') && n.contains('school');
    final isSchoolIndoor =
        n.contains('school') && (n.contains('indoor') || n.contains('class'));
    if (isPreschool || isSchoolIndoor) return isNight ? 30 : 35;

    final isSchoolOutdoor =
        n.contains('school') && (n.contains('outdoor') || n.contains('play'));
    if (isSchoolOutdoor) return 80;

    if (n.contains('hospital') || n.contains('ward')) return 30;

    if (n.contains('ceremony') ||
        n.contains('festival') ||
        n.contains('entertainment') ||
        n.contains('event')) {
      return 100;
    }

    return null;
  }

  double? get minRequiredDecibel {
    if (reportType != ReportTypeEnum.sound.name) return null;
    final area = _getSelectedSoundArea();
    if (area == null) return null;
    final isNight = soundPeriod.value.toLowerCase() == 'night';
    return _resolveMinDecibelForAreaName(area.name, isNight: isNight);
  }

  bool get isBelowMinDecibel {
    final minDb = minRequiredDecibel;
    if (minDb == null) return false;
    return maxDecibel.value < minDb;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize recorder controller
    recorderController = RecorderController();

    // Enforce max 10 digits on phone input even if pasted
    phoneController.addListener(() {
      const maxLen = 10;
      final text = phoneController.text;
      if (text.length > maxLen) {
        final truncated = text.substring(0, maxLen);
        phoneController.value = phoneController.value.copyWith(
          text: truncated,
          selection: TextSelection.collapsed(offset: truncated.length),
          composing: TextRange.empty,
        );
      }

      // Simple prefix validation: must start with 09 or 07
      final current = phoneController.text;
      if (current.isEmpty) {
        phoneError.value = '';
      } else if (current[0] != '0') {
        phoneError.value = 'Phone number must start with 09 or 07';
      } else if (current.length >= 2 &&
          !(current.startsWith('09') || current.startsWith('07'))) {
        phoneError.value = 'Phone number must start with 09 or 07';
      } else {
        phoneError.value = '';
      }
    });



    // Reset form to ensure clean state when entering the page
    _resetForm();
    _loadAuthState();

    // Get report type and pollution category ID from arguments
    final args = Get.arguments;
    if (args is String) {
      reportType = args;
    } else if (args is Map) {
      if (args['reportType'] is String) {
        reportType = args['reportType'];
      }
      if (args['pollutionCategoryId'] is String) {
        pollutionCategoryId = args['pollutionCategoryId'];
        secureLog(
          'Received pollution category ID from route: $pollutionCategoryId',
        );
      } else {
        secureLog(
          'No pollution category ID in route arguments. Available keys: ${args.keys.toList()}',
        );
      }
    }

    if (autoDetectLocation.value) {
      detectLocation();
    }
    // Fetch regions and cities from API
    fetchRegions();
    fetchCities();

    // Fetch sound areas only for sound report type
    if (reportType == ReportTypeEnum.sound.name) {
      fetchSoundAreas();
    }
    fetchPollutionCategories();
  }

  void loadAuthState() {
    final token = box.read('auth_token');
    isLoggedIn.value = token != null && token.toString().isNotEmpty;

    // Pre-fill phone if available
    final storedPhone = box.read('phone')?.toString();
    if (isLoggedIn.value && storedPhone != null && storedPhone.isNotEmpty) {
      phoneController.text = storedPhone;
    }

    // Load display name if available (supports multiple keys)
    final storedName =
        box.read('username')?.toString() ??
        box.read('fullName')?.toString() ??
        box.read('name')?.toString();
    if (isLoggedIn.value &&
        storedName != null &&
        storedName.trim().isNotEmpty) {
      name.value = storedName.trim();
    }
  }

  // Private method for backward compatibility
  void _loadAuthState() => loadAuthState();

  // Reset form to initial state (made public so it can be called from view)
  void resetForm() {
    // Clear text fields
    descriptionController.clear();
    phoneController.clear();
    phoneError.value = '';

    // Clear selected values
    selectedRegion.value = 'Select Region / City Administration';
    selectedZone.value = 'Select Zone / Sub-City';
    selectedWoreda.value = 'Select Woreda';

    // Clear location data
    regions.clear();
    cities.clear();
    regionsAndCities.clear();
    zones.clear();
    woredas.clear();

    // Clear picked images
    pickedImagesX.clear();

    // Clear cached pollution categories
    pollutionCategories.clear();
    pollutionCategoryIsSound.clear();
    pollutionCategoriesSound.clear();
    pollutionCategoriesNormal.clear();

    // Set date and time to current date and time
    final now = DateTime.now();
    selectedDate.value = now;
    selectedTime.value = TimeOfDay.fromDateTime(now);
    soundPeriod.value = 'Day';
    selectedSoundAreaId.value = null;

    // Clear location detection - reset to initial state (null = neither selected)
    isInTheSpot.value = null;
    hasSelectedLocationOption.value = false;
    detectedPosition.value = null;
    detectedAddress.value = 'Tap Search Location\nAddis Ababa | N.L | W-1';
    autoDetectLocation.value = false;

    // Clear terms acceptance
    termsAccepted.value = false;
    phoneOptIn.value = false;
    obscurePhoneNumber.value = false;

    // Clear audio recording
    audioFilePath.value = null;
    isRecording.value = false;
    isPaused.value = false;
    recordingDuration.value = Duration.zero;
    try {
      if (recorderController.isRecording) {
        recorderController.stop();
      }
    } catch (_) {}

    // Clear noise meter readings
    currentDecibel.value = 0.0;
    maxDecibel.value = 0.0;
    showMinDecibelWarning.value = false;
    _noiseSubscription?.cancel();
    _noiseSubscription = null;

    // Reset pollution category ID
    pollutionCategoryId = null;
    selectedPollutionCategoryId.value = null;

    secureLog('Form reset completed');
  }

  /// Load sound areas from API
  Future<void> fetchSoundAreas() async {
    isLoadingSoundAreas.value = true;
    soundAreasError.value = null;
    try {
      final areas = await getSoundAreasUseCase.execute();
      soundAreas.assignAll(areas);
      // Reset selection if list is available
      if (areas.isNotEmpty) {
        selectedSoundAreaId.value = null;
      }
    } catch (e) {
      soundAreasError.value = _cleanErrorMessage(e);
    } finally {
      isLoadingSoundAreas.value = false;
    }
  }

  // Fetch pollution categories from API
  Future<void> fetchPollutionCategories() async {
    secureLog('Starting to fetch pollution categories...');
    isLoadingPollutionCategories.value = true;
    pollutionCategoriesError.value = null;
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = box.read('auth_token');
      final res = await httpClient.get(
        ApiConstants.pollutionCategoriesEndpoint,
        options: dio.Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      
      secureLog('📡 Pollution Categories API Response: ${res.data}');
      secureLog('📡 Response Status Code: ${res.statusCode}');
      
      final data = res.data;
      List items = [];
      if (data is List) {
        items = data;
        secureLog('✓ Categories data is a direct List with ${items.length} items');
      } else if (data is Map) {
        if (data['data'] is List) {
          items = data['data'];
          secureLog('✓ Categories data found in "data" key with ${items.length} items');
        } else if (data['categories'] is List) {
          items = data['categories'];
          secureLog('✓ Categories data found in "categories" key with ${items.length} items');
        } else {
          secureLog('⚠️ Could not find categories array. Available keys: ${data.keys.toList()}');
        }
      }
      
      pollutionCategories.clear();
      pollutionCategoryIsSound.clear();
      pollutionCategoriesSound.clear();
      pollutionCategoriesNormal.clear();

      final seenSoundIds = <String>{};
      final seenNormalIds = <String>{};
      for (var item in items) {
        if (item is Map) {
          final id = item['pollution_category_id']?.toString() ?? item['id']?.toString() ?? '';
          final name = item['pollution_category']?.toString() ?? item['name']?.toString() ?? '';
          final isSound = _parseIsSoundFlag(item['is_sound']);
          if (id.isNotEmpty && name.isNotEmpty) {
            // Store multiple variations for flexible lookup
            final normalizedName = name.toLowerCase().trim();
            pollutionCategories[normalizedName] = id; // lowercase: "pollution"
            pollutionCategories[name.trim()] = id; // original case: "Pollution"
            pollutionCategories[name.trim().toLowerCase()] = id; // lowercase original: "pollution"

            // Track if category is for sound-only reports
            pollutionCategoryIsSound[id] = isSound;

            // Store categorized lists (dedup by id)
            final displayName = name.trim();
            if (isSound) {
              if (!seenSoundIds.contains(id)) {
                pollutionCategoriesSound.add({'id': id, 'name': displayName});
                seenSoundIds.add(id);
              }
            } else {
              if (!seenNormalIds.contains(id)) {
                pollutionCategoriesNormal.add({'id': id, 'name': displayName});
                seenNormalIds.add(id);
              }
            }
            
            // Also handle common variations
            if (normalizedName == 'pollution') {
              pollutionCategories['air pollution'] = id;
            }
            
            secureLog('📋 Loaded category: "$name" (ID: $id)');
            secureLog('   - Stored as: "$normalizedName", "${name.trim()}"');
          }
        }
      }
      
      secureLog('✅ Loaded ${pollutionCategories.length} pollution category mappings');
      secureLog('   Available keys: ${pollutionCategories.keys.toList()}');
    } catch (e, stackTrace) {
      secureLog('❌ Error fetching pollution categories: $e');
      secureLog('Stack trace: $stackTrace');
      pollutionCategoriesError.value = _cleanErrorMessage(e);
    }
    isLoadingPollutionCategories.value = false;
  }
  

  /// Update selected sound area
  void selectSoundArea(String? id) {
    selectedSoundAreaId.value = id;
  }

  void selectPollutionCategory(String? id) {
    selectedPollutionCategoryId.value = id;
  }
  // Private method for internal use (calls public resetForm)
  void _resetForm() => resetForm();

  @override
  void onClose() {
    // Ensure recording is stopped before disposing
    try {
      if (isRecording.value || isPaused.value) {
        recorderController.stop();
      }
    } catch (_) {}
    isRecording.value = false;
    isPaused.value = false;
    recordingDuration.value = Duration.zero;
    audioFilePath.value = null;
    _recordingTimer?.cancel();
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    recorderController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // ----------------------------
  // LOCAL DATA (temporary - replace with API later)
  // ----------------------------
  void loadLocalRegions() {
    regions.clear();
    regions.addAll([
      {'id': 'bc7e6719-cfe4-4464-b237-2b0df88dd734', 'name': 'Oromia'},
      {'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'name': 'Amhara'},
      {'id': 'f1e2d3c4-b5a6-9876-5432-10fedcba9876', 'name': 'Tigray'},
      {'id': '12345678-1234-1234-1234-123456789abc', 'name': 'SNNPR'},
      {'id': 'abcdef12-3456-7890-abcd-ef1234567890', 'name': 'Addis Ababa'},
    ]);
  }

  void loadLocalZones(String regionId) {
    zones.clear();
    selectedZone.value = 'Select Zone / Sub-City';
    woredas.clear();
    selectedWoreda.value = 'Select Woreda';

    // Sample zones for Oromia
    if (regionId == 'bc7e6719-cfe4-4464-b237-2b0df88dd734') {
      zones.addAll([
        {'id': '11111111-1111-1111-1111-111111111111', 'name': 'East Shewa'},
        {'id': '22222222-2222-2222-2222-222222222222', 'name': 'West Shewa'},
        {'id': '33333333-3333-3333-3333-333333333333', 'name': 'North Shewa'},
      ]);
    } else {
      // Default zones for other regions
      zones.addAll([
        {'id': '11111111-1111-1111-1111-111111111111', 'name': 'Zone 1'},
        {'id': '22222222-2222-2222-2222-222222222222', 'name': 'Zone 2'},
        {'id': '33333333-3333-3333-3333-333333333333', 'name': 'Zone 3'},
      ]);
    }
  }

  void loadLocalWoredas(String zoneId) {
    woredas.clear();
    selectedWoreda.value = 'Select Woreda';

    // Sample woredas with valid UUIDs
    woredas.addAll([
      {'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'name': 'Woreda 1'},
      {'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'name': 'Woreda 2'},
      {'id': 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'name': 'Woreda 3'},
    ]);
  }

  // ----------------------------
  // DATE PICKER
  // ----------------------------
  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day - 10);
    final last = DateTime(now.year, now.month, now.day);

    DateTime initial = selectedDate.value ?? now;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFFF6F6FA),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) selectedDate.value = picked;
  }

  // ----------------------------
  // TIME PICKER (CUSTOM AM/PM)
  // ----------------------------
Future<void> pickTime(BuildContext context) async {
  final DateTime now = DateTime.now();
  final TimeOfDay initial = selectedTime.value ?? TimeOfDay.fromDateTime(now);

  int selectedHour;
  int selectedMinute = initial.minute;
  bool isAM;

  // ─── Convert initial time to 12-hour ───
  if (initial.hour == 0) {
    selectedHour = 12;
    isAM = true;
  } else if (initial.hour == 12) {
    selectedHour = 12;
    isAM = false;
  } else if (initial.hour > 12) {
    selectedHour = initial.hour - 12;
    isAM = false;
  } else {
    selectedHour = initial.hour;
    isAM = true;
  }

  final bool isToday =
      selectedDate.value?.year == now.year &&
      selectedDate.value?.month == now.month &&
      selectedDate.value?.day == now.day;

  // Current time in 12-hour format to help disable periods
  final bool nowIsAM = now.hour < 12;

  // ─── SINGLE SOURCE OF TRUTH (FIX) ───
  bool isFutureTime(int hour12, int minute, bool am) {
    if (!isToday) return false;

    int hour24 = hour12;
    if (am && hour12 == 12) hour24 = 0;
    if (!am && hour12 != 12) hour24 = hour12 + 12;

    final DateTime selected = DateTime(
      now.year,
      now.month,
      now.day,
      hour24,
      minute,
    );

    return selected.isAfter(now);
  }

  // Disable entire period when all its times are in the future
  bool isPeriodCompletelyFuture(bool am) {
    if (!isToday) return false;
    // If it's AM now, the entire PM is in the future
    if (!am) return nowIsAM;
    // AM is never completely future for today
    return false;
  }

  final picked = await showDialog<TimeOfDay>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select time',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ───────── TIME PICKERS ─────────
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ─── Hour ───
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 50,
                            physics: const FixedExtentScrollPhysics(),
                            controller: FixedExtentScrollController(
                              initialItem: selectedHour - 1,
                            ),
                            onSelectedItemChanged: (index) {
                              final h = index + 1;
                              if (isFutureTime(h, selectedMinute, isAM)) return;

                              setState(() => selectedHour = h);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 12,
                              builder: (_, i) {
                                final hour = i + 1;
                                final isSelected = hour == selectedHour;
                                final disabled =
                                    isFutureTime(hour, selectedMinute, isAM);

                                return Center(
                                  child: Text(
                                    hour.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: isSelected ? 32 : 24,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: disabled
                                          ? Colors.grey.shade400
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // ─── Minute ───
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 50,
                            physics: const FixedExtentScrollPhysics(),
                            controller: FixedExtentScrollController(
                              initialItem: selectedMinute,
                            ),
                            onSelectedItemChanged: (index) {
                              if (isFutureTime(
                                  selectedHour, index, isAM)) {
                                return;
                              }

                              setState(() => selectedMinute = index);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 60,
                              builder: (_, minute) {
                                final isSelected = minute == selectedMinute;
                                final disabled = isFutureTime(
                                  selectedHour,
                                  minute,
                                  isAM,
                                );

                                return Center(
                                  child: Text(
                                    minute.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: isSelected ? 32 : 24,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: disabled
                                          ? Colors.grey.shade400
                                          : isSelected
                                              ? AppColors.primary
                                              : Colors.black87,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ───────── AM / PM ─────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: isPeriodCompletelyFuture(true)
                            ? null
                            : () {
                                if (isFutureTime(selectedHour, selectedMinute, true)) return;
                                setState(() => isAM = true);
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isAM ? AppColors.primary : null,
                        ),
                        child: const Text('AM'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: isPeriodCompletelyFuture(false)
                            ? null
                            : () {
                                if (isFutureTime(selectedHour, selectedMinute, false)) return;
                                setState(() => isAM = false);
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: !isAM ? AppColors.primary : null,
                        ),
                        child: const Text('PM'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ───────── ACTIONS ─────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: isFutureTime(selectedHour, selectedMinute, isAM)
                            ? null
                            : () {
                                int hour24 = selectedHour;
                                if (isAM && hour24 == 12) hour24 = 0;
                                if (!isAM && hour24 != 12) hour24 += 12;

                                Navigator.pop(
                                  ctx,
                                  TimeOfDay(
                                    hour: hour24,
                                    minute: selectedMinute,
                                  ),
                                );
                              },
                        child: Text(
                          'OK',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (picked != null) {
    selectedTime.value = picked;
  }
}

  // ----------------------------
  // LOCATION API (regions / cities / zones / woredas)
  // ----------------------------
  Future<void> fetchRegions() async {
    isLoadingRegions.value = true;
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await httpClient.get(
        ApiConstants.regionsEndpoint,
        options: dio.Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      secureLog('Regions API Response: ${res.data}');
      secureLog('Response Type: ${res.data.runtimeType}');

      final data = res.data;
      List items = [];
      if (data is List) {
        items = data;
        secureLog('Data is a List with ${items.length} items');
      } else if (data is Map) {
        // Try multiple possible keys for the data array
        if (data['data'] is List) {
          items = data['data'];
          secureLog('Data found in data key: ${items.length} items');
        } else if (data['regions'] is List) {
          items = data['regions'];
          secureLog('Data found in regions key: ${items.length} items');
        } else if (data['results'] is List) {
          items = data['results'];
          secureLog('Data found in results key: ${items.length} items');
        } else {
          secureLog(
            'Warning: Could not find data array in response. Available keys: ${data.keys.toList()}',
          );
        }
      }

      regions.clear();
      final mappedRegions = items
          .map<Map<String, String>>((e) {
            // Prefer explicit keys from the API response (region_id / region_name)
            final id = (e is Map && (e['region_id'] != null))
                ? e['region_id']?.toString() ?? ''
                : (e['id']?.toString() ?? e['regionId']?.toString() ?? '');
            final name = (e is Map && (e['region_name'] != null))
                ? (e['region_name']?.toString() ?? '')
                : (e['name']?.toString() ??
                      e['title']?.toString() ??
                      e['region']?.toString() ??
                      '');
            return {'id': id, 'name': name};
          })
          .where((m) => m['id']!.isNotEmpty && m['name']!.isNotEmpty)
          .toList();

      regions.addAll(mappedRegions);
      // Debug: print mapped regions so we can verify UI data
      secureLog('Mapped regions for UI: ${regions.map((r) => r['name']).toList()}');
      secureLog('Total regions loaded: ${regions.length}');

      // Update combined list
      _updateRegionsAndCities();
    } catch (e) {
      secureLog('Error fetching regions: $e');
      Get.snackbar(
        'Error',
        'Failed to load regions: ${_cleanErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRegions.value = false;
    }
  }

  Future<void> fetchCities() async {
    secureLog('🔄 Starting to fetch cities...');
    isLoadingCities.value = true;
    try {
      secureLog('📡 Calling getCitiesUseCase.execute()...');
      final citiesList = await getCitiesUseCase.execute();
      secureLog('✅ Received ${citiesList.length} cities from usecase');

      cities.clear();
      final mappedCities = citiesList.map<Map<String, String>>((city) {
        return {
          'id': city.id,
          'name': city.name,
          'type': 'city', // Mark as city to distinguish from regions
        };
      }).toList();

      cities.addAll(mappedCities);
      secureLog('📋 Mapped cities for UI:');
      for (var i = 0; i < cities.length; i++) {
        secureLog('   City $i: ${cities[i]['name']} (id: ${cities[i]['id']})');
      }
      secureLog('✅ Total cities loaded: ${cities.length}');

      // Update combined list
      _updateRegionsAndCities();
      secureLog('✅ Cities successfully added to regionsAndCities list');
    } catch (e, stackTrace) {
      secureLog('❌ Error fetching cities: $e');
      secureLog('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load cities: ${_cleanErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCities.value = false;
      secureLog('🏁 Finished fetching cities (isLoadingCities = false)');
    }
  }

  //  Future<void> fetchSubCities() async {
  //     // isLoadingRegions.value = true; // reuse same loading flag for now
  //     try {
  //       final httpClient = Get.find<DioClient>().dio;
  //       final token = Get.find<GetStorage>().read('auth_token');
  //       final res = await httpClient.get(
  //         ApiConstants.subCitiesEndpoint,
  //         options: dio.Options(headers: {
  //           if (token != null) 'Authorization': 'Bearer $token',
  //         }),
  //       );

  //       print('SubCities API Response: ${res.data}');
  //       print('SubCities Type: ${res.data.runtimeType}');

  //       final data = res.data;
  //       List items = [];
  //       if (data is List) {
  //         items = data;
  //         print('Data is a List with ${items.length} items');
  //       } else if (data is Map) {
  //         // Try multiple possible keys for the data array
  //         if (data['data'] is List) {
  //           items = data['data'];
  //           print('Data found in data key: ${items.length} items');
  //         } else if (data['subCities'] is List) {
  //           items = data['subCities'];
  //           print('Data found in subCities key: ${items.length} items');
  //         } else if (data['subcities'] is List) {
  //           items = data['subcities'];
  //           print('Data found in subcities key: ${items.length} items');
  //         } else if (data['results'] is List) {
  //           items = data['results'];
  //           print('Data found in results key: ${items.length} items');
  //         } else {
  //           print('Warning: Could not find data array in response. Available keys: ${data.keys.toList()}');
  //         }
  //       }

  //       subcities.clear();
  //       final mappedSubCities = items.map<Map<String, String>>((e) {
  //         // Prefer explicit sub-city keys, with safe fallbacks
  //         final id = (e is Map && (e['sub_city_id'] != null))
  //             ? e['sub_city_id']?.toString() ?? ''
  //             : (e['subcity_id']?.toString() ??
  //                e['subCityId']?.toString() ??
  //                e['id']?.toString() ?? '');
  //         final name = (e is Map && (e['sub_city_name'] != null))
  //             ? (e['sub_city_name']?.toString() ?? '')
  //             : (e['subcity_name']?.toString() ??
  //                e['subCityName']?.toString() ??
  //                e['name']?.toString() ??
  //                e['title']?.toString() ?? '');
  //         return {'id': id, 'name': name};
  //       }).where((m) => m['id']!.isNotEmpty && m['name']!.isNotEmpty).toList();

  //       subcities.addAll(mappedSubCities);
  //       // Debug: print mapped subcities so we can verify UI data
  //       print('Mapped subcities for UI: ${subcities.map((r) => r['name']).toList()}');
  //       print('Total subcities loaded: ${subcities.length}');

  //     } catch (e) {
  //       print('Error fetching subcities: $e');
  //       Get.snackbar(
  //         'Error',
  //         'Failed to load subcities: ${e.toString()}',
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //     } finally {
  //       isLoadingRegions.value = false;
  //     }
  //   }

  void _updateRegionsAndCities() {
    secureLog('🔄 Updating combined regionsAndCities list...');
    regionsAndCities.clear();
    // Add regions with type marker
    final mappedRegions = regions
        .map(
          (r) => {
            'id': r['id']!,
            'name': r['name']!,
            'type': 'region', // Mark as region
          },
        )
        .toList();
    regionsAndCities.addAll(mappedRegions);
    secureLog('   Added ${mappedRegions.length} regions');
    // Add cities
    regionsAndCities.addAll(cities);
    secureLog('   Added ${cities.length} cities');
    secureLog('✅ Total regions and cities combined: ${regionsAndCities.length}');
    secureLog(
      '   Combined list: ${regionsAndCities.map((e) => '${e['name']} (${e['type']})').toList()}',
    );
  }

  Future<void> fetchZonesForRegion(String regionId) async {
    isLoadingZones.value = true;
    isLoadingZones.value = true;
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await httpClient.get(
        '${ApiConstants.zonesByRegionEndpoint}/$regionId',
        options: dio.Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      final data = res.data;
      secureLog('Zones API Response for region $regionId: ${res.data}');

      List items = [];
      if (data is List) {
        items = data;
        secureLog('Data is a List with ${items.length} items');
      } else if (data is Map) {
        // Try multiple possible keys for the data array
        if (data['data'] is List) {
          items = data['data'];
          secureLog('Data found in data key: ${items.length} items');
        } else if (data['zones'] is List) {
          items = data['zones'];
          secureLog('Data found in zones key: ${items.length} items');
        } else if (data['results'] is List) {
          items = data['results'];
          secureLog('Data found in results key: ${items.length} items');
        } else {
          secureLog(
            'Warning: Could not find data array in response. Available keys: ${data.keys.toList()}',
          );
        }
      }

      zones.clear();
      // Reset zone selection when loading new zones
      selectedZone.value = 'Select Zone / Sub-City';
      woredas.clear();
      selectedWoreda.value = 'Select Woreda';

      final mappedZones = items
          .map<Map<String, String>>((e) {
            final id = (e is Map && (e['zone_id'] != null))
                ? e['zone_id']?.toString() ?? ''
                : (e['id']?.toString() ?? '');
            final name = (e is Map && (e['zone_name'] != null))
                ? (e['zone_name']?.toString() ?? '')
                : (e['name']?.toString() ?? '');
            return {'id': id, 'name': name};
          })
          .where((m) => m['id']!.isNotEmpty && m['name']!.isNotEmpty)
          .toList();

      zones.addAll(mappedZones);
      secureLog('Mapped zones for UI: ${zones.map((r) => r['name']).toList()}');
      secureLog('Total zones loaded: ${zones.length}');
    } catch (e) {
      secureLog('Error fetching zones: $e');
      Get.snackbar(
        'Error',
        'Failed to load zones: ${_cleanErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingZones.value = false;
    }
  }

  Future<void> fetchWoredasForZone(String zoneId) async {
    isLoadingWoredas.value = true;
    isLoadingWoredas.value = true;
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await httpClient.get(
        '${ApiConstants.woredasByLocationEndpoint}/$zoneId',
        options: dio.Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      final data = res.data;
      secureLog('Woredas API Response for zone $zoneId: ${res.data}');

      List items = [];
      if (data is List) {
        items = data;
        secureLog('Data is a List with ${items.length} items');
      } else if (data is Map) {
        // Try multiple possible keys for the data array
        if (data['data'] is List) {
          items = data['data'];
          secureLog('Data found in data key: ${items.length} items');
        } else if (data['woredas'] is List) {
          items = data['woredas'];
          secureLog('Data found in woredas key: ${items.length} items');
        } else if (data['results'] is List) {
          items = data['results'];
          secureLog('Data found in results key: ${items.length} items');
        } else {
          secureLog(
            'Warning: Could not find data array in response. Available keys: ${data.keys.toList()}',
          );
        }
      }

      woredas.clear();
      // Reset woreda selection when loading new woredas
      selectedWoreda.value = 'Select Woreda';

      final mappedWoredas = items
          .map<Map<String, String>>((e) {
            final id = (e is Map && (e['woreda_id'] != null))
                ? e['woreda_id']?.toString() ?? ''
                : (e['id']?.toString() ?? '');
            final name = (e is Map && (e['woreda_name'] != null))
                ? (e['woreda_name']?.toString() ?? '')
                : (e['name']?.toString() ?? e['title']?.toString() ?? '');
            return {'id': id, 'name': name};
          })
          .where((m) => m['id']!.isNotEmpty && m['name']!.isNotEmpty)
          .toList();

      woredas.addAll(mappedWoredas);
      secureLog('Mapped woredas for UI: ${woredas.map((r) => r['name']).toList()}');
      secureLog('Total woredas loaded: ${woredas.length}');
    } catch (e) {
      secureLog('Error fetching woredas: $e');
      Get.snackbar(
        'Error',
        'Failed to load woredas: ${_cleanErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingWoredas.value = false;
    }
  }

  String? findIdByName(List<Map<String, String>> list, String name) {
    try {
      if (list.isEmpty) {
        secureLog('findIdByName: List is empty for name: $name');
        return null;
      }
      final found = list.firstWhere((e) => e['name'] == name);
      final id = found['id'];
      secureLog('findIdByName: Found "$name" → ID: $id');
      return id;
    } catch (e) {
      secureLog(
        'findIdByName: Not found "$name" in list. Available names: ${list.map((e) => e['name']).toList()}',
      );
      return null;
    }
  }

  // ----------------------------
  // IMAGE/VIDEO PICKING
  // ----------------------------
  Future<void> pickFromCamera() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (img != null) addPickedImage(img);
  }

  Future<void> pickFromGallery() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (img != null) addPickedImage(img);
  }

  Future<void> pickVideoFromCamera() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (video != null) addPickedImage(video);
  }

  Future<void> pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (video != null) addPickedImage(video);
  }

  // ----------------------------
  // LOCATION LOGIC
  // ----------------------------
  Future<void> toggleAutoDetect(bool v) async {
    if (v) {
      // When turning ON, request permission (this will show native dialog)
      try {
        // Check if location services are enabled
        bool enabled = await Geolocator.isLocationServiceEnabled();
        if (!enabled) {
          Get.snackbar(
            'Location Services',
            'Please enable location services in your device settings',
            snackPosition: SnackPosition.BOTTOM,
          );
          return; // Don't turn on the toggle
        }

        // Check current permission status
        LocationPermission permission = await Geolocator.checkPermission();

        // If permission is denied, request it (this shows native dialog)
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        // Handle the permission result
        if (permission == LocationPermission.denied) {
          // User denied permission after seeing the dialog
          Get.snackbar(
            'Permission Denied',
            'Location permission is required to detect your location',
            snackPosition: SnackPosition.BOTTOM,
          );
          return; // Don't turn on the toggle
        }

        if (permission == LocationPermission.deniedForever) {
          // Permission permanently denied, guide user to settings
          Get.snackbar(
            'Permission Required',
            'Location permission is permanently denied. Please enable it in app settings',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
          return; // Don't turn on the toggle
        }

        // Permission granted (whileInUse or always), turn on and detect location
        autoDetectLocation.value = true;
        detectionError.value = null;
        detectLocation();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to request location permission: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      // Turning OFF - no permission needed
      autoDetectLocation.value = false;
      detectionError.value = null;
    }
  }

  void togglePhoneOptIn(bool v) {
    phoneOptIn.value = v;
  }

  Future<void> detectLocation({int timeoutSeconds = 12}) async {
    detectionError.value = null;
    isDetecting.value = true;

    try {
      final allowed = await _ensurePermission();
      if (!allowed) {
        detectedAddress.value = 'Tap Search Location\nAddis Ababa | N.L | W-1';
        isDetecting.value = false;
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(Duration(seconds: timeoutSeconds));

      detectedPosition.value = pos;

      // Reverse geocode
      try {
        if (kIsWeb) {
          detectedAddress.value =
              'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';
        } else {
          final places = await placemarkFromCoordinates(
            pos.latitude,
            pos.longitude,
          );

          if (places.isEmpty) {
            detectedAddress.value =
                'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';
          } else {
            final p = places.first;
            final parts = [
              p.name,
              p.subLocality,
              p.locality,
              p.administrativeArea,
              p.country,
            ].where((e) => e != null && e.isNotEmpty).toList();

            detectedAddress.value = parts.join(', ');
          }
        }
      } catch (_) {
        detectionError.value = 'Unable to resolve address';
        detectedAddress.value =
            'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';
      }
    } catch (_) {
      detectionError.value = 'Could not detect location';
      detectedAddress.value = 'Tap Search Location\nAddis Ababa | N.L | W-1';
    } finally {
      isDetecting.value = false;
    }
  }

  Future<bool> _ensurePermission() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        detectionError.value = 'Location services are disabled.';
        return false;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied) {
        detectionError.value = 'Location permission denied.';
        return false;
      }

      if (perm == LocationPermission.deniedForever) {
        detectionError.value =
            'Location permanently denied. Enable it in settings.';
        return false;
      }

      return true;
    } catch (_) {
      detectionError.value = 'Permission check failed.';
      return false;
    }
  }

  void increment() => count.value++;

  // ----------------------------
  // AUDIO RECORDING
  // ----------------------------
  Future<bool> _ensureMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    try {
      if (kIsWeb) {
        Get.snackbar(
          'Not Supported',
          'Recording is not available on web. Please use a mobile device.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final hasPermission = await _ensureMicrophonePermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission Denied',
          'Microphone permission is required to record audio',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get directory for saving audio
      String filePath;
      if (kIsWeb) {
        // On web, use a temporary path
        filePath = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        filePath = path.join(directory.path, fileName);
      }

      // Clear any previous waveform frames before a new recording
      try {
        recorderController.reset();
        // Small delay to ensure reset completes
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (_) {}

      // Start recording - waveform will automatically work when recording starts
      await recorderController.record(
        path: filePath,
        recorderSettings: recorderSettings,
      );

      secureLog('✅ Recording started, waveform should be active');

      audioFilePath.value = filePath;
      isRecording.value = true;
      isPaused.value = false;
      _pausedDuration = Duration.zero;
      _recordingStartTime = DateTime.now();

      // Reset decibel readings
      currentDecibel.value = 0.0;
      maxDecibel.value = 0.0;
      showMinDecibelWarning.value = false;

      // Start noise meter
      _startNoiseMeter();

      // Start timer to update duration
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        if (isRecording.value &&
            !isPaused.value &&
            _recordingStartTime != null) {
          final now = DateTime.now();
          final elapsed = now.difference(_recordingStartTime!);
          recordingDuration.value = elapsed + _pausedDuration;
        }
      });
    } catch (e) {
      Get.snackbar(
        'Recording Error',
        'Failed to start recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pauseRecording() async {
    try {
      if (isRecording.value && !isPaused.value) {
        await recorderController.pause();
        _stopNoiseMeter(); // Stop noise meter when paused
        isPaused.value = true;
        _pauseStartTime = DateTime.now();
      }
    } catch (e) {
      Get.snackbar(
        'Recording Error',
        'Failed to pause recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> resumeRecording() async {
    try {
      if (isRecording.value && isPaused.value) {
        // Resume recording by starting again with the same path
        if (audioFilePath.value != null) {
          await recorderController.record(
            path: audioFilePath.value!,
            recorderSettings: recorderSettings,
          );
        }
        _startNoiseMeter(); // Restart noise meter when resumed
        if (_pauseStartTime != null) {
          final pauseDuration = DateTime.now().difference(_pauseStartTime!);
          _pausedDuration += pauseDuration;
          _pauseStartTime = null;
        }
        isPaused.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Recording Error',
        'Failed to resume recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  final isStopping = false.obs;
  final isCanceling = false.obs;

  Future<void> stopRecording() async {
    if (isStopping.value) return;
    if (!isRecording.value && !isPaused.value) {
      Get.snackbar(
        'Info',
        'No active recording to stop',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isStopping.value = true;

    try {
      // Store path before stopping
      final savePath = audioFilePath.value;

      // Stop timer and noise meter
      _recordingTimer?.cancel();
      _stopNoiseMeter();

      // Stop the recorder - same pattern as camera/video (await the operation)
      String? finalPath = savePath;
      if (recorderController.isRecording) {
        try {
          // Stop recorder and get the file path
          final stoppedPath = await recorderController.stop().timeout(
            const Duration(seconds: 3),
          );
          if (stoppedPath != null && stoppedPath.isNotEmpty) {
            finalPath = stoppedPath;
          }
        } catch (e) {
          secureLog('⚠️ Error stopping recorder: $e');
          // Try alternative stop method
          try {
            recorderController.stop();
          } catch (_) {}
        }
      }

      // Wait for file to be finalized
      await Future.delayed(const Duration(milliseconds: 500));

      // Add file immediately - EXACTLY like camera/video pattern
      if (finalPath != null && finalPath.isNotEmpty) {
        final file = File(finalPath);

        // Check if file exists (with retry)
        bool exists = await file.exists();
        if (!exists) {
          await Future.delayed(const Duration(milliseconds: 500));
          exists = await file.exists();
        }

        if (exists) {
          // Add file immediately - same as pickFromCamera/pickVideoFromCamera
          final xFile = XFile(finalPath);
          _removeExistingAudioAttachments();
          addPickedImage(xFile);
          Get.snackbar(
            'Upload',
            'File added',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          // Try to find the file in directory
          try {
            final dir = file.parent;
            if (await dir.exists()) {
              final files = await dir.list().toList();
              final audioFiles = files.where((f) {
                final name = f.path.split('/').last.toLowerCase();
                return name.endsWith('.m4a') && name.contains('voice_note');
              }).toList();

              if (audioFiles.isNotEmpty) {
                // Get most recent
                audioFiles.sort((a, b) {
                  try {
                    return File(b.path).statSync().modified.compareTo(
                      File(a.path).statSync().modified,
                    );
                  } catch (_) {
                    return 0;
                  }
                });

                final xFile = XFile(audioFiles.first.path);
                _removeExistingAudioAttachments();
                addPickedImage(xFile);
                Get.snackbar(
                  'Upload',
                  'File added',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Recording file not found',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            }
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to save recording',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      }

      // Reset UI state after file is added
      isRecording.value = false;
      isPaused.value = false;
      recordingDuration.value = Duration.zero;
      currentDecibel.value = 0.0;
      _pausedDuration = Duration.zero;
      _recordingStartTime = null;
      _pauseStartTime = null;
      audioFilePath.value = null;

      // Reset recorder
      try {
        recorderController.reset();
      } catch (_) {}
    } catch (e) {
      secureLog('❌ Error in stopRecording: $e');
      Get.snackbar(
        'Error',
        'Failed to stop recording',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isStopping.value = false;
    }
  }

  Future<void> cancelRecording() async {
    if (isCanceling.value) return;
    if (!isRecording.value && !isPaused.value) {
      Get.snackbar(
        'Info',
        'No active recording to cancel',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isCanceling.value = true;

    // INSTANTLY reset UI state - don't wait for anything
    _recordingTimer?.cancel();
    _stopNoiseMeter();
    isRecording.value = false;
    isPaused.value = false;
    recordingDuration.value = Duration.zero;
    currentDecibel.value = 0.0;
    maxDecibel.value = 0.0;
    showMinDecibelWarning.value = false;
    _pausedDuration = Duration.zero;
    _recordingStartTime = null;
    _pauseStartTime = null;
    _removeExistingAudioAttachments();
    pickedImagesX.refresh();

    // Store path for cleanup
    final pathToDelete = audioFilePath.value;
    audioFilePath.value = null;

    // Reset recorder UI immediately
    try {
      recorderController.reset();
    } catch (_) {}

    // Show message immediately
    Get.snackbar(
      'Cancelled',
      'Recording discarded',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Clean up recorder and file in background (don't wait)
    Future.microtask(() async {
      try {
        // Stop recorder in background (non-blocking)
        if (recorderController.isRecording) {
          try {
            await recorderController
                .stop(false)
                .timeout(const Duration(seconds: 2));
          } catch (_) {
            // Ignore errors - we don't care if it fails
          }
        }
      } catch (_) {}

      // Delete file in background
      if (pathToDelete != null && !kIsWeb) {
        try {
          final file = File(pathToDelete);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }
    });

    isCanceling.value = false;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Noise meter helper methods
  Future<void> _startNoiseMeter() async {
    try {
      // Noise meter doesn't work on web, skip it
      if (kIsWeb) {
        secureLog('Noise meter not supported on web platform');
        return;
      }

      // Check microphone permission
      if (!(await Permission.microphone.isGranted)) {
        await Permission.microphone.request();
      }

      if (await Permission.microphone.isGranted) {
        // Create noise meter if not already created
        _noiseMeter ??= noise_meter.NoiseMeter();

        // Listen to noise readings
        _noiseSubscription = _noiseMeter!.noise.listen(
          (noise_meter.NoiseReading reading) {
            // Update current decibel (using meanDecibel)
            currentDecibel.value = reading.meanDecibel;

            // Update max decibel if current is higher
            if (reading.meanDecibel > maxDecibel.value) {
              maxDecibel.value = reading.meanDecibel;
            }
          },
          onError: (error) {
            secureLog('Noise meter error: $error');
            // Don't stop recording if noise meter fails
          },
        );
      }
    } catch (e) {
      secureLog('Failed to start noise meter: $e');
      // Don't stop recording if noise meter fails
    }
  }

  void _stopNoiseMeter() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
  }

  // ----------------------------
  // HELPERS
  // ----------------------------
  void _removeExistingAudioAttachments() {
    pickedImagesX.removeWhere((f) {
      final name = f.name.toLowerCase();
      return name.endsWith('.m4a') ||
          name.endsWith('.mp3') ||
          name.endsWith('.aac') ||
          name.contains('voice_note');
    });
  }

  // Normalize various API shapes (bool, int, string) into a bool flag
  bool _parseIsSoundFlag(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == 'true' || v == 'yes' || v == '1') return true;
      if (v == 'false' || v == 'no' || v == '0') return false;
    }
    return false;
  }

  // ----------------------------
  // FORM SUBMISSION
  // ----------------------------
  // Fetch pollution category ID from API
  Future<String?> _fetchPollutionCategoryId(String reportType) async {
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await httpClient.get(
        ApiConstants.pollutionCategoriesEndpoint,
        options: dio.Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      final data = res.data;
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        if (data['data'] is List) {
          items = data['data'];
        } else if (data['categories'] is List) {
          items = data['categories'];
        }
      }

      // Try to find matching category
      String normalize(String v) => v.toLowerCase().trim();
      // Route uses "pollution", backend now returns "Air Pollution"
      final normalizedType = normalize(
        reportType == 'pollution' ? 'air pollution' : reportType,
      );
      final isSoundReportType = reportType == ReportTypeEnum.sound.name;
      for (var item in items) {
        if (item is Map) {
          final id =
              item['pollution_category_id']?.toString() ??
              item['id']?.toString() ??
              '';
          final isSoundCategory = _parseIsSoundFlag(item['is_sound']);
          if (isSoundCategory != isSoundReportType) {
            continue; // enforce sound-only categories visibility rule
          }
          
          final name = normalize(
            item['pollution_category']?.toString() ??
                item['name']?.toString() ??
                '',
          );
          final matches =
              name == normalizedType ||
              name.contains(normalizedType) ||
              normalizedType.contains(name);
          if (id.isNotEmpty && matches) {
            secureLog('Found pollution category ID for "$reportType": $id');
            return id;
          }
        }
      }
      secureLog('Sound pollution category search: isSoundReportType=$isSoundReportType');
      secureLog('Warning: Could not find pollution category for "$reportType"');
      return null;
    } catch (e) {
      secureLog('Error fetching pollution category: $e');
      return null;
    }
  }

  Future<void> submitReport(bool isSound) async {
    // Validation
    final desc = descriptionController.text.trim();
    if (desc.isEmpty) {
      Get.snackbar(
        'Error',
        'Please provide a description',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (desc.length < 30) {
      Get.snackbar(
        'Error',
        'Description must be at least 30 characters',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (pickedImagesX.isEmpty && !isSound) {
      Get.snackbar(
        'Error',
        'Please add at least one photo or video or audio',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isSound) {
      // Ensure at least one audio file is attached
      final hasAudio = pickedImagesX.any((f) {
        final name = f.name.toLowerCase();
        return name.endsWith('.m4a') ||
            name.endsWith('.mp3') ||
            name.endsWith('.aac') ||
            name.contains('voice_note');
      });
      if (!hasAudio) {
        Get.snackbar(
          'Error',
          'Please add an audio recording',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      showMinDecibelWarning.value = true;
      final minDb = minRequiredDecibel;
      if (minDb != null && maxDecibel.value < minDb) {
        Get.snackbar(
          'Error',
          'Recorded sound level is below the minimum required (${minDb.toStringAsFixed(0)} dB) for the selected land use type',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      showMinDecibelWarning.value = false;
    }

    if (!termsAccepted.value) {
      Get.snackbar(
        'Error',
        'Please accept the terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedDate.value == null || selectedTime.value == null) {
      Get.snackbar(
        'Error',
        'Please select date and time',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate "Are you in the spot" is selected
    if (!hasSelectedLocationOption.value || isInTheSpot.value == null) {
      Get.snackbar(
        'Error',
        'Please select "Are you in the spot"',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate location based on selection
    if (isInTheSpot.value == true) {
      // If "Yes", location should be detected or manually entered
      if (!autoDetectLocation.value && detectedPosition.value == null) {
        Get.snackbar(
          'Error',
          'Please enable location detection or provide location details',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } else {
      // If "No", region/zone/woreda should be selected
      if (selectedRegion.value == 'Select Region / City Administration') {
        Get.snackbar(
          'Error',
          'Please select a region/city',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    isSubmitting.value = true;

    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');

      // if (token == null) {
      //   Get.snackbar(
      //     'Error',
      //     'Please login to submit a report',
      //     snackPosition: SnackPosition.BOTTOM,
      //   );
      //   isSubmitting.value = false;
      //   return;
      // }

      // Get location IDs
      final regionId =
          findIdByName(regionsAndCities, selectedRegion.value) ?? '';
      final zoneId = findIdByName(zones, selectedZone.value) ?? '';
      final woredaId = findIdByName(woredas, selectedWoreda.value) ?? '';

      // Debug logging for location IDs
      secureLog('📍 Location IDs for submission:');
      secureLog('   Selected Region: ${selectedRegion.value} → ID: $regionId');
      secureLog('   Selected Zone: ${selectedZone.value} → ID: $zoneId');
      secureLog('   Selected Woreda: ${selectedWoreda.value} → ID: $woredaId');
      secureLog('   Available zones: ${zones.map((z) => z['name']).toList()}');
      secureLog('   Available woredas: ${woredas.map((w) => w['name']).toList()}');

      // Get location coordinates
      String locationUrl = '';
      if (autoDetectLocation.value && detectedPosition.value != null) {
        final pos = detectedPosition.value!;
        locationUrl = '${pos.latitude},${pos.longitude}';
      }

      // Create form data
      final formData = dio.FormData();

      // Add text fields
      if (regionId.isNotEmpty) {
        formData.fields.add(MapEntry('region_id', regionId));
        secureLog('Added region_id: $regionId');
      } else {
        secureLog('Region ID is empty');
      }

      if (zoneId.isNotEmpty) {
        formData.fields.add(MapEntry('zone_id', zoneId));
        secureLog('Added zone_id: $zoneId');
      } else {
        secureLog(
          'Zone ID is empty - selectedZone: ${selectedZone.value}, zones count: ${zones.length}',
        );
      }

      if (woredaId.isNotEmpty) {
        formData.fields.add(MapEntry('Woreda_id', woredaId));
        secureLog('Added Woreda_id: $woredaId');
      } else {
        secureLog('Woreda ID is empty');
      }
      if (locationUrl.isNotEmpty) {
        formData.fields.add(MapEntry('location_url', locationUrl));
      }
      formData.fields.add(
        MapEntry('detail', descriptionController.text.trim()),
      );

      if (isSound) {
        final soundAreaId = selectedSoundAreaId.value;
        if (soundAreaId != null && soundAreaId.isNotEmpty) {
          formData.fields.add(MapEntry('sound_area_id', soundAreaId));
          secureLog('Added sound_area_id: $soundAreaId');
        } else {
          secureLog('sound_area_id is empty');
        }

        formData.fields.add(
          MapEntry('max_freq_measured', maxDecibel.value.toStringAsFixed(2)),
        );
        secureLog('Added max_freq_measured: ${maxDecibel.value.toStringAsFixed(2)}');
      }

      // Activity date & time (from user selection)
      final pickedDate = selectedDate.value;
      final pickedTime = selectedTime.value;
      if (pickedDate != null && pickedTime != null) {
        // Date as YYYY-MM-DD
        final dateStr =
            '${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';

        // Time as HH:mm:ss.SSSZ (UTC) using combined DateTime
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        ).toUtc();
        final timeStr = combined.toIso8601String().split('T')[1]; // e.g. 12:50:34.137Z

        formData.fields.add(MapEntry('actDate', dateStr));
        formData.fields.add(MapEntry('actTime', timeStr));
        secureLog('Added actDate: $dateStr, actTime: $timeStr');
      }

      // Add pollution category ID (use from route if available, otherwise fetch from API)
      String? categoryId = selectedPollutionCategoryId.value;
      if (categoryId?.isEmpty ?? true) {
        secureLog('Pollution category ID not in route, fetching from API...');
        categoryId = await _fetchPollutionCategoryId(reportType);
      }

      secureLog(
        'Using pollution category ID: $categoryId (from route: ${pollutionCategoryId != null})',
      );
      if (categoryId != null && categoryId.isNotEmpty) {
        formData.fields.add(MapEntry('pollution_category_id', categoryId));
      } else {
        Get.snackbar(
          'Error',
          'Could not find pollution category. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        isSubmitting.value = false;
        return;
      }

      // Add phone if opted in
      if (phoneOptIn.value && phoneController.text.trim().isNotEmpty) {
        formData.fields.add(MapEntry('phone_no', phoneController.text.trim()));
      }

      // Add files
      secureLog('Adding ${pickedImagesX.length} files to form data...');
      for (var xFile in pickedImagesX) {
        try {
          final fileName = xFile.name;
          final bytes = await xFile.readAsBytes();

          formData.files.add(
            MapEntry(
              'file',
              dio.MultipartFile.fromBytes(bytes, filename: fileName),
            ),
          );
          secureLog('Added file: $fileName');
        } catch (e) {
          secureLog('Error adding file ${xFile.name}: $e');
        }
      }
      secureLog('Total files in form data: ${formData.files.length}');

      // If user is a guest, request OTP using the phone on this page
      final isLoggedIn = token != null && token.toString().isNotEmpty;
      if (!isLoggedIn) {
        final phone = phoneController.text.trim();
        final isValidPhone = phone.length == 10 &&
            (phone.startsWith('09') || phone.startsWith('07'));
        if (!isValidPhone) {
          phoneError.value = 'Phone number must start with 09 or 07';
          Get.snackbar(
            'Invalid phone number',
            'Please enter a valid phone number to receive the code.',
            snackPosition: SnackPosition.BOTTOM,
          );
          isSubmitting.value = false;
          return;
        }

        try {
          // Ensure guest OTP request is sent without any existing auth header
          final headers = Map<String, dynamic>.from(
            DioClient.instance.dio.options.headers,
          )..remove('Authorization');

          final response = await DioClient.instance.dio.post(
            ApiConstants.requestReportOtpEndpoint,
            data: {
              'phone_number': phone,
              'isGuest': true,
            },
            options: dio.Options(
              followRedirects: true,
              headers: headers,
            ),
          );

          final status = response.statusCode ?? 0;
          final success = status >= 200 && status < 300;
          if (!success) {
            throw Exception('Failed to send OTP');
          }

          _pendingFormData = formData;
          _pendingRegionForSuccess = selectedRegion.value;
          isSubmitting.value = false;

          Get.snackbar(
            'OTP sent',
            'A code was sent to $phone',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: AppColors.onPrimary,
          );

          Get.toNamed(
            Routes.Report_Otp,
            arguments: {
              'phone': phone,
              'region': selectedRegion.value,
            },
          );
        } catch (e) {
          isSubmitting.value = false;
          Get.snackbar(
            'Failed to send OTP',
            _cleanErrorMessage(e),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
        return;
      }

      await _submitFormData(
        httpClient: httpClient,
        formData: formData,
        token: token?.toString(),
        regionToPass: selectedRegion.value,
        isLoggedIn: true,
      );
    } catch (e) {
      isSubmitting.value = false;
      secureLog('Error submitting report: $e');
      Get.snackbar(
        'Error',
        'Failed to submit report: ${_cleanErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _submitFormData({
    required dio.Dio httpClient,
    required dio.FormData formData,
    required String regionToPass,
    String? token,
    required bool isLoggedIn,
  }) async {
    try {
      secureLog('Submitting to: ${ApiConstants.complaintsEndpoint}');
      secureLog('Total files: ${formData.files.length}');

      final response = await httpClient.post(
        ApiConstants.complaintsEndpoint,
        data: formData,
        options: dio.Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            // Don't set Content-Type for multipart/form-data - let Dio set it with boundary
          },
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      isSubmitting.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract report ID from response
        String reportId = '';
        try {
          final responseData = response.data;
          secureLog('Response data: $responseData');

          if (responseData is Map) {
            // Check if data is nested
            final data = responseData['data'] ?? responseData;
            if (data is Map) {
              reportId =
                  data['report_id']?.toString() ??
                  data['complaint_id']?.toString() ??
                  data['id']?.toString() ??
                  '';
            }

            // If still not found, check top level
            if (reportId.isEmpty) {
              reportId =
                  responseData['report_id']?.toString() ??
                  responseData['complaint_id']?.toString() ??
                  responseData['id']?.toString() ??
                  '';
            }
          }

          secureLog('Extracted report ID: $reportId');
        } catch (e) {
          secureLog('Error extracting report ID: $e');
        }

        // If no report ID found, generate a temporary one
        if (reportId.isEmpty) {
          reportId = 'REP-${DateTime.now().millisecondsSinceEpoch}';
        }

        // Clear form data before navigating
        _resetForm();

        secureLog(
          'Navigating to success page with report ID: $reportId (logged in: $isLoggedIn)',
        );
        Get.offNamed(
          Routes.Report_Success,
          arguments: {
            'reportId': reportId,
            'dateTime': DateTime.now(),
            'region': regionToPass,
          },
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit report',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      secureLog('Error submitting report: $e');
      Get.snackbar(
        'Error',
        'Failed to submit report: ${_cleanErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _cleanErrorMessage(Object error) {
    if (error is dio.DioException) {
      final extracted = _extractMessage(error.response?.data);
      if (extracted != null && extracted.trim().isNotEmpty) {
        return extracted.trim();
      }
      final msg = error.message;
      if (msg != null && msg.trim().isNotEmpty) {
        return msg.trim();
      }
    }
    final text = error.toString();
    final cleaned = text
        .replaceAll('Exception: ', '')
        .replaceAll(RegExp(r'^DioException[^:]*:\s*'), '')
        .trim();
    return cleaned.isEmpty ? 'Something went wrong' : cleaned;
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      for (final key in ['message', 'msg', 'detail', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return null;
  }
}
