import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/models/customer.dart';
import 'package:signloop/providers/app_provider.dart';

class CustomButton extends ConsumerWidget {
  final String text;
  final Color backgroundColor;
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final TextEditingController birthDateController;
  final BuildContext context;

  const CustomButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.lastNameController,
    required this.firstNameController,
    required this.birthDateController,
    required this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        final customer = Customer(
          nom: lastNameController.text,
          prenom: firstNameController.text,
          birthdate: DateTime.parse(birthDateController.text),
        );
        ref.read(customerProvider.notifier).addCustomer(customer);
        // Clear form
        lastNameController.clear();
        firstNameController.clear();
        birthDateController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client ajouté avec succès !')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}