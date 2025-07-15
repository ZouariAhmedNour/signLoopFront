import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import 'package:signloop/auth/register_controller.dart';
import 'package:signloop/components/textformfield.dart';
import 'package:signloop/models/user.dart';


class RegisterPage extends ConsumerWidget {
  RegisterPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final telephoneController = TextEditingController();
  final adresseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerControllerProvider);
    final isLoading = registerState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ⬇️ ... garde ton header intact
          _buildHeader(context),
          // Corps de la page
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildPersonalInfo(),
                    const SizedBox(height: 20),
                    _buildContactInfo(),
                    const SizedBox(height: 20),
                    _buildSecurityInfo(context, ref, isLoading),
                    const SizedBox(height: 20),
                    _buildLoginLink(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Créer un compte",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_add, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rejoignez-nous",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Créez votre compte en quelques étapes",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return _sectionContainer(
      title: "Infos personnelles",
      icon: Icons.person_outline,
      color: const Color(0xFF667eea),
      child: Column(
        children: [
          _buildFieldSection(
            field: CustomTextFormField(
              controller: nomController,
              hintText: "Entrez votre nom",
              prefixIcon: Icons.person,
              validator: (v) => v != null && v.isNotEmpty ? null : "Obligatoire",
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldSection(
            field: CustomTextFormField(
              controller: prenomController,
              hintText: "Entrez votre prénom",
              prefixIcon: Icons.person_outline,
              validator: (v) => v != null && v.isNotEmpty ? null : "Obligatoire",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return _sectionContainer(
      title: "Informations de contact",
      icon: Icons.contact_phone_outlined,
      color: const Color(0xFF66BB6A),
      child: Column(
        children: [
          _buildFieldSection(
            field: CustomTextFormField(
              controller: telephoneController,
              hintText: "Entrez votre téléphone",
              prefixIcon: Icons.phone,
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldSection(
            field: CustomTextFormField(
              controller: adresseController,
              hintText: "Entrez votre adresse",
              prefixIcon: Icons.home,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo(BuildContext context, WidgetRef ref, bool isLoading) {
    return _sectionContainer(
      title: "Sécurité du compte",
      icon: Icons.security,
      color: const Color(0xFFAB47BC),
      child: Column(
        children: [
          _buildFieldSection(
            field: CustomTextFormField(
              controller: emailController,
              hintText: "Entrez votre email",
              prefixIcon: Icons.email,
              validator: (v) => v != null && v.contains("@") ? null : "Email invalide",
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldSection(
            field: CustomTextFormField(
              controller: passwordController,
              hintText: "Entrez votre mot de passe",
              prefixIcon: Icons.lock,
              obscureText: true,
              validator: (v) => v != null && v.length >= 6 ? null : "Min 6 caractères",
            ),
          ),
          const SizedBox(height: 32),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFF66BB6A),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    await ref.read(registerControllerProvider.notifier).register(
                          user: User(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            nom: nomController.text.trim(),
                            prenom: prenomController.text.trim(),
                            telephone: telephoneController.text.trim(),
                            adresse: adresseController.text.trim(),
                          ),
                          context: context,
                        );
                  },
                  child: const Text("S'inscrire"),
                ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.loginPage);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.login, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Déjà un compte ? Se connecter",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSection({required Widget field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [field],
    );
  }

  Widget _sectionContainer({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
