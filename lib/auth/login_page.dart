import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:signloop/auth/forgot_password_page.dart';
import 'package:signloop/components/elevatedbutton.dart';
import 'package:signloop/components/textformfield.dart';
import '../../Configurations/app_routes.dart';
import '../../services/user_api.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final api = UserApi();
  bool loading = false;

void _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => loading = true);

  print("🔵 Tentative de connexion avec: ${emailController.text}");

  try {
    final user = await api.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    print("✅ Connexion réussie: ${user.email}");

    // Sauvegarde dans Riverpod
    ref.read(authProvider.notifier).state = user;

    Get.offAllNamed(AppRoutes.home);
  } catch (e) {
    print("❌ Erreur lors de la connexion: $e");
    String errorMessage = e.toString();

    // Vérifie si c'est une exception avec un status 403
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
            final message = await api.resendVerificationEmail(emailController.text.trim());
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
    setState(() => loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    CustomTextFormField(
      controller: emailController,
      hintText: "Email",
      prefixIcon: Icons.email,
      validator: (v) =>
          v != null && v.contains("@") ? null : "Email invalide",
    ),
    const SizedBox(height: 12),
    CustomTextFormField(
      controller: passwordController,
      hintText: "Mot de passe",
      prefixIcon: Icons.lock,
      obscureText: true,
      validator: (v) =>
          v != null && v.length >= 6 ? null : "Min 6 caractères",
    ),
    const SizedBox(height: 24),
    loading
        ? const Center(child: CircularProgressIndicator())
        : CustomElevatedButton(
            onPressed: _login,
            child: const Text("Se connecter"),
          ),
    const SizedBox(height: 16),
    Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordPage(),
            ),
          );
        },
        child: const Text(
          "Mot de passe oublié ?",
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
    const SizedBox(height: 24),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Pas de compte ? "),
        GestureDetector(
          onTap: () {
            // Naviguer vers la page Register
            Get.toNamed(AppRoutes.registerPage);
          },
          child: const Text(
            "Créer un compte",
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    ),
  ],
)

          
        ),
        
      ),
    );
  }
}
