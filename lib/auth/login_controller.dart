// lib/auth/controllers/login_controller.dart
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import 'package:signloop/services/user_api.dart';
import 'package:signloop/providers/auth_provider.dart';

class LoginController {
  final BuildContext context;
  final WidgetRef ref;
  final UserApi api = UserApi();

  LoginController({required this.context, required this.ref});

  Future<void> login(String email, String password, GlobalKey<FormState> formKey, Function(bool) setLoading) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);

    print("🔵 Tentative de connexion avec: $email");

    try {
      final user = await api.login(email.trim(), password.trim());

      print("✅ Connexion réussie: ${user.email}");

      // Sauvegarder dans Riverpod
      ref.read(authProvider.notifier).state = user;

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      print("❌ Erreur lors de la connexion: $e");
      String errorMessage = e.toString();

      if (errorMessage.contains("Exception:")) {
        errorMessage = errorMessage.replaceFirst("Exception:", "").trim();
      }

      if (errorMessage.contains("403") ||
          errorMessage.toLowerCase().contains("vérifier votre email")) {
        // Compte non vérifié
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Email non vérifié',
          desc: 'Votre compte n\'est pas activé.\n\nCliquez sur "Renvoyer" pour recevoir un nouvel email de vérification.',
          btnOkText: "Renvoyer",
          btnOkOnPress: () async {
            try {
              print("🔵 Renvoyer email de vérification...");
              final message = await api.resendVerificationEmail(email.trim());
              AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.bottomSlide,
                title: 'Succès',
                desc: message,
                btnOkOnPress: () {},
              ).show();
            } catch (e) {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.bottomSlide,
                title: 'Erreur',
                desc: 'Impossible de renvoyer l\'email : ${e.toString()}',
                btnOkOnPress: () {},
              ).show();
            }
          },
          btnCancelText: "Annuler",
          btnCancelOnPress: () {},
        ).show();
      } else {
        // Autre erreur
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Erreur',
          desc: errorMessage,
          btnOkOnPress: () {},
        ).show();
      }
    } finally {
      setLoading(false);
    }
  }
}
