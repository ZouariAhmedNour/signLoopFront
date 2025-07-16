
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signloop/models/contract.dart';
import 'package:signloop/providers/app_provider.dart';
import 'package:signloop/providers/contract_form_provider.dart';

class UpdateContractPage extends ConsumerStatefulWidget {
  final Contract contract;

  const UpdateContractPage({super.key, required this.contract});

  @override
  ConsumerState<UpdateContractPage> createState() => _UpdateContractPageState();
}

class _UpdateContractPageState extends ConsumerState<UpdateContractPage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _creationDateController = TextEditingController();
  final _paymentModeController = TextEditingController();
  int? _selectedCustomerId;
  


  @override
  void initState() {
    super.initState();
    _typeController.text = widget.contract.type ?? '';
    _creationDateController.text = widget.contract.creationDate?.toIso8601String().split('T')[0] ?? '';
    _paymentModeController.text = widget.contract.paymentMode ?? '';
    _selectedCustomerId = widget.contract.customer?['customerId'] as int?;

      // Décoder l'image existante si présente
  if (widget.contract.cinPicBase64 != null) {
    final bytes = base64Decode(widget.contract.cinPicBase64!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cinImageProvider.notifier).state = bytes;
    });
  }
  }

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

  void _saveContract() {
    if (_formKey.currentState!.validate() && _selectedCustomerId != null) {
      final cinBytes = ref.read(cinImageProvider);
    String? base64Cin;
    if (cinBytes != null && cinBytes.isNotEmpty) {
      base64Cin = base64Encode(cinBytes);
    }
      final contract = Contract(
        contractId: widget.contract.contractId,
        type: _typeController.text,
        creationDate: DateTime.parse(_creationDateController.text),
        paymentMode: _paymentModeController.text,
        customer: {'customerId': _selectedCustomerId},
        cinPicBase64: base64Cin, 
      );
      ref.read(contractProvider.notifier).updateContract(contract);
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source, imageQuality: 75);
  if (pickedFile != null) {
    final bytes = await pickedFile.readAsBytes();
    ref.read(cinImageProvider.notifier).state = bytes;
  }
}

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Modifier un Contrat',
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
            // Header Profile Section
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
                      Icons.edit_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Modifier Contrat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
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
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextFormField(
                            controller: _typeController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.assignment_outlined, color: Color(0xFF1976D2)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              hintText: 'Ex: Journalier, Mensuel, Annuel',
                            ),
                            validator: (value) => (value?.isEmpty ?? true) ? 'Ce champ est requis' : null,
                          ),
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
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextFormField(
                            controller: _creationDateController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today_outlined, color: Color(0xFF1976D2)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              hintText: 'Sélectionner une date',
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            validator: (value) => (value?.isEmpty ?? true) ? 'Ce champ est requis' : null,
                          ),
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
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextFormField(
                            controller: _paymentModeController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.payment_outlined, color: Color(0xFF1976D2)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              hintText: 'Ex: Cash, Visa, Mastercard',
                            ),
                            validator: (value) => (value?.isEmpty ?? true) ? 'Ce champ est requis' : null,
                          ),
                        ),
                        const SizedBox(height: 24),
// Row(
//   children: [
//     ElevatedButton.icon(
//       onPressed: () => _pickImage(ImageSource.camera),
//       icon: const Icon(Icons.camera_alt),
//       label: const Text('Prendre une photo'),
//     ),
//     const SizedBox(width: 12),
//     ElevatedButton.icon(
//       onPressed: () => _pickImage(ImageSource.gallery),
//       icon: const Icon(Icons.photo_library),
//       label: const Text('Depuis galerie'),
//     ),
//   ],
// ),
// // Aperçu de l'image
// if (ref.watch(cinImageProvider) != null)
//   Padding(
//     padding: const EdgeInsets.symmetric(vertical: 12),
//     child: Image.memory(
//       ref.watch(cinImageProvider)!,
//       width: double.infinity,
//       height: 200,
//       fit: BoxFit.cover,
//     ),
//   ),
//   TextButton.icon(
//   onPressed: () {
//     ref.read(cinImageProvider.notifier).state = null;
//   },
//   icon: const Icon(Icons.delete, color: Colors.red),
//   label: const Text('Retirer la photo', style: TextStyle(color: Colors.red)),
// ),

Column(
  mainAxisSize: MainAxisSize.min, // Allows shrink-wrapping
  crossAxisAlignment: CrossAxisAlignment.start, // Match your original layout
  children: [
    ElevatedButton.icon(
      onPressed: () => _pickImage(ImageSource.camera),
      icon: const Icon(Icons.camera_alt, color: Colors.white),
      label: const Text('Prendre une photo'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    ),
    const SizedBox(width: 12),
    ElevatedButton.icon(
      onPressed: () => _pickImage(ImageSource.gallery),
      icon: const Icon(Icons.photo_library, color: Colors.white),
      label: const Text('Depuis galerie'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    ),
  ],
),
// Aperçu de l'image
if (ref.watch(cinImageProvider) != null)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          ref.watch(cinImageProvider)!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    ),
  ),
TextButton.icon(
  onPressed: () {
    ref.read(cinImageProvider.notifier).state = null;
  },
  icon: const Icon(Icons.delete, color: Colors.red),
  label: const Text('Retirer la photo', style: TextStyle(color: Colors.red)),
  style: TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    backgroundColor: const Color(0xFFF7FAFC),
    foregroundColor: Colors.red,
  ),
),

                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _saveContract,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Sauvegarder',
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