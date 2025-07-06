import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:signloop/global.dart';
import 'package:signloop/models/contract.dart';

class ContractApi {
  Future<List<Contract>> getContracts() async {
    final url = Uri.parse('${UrlApi}contracts');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final rawData = response.body;
        print('✅ API Response: $rawData');
        final List<dynamic> data = jsonDecode(rawData);
        return data.map((json) => Contract.fromJson(json)).toList();
      } else {
        print('❌ API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load contracts, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching contracts: $e');
      return [];
    }
  }

  Future<Contract?> addContract(Contract contract) async {
    final url = Uri.parse('${UrlApi}contracts');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(contract.toJson()),
      );
      if (response.statusCode == 200) {
        return Contract.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add contract, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error adding contract: $e');
      return null;
    }
  }

  Future<Contract?> updateContract(Contract contract) async {
    final url = Uri.parse('${UrlApi}contracts/${contract.contractId}');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(contract.toJson()),
      );
      if (response.statusCode == 200) {
        return Contract.fromJson(jsonDecode(response.body));
      } else {
        print('❌ API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to update contract, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating contract: $e');
      return null;
    }
  }

  Future<void> deleteContract(int contractId) async {
    final url = Uri.parse('${UrlApi}contracts/$contractId');
    try {
      final response = await http.delete(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        print('❌ API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete contract, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting contract: $e');
      throw e;
    }
  }
}