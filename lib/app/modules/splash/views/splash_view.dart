import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool showContent = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Step 1: Fade in content
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => showContent = true);

    // Step 2: Hold for a moment
    await Future.delayed(const Duration(seconds: 2));

    // Step 3: Fade out + scale down
    setState(() => showContent = false);
    await Future.delayed(const Duration(milliseconds: 700));

    // Step 4: Navigate with custom transition
    if (!mounted) return;
    final controller = Get.find<SplashController>();
    final nextRoute = await controller.resolveNextRoute();
    if (!mounted) return;
    Get.offAllNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 700),
          opacity: showContent ? 1.0 : 0.0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: showContent ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/logo.png',
                    width: screenWidth * 0.9,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.error,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
