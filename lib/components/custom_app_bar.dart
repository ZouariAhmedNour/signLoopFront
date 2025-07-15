import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import '../providers/auth_provider.dart';

class CustomAppBar extends ConsumerWidget {
  final String title;
  final VoidCallback? onRefresh;
  final bool showHomeButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onRefresh,
    this.showHomeButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: onRefresh,
            ),
          if (showHomeButton)
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.white),
              onPressed: () {
                Get.toNamed(AppRoutes.home);
                print('Navigating to Home');
              },
            ),
             IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Déconnexion',
            onPressed: () async {
              // Vider l'état utilisateur
              ref.read(authProvider.notifier).state = null;

              // Optionnel: supprimer token de SharedPreferences
              // final prefs = await SharedPreferences.getInstance();
              // await prefs.remove('jwt_token');

              // Aller à la page de login
              Get.offAllNamed(AppRoutes.loginPage);

              print('Utilisateur déconnecté');
            },
          ),
         
        ],
      ),
    );
  }
}
