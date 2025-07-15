import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:signloop/providers/auth_provider.dart';
import 'Configurations/app_routes.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:  Text(
          'Accueil (${user?.nom ?? "Invité"})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF66BB6A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Bienvenue',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gérez vos clients et contrats facilement',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Cards Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      children: [
                        _buildMenuCard(
                          icon: Icons.people_rounded,
                          title: 'Clients',
                          subtitle: 'Gérer vos clients',
                          color: const Color(0xFF4A90E2),
                          onTap: () => Get.toNamed(AppRoutes.customerListPage),
                        ),
                        _buildMenuCard(
                          icon: Icons.article_rounded,
                          title: 'Contrats',
                          subtitle: 'Gérer vos contrats',
                          color: const Color(0xFF7B68EE),
                          onTap: () => Get.toNamed(AppRoutes.contractPage),
                        ),
                        _buildMenuCard(
                          icon: Icons.settings_rounded,
                          title: 'Profile',
                          subtitle: 'Gérer votre profil',
                          color: const Color(0xFF7B68EE),
                          onTap: () => Get.toNamed(AppRoutes.profilePage),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}