import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:signloop/components/contract_components/contract_card.dart';
import 'package:signloop/contract/add_contract.dart';
import 'package:signloop/contract/update_contract.dart';
import 'package:signloop/providers/app_provider.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_header.dart';

class ContractPage extends ConsumerStatefulWidget {
  const ContractPage({super.key});

  @override
  ConsumerState<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends ConsumerState<ContractPage> {
  Future<void> _deleteContract(int? contractId) async {
    if (contractId == null) return;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Confirmation',
      desc: 'Êtes-vous sûr de vouloir supprimer ce contrat ?',
      btnCancelText: 'Non',
      btnOkText: 'Oui',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        try {
          await ref.read(contractProvider.notifier).deleteContract(contractId);
          setState(() {}); // Rafraîchir l'interface
          
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Succès',
            desc: 'Contrat supprimé avec succès !',
            btnOkOnPress: () {},
          ).show();
        } catch (e) {
          debugPrint('Error during deletion: $e');
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Erreur',
            desc: 'Échec de la suppression du contrat. Veuillez réessayer ou contacter le support.',
            btnOkOnPress: () {},
          ).show();
        }
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final contracts = ref.watch(contractProvider);
    final customers = ref.watch(customerProvider);

    if (customers.isEmpty || contracts.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('Chargement des contrats...', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                CustomAppBar(
                  title: 'Contrats',
                  onRefresh: () {
                    ref.refresh(contractProvider);
                    debugPrint('Contract list refreshed');
                  },
                ),
                CustomHeader(
                  title: 'Contrat',
                  itemCount: contracts.length,
                  icon: Icons.description_outlined,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: contracts.length,
                      itemBuilder: (context, index) {
                        final contract = contracts[index];
                        return ContractCard(
                          contract: contract,
                          customers: customers,
                          onEdit: () => Get.to(() => UpdateContractPage(contract: contract)),
                          onDelete: () => _deleteContract(contract.contractId),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF66BB6A).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => Get.to(() => const AddContractPage()),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}