import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/providers/app_provider.dart';
import 'package:signloop/models/contract.dart';
import 'package:signloop/models/customer.dart';

class ContractDetailsPage extends ConsumerWidget {
  final int contractId;

  const ContractDetailsPage({super.key, required this.contractId});

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'journalier':
        return const Color(0xFF66BB6A);
      case 'mensuel':
        return const Color(0xFFAB47BC);
      case 'annuel':
        return const Color(0xFF1976D2);
      default:
        return const Color(0xFF718096);
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'journalier':
        return Icons.today_outlined;
      case 'mensuel':
        return Icons.calendar_month_outlined;
      case 'annuel':
        return Icons.date_range_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  String _getCustomerInitials(Customer customer) {
    final nom = customer.nom.isNotEmpty ? customer.nom[0] : '';
    final prenom = customer.prenom.isNotEmpty ? customer.prenom[0] : '';
    return '$nom$prenom'.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(contractProvider);
    final customers = ref.watch(customerProvider);

    // Récupérer le contrat avec try/catch
    Contract? contract;
    try {
      contract = contracts.firstWhere((c) => c.contractId == contractId);
    } catch (e) {
      contract = null;
    }

    if (contract == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text("Détails du contrat"),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contrat introuvable',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Récupérer le client associé
    final customerId = contract.customer?['customerId'] ?? contract.effectiveCustomerId;
    Customer? customer;
    try {
      customer = customers.firstWhere((c) => c.customerId == customerId);
    } catch (e) {
      customer = Customer(
        customerId: 0,
        nom: 'Non défini',
        prenom: '',
        birthdate: DateTime.now(),
        contracts: [],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Détails du contrat"),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge du contrat en haut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getTypeColor(contract.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getTypeColor(contract.type).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(contract.type),
                    color: _getTypeColor(contract.type),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${contract.type?.toUpperCase() ?? 'CONTRAT'} - ID: #${contract.contractId}",
                    style: TextStyle(
                      color: _getTypeColor(contract.type),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Informations du client
            _buildSectionTitle("Informations du client", Icons.person_outline),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar avec initiales
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _getCustomerInitials(customer),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Informations client
                  _buildInfoRow(Icons.account_circle_outlined, "Nom complet", 
                      "${customer.nom} ${customer.prenom}"),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.cake_outlined, "Date de naissance", 
                      customer.birthdate.toLocal().toString().split(' ')[0]),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.badge_outlined, "ID Client", 
                      "#${customer.customerId}"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Photo CIN si disponible
            if (contract.cinPicBase64 != null && contract.cinPicBase64!.isNotEmpty) ...[
              _buildSectionTitle("Photo CIN", Icons.credit_card_outlined),
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    base64Decode(contract.cinPicBase64!),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Informations du contrat
            _buildSectionTitle("Informations du contrat", Icons.description_outlined),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Type de contrat avec badge coloré
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getTypeColor(contract.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getTypeIcon(contract.type),
                          color: _getTypeColor(contract.type),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Type de contrat",
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(contract.type),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              contract.type?.toUpperCase() ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildInfoRow(Icons.calendar_today_outlined, "Date de création", 
                      contract.creationDate?.toIso8601String().split('T')[0] ?? 'N/A'),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.payment_outlined, "Mode de paiement", 
                      contract.paymentMode ?? 'N/A'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1976D2),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667eea),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2D3748),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}