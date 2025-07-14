import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';

class CustomAppBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              icon : const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Get.offAllNamed(AppRoutes.loginPage);
                print('Logging out and navigating to Login');
              },
              ),
        ],
      ),
    );
  }
}