import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import 'package:signloop/models/customer.dart';
import 'package:signloop/providers/app_provider.dart';

class CustomerDetailsPage extends ConsumerStatefulWidget {
  final dynamic customerId; // Accepte un customerId (int)

  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends ConsumerState<CustomerDetailsPage> {
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _birthDateController;

  @override
  void initState() {
    super.initState();
    final customerList = ref.read(customerProvider);
    if (customerList.isEmpty) {
      _initializeEmptyControllers();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Erreur',
          desc: 'Aucun client trouvé dans la liste.',
          btnOkOnPress: () {
            Get.back();
          },
        ).show();
      });
      return;
    }
    try {
      final int effectiveIndex = widget.customerId is int
          ? customerList.indexWhere((c) => c.customerId == widget.customerId)
          : 0; // Fallback to first if not int
      final customer = effectiveIndex != -1
          ? customerList[effectiveIndex]
          : customerList.firstWhere(
              (c) => c.customerId == widget.customerId,
              orElse: () => Customer(nom: '', prenom: '', birthdate: DateTime.now(), contracts: []),
            );
      _lastNameController = TextEditingController(text: customer.nom.isEmpty ? '' : customer.nom);
      _firstNameController = TextEditingController(text: customer.prenom.isEmpty ? '' : customer.prenom);
      _birthDateController = TextEditingController(text: customer.birthdate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0]);
    } catch (e) {
      _initializeEmptyControllers();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Erreur',
          desc: 'Erreur lors de l\'initialisation : $e',
          btnOkOnPress: () {
            Get.back();
          },
        ).show();
      });
    }
  }

  void _initializeEmptyControllers() {
    _lastNameController = TextEditingController();
    _firstNameController = TextEditingController();
    _birthDateController = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDateController.text.isNotEmpty
          ? DateTime.tryParse(_birthDateController.text) ?? DateTime.now()
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
        _birthDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _updateCustomer() async {
    if (_lastNameController.text.isEmpty || _firstNameController.text.isEmpty || _birthDateController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Erreur',
        desc: 'Veuillez remplir tous les champs.',
        btnOkOnPress: () {},
      ).show();
      return;
    }
    try {
      final customerList = ref.read(customerProvider);
      final int customerIndex = customerList.indexWhere((c) => c.customerId == widget.customerId);
      if (customerIndex == -1) {
        throw Exception('Customer not found');
      }
      final customer = customerList[customerIndex];
      final DateTime birthDate = DateTime.tryParse(_birthDateController.text) ?? DateTime.now();
      final updatedCustomer = Customer(
        customerId: customer.customerId,
        nom: _lastNameController.text,
        prenom: _firstNameController.text,
        birthdate: birthDate,
        contracts: customer.contracts ?? [],
      );
      await ref.read(customerProvider.notifier).updateCustomer(updatedCustomer);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Succès',
        desc: 'Client modifié avec succès !',
        btnOkOnPress: () {
          Get.offNamed(AppRoutes.customerListPage);
        },
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Erreur',
        desc: 'Erreur lors de la modification : $e',
        btnOkOnPress: () {},
      ).show();
    }
  }

  void _deleteCustomer() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Confirmation',
      desc: 'Êtes-vous sûr de vouloir supprimer ce client ?',
      btnCancelText: 'Non',
      btnOkText: 'Oui',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        try {
          final int effectiveId = widget.customerId is int
              ? widget.customerId
              : ref.read(customerProvider).firstWhere((c) => c.customerId == widget.customerId, orElse: () => Customer(customerId: widget.customerId as int, nom: '', prenom: '', birthdate: DateTime.now(), contracts: [])).customerId;
          await ref.read(customerProvider.notifier).deleteCustomer(effectiveId);
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Succès',
            desc: 'Client supprimé avec succès !',
            btnOkOnPress: () {
              Get.offNamed(AppRoutes.customerListPage);
            },
          ).show();
        } catch (e) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Erreur',
            desc: 'Erreur lors de la suppression : $e',
            btnOkOnPress: () {},
          ).show();
        }
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final customerList = ref.watch(customerProvider);
    final int effectiveIndex = widget.customerId is int
        ? customerList.indexWhere((c) => c.customerId == widget.customerId)
        : 0; // Fallback to first if not int
    final customer = effectiveIndex != -1
        ? customerList[effectiveIndex]
        : customerList.firstWhere(
            (c) => c.customerId == widget.customerId,
            orElse: () => Customer(nom: '', prenom: '', birthdate: DateTime.now(), contracts: []),
          );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Détails du Client',
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
          onPressed: () => Get.back(),
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
                      Icons.person_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${customer.prenom} ${customer.nom}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${customer.customerId ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations personnelles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Nom',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _birthDateController,
                        label: 'Date de naissance',
                        icon: Icons.calendar_today_rounded,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 30),
                      
                      // Contracts Section
                      if (customer.contracts?.isNotEmpty ?? false) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.article_rounded,
                              color: Color(0xFF7B68EE),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Contrats (${customer.contracts!.length})',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        ...customer.contracts!.map((contract) => _buildContractCard(contract)),
                        const SizedBox(height: 30),
                      ],
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _updateCustomer,
                              icon: const Icon(Icons.edit_rounded),
                              label: const Text('Modifier'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _deleteCustomer,
                              icon: const Icon(Icons.delete_rounded),
                              label: const Text('Supprimer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE74C3C),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D3748),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF1976D2),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildContractCard(contract) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type: ${contract.type ?? "N/A"}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Créé le: ${contract.creationDate?.toIso8601String().split('T')[0] ?? "N/A"}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                  Text(
                    'Paiement: ${contract.paymentMode ?? "N/A"}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}