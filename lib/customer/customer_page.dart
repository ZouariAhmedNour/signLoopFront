import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/models/customer.dart';
import '../components/custom_button.dart';
import '../components/textformfield.dart';
import '../providers/app_provider.dart';


class CustomerPage extends ConsumerWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerState = ref.watch(customerProvider);
    final lastNameController = TextEditingController();
    final firstNameController = TextEditingController();
    final birthDateController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        backgroundColor: const Color(0xFFB6D8F2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter un client',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
            CustomTextForm(
              hinttext: 'Date de naissance (YYYY-MM-DD)',
              mycontroller: birthDateController,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Ajouter',
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
              backgroundColor: const Color(0xFFB6D8F2),
            ),
            const SizedBox(height: 20),
            const Text(
              'Clients enregistrés :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: customerState.length,
                itemBuilder: (context, index) {
                  final customer = customerState[index];
                  return ListTile(
                    title: Text('${customer.prenom} ${customer.nom}'),
                    subtitle: Text('Né le: ${customer.birthdate.toIso8601String().split('T')[0]}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}