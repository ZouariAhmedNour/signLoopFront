import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signloop/Configurations/app_routes.dart';
import '../models/user.dart';

/// Contient l'utilisateur connecté (ou null si non connecté)
final authProvider = StateProvider<User?>((ref) => null);


void logout(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("jwt_token");
  ref.read(authProvider.notifier).state = null;
  Get.offAllNamed(AppRoutes.loginPage);
}