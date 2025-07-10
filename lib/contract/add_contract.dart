import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:signloop/models/contract.dart';
import 'package:signloop/providers/app_provider.dart';
import 'package:signloop/components/elevatedbutton.dart';
import 'package:signloop/components/textformfield.dart';

class AddContractPage extends ConsumerStatefulWidget {
  const AddContractPage({super.key});

  @override
  ConsumerState<AddContractPage> createState() => _AddContractPageState();
}

class _AddContractPageState extends ConsumerState<AddContractPage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _creationDateController = TextEditingController();
  final _paymentModeController = TextEditingController();
  int? _selectedCustomerId;

  @override
  void dispose() {
    _typeController.dispose();
    _creationDateController.dispose();
    _paymentModeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _creationDateController.text.isNotEmpty
          ? DateTime.parse(_creationDateController.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _creationDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveContract() async {
    if (_formKey.currentState!.validate() && _selectedCustomerId != null) {
      final contract = Contract(
        type: _typeController.text,
        creationDate: DateTime.parse(_creationDateController.text),
        paymentMode: _paymentModeController.text,
        customer: {'customerId': _selectedCustomerId},
      );
      try {
        await ref.read(contractProvider.notifier).addContract(contract);
        ref.refresh(contractProvider);
        ref.refresh(customerProvider);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Succès',
          desc: 'Contrat créé avec succès !',
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        ).show();
      } catch (e) {
        debugPrint('Error saving contract: $e');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Erreur',
          desc: 'Une erreur s\'est produite lors de la création du contrat. Veuillez réessayer.',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ajouter un Contrat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF66BB6A)],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.add_box_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nouveau Contrat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations du contrat',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Client',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonFormField<int>(
                            value: _selectedCustomerId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline, color: Color(0xFF1976D2)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              hintText: 'Sélectionner un client',
                            ),
                            dropdownColor: Colors.white,
                            iconEnabledColor: const Color(0xFF1976D2),
                            style: const TextStyle(color: Color(0xFF2D3744), fontSize: 16),
                            items: customers.map<DropdownMenuItem<int>>((customer) {
                              return DropdownMenuItem<int>(
                                value: customer.customerId,
                                child: Text('${customer.prenom} ${customer.nom} (ID: ${customer.customerId})'),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedCustomerId = value),
                            validator: (value) => value == null ? 'Veuillez sélectionner un client' : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Type de contrat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: _typeController,
                          hintText: 'Ex: Journalier, Mensuel, Annuel',
                          prefixIcon: Icons.assignment_outlined,
                          validator: (value) => (value?.isEmpty ?? true) ? 'Ce champ est requis' : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Date de création',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: _creationDateController,
                          hintText: 'Sélectionner une date',
                          prefixIcon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) => (value?.isEmpty ?? true) ? 'Ce champ est requis' : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Mode de paiement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: _paymentModeController,
                          hintText: 'Ex: Cash, Visa, Mastercard',
                          prefixIcon: Icons.payment_outlined,
                          validator: (value) => (value?.isEmpty ?? true) ? 'Ce champ est requis' : null,
                        ),
                        const SizedBox(height: 30),
                        CustomElevatedButton(
                          onPressed: _saveContract,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Créer le contrat',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
            ),
          ],
        ),
      ),
    );
  }
}