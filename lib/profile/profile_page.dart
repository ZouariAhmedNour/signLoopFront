import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import '../../models/user.dart';
import '../../services/user_api.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final api = UserApi();

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final telephoneController = TextEditingController();
  final adresseController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => loading = true);
    try {
      final user = await api.getMyProfile();

      if (user == null) {
        throw Exception("Aucun utilisateur retourné");
      }

      nomController.text = user.nom;
      prenomController.text = user.prenom;
      telephoneController.text = user.telephone ?? '';
      adresseController.text = user.adresse ?? '';

      // Mettre à jour authProvider
      ref.read(authProvider.notifier).state = user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement: ${e.toString()}")),
      );
      Get.offAllNamed(AppRoutes.loginPage); // Si erreur, retour login
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      // L'utilisateur n'est pas connecté, retour
      return;
    }

    setState(() => loading = true);

    try {
      final updatedUser = await api.updateMyProfile(
        User(
          userId: currentUser.userId,
          nom: nomController.text.trim(),
          prenom: prenomController.text.trim(),
          email: currentUser.email, // Email reste inchangé
          password: currentUser.password, // Tu peux garder l'ancien mot de passe
          telephone: telephoneController.text.trim(),
          adresse: adresseController.text.trim(),
          emailVerified: currentUser.emailVerified,
        ),
      );

      ref.read(authProvider.notifier).state = updatedUser;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: "Succès",
        desc: "Profil mis à jour avec succès.",
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Erreur",
        desc: "Erreur: ${e.toString()}",
        btnOkOnPress: () {},
      ).show();
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _buildFieldSection({
    required String title,
    required IconData icon,
    required Color color,
    required TextEditingController controller,
    required String hintText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Requis",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: color),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
          validator: isRequired
              ? (value) => value == null || value.isEmpty ? "Champ requis" : null
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Utilisateur non connecté."),
        ),
      );
    }

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
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Mon Profil",
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
                    // Section profil utilisateur
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar avec initiales
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${user.nom.isNotEmpty ? user.nom[0] : ''}${user.prenom.isNotEmpty ? user.prenom[0] : ''}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${user.nom} ${user.prenom}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Badge de statut
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.emailVerified == true
                                        ? const Color(0xFF66BB6A)
                                        : const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.emailVerified == true ? "Vérifié" : "Non vérifié",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
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
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          
                          // Section Informations personnelles
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Titre de section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Informations perso",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Nom
                                _buildFieldSection(
                                  title: "Nom",
                                  icon: Icons.person_outline,
                                  color: const Color(0xFF42A5F5),
                                  controller: nomController,
                                  hintText: "Entrez votre nom",
                                  isRequired: true,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Prénom
                                _buildFieldSection(
                                  title: "Prénom",
                                  icon: Icons.person_outline,
                                  color: const Color(0xFF1976D2),
                                  controller: prenomController,
                                  hintText: "Entrez votre prénom",
                                  isRequired: true,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Section Contact
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Titre de section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF66BB6A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.contact_phone_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Informations de contact",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Téléphone
                                _buildFieldSection(
                                  title: "Téléphone",
                                  icon: Icons.phone_outlined,
                                  color: const Color(0xFF66BB6A),
                                  controller: telephoneController,
                                  hintText: "Entrez votre téléphone (optionnel)",
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Adresse
                                _buildFieldSection(
                                  title: "Adresse",
                                  icon: Icons.home_outlined,
                                  color: const Color(0xFF2E7D32),
                                  controller: adresseController,
                                  hintText: "Entrez votre adresse (optionnel)",
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Section Email (lecture seule)
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Titre de section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFAB47BC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.email_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Informations du compte",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Email (lecture seule)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFAB47BC).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFAB47BC).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.email_outlined,
                                          color: Color(0xFF8E24AA),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Email",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF718096),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user.email,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF2D3748),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFF718096),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Bouton de sauvegarde
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF66BB6A).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(
                                Icons.save,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Enregistrer les modifications",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
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