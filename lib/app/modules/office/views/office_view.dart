import 'package:eprs/app/modules/bottom_nav/widgets/bottom_nav_footer.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/domain/usecases/get_offices_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import '../controllers/office_controller.dart';

class OfficeView extends StatefulWidget {
  const OfficeView({super.key});

  @override
  State<OfficeView> createState() => _OfficeViewState();
}

class _OfficeViewState extends State<OfficeView> {
  late final OfficeController controller;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<OfficeController>()
        ? Get.find<OfficeController>()
        : Get.put(OfficeController(
            getOfficesUsecase: Get.find<GetOfficesUsecase>(),
          ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _moveToOffice(OfficeLocation office) {
    _mapController.move(office.position, 14.5);
  }

  void _focusOffice(OfficeLocation office) {
    controller.selectOffice(office);
    _moveToOffice(office);
    _searchController.text = office.name;
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Offices',
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Obx(() {
                final highlightSet = controller.searchQuery.value.isEmpty
                    ? <String>{}
                    : controller.filteredOffices.map((o) => o.name).toSet();
                final selectedName = controller.selectedOffice.value?.name;

                return SizedBox.expand(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: controller.initialCenter,
                      initialZoom: 12.6,
                      maxZoom: 18,
                      minZoom: 10,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.eprs.app',
                      ),
                      MarkerLayer(
                        markers: controller.offices
                            .map(
                              (office) {
                                final isHighlighted =
                                    highlightSet.contains(office.name) || office.name == selectedName;
                                return Marker(
                                  width: 90,
                                  height: 90,
                                  point: office.position,
                                  rotate: false,
                                  child: GestureDetector(
                                    onTap: () => _focusOffice(office),
                                    child: _MapPin(
                                      title: office.name,
                                      isHighlighted: isHighlighted,
                                    ),
                                  ),
                                );
                              },
                            )
                            .toList(),
                      ),
                    ],
                  ),
                );
              }),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Constrain the search field width to avoid it spanning full
                    // width on large screens and to control its visual size.
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              textInputAction: TextInputAction.search,
                              onChanged: controller.updateSearch,
                              onSubmitted: (value) {
                                final query = value.trim().toLowerCase();
                                final match = controller.offices.firstWhere(
                                  (office) =>
                                      office.name.toLowerCase().contains(query) ||
                                      office.address.toLowerCase().contains(query),
                                  orElse: () => controller.offices.first,
                                );
                                _focusOffice(match);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search for Location',
                                hintStyle: TextStyle(fontSize: 14),
                                prefixIcon: Icon(Icons.search, color: Color(0xFF9BA5B1), size: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final query = controller.searchQuery.value.trim();
                      final results = controller.filteredOffices;
                      if (query.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      if (results.isEmpty) {
                        return _SuggestionCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: const [
                                Icon(Icons.info_outline, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(child: Text('No offices match that search.')),
                              ],
                            ),
                          ),
                        );
                      }
                      return _SuggestionCard(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final office = results[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              title: Text(office.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(office.address),
                              onTap: () {
                                controller.updateSearch(office.name);
                                _focusOffice(office);
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Obx(() {
              final office = controller.selectedOffice.value;
              if (office == null) {
                return const SizedBox.shrink();
              }
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                  child: _OfficeInfoCard(
                    office: office,
                    onClose: controller.clearSelection,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarFooter(),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Widget child;

  const _SuggestionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(5),
      child: child,
    );
  }
}

class _OfficeInfoCard extends StatelessWidget {
  final OfficeLocation office;
  final VoidCallback onClose;

  const _OfficeInfoCard({
    required this.office,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 12,
      letterSpacing: 0.8,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6C7A89),
    );

    const valueStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Color(0xFF0F3B52),
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 10,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(office.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F3B52))),
                      const SizedBox(height: 2),
                      Text(office.address,
                          style: const TextStyle(
                              color: Color(0xFF6C7A89), fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF6C7A89)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.phone_outlined,
                    color: Color(0xFF00A650), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PHONE', style: labelStyle),
                      const SizedBox(height: 2),
                      Text(office.phone, style: valueStyle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.email_outlined,
                    color: Color(0xFF00A650), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EMAIL', style: labelStyle),
                      const SizedBox(height: 2),
                      Text(
                        office.email,
                        style: valueStyle.copyWith(color: const Color(0xFF00A650)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String title;
  final bool isHighlighted;

  const _MapPin({
    required this.title,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          color: isHighlighted ? const Color(0xFFE53935) : const Color(0xFFF06263),
          size: isHighlighted ? 44 : 38,
        ),
        if (isHighlighted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
