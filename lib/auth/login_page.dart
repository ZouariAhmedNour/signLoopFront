import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:signloop/auth/forgot_password_page.dart';
import 'package:signloop/auth/login_controller.dart';

import 'package:signloop/components/textformfield.dart';
import '../../Configurations/app_routes.dart';
import '../../services/user_api.dart';

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

  void _login() {
    final controller = LoginController(context: context, ref: ref);
    controller.login(
      emailController.text,
      passwordController.text,
      _formKey,
      (value) => setState(() => loading = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header avec dégradé bleu
          Container(
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
                    // Header avec navigation
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Connexion",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Pour centrer le titre
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Section d'informations avec icône
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.login,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bienvenue",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Connectez-vous à votre compte",
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
          ),
          
          // Corps de la page
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Carte principale du formulaire
                    Container(
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Section Email
                         
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: emailController,
                            hintText: "Entrez votre email",
                            prefixIcon: Icons.email,
                            validator: (v) =>
                                v != null && v.contains("@") ? null : "Email invalide",
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Section Mot de passe
                          
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: passwordController,
                            hintText: "Entrez votre mot de passe",
                            prefixIcon: Icons.lock,
                            obscureText: true,
                            validator: (v) =>
                                v != null && v.length >= 6 ? null : "Min 6 caractères",
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Bouton de connexion
                          loading
                              ? Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF42A5F5).withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      "Se connecter",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Section liens
                    Container(
                      padding: const EdgeInsets.all(20),
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
                        children: [
                          // Mot de passe oublié
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF66BB6A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF66BB6A).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.help_outline,
                                      color: Color(0xFF2E7D32),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      "Mot de passe oublié ?",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xFF2E7D32),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Séparateur
                          Container(
                            height: 1,
                            color: const Color(0xFFE2E8F0),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Créer un compte
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.registerPage);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.person_add_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Pas de compte ?",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          "Créer un compte",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
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
}