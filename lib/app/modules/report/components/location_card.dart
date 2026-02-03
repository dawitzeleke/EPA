import 'package:eprs/app/modules/report/controllers/report_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef DropdownBuilder = Widget Function(
  String label,
  List<String> items, {
  required String value,
  required bool enabled,
  required ValueChanged<String?>? onChanged,
});

typedef OnOffToggleBuilder = Widget Function({
  RxBool? bound,
  bool isPhoneNumber,
  void Function(bool)? onChanged,
});

class LocationCard extends StatelessWidget {
  final ReportController controller;
  final DropdownBuilder buildDropdown;
  final OnOffToggleBuilder buildOnOffToggle;

  const LocationCard({
    super.key,
    required this.controller,
    required this.buildDropdown,
    required this.buildOnOffToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'Are you in the spot',
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
            Obx(() {
              final isInSpotValue = controller.isInTheSpot.value;
              final isInSpot = isInSpotValue == true;
              final isNotInSpot = isInSpotValue == false;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        controller.hasSelectedLocationOption.value = true;
                        controller.isInTheSpot.value = true;
                        controller.selectedRegion.value =
                            'Select Region / City Administration';
                        controller.selectedZone.value = 'Select Zone / Sub-City';
                        controller.selectedWoreda.value = 'Select Woreda';
                        controller.zones.clear();
                        controller.woredas.clear();

                        if (!controller.autoDetectLocation.value) {
                          await controller.toggleAutoDetect(true);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        side: BorderSide(
                          color: isInSpot
                              ? AppColors.primary
                              : const Color.fromRGBO(212, 212, 212, 1),
                          width: isInSpot ? 1.1 : 1,
                        ),
                        backgroundColor: isInSpot
                            ? AppColors.primary.withOpacity(0.08)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color:
                              isInSpot ? AppColors.primary : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.hasSelectedLocationOption.value = true;
                        controller.isInTheSpot.value = false;
                        controller.autoDetectLocation.value = false;
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        side: BorderSide(
                          color: isNotInSpot
                              ? AppColors.primary
                              : const Color.fromRGBO(212, 212, 212, 1),
                          width: isNotInSpot ? 1.1 : 1,
                        ),
                        backgroundColor: isNotInSpot
                            ? AppColors.primary.withOpacity(0.08)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          color:
                              isNotInSpot ? AppColors.primary : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            Obx(() {
              if (!controller.hasSelectedLocationOption.value ||
                  controller.isInTheSpot.value != true) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Location',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FFF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(
                            () => Text(
                              controller.autoDetectLocation.value
                                  ? controller.detectedAddress.value
                                  : 'Tap Search Location\nAddis Ababa | N.L | W-1',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                        Column(children: [buildOnOffToggle()]),
                      ],
                    ),
                  ),
                ],
              );
            }),
            Obx(() {
              if (!controller.hasSelectedLocationOption.value ||
                  controller.isInTheSpot.value != false) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Obx(() {
                    final items = controller.regionsAndCities;
                    final names =
                        ['Select Region / City Administration'] +
                            items.map((e) => e['name']!).toList();
                    if (items.isNotEmpty &&
                        !names.contains(controller.selectedRegion.value)) {
                      controller.selectedRegion.value =
                          'Select Region / City Administration';
                    }
                    return buildDropdown(
                      'Region / City Administration',
                      names,
                      value: controller.selectedRegion.value,
                      enabled: true,
                      onChanged: (v) {
                        final selected =
                            v ?? 'Select Region / City Administration';
                        controller.selectedRegion.value = selected;
                        controller.selectedZone.value =
                            'Select Zone / Sub-City';
                        controller.selectedWoreda.value = 'Select Woreda';
                        controller.woredas.clear();

                        final id = controller.findIdByName(
                            controller.regionsAndCities, selected);
                        final selectedItem = items
                            .where((item) => item['name'] == selected)
                            .firstOrNull;
                        final isRegion = selectedItem?['type'] == 'region';

                        if (id != null && isRegion) {
                          controller.fetchZonesForRegion(id);
                        } else {
                          controller.zones.clear();
                        }
                      },
                    );
                  }),
                  Obx(() {
                    final isRegionSelected = controller.selectedRegion.value !=
                        'Select Region / City Administration';
                    if (!isRegionSelected) {
                      return const SizedBox.shrink();
                    }

                    final items = controller.zones;
                    final names =
                        ['Select Zone / Sub-City'] +
                            items.map((e) => e['name']!).toList();

                    if (controller.isLoadingZones.value) {
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          buildDropdown(
                            'Zone / Sub-City',
                            ['Select Zone / Sub-City'],
                            value: 'Select Zone / Sub-City',
                            enabled: false,
                            onChanged: null,
                          ),
                          const SizedBox(height: 4),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ],
                      );
                    }

                    if (items.isNotEmpty &&
                        !names.contains(controller.selectedZone.value)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.selectedZone.value = 'Select Zone / Sub-City';
                      });
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        buildDropdown(
                          'Zone / Sub-City',
                          names,
                          value: controller.selectedZone.value,
                          enabled: items.isNotEmpty,
                          onChanged: items.isNotEmpty
                              ? (v) {
                                  final selected = v ?? 'Select Zone / Sub-City';
                                  controller.selectedZone.value = selected;
                                  controller.selectedWoreda.value =
                                      'Select Woreda';

                                  final id = controller.findIdByName(
                                      controller.zones, selected);
                                  if (id != null) {
                                    controller.fetchWoredasForZone(id);
                                  } else {
                                    controller.woredas.clear();
                                  }
                                }
                              : null,
                        ),
                      ],
                    );
                  }),
                  Obx(() {
                    if (controller.selectedZone.value ==
                            'Select Zone / Sub-City' ||
                        controller.woredas.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final items = controller.woredas;
                    final names =
                        ['Select Woreda'] +
                            items.map((e) => e['name']!).toList();
                    if (items.isNotEmpty &&
                        !names.contains(controller.selectedWoreda.value)) {
                      controller.selectedWoreda.value = 'Select Woreda';
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        buildDropdown(
                          'Woreda',
                          names,
                          value: controller.selectedWoreda.value,
                          enabled: true,
                          onChanged: (v) => controller.selectedWoreda.value =
                              v ?? 'Select Woreda',
                        ),
                      ],
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
