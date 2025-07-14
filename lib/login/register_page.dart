import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signloop/components/elevatedbutton.dart';
import 'package:signloop/components/textformfield.dart';
import '../services/user_api.dart';
import '../models/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nomController = TextEditingController();
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final api = UserApi();

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      await api.register(
        User(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          nom: nomController.text.trim(),
          prenom : '', // Optionnel, peut être ajouté plus tard
        ),
      );
      Get.snackbar("Succès", "Email de vérification envoyé");
      Get.offAllNamed("/login");
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextFormField(
                controller: nomController,
                hintText: "Nom",
                prefixIcon: Icons.person,
                validator: (v) => v != null && v.isNotEmpty ? null : "Obligatoire",
              ),
              const SizedBox(height: 12),
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
                      onPressed: _register,
                      child: const Text("S'inscrire"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
