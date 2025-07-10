import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/services/customer_api.dart';
import 'package:signloop/services/contract_api.dart';
import '../models/customer.dart';
import '../models/contract.dart';

final dataProvider = StateProvider<String>((ref) => 'Aucune donnée');

final customerProvider = StateNotifierProvider<CustomerNotifier, List<Customer>>(
  (ref) => CustomerNotifier(ref.watch(customerApiProvider), ref),
);

final customerApiProvider = Provider<CustomerApi>((ref) => CustomerApi());

class CustomerNotifier extends StateNotifier<List<Customer>> {
  final CustomerApi api;
  final Ref ref;
  CustomerNotifier(this.api, this.ref) : super([]) {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await api.getCustomers();
    debugPrint('Loaded customers: $customers');
    state = customers;
  }

  Future<void> addCustomer(Customer customer) async {
    final newCustomer = await api.addCustomer(customer);
    if (newCustomer != null) {
      state = [...state, newCustomer];
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    final updatedCustomer = await api.updateCustomer(customer);
    if (updatedCustomer != null) {
      state = state.map((c) => c.customerId == customer.customerId ? updatedCustomer : c).toList();
    }
  }

  Future<void> deleteCustomer(int customerId) async {
    await api.deleteCustomer(customerId);
    state = state.where((c) => c.customerId != customerId).toList();
  }
}

final contractProvider = StateNotifierProvider<ContractNotifier, List<Contract>>(
  (ref) => ContractNotifier(ref.watch(contractApiProvider), ref),
);

final contractApiProvider = Provider<ContractApi>((ref) => ContractApi());

class ContractNotifier extends StateNotifier<List<Contract>> {
  final ContractApi api;
  final Ref ref;
  ContractNotifier(this.api, this.ref) : super([]) {
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    try {
      final contracts = await api.getContracts();
      debugPrint('Raw contracts from API: $contracts');
      state = contracts;
    } catch (e) {
      debugPrint('Error loading contracts: $e');
    }
  }

  Future<void> addContract(Contract contract) async {
    try {
      final newContract = await api.addContract(contract);
      if (newContract != null) {
        state = [...state, newContract];
        debugPrint('Contract added: $newContract');

        final customerId = contract.customer?['customerId'] as int?;
        if (customerId != null) {
          final customers = ref.read(customerProvider);
          final updatedCustomers = customers.map((c) {
            if (c.customerId == customerId) {
              return Customer(
                customerId: c.customerId,
                nom: c.nom,
                prenom: c.prenom,
                birthdate: c.birthdate,
                contracts: [...c.contracts, newContract],
              );
            }
            return c;
          }).toList();
          ref.read(customerProvider.notifier).state = updatedCustomers;
        }

        await _loadContracts();
      }
    } catch (e) {
      debugPrint('Error adding contract: $e');
    }
  }

  Future<void> updateContract(Contract contract) async {
    try {
      final updatedContract = await api.updateContract(contract);
      if (updatedContract != null) {
        state = state.map((c) => c.contractId == contract.contractId ? updatedContract : c).toList();
        await _loadContracts();
      }
    } catch (e) {
      debugPrint('Error updating contract: $e');
    }
  }

  Future<void> deleteContract(int contractId) async {
    try {
      debugPrint('Attempting to delete contract with ID: $contractId');
      await api.deleteContract(contractId);
      debugPrint('API delete successful for contract ID: $contractId');
      state = state.where((c) => c.contractId != contractId).toList();
      debugPrint('Local state updated, remaining contracts: ${state.length}');
      await Future.delayed(Duration(seconds: 2)); // Augmenter le délai
      final reloadedContracts = await api.getContracts();
      if (reloadedContracts.any((c) => c.contractId == contractId)) {
        debugPrint('Warning: Contract $contractId still present after deletion');
        state = reloadedContracts; // Restaurer avec les données API
        throw Exception('Contract $contractId not deleted on server');
      } else {
        state = reloadedContracts;
        debugPrint('Contracts reloaded after deletion, confirmed removal');
      }
    } catch (e) {
      debugPrint('Error deleting contract: $e');
      await _loadContracts(); // Restaurer l'état en cas d'échec
      throw e; // Propager l'erreur
    }
  }
}