import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/models/contract.dart';
import 'package:signloop/models/customer.dart';
import 'package:signloop/providers/app_provider.dart';

class ContractForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController typeController;
  final TextEditingController creationDateController;
  final TextEditingController paymentModeController;
  final Contract? editingContract;
  final int? selectedCustomerId;
  final Function(int?) onCustomerChanged;
  final Function(BuildContext) selectDate;

  const ContractForm({
    super.key,
    required this.formKey,
    required this.typeController,
    required this.creationDateController,
    required this.paymentModeController,
    this.editingContract,
    this.selectedCustomerId,
    required this.onCustomerChanged,
    required this.selectDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                value: selectedCustomerId,
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
                items: customers.map<DropdownMenuItem<int>>((Customer customer) {
                  return DropdownMenuItem<int>(
                    value: customer.customerId,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 65),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration:  BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1976D2), Color(0xFF66BB6A)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  '${customer.prenom.isNotEmpty ? customer.prenom[0] : ''}${customer.nom.isNotEmpty ? customer.nom[0] : ''}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${customer.prenom} ${customer.nom}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'ID: ${customer.customerId}',
                                    style: const TextStyle(
                                      color: Color(0xFF718096),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: editingContract == null ? onCustomerChanged : null,
                validator: (value) => editingContract == null && value == null ? 'Veuillez sélectionner un client' : null,
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
                controller: typeController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.assignment_outlined, color: Color(0xFF1976D2)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintText: 'Ex: Journalier, Mensuel, Annuel',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Journalier', 'Mensuel', 'Annuel'].map((type) {
                final isSelected = typeController.text == type;
                return GestureDetector(
                  onTap: () {
                    typeController.text = type;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1976D2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1976D2) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF718096),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                controller: creationDateController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: Color(0xFF1976D2)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintText: 'Sélectionner une date',
                ),
                readOnly: true,
                onTap: () => selectDate(context),
                validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
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
                controller: paymentModeController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.payment_outlined, color: Color(0xFF1976D2)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintText: 'Ex: Cash, Visa, Mastercard',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Cash', 'Visa', 'Mastercard', 'PayPal'].map((mode) {
                final isSelected = paymentModeController.text == mode;
                return GestureDetector(
                  onTap: () {
                    paymentModeController.text = mode;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF66BB6A) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF66BB6A) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconData(0xe3a1, fontFamily: 'MaterialIcons'), // Placeholder, remplace par _getPaymentIcon si défini
                          size: 16,
                          color: isSelected ? Colors.white : const Color(0xFF718096),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mode,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF718096),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

