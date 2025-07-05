import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:signloop/global.dart';
import '../models/contract.dart';

class ContractApi {
  // Placeholder : à utiliser si tu veux récupérer les contrats séparément
  Future<List<Contract>> getContracts() async {
    final url = Uri.parse('${UrlApi}contracts');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
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
}