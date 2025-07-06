import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signloop/models/contract.dart';
import 'package:signloop/models/customer.dart';
import 'package:signloop/providers/app_provider.dart';

class ContractPage extends ConsumerStatefulWidget {
  const ContractPage({super.key});

  @override
  ConsumerState<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends ConsumerState<ContractPage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _creationDateController = TextEditingController();
  final _paymentModeController = TextEditingController();
  Contract? _editingContract;
  int? _selectedCustomerId; // Nouvelle variable pour suivre la sélection

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
    );
    if (picked != null) {
      setState(() {
        _creationDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showAddEditForm({Contract? contract}) {
    _editingContract = contract;
    _typeController.text = contract?.type ?? '';
    _creationDateController.text = contract?.creationDate?.toIso8601String().split('T')[0] ?? '';
    _paymentModeController.text = contract?.paymentMode ?? '';

    // Initialiser _selectedCustomerId en cherchant dans les contracts des clients
    _selectedCustomerId = null;
    if (contract != null) {
      final customers = ref.read(customerProvider);
      for (var customer in customers) {
        for (var c in customer.contracts) {
          if (c.contractId == contract.contractId) {
            _selectedCustomerId = customer.customerId;
            break;
          }
        }
        if (_selectedCustomerId != null) break;
      }
    }

    Get.dialog(
      AlertDialog(
        title: Text(_editingContract == null ? 'Ajouter un contrat' : 'Modifier un contrat'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final customers = ref.watch(customerProvider);
                  return DropdownButtonFormField<int>(
                    value: _selectedCustomerId,
                    decoration: const InputDecoration(labelText: 'Customer ID'),
                    items: customers.map<DropdownMenuItem<int>>((Customer customer) {
                      return DropdownMenuItem<int>(
                        value: customer.customerId,
                        child: Text('${customer.prenom} ${customer.nom} (ID: ${customer.customerId})'),
                      );
                    }).toList(),
                    onChanged: _editingContract == null
                        ? (int? newValue) {
                            setState(() {
                              _selectedCustomerId = newValue;
                            });
                          }
                        : null, // Désactiver la modification en mode édition
                    validator: (value) => _editingContract == null && value == null ? 'Required' : null,
                  );
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _creationDateController,
                decoration: const InputDecoration(labelText: 'Date de création'),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _paymentModeController,
                decoration: const InputDecoration(labelText: 'Mode de paiement'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final contract = Contract(
                  contractId: _editingContract?.contractId,
                  type: _typeController.text,
                  creationDate: DateTime.parse(_creationDateController.text),
                  paymentMode: _paymentModeController.text,
                  customer: _selectedCustomerId != null ? {'customerId': _selectedCustomerId} : _editingContract?.customer,
                );
                debugPrint('Sending contract to update: $contract');
                if (_editingContract == null) {
                  ref.read(contractProvider.notifier).addContract(contract);
                } else {
                  ref.read(contractProvider.notifier).updateContract(contract);
                }
                Get.back();
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _deleteContract(int? contractId) {
    if (contractId == null) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Confirmation',
      desc: 'Êtes-vous sûr de vouloir supprimer ce contrat ?',
      btnCancelText: 'Non',
      btnOkText: 'Oui',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        ref.read(contractProvider.notifier).deleteContract(contractId);
        Get.back();
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final contracts = ref.watch(contractProvider);
    final customers = ref.watch(customerProvider);

    if (customers.isEmpty || contracts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrats'),
        backgroundColor: const Color(0xFFB6D8F2),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];
          // Trouver le customerId à partir des contrats des clients
          int? contractCustomerId;
          for (var customer in customers) {
            for (var c in customer.contracts) {
              if (c.contractId == contract.contractId) {
                contractCustomerId = customer.customerId;
                break;
              }
            }
            if (contractCustomerId != null) break;
          }
          debugPrint('Contract ${contract.contractId}: customerId = $contractCustomerId');
          final customer = contractCustomerId != null
              ? customers.firstWhere(
                  (c) => c.customerId == contractCustomerId,
                  orElse: () => Customer(customerId: contractCustomerId, nom: 'Non trouvé', prenom: '', birthdate: DateTime.now(), contracts: []),
                )
              : null;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.description, size: 40, color: Colors.blue),
              title: Text('Type: ${contract.type ?? "N/A"}'),
              subtitle: Text(
                'Client: ${customer?.prenom ?? "Non défini"} ${customer?.nom ?? ""}\n'
                'Créé le: ${contract.creationDate?.toIso8601String().split('T')[0] ?? "N/A"}\n'
                'Paiement: ${contract.paymentMode ?? "N/A"}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showAddEditForm(contract: contract),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteContract(contract.contractId),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditForm(),
        backgroundColor: const Color(0xFFB6D8F2),
        child: const Icon(Icons.add),
      ),
    );
  }
}