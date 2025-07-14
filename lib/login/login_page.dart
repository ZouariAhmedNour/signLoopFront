import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
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

    // Redirection
    Get.offAllNamed(AppRoutes.home);
  } catch (e) {
    print("❌ Erreur lors de la connexion: $e");
    Get.snackbar("Erreur", e.toString());
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
            children: [
              CustomTextFormField(
                controller: emailController,
                hintText: "Email",
                prefixIcon: Icons.email,
                validator: (v) => v != null && v.contains("@") ? null : "Email invalide",
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                controller: passwordController,
                hintText: "Mot de passe",
                prefixIcon: Icons.lock,
                validator: (v) => v != null && v.length >= 6 ? null : "Min 6 caractères",
              ),
              const SizedBox(height: 24),
              loading
                  ? const CircularProgressIndicator()
                  : CustomElevatedButton(
                      onPressed: _login,
                      child: const Text("Se connecter"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
