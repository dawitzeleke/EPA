import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../../domain/repositories/auth_repository.dart';

class SplashController extends GetxController {
  /// Decide the next route based on persisted auth token using repository helper
  Future<String> resolveNextRoute() async {
    final authRepo = Get.find<AuthRepository>();
    final loggedIn = await authRepo.isLoggedIn();
    return loggedIn ? Routes.HOME : Routes.LOGIN;
  }
}
