import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/models/customer.dart';
import '../components/textformfield.dart';
import '../components/custom_button.dart';
import '../providers/app_provider.dart';

class CustomerPage extends ConsumerWidget {
  const CustomerPage({super.key});

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB6D8F2),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

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
            CustomTextFormField(
              controller: lastNameController,
              hintText: 'Nom',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 10),
            CustomTextFormField(
              controller: firstNameController,
              hintText: 'Prénom',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 10),
            CustomTextFormField(
              controller: birthDateController,
              hintText: 'Date de naissance (YYYY-MM-DD)',
              prefixIcon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: () => _selectDate(context, birthDateController),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Ajouter',
              backgroundColor: const Color(0xFFB6D8F2),
              lastNameController: lastNameController,
              firstNameController: firstNameController,
              birthDateController: birthDateController,
              context: context,
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