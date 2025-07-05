import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signloop/services/customer_api.dart';
import '../models/customer.dart';
import '../models/contract.dart';

final dataProvider = StateProvider<String>((ref) => 'Aucune donnée');

final customerProvider = StateNotifierProvider<CustomerNotifier, List<Customer>>
((ref) => CustomerNotifier(ref.watch(customerApiProvider)));

final customerApiProvider = Provider<CustomerApi>((ref) => CustomerApi());

class CustomerNotifier extends StateNotifier<List<Customer>> {
  final CustomerApi api;
  CustomerNotifier(this.api) : super([]) {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await api.getCustomers();
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

 
final contractProvider = StateNotifierProvider<ContractNotifier, List<Contract>>((ref) => ContractNotifier());

class ContractNotifier extends StateNotifier<List<Contract>> {
  ContractNotifier() : super([]);

  void addContract(Contract contract) {
    state = [...state, contract];
  }
}