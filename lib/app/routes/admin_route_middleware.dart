import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import 'app_routes.dart';

class AdminRouteMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = Get.find<AuthController>().user.value;
    if (user == null) return const RouteSettings(name: AppRoutes.login);
    if (user.role != 'admin') return const RouteSettings(name: AppRoutes.home);
    return null;
  }
}
