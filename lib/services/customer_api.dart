import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:signloop/global.dart';
import 'package:signloop/models/customer.dart';

class CustomerApi {
  Future<List<Customer>> getCustomers() async {
    final url = Uri.parse('${UrlApi}customers');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final rawData = response.body;
        print('✅ API Response: $rawData'); // Débogage de la réponse JSON
        final List<dynamic> data = jsonDecode(rawData);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        print('❌ API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load customers, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching customers: $e');
      return [];
    }
  }

  Future<Customer?> addCustomer(Customer customer) async {
    final url = Uri.parse('${UrlApi}customers');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(customer.toJson()),
      );
      if (response.statusCode == 200) {
        return Customer.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add customer, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error adding customer: $e');
      return null;
    }
  }

  Future<Customer?> updateCustomer(Customer customer) async {
    final url = Uri.parse('${UrlApi}customers/${customer.customerId}');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(customer.toJson()),
      );
      if (response.statusCode == 200) {
        return Customer.fromJson(jsonDecode(response.body));
      } else {
        print('❌ API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to update customer, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating customer: $e');
      return null;
    }
  }

  Future<void> deleteCustomer(int customerId) async {
    final url = Uri.parse('${UrlApi}customers/$customerId');
    try {
      final response = await http.delete(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        print('❌ API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete customer, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting customer: $e');
      throw e;
    }
  }
}