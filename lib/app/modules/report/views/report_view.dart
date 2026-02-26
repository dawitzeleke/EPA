

import 'package:eprs/app/modules/report/components/dash_border.dart';
import 'package:eprs/app/modules/report/components/date_time_card.dart';
import 'package:eprs/app/modules/report/components/location_description_card.dart';
import 'package:eprs/app/modules/report/components/location_card.dart';
import 'package:eprs/app/modules/report/components/report_type_description_card.dart';
import 'package:eprs/app/modules/report/components/sound_period_card.dart';
import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/core/enums/report_type_enum.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eprs/core/utils/secure_log.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../components/sound_gauge_painter.dart';
import '../controllers/report_controller.dart';

class ReportView extends StatefulWidget {
  final String reportType;

  const ReportView({super.key, required this.reportType});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  // Get controller instance
  ReportController get controller => Get.find<ReportController>();
  
  @override
  void initState() {
    super.initState();
    // Reset form when view is initialized (when navigating to this page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetForm();
      // Reload necessary data after reset
      controller.loadAuthState(); // Restore phone number if user is logged in
      controller.fetchRegions();
      controller.fetchPollutionCategories();
      if (controller.autoDetectLocation.value) {
        controller.detectLocation();
      }
      if (widget.reportType == ReportTypeEnum.sound.name) {
        controller.fetchSoundAreas();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set report type in controller
    controller.reportType = widget.reportType;
    final isSoundReport = widget.reportType == ReportTypeEnum.sound.name;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Report Issue',
        showBack: true,
        forceHomeOnBack: true, // ensure back reliably returns to Home shell
        showHelp: true,
        helpRoute: Routes.FAQ,
      ),
      backgroundColor: const Color(0xFFF6F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Insert this Card ABOVE the Evidence Card ---
              ReportTypeDescriptionCard(reportType: widget.reportType),

              const SizedBox(height: 12),
              // Pollution Category Card
                Card(
                  color: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pollution Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.isLoadingPollutionCategories.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (controller.pollutionCategoriesError.value != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.pollutionCategoriesError.value ?? 'Failed to Load Categories',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: controller.fetchPollutionCategories,
                                  child: const Text('Retry'),
                                ),
                              ],
                            );
                          }

                          final relevantItems = isSoundReport
                              ? controller.pollutionCategoriesSound
                              : controller.pollutionCategoriesNormal;

                          String? value = controller.selectedPollutionCategoryId.value;
                          final validValues =
                              relevantItems.map((entry) => entry['id']).whereType<String>().toSet();
                          if (!validValues.contains(value)) {
                            // Clear stale selection after rebuild to satisfy dropdown constraint
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.selectPollutionCategory(null);
                            });
                            value = null;
                          }

                          if (relevantItems.isEmpty) {
                            return const Text(
                              'No pollution categories available for this report type',
                              style: TextStyle(color: Colors.black54),
                            );
                          }

                          return DropdownButtonFormField<String?>(
                            initialValue: value,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            alignment: AlignmentDirectional.centerStart,
                            itemHeight: 48,
                            menuMaxHeight: 260,
                            borderRadius: BorderRadius.circular(8),
                            items: [
                              
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Select pollution category',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ...relevantItems.map((category) {
                                final id = category['id'];
                                final name = category['name'] ?? '';
                                return DropdownMenuItem<String?>(
                                  value: id,
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }),
                            ],
                            onChanged: controller.selectPollutionCategory,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1.1,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Select pollution category',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),


              const SizedBox(height: 12),

              if (isSoundReport)
                Card(
                  color: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Land Use Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.isLoadingSoundAreas.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (controller.soundAreasError.value != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.soundAreasError.value ?? 'Failed to load areas',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: controller.fetchSoundAreas,
                                  child: const Text('Retry'),
                                ),
                              ],
                            );
                          }

                          if (controller.soundAreas.isEmpty) {
                            return const Text(
                              'No sound areas available',
                              style: TextStyle(color: Colors.black54),
                            );
                          }

                          final items = controller.soundAreas;
                          final value = controller.selectedSoundAreaId.value;

                          return DropdownButtonFormField<String?>(
                            initialValue: value,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            alignment: AlignmentDirectional.centerStart,
                            itemHeight: 48,
                            menuMaxHeight: 260,
                            borderRadius: BorderRadius.circular(8),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Select sound area',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ...items.map(
                                (area) => DropdownMenuItem<String?>(
                                  value: area.id,
                                  child: Text(
                                    area.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: controller.selectSoundArea,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1.1,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Select sound area',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                if (isSoundReport)
              const SizedBox(height: 12),

              //time of the day card for sound report
              if (widget.reportType == ReportTypeEnum.sound.name)
                SoundPeriodCard(soundPeriod: controller.soundPeriod),

              const SizedBox(height: 12),
              
              // Time & Date Card
              DateTimeCard(
                selectedDate: controller.selectedDate,
                selectedTime: controller.selectedTime,
                onPickDate: () => controller.pickDate(context),
                onPickTime: () => controller.pickTime(context),
              ),

              const SizedBox(height: 12),
              // Evidence Card
              Card(
                color: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: Colors.black87,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add Evidence',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Evidence input: voice recorder for sound, tiles for others
                      if (widget.reportType == ReportTypeEnum.sound.name) ...[
                        _buildRecordingUI(context),
                      ] else ...[
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.9,
                          children: [
                            _evidenceTile(
                              context,
                              Icons.camera_alt_outlined,
                              'Photo',
                            ),
                            _evidenceTile(
                              context,
                              Icons.videocam_outlined,
                              'Record Video',
                              isVideo: true,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Obx(() {
                        final imgs = controller.pickedImages;
                        final count = imgs.length;
                        if (count == 0) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF7F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'No files uploaded',
                              style: TextStyle(color: Colors.black87),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 84,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: count,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (ctx, i) {
                                  final xFile = imgs[i];
                                  final fileName = (xFile.name.isNotEmpty
                                          ? xFile.name
                                          : xFile.path.split('/').last)
                                      .toLowerCase();
                                  final isAudio = fileName.endsWith('.m4a') ||
                                      fileName.endsWith('.mp3') ||
                                      fileName.endsWith('.wav') ||
                                      fileName.endsWith('.aac') ||
                                      fileName.contains('voice_note');
                                  final isVideo = fileName.endsWith('.mp4') ||
                                      fileName.endsWith('.mov') ||
                                      fileName.endsWith('.avi') ||
                                      fileName.endsWith('.mkv');
                                  final isImage = fileName.endsWith('.png') ||
                                      fileName.endsWith('.jpg') ||
                                      fileName.endsWith('.jpeg') ||
                                      fileName.endsWith('.gif') ||
                                      fileName.endsWith('.webp');
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _openAttachment(
                                          xFile,
                                          isImage: isImage,
                                          isVideo: isVideo,
                                          isAudio: isAudio,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            width: 120,
                                            height: 84,
                                            decoration: BoxDecoration(
                                              color: isAudio 
                                                  ? const Color(0xFFEFF7F0)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: isAudio
                                                ? const Center(
                                                    child: Icon(
                                                      Icons.audiotrack,
                                                      size: 40,
                                                      color: Color(0xFF63557F),
                                                    ),
                                                  )
                                                : isVideo
                                                    ? const Center(
                                                        child: Icon(
                                                          Icons.videocam,
                                                          size: 40,
                                                          color: Color(0xFF63557F),
                                                        ),
                                                      )
                                                    : isImage
                                                        ? FutureBuilder<Uint8List>(
                                                            future: xFile.readAsBytes(),
                                                            builder: (context, snapshot) {
                                                              if (snapshot.hasData) {
                                                                return Image.memory(
                                                                  snapshot.data!,
                                                                  fit: BoxFit.cover,
                                                                );
                                                              } else if (snapshot.hasError) {
                                                                return const Icon(Icons.image);
                                                              } else {
                                                                return const Center(
                                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                                );
                                                              }
                                                            },
                                                          )
                                                        : const Center(
                                                            child: Icon(
                                                              Icons.insert_drive_file,
                                                              size: 32,
                                                              color: Color(0xFF63557F),
                                                            ),
                                                          ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => controller.removePickedImageAt(i),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$count File(s) Uploaded',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Location Card
              LocationCard(
                controller: controller,
                buildDropdown: _buildDropdown,
                buildOnOffToggle: _onOffToggle,
              ),
              
              const SizedBox(height: 12),

              LabeledTextFieldCard(
                title: 'Specific Location',
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              LabeledTextFieldCard(
                title: 'Description',
                maxLines: 3,
                controller: controller.descriptionController,
              ),


              const SizedBox(height: 12),
              // Phone Number Card

              
              Obx(() => controller.isLoggedIn.value
                  ? const SizedBox.shrink()
                  : Card(
                      color: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                        children: const [
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                       ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      // 1. The actual input field
                                      Obx(() {
                                        final isHidden = controller.obscurePhoneNumber.value;
                                        return TextFormField(
                                          controller: controller.phoneController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                          inputFormatters:  [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(10),
                                          ],
                                          // When hidden, make text transparent so overlay can show
                                          style: isHidden
                                              ? GoogleFonts.robotoMono(color: Colors.transparent, fontSize: 16)
                                              : GoogleFonts.robotoMono(color: Colors.black87, fontSize: 16),
                                          cursorColor: Colors.black,
                                          showCursor: true,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Your Phone Number (e.g. 091XXXXXXX)',
                                            hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),
                                            counterText: '',
                                            errorText: null,
                                            errorStyle: const TextStyle(height: 0, fontSize: 0),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(212, 212, 212, 1),
                                                width: 0.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(212, 212, 212, 1),
                                                width: 0.4,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(212, 212, 212, 1),
                                                width: 0.8,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      
                                      // 2. The Masked Overlay
                                      // Listens to controller changes to update mask in real-time
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          ignoring: true,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Obx(() {
                                                final isHidden = controller.obscurePhoneNumber.value;
                                                return ValueListenableBuilder<TextEditingValue>(
                                                  valueListenable: controller.phoneController,
                                                  builder: (context, value, child) {
                                                    // Only show overlay if hidden AND not empty
                                                    if (!isHidden || value.text.isEmpty) {
                                                      return const SizedBox.shrink();
                                                    }
                                                    
                                                    final text = value.text;
                                                    String maskedText;
                                                    if (text.length <= 2) {
                                                      maskedText = text;
                                                    } else {
                                                      maskedText = text.substring(0, 2) + '*' * (text.length - 2);
                                                    }

                                                    return Text(
                                                      maskedText,
                                                      style: GoogleFonts.robotoMono(
                                                        color: Colors.black87,
                                                        fontSize: 16, // Must match TextFormField default
                                                      ),
                                                    );
                                                  },
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Toggle Button
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _onOffToggle(
                                      bound: controller.phoneOptIn,
                                      isPhoneNumber: true,
                                      onChanged: (v) {
                                        // v=true (ON) -> obscure=true (Masked)
                                        // v=false (OFF) -> obscure=false (Visible)
                                        controller.obscurePhoneNumber.value = v;
                                        controller.togglePhoneOptIn(v);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Obx(() {
                              final err = controller.phoneError.value;
                              return SizedBox(
                                height: 18,
                                child: err.isEmpty
                                    ? const SizedBox.shrink()
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          err,
                                          style: const TextStyle(color: Colors.red, fontSize: 12),
                                        ),
                                      ),
                              );
                            }),
                          ],
                        ),
                      ),
                    )),




              const SizedBox(height: 18),

              // Terms checkbox
              Obx(() => Row(
                children: [
                  Checkbox(
                    activeColor: AppColors.primary,
                    value: controller.termsAccepted.value,
                    onChanged: (v) => controller.termsAccepted.value = v ?? false,
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I Agree To The ',
                        style: const TextStyle(
                          color: AppColors.primary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms And Conditions',
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(Routes.TERM_AND_CONDITIONS);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 12),

              // Send button
              Obx(() => SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.submitReport(isSoundReport),
                  style: ButtonStyle(
                    // Keep the button green for all states (including disabled)
                    backgroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
                    foregroundColor: WidgetStateProperty.all<Color>(AppColors.onPrimary),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                          ),
                        )
                      : const Text(
                          'SEND',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _evidenceTile(BuildContext ctx, IconData icon, String label, {bool isVoiceNote = false, bool isVideo = false}) {
    return InkWell(
      onTap: () async {
        if (isVoiceNote) {
          // Start recording immediately when voice note button is pressed
          await controller.startRecording();
          return;
        }

        if (isVideo) {
          // Show video picker options
          final choice = await showModalBottomSheet<int>(
            context: ctx,
            builder: (sheetCtx) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.videocam_outlined),
                      title: const Text('Record a Video'),
                      onTap: () => Navigator.of(sheetCtx).pop(1),
                    ),
                    ListTile(
                      leading: const Icon(Icons.video_library_outlined),
                      title: const Text('Upload from Gallery'),
                      onTap: () => Navigator.of(sheetCtx).pop(2),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );

          if (choice == 1 || choice == 2) {
            showDialog(
              context: ctx,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            try {
              if (choice == 1) {
                await controller.pickVideoFromCamera();
              } else {
                await controller.pickVideoFromGallery();
              }
              Get.snackbar(
                'Upload',
                'Video added',
                snackPosition: SnackPosition.BOTTOM,
              );
            } catch (e) {
              Get.snackbar(
                'Upload failed',
                e.toString(),
                snackPosition: SnackPosition.BOTTOM,
              );
            } finally {
              try {
                Navigator.of(ctx, rootNavigator: true).pop();
              } catch (_) {}
            }
          }
          return;
        }

        // Photo picker
        final choice = await showModalBottomSheet<int>(
          context: ctx,
          builder: (sheetCtx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text('Take Photo'),
                    onTap: () => Navigator.of(sheetCtx).pop(1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('Upload from Gallery'),
                    onTap: () => Navigator.of(sheetCtx).pop(2),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );

        if (choice == 1 || choice == 2) {
          // show a small progress indicator while the picker runs
          showDialog(
            context: ctx,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
          try {
            if (choice == 1) {
              await controller.pickFromCamera();
            } else {
              await controller.pickFromGallery();
            }
            // optional: brief success feedback
            Get.snackbar(
              'Upload',
              'File added',
              snackPosition: SnackPosition.BOTTOM,
            );
          } catch (e) {
            Get.snackbar(
              'Upload failed',
              e.toString(),
              snackPosition: SnackPosition.BOTTOM,
            );
          } finally {
            // close the progress dialog
            try {
              Navigator.of(ctx, rootNavigator: true).pop();
            } catch (_) {}
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // make the dashed box responsive to available width; keep a sensible min height
          final boxHeight = (constraints.maxWidth * 0.5).clamp(64.0, 120.0);
          return DashedBorder(
            child: Container(
              height: boxHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 28, color: const Color(0xFF63557F)),
                    const SizedBox(height: 8),
                    Text(label, style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordingUI(BuildContext context) {
    // Build waveform outside Obx to keep it stable
    final waveformWidget = _buildSoundGauge();
    
    return Obx(() {
      final duration = controller.recordingDuration.value;
      final isPaused = controller.isPaused.value;
      final isRecording = controller.isRecording.value;
      final isWeb = kIsWeb;
      // Idle state: show start prompt instead of auto-starting
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromRGBO(212, 212, 212, 1), width: 0.4),
        ),
        child: Column(
          children: [
            if (isWeb)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recording not supported in web. Please use Android/iOS.',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (isWeb) const SizedBox(height: 12),
            // Waveform visualization - built outside Obx to keep it stable
            waveformWidget,
            const SizedBox(height: 16),
            // Frequency and Duration display
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Obx(() {
                  final decibel = controller.isRecording.value
                      ? controller.currentDecibel.value
                      : 0.0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Frequency ${decibel.toStringAsFixed(1)}db',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Duration ${controller.formatDuration(duration)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final minDb = controller.minRequiredDecibel;
              final maxDb = controller.maxDecibel.value;
              if (minDb == null) return const SizedBox.shrink();
              final isBelow = maxDb < minDb;
              return Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F7F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Min required ${minDb.toStringAsFixed(0)} dB',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F7F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Max recorded ${maxDb.toStringAsFixed(1)} dB',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (controller.showMinDecibelWarning.value && isBelow) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Recorded sound level is below the minimum required for the selected land use type.',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 20),
            // Three buttons: Stop, Cancel, Start/Pause/Resume
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                // Cancel button
                _buildRecordingButton(
                  icon: Icons.cancel_outlined,
                  label: 'Cancel',
                  color: (isRecording || isPaused) && !isWeb
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  enabled: (isRecording || isPaused) && !isWeb && !controller.isCanceling.value,
                  onPressed: () {
                    if (controller.isCanceling.value) return;
                    controller.cancelRecording().catchError((error) {
                      secureLog('Error canceling recording: $error');
                      Get.snackbar(
                        'Error',
                        'Failed to cancel recording: ${error.toString()}',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    });
                  },
                ),

                // Pause/Resume button
                _buildRecordingButton(
                  icon: isRecording
                      ? (isPaused ? Icons.play_arrow : Icons.pause)
                      : Icons.mic,
                  label: isRecording
                      ? (isPaused ? 'Resume' : 'Pause')
                      : 'Start',
                  color: isWeb ? Colors.grey.shade400 : AppColors.primary,
                  enabled: !isWeb,
                  onPressed: () {
                    if (isWeb) return;
                    if (!isRecording) {
                      controller.startRecording();
                    } else if (isPaused) {
                      controller.resumeRecording();
                    } else {
                      controller.pauseRecording();
                    }
                  },
                ),

                // Stop button
                _buildRecordingButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  color: (isRecording || isPaused) && !isWeb
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  enabled: (isRecording || isPaused) && !isWeb && !controller.isStopping.value,
                  onPressed: () {
                    if (controller.isStopping.value) return;
                    controller.stopRecording().catchError((error) {
                      secureLog('Error stopping recording: $error');
                      Get.snackbar(
                        'Error',
                        'Failed to stop recording: ${error.toString()}',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    });
                  },
                ),  
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSoundGauge() {
    // Speedometer-like gauge driven by current decibel (0–100 dB)
    return Obx(() {
      final isRecording = controller.isRecording.value;
      final isPaused = controller.isPaused.value;
      final db = isRecording ? controller.currentDecibel.value : 0.0;

      return SizedBox(
        height: 120,
        width: double.infinity,
        child: CustomPaint(
          painter: SoundGaugePainter(
            value: db,
            min: 0,
            max: 100,
            active: isRecording && !isPaused,
          ),
        ),
      );
    });
  }

  Widget _buildRecordingButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: enabled ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: enabled
                ? () {
                    try {
                      onPressed();
                    } catch (e) {
                      secureLog('Error in recording button callback: $e');
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? color : Colors.grey.shade300,
              ),
              child: Icon(
                icon,
                color: enabled ? Colors.white : Colors.white70,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items, {
    required String value,
    required bool enabled,
    required ValueChanged<String?>? onChanged,
  }) {
    // Ensure the current value is in the items list
    // If value is not in items, use the first item (placeholder) if available
    final currentValue = items.isNotEmpty
        ? (items.contains(value) ? value : items.first)
        : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey('${label}_${items.length}'),
          initialValue: currentValue,
          dropdownColor: Colors.white,
          items: items.isEmpty
              ? null
              : items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ))
                  .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color.fromRGBO(212, 212, 212, 1),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color.fromRGBO(212, 212, 212, 1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color.fromRGBO(212, 212, 212, 1),
                width: 1,
              ),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            hintText: items.isNotEmpty ? items.first : label,
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          isExpanded: true,
          menuMaxHeight: 260,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  /// Custom rounded toggle with internal ON/OFF label to match the design.
  // Generic toggle widget. If [bound] is provided it will control that
  // observable; otherwise it defaults to controlling the location auto-detect.
  Widget _onOffToggle({
    RxBool? bound,
    bool isPhoneNumber = false,
    void Function(bool)? onChanged,
  }) {
    return Obx(() {
      final rx = bound ?? controller.autoDetectLocation;
      final isOn = rx.value;
      return GestureDetector(
        onTap: () async {
          final newVal = !isOn;
          if (onChanged != null) {
            onChanged(newVal);
          } else if (bound != null) {
            bound.value = newVal;
          } else {
            // For location toggle, request permission when turning ON
            await controller.toggleAutoDetect(newVal);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 92,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isOn ? AppColors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // label (ON / OFF) positioned on the opposite side of the thumb
              Align(
                alignment: isOn ? Alignment.centerLeft : Alignment.centerRight,
                child: Padding(
                  padding: isOn
                      ? const EdgeInsets.only(left: 8.0)
                      : const EdgeInsets.only(right: 8.0),
                  child: isPhoneNumber
                      ? Text(
                          isOn ? 'HIDE' : 'SHOW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : Text(
                          isOn ? 'ON' : 'OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              // thumb
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _openAttachment(
    XFile file, {
    required bool isImage,
    required bool isVideo,
    required bool isAudio,
  }) async {
    if (isImage) {
      try {
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (_) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: InteractiveViewer(
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            );
          },
        );
        return;
      } catch (e) {
        if (!mounted) return;
        Get.snackbar(
          'Preview failed',
          'Could not open image: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final typeLabel = isVideo
        ? 'video'
        : isAudio
            ? 'audio'
            : 'file';

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(file.name.isNotEmpty ? file.name : 'Attached $typeLabel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preview for this $typeLabel is not available in-app.'),
              const SizedBox(height: 8),
              Text(
                'Path: ${file.path}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}



