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
    try {
      final customerList = ref.read(customerProvider);
      final int effectiveIndex = widget.customerId is int
          ? customerList.indexWhere((c) => c.customerId == widget.customerId)
          : (widget.customerId as int? ?? 0);
      final customer = effectiveIndex != -1
          ? customerList[effectiveIndex]
          : customerList.firstWhere(
              (c) => c.customerId == widget.customerId,
              orElse: () => Customer(nom: '', prenom: '', birthdate: DateTime.now(), contracts: []),
            );
      _lastNameController = TextEditingController(text: customer.nom ?? '');
      _firstNameController = TextEditingController(text: customer.prenom ?? '');
      _birthDateController = TextEditingController(text: customer.birthdate?.toIso8601String().split('T')[0] ?? '');
      print('✅ Initialized with customer: ${customer.nom} ${customer.prenom}, customerId: ${widget.customerId}');
    } catch (e) {
      print('❌ Error initializing customer details: $e');
      _lastNameController = TextEditingController();
      _firstNameController = TextEditingController();
      _birthDateController = TextEditingController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Erreur',
          desc: 'Client non trouvé : $e',
          btnOkOnPress: () {
            Get.back();
          },
        ).show();
      });
    }
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
          ? DateTime.parse(_birthDateController.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF2E7D96),
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
    print('✅ Starting update for customerId: ${widget.customerId}');
    try {
      final customerList = ref.read(customerProvider);
      final int customerIndex = customerList.indexWhere((c) => c.customerId == widget.customerId);
      if (customerIndex == -1) {
        print('❌ Customer not found with customerId: ${widget.customerId}');
        throw Exception('Customer not found');
      }
      final customer = customerList[customerIndex];
      final updatedCustomer = Customer(
        customerId: customer.customerId,
        nom: _lastNameController.text,
        prenom: _firstNameController.text,
        birthdate: DateTime.parse(_birthDateController.text),
        contracts: customer.contracts ?? [],
      );
      print('✅ Updating customer: ${updatedCustomer.nom} ${updatedCustomer.prenom}');
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
      print('❌ Error updating customer: $e');
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
    print('✅ Starting delete for customerId: ${widget.customerId}');
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
          final int effectiveId = widget.customerId is int ? widget.customerId : ref.read(customerProvider)[widget.customerId as int? ?? 0].customerId ?? widget.customerId as int;
          print('✅ Deleting customer with id: $effectiveId');
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
          print('❌ Error deleting customer: $e');
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
        : (widget.customerId as int? ?? 0);
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
        backgroundColor: const Color(0xFF2E7D96),
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
              Color(0xFF2E7D96),
              Color(0xFFB6D8F2),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Profile Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
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
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Section
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Section
                      const Text(
                        'Informations personnelles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                                color: Colors.black87,
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
                                backgroundColor: const Color(0xFF4A90E2),
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF2E7D96),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF7B68EE).withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7B68EE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Color(0xFF7B68EE),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Créé le: ${contract.creationDate?.toIso8601String().split('T')[0] ?? "N/A"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Paiement: ${contract.paymentMode ?? "N/A"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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