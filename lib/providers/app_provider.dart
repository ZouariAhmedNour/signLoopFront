import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/services/customer_api.dart';
import 'package:signloop/services/contract_api.dart';
import '../models/customer.dart';
import '../models/contract.dart';

final dataProvider = StateProvider<String>((ref) => 'Aucune donnée');

final customerProvider = StateNotifierProvider<CustomerNotifier, List<Customer>>(
  (ref) => CustomerNotifier(ref.watch(customerApiProvider)),
);

final customerApiProvider = Provider<CustomerApi>((ref) => CustomerApi());

class CustomerNotifier extends StateNotifier<List<Customer>> {
  final CustomerApi api;
  CustomerNotifier(this.api) : super([]) {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await api.getCustomers();
    debugPrint('Loaded customers: $customers');
    state = customers;
  }

  Future<void> addCustomer(Customer customer) async {
    final customers = await api.addCustomer(customer);
    if (customers != null) {
      state = [...state, customers];
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
  (ref) => ContractNotifier(ref.watch(contractApiProvider)),
);

final contractApiProvider = Provider<ContractApi>((ref) => ContractApi());

class ContractNotifier extends StateNotifier<List<Contract>> {
  final ContractApi api;
  ContractNotifier(this.api) : super([]) {
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    final contracts = await api.getContracts();
    debugPrint('Raw contracts from API: $contracts'); // Débogage des données brutes
    state = contracts;
  }

  Future<void> addContract(Contract contract) async {
    final newContract = await api.addContract(contract);
    if (newContract != null) {
      state = [...state, newContract];
      await _loadContracts(); // Recharger pour s'assurer que les données sont à jour
    }
  }

  Future<void> updateContract(Contract contract) async {
    final updatedContract = await api.updateContract(contract);
    if (updatedContract != null) {
      state = state.map((c) => c.contractId == contract.contractId ? updatedContract : c).toList();
      await _loadContracts(); // Recharger pour s'assurer que les données sont à jour
    }
  }

  Future<void> deleteContract(int contractId) async {
    await api.deleteContract(contractId);
    state = state.where((c) => c.contractId != contractId).toList();
    await _loadContracts(); // Recharger pour s'assurer que les données sont à jour
  }
}