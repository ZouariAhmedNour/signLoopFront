import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import 'package:signloop/models/user.dart';
import 'package:signloop/services/user_api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class RegisterController extends AsyncNotifier<void> {
  final api = UserApi();

  @override
  Future<void> build() async {
    // Pas besoin d'initialisation
  }

  Future<void> register({
    required User user,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    try {
      await api.register(user);

      // Afficher le succès
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Compte créé avec succès',
        desc: 'Veuillez vérifier votre email pour activer votre compte.',
        btnOkOnPress: () {
          Get.offAllNamed(AppRoutes.loginPage);
        },
      ).show();

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      Get.snackbar("Erreur", e.toString());
    }
  }
}
 final registerControllerProvider =
    AsyncNotifierProvider<RegisterController, void>(RegisterController.new);