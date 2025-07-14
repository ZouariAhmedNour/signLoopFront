import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import 'package:signloop/components/elevatedbutton.dart';
import 'package:signloop/components/textformfield.dart';
import '../services/user_api.dart';
import '../models/user.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final telephoneController = TextEditingController();
  final adresseController = TextEditingController();
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
          prenom: prenomController.text.trim(),
          telephone: telephoneController.text.trim(),
          adresse: adresseController.text.trim(),
        ),
      );

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
                controller: prenomController,
                hintText: "Prénom",
                prefixIcon: Icons.person_outline,
                validator: (v) => v != null && v.isNotEmpty ? null : "Obligatoire",
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                controller: telephoneController,
                hintText: "Téléphone",
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                controller: adresseController,
                hintText: "Adresse",
                prefixIcon: Icons.home,
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
                obscureText: true,
                validator: (v) => v != null && v.length >= 6 ? null : "Min 6 caractères",
              ),
              const SizedBox(height: 24),
              loading
                  ? const Center(child: CircularProgressIndicator())
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
