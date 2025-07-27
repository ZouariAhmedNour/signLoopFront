import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import 'package:signloop/models/contract.dart';
import 'package:signloop/models/customer.dart';

class ContractCard extends StatelessWidget {
  final Contract contract;
  final List<Customer> customers;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContractCard({
    super.key,
    required this.contract,
    required this.customers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Essayer de récupérer le customerId directement depuis le contrat
    final int? contractCustomerId = contract.customer?['customerId'] as int?;
    Customer? customer;

    if (contractCustomerId != null) {
      customer = customers.firstWhere(
        (c) => c.customerId == contractCustomerId,
        orElse: () => Customer(
          customerId: contractCustomerId,
          nom: 'Non trouvé',
          prenom: '',
          birthdate: DateTime.now(),
          contracts: [],
        ),
      );
    } else {
      // Fallback : chercher dans customer.contracts si customerId est null
      for (var c in customers) {
        for (var cont in c.contracts) {
          if (cont.contractId == contract.contractId) {
            customer = c;
            break;
          }
        }
        if (customer != null) break;
      }
      if (customer == null) {
        customer = Customer(
          customerId: 0,
          nom: 'Non défini',
          prenom: '',
          birthdate: DateTime.now(),
          contracts: [],
        );
      }
    }

    Color _getContractTypeColor(String? type) {
      switch (type?.toLowerCase()) {
        case 'journalier':
          return const Color(0xFF66BB6A);
        case 'mensuel':
          return const Color(0xFFAB47BC);
        case 'annuel':
          return const Color(0xFF1976D2);
        default:
          return const Color(0xFFB0BEC5);
      }
    }

    IconData _getPaymentIcon(String? paymentMode) {
      switch (paymentMode?.toLowerCase()) {
        case 'cash':
          return Icons.attach_money;
        case 'mastercard':
        case 'visa':
          return Icons.credit_card;
        case 'paypal':
          return Icons.account_balance_wallet;
        default:
          return Icons.payment;
      }
    }

    return GestureDetector(
     onTap: () {
  Get.toNamed(
    AppRoutes.contractDetails,
    arguments: {
      'contractId': contract.contractId,
      'customerId': contract.effectiveCustomerId
    },
  );
},
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB0BEC5).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getContractTypeColor(contract.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      contract.type ?? "N/A",
                      style: TextStyle(
                        color: _getContractTypeColor(contract.type),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF6A1B9A)),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF66BB6A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF2E7D32), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Client', style: TextStyle(color: Color(0xFF78909C), fontSize: 12)),
                        Text(
                          '${customer.prenom} ${customer.nom}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFAB47BC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.calendar_today, color: Color(0xFF6A1B9A), size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Créé le', style: TextStyle(color: Color(0xFF78909C), fontSize: 10)),
                              Text(
                                contract.creationDate?.toIso8601String().split('T')[0] ?? "N/A",
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF66BB6A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_getPaymentIcon(contract.paymentMode), color: const Color(0xFF2E7D32), size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Paiement', style: TextStyle(color: Color(0xFF78909C), fontSize: 10)),
                              Text(
                                contract.paymentMode ?? "N/A",
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}