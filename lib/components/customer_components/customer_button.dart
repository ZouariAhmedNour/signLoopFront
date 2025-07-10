import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:signloop/models/customer.dart';
import 'package:signloop/providers/app_provider.dart';

class CustomerButton extends ConsumerWidget {
  final String text;
  final Color backgroundColor;
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final TextEditingController birthDateController;
  final BuildContext context;

  const CustomerButton({
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
      onPressed: () async {
        if (lastNameController.text.trim().isEmpty ||
            firstNameController.text.trim().isEmpty ||
            birthDateController.text.isEmpty) {
          AwesomeDialog(
            context: this.context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Erreur',
            desc: 'Veuillez remplir tous les champs.',
            btnOkOnPress: () {},
          ).show();
          return;
        }
        try {
          final customer = Customer(
            nom: lastNameController.text.trim(),
            prenom: firstNameController.text.trim(),
            birthdate: DateTime.parse(birthDateController.text),
          );
          try {
            await ref.read(customerProvider.notifier).addCustomer(customer);
            AwesomeDialog(
              context: this.context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              title: 'Succès',
              desc: 'Client ajouté avec succès !',
              btnOkOnPress: () {
                Navigator.pop(this.context);
              },
            ).show();
          } catch (apiError) {
            AwesomeDialog(
              context: this.context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Erreur',
              desc: 'Erreur lors de l\'ajout du client : $apiError',
              btnOkOnPress: () {},
            ).show();
          }
        } catch (e) {
          AwesomeDialog(
            context: this.context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Erreur',
            desc: 'Format de date invalide ou erreur inattendue : $e',
            btnOkOnPress: () {},
          ).show();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}