import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../components/custom_button.dart';
import '../components/textformfield.dart';
import '../models/customer.dart';
import '../providers/app_provider.dart';

class AddCustomerPage extends ConsumerStatefulWidget {
  const AddCustomerPage({super.key});

  @override
  ConsumerState<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends ConsumerState<AddCustomerPage> {
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final birthDateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Client'),
        backgroundColor: const Color(0xFFB6D8F2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextForm(
              hinttext: 'Nom',
              mycontroller: lastNameController,
            ),
            const SizedBox(height: 10),
            CustomTextForm(
              hinttext: 'Prénom',
              mycontroller: firstNameController,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: birthDateController,
              decoration: InputDecoration(
                hintText: 'Date de naissance (YYYY-MM-DD)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true, // Empêche la saisie manuelle
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Ajouter',
              onPressed: () async {
                try {
                  final customer = Customer(
                    nom: lastNameController.text,
                    prenom: firstNameController.text,
                    birthdate: DateTime.parse(birthDateController.text),
                  );
                    try {
                         await ref.read(customerProvider.notifier).addCustomer(customer);
                         AwesomeDialog(
                           context: context,
                           dialogType: DialogType.success,
                           animType: AnimType.bottomSlide,
                           title: 'Succès',
                           desc: 'Client ajouté avec succès !',
                           btnOkOnPress: () {
                             Navigator.pop(context);
                           },
                         ).show();
                       } catch (apiError) {
                         print('❌ API Error: $apiError');
                         AwesomeDialog(
                           context: context,
                           dialogType: DialogType.error,
                           animType: AnimType.bottomSlide,
                           title: 'Erreur',
                           desc: 'Erreur lors de l\'ajout du client : $apiError',
                           btnOkOnPress: () {},
                         ).show();
                       }
                     } catch (e) {
                       AwesomeDialog(
                         context: context,
                         dialogType: DialogType.error,
                         animType: AnimType.bottomSlide,
                         title: 'Erreur',
                         desc: 'Format de date invalide ou erreur inattendue : $e',
                         btnOkOnPress: () {},
                       ).show();
                     }
                   },
                   backgroundColor: const Color(0xFFB6D8F2),
            ),
          ],
        ),
      ),
    );
  }
}