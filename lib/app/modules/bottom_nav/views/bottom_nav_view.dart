import 'package:eprs/app/modules/awareness/views/awareness_view.dart';
import 'package:eprs/app/modules/bottom_nav/widgets/bottom_nav_footer.dart';
import 'package:eprs/app/modules/report/bindings/report_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';
import '../../home/views/home_view.dart';
import '../../status/views/status_view.dart';
import '../../setting/views/setting_view.dart';
// Import bindings so we can register controllers when the shell is created
import '../../home/bindings/home_binding.dart';
import '../../awareness/bindings/awareness_binding.dart';
import '../../status/bindings/status_binding.dart';
import '../../status/controllers/status_controller.dart';
import '../../setting/bindings/setting_binding.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  // Avoid storing controller in a late field to make hot-reload safe.
  BottomNavController get _controller {
    if (Get.isRegistered<BottomNavController>()) {
      return Get.find<BottomNavController>();
    }
    // If not registered, register a permanent instance.
    return Get.put(BottomNavController(), permanent: true);
  }

  @override
  void initState() {
    super.initState();

    // Ensure a BottomNavController exists and register page bindings.
    final c = _controller;
    HomeBinding().dependencies();
    // OfficeBinding().dependencies();
    AwarenessBinding().dependencies();
    StatusBinding().dependencies();
    // Ensure the StatusController is instantiated now so seeded data and
    // `onInit` runs before the tab widget builds. This avoids the "No reports"
    // symptom when the controller factory is registered but not yet created.
    try {
      Get.find<StatusController>();
    } catch (_) {
      // If not created yet, calling find will create it because the binding
      // registered a lazyPut factory above.
      // Swallow errors to avoid breaking init if some other lifecycle occurs.
    }
    SettingBinding().dependencies();
    ReportBinding().dependencies();
    // Access navigatorKeys so they are initialized.
    c.navigatorKeys;
  }

  // (tab builders are created inside build to be hot-reload safe)

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    // Create tab builders locally to avoid referencing stale fields after hot-reload.
    final tabBuilders = [
      () => HomeView(),
      // () => OfficeView(),
      () => AwarenessView(),
      () => StatusView(),
      () => SettingView(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await controller.onWillPop();
        if (!context.mounted) return;
        if (shouldExit) {
          Navigator.of(context).maybePop();
        }
      },
      child: Obx(() {
        final currentIndex = controller.currentIndex.value;
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: List.generate(tabBuilders.length, (i) {
              return Navigator(
                key: controller.navigatorKeys[i],
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (_) => tabBuilders[i](),
                  settings: settings,
                ),
              );
            }),
          ),
          bottomNavigationBar: const BottomNavBarFooter(),
        );
      }),
    );
  }
}
