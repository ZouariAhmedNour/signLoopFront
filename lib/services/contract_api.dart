import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signloop/global.dart';
import 'package:signloop/models/contract.dart';

class ContractApi {

  
   Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }
  Future<List<Contract>> getContracts() async {
     final token = await _getToken();
    if (token == null) throw Exception("Aucun token trouvé");

    final url = Uri.parse('${UrlApi}contracts');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization' : 'Bearer $token',
        });
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

  // Future<Contract?> addContract(Contract contract) async {

  //    final token = await _getToken();
  //    print('✅ Token récupéré pour POST: $token');
  //   if (token == null) throw Exception("Aucun token trouvé");

  //   final url = Uri.parse('${UrlApi}contracts');
  //    final payload = jsonEncode(contract.toJson());
  // print('✅ Payload envoyé: $payload');
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //         },
  //       body: payload,
  //     );
  //       print('✅ Status code: ${response.statusCode}');
  // print('✅ Body response: ${response.body}');
  //     if (response.statusCode == 200) {
  //       return Contract.fromJson(jsonDecode(response.body));
  //     } else {
  //       throw Exception('Failed to add contract, status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Error adding contract: $e');
  //     return null;
  //   }
  // }

  Future<Contract?> addContract(Contract contract) async {
  // Debug: Log the start of the add process
  print("🔵 [DEBUG] Starting addContract process");

  // Debug: Retrieve and validate token
  print("🔑 [DEBUG] Retrieving token...");
  final token = await _getToken();
  print("🔑 [DEBUG] Retrieved token: ${token != null ? token.substring(0, 10) + '...' : 'null'}");
  if (token == null) {
    print("❌ [DEBUG] Error: No token found");
    throw Exception("Aucun token trouvé");
  }

  // Debug: Prepare the request URL
  final url = Uri.parse('${UrlApi}contracts');
  print("➡️ [DEBUG] Preparing POST request to: $url");

  // Debug: Prepare the request body
  final payload = jsonEncode(contract.toJson());
  print("➡️ [DEBUG] Payload to send: $payload");

  try {
    // Debug: Sending the request
    print("🚀 [DEBUG] Sending POST request with Authorization: Bearer $token");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: payload,
    );

    // Debug: Log the raw response
    print("⬅️ [DEBUG] Received response - Status Code: ${response.statusCode}");
    print("⬅️ [DEBUG] Raw Response Body: ${response.body}");

    if (response.statusCode == 200) {
      // Debug: Successful response handling
      print("✅ [DEBUG] Successfully received 200 OK response");
      final decodedResponse = jsonDecode(response.body);
      print("📦 [DEBUG] Decoded JSON Response: $decodedResponse");
      final newContract = Contract.fromJson(decodedResponse);
      print("✅ [DEBUG] Contract added: $newContract");
      return newContract;
    } else {
      // Debug: Error response handling
      print("❌ [DEBUG] Non-200 status code received: ${response.statusCode}");
      print("❌ [DEBUG] Response Body: ${response.body}");
      throw Exception('Failed to add contract, status code: ${response.statusCode}');
    }
  } catch (e) {
    // Debug: Catch and log any exceptions
    print("❌ [DEBUG] Error adding contract: $e");
    return null;
  }
}

  // Future<Contract?> updateContract(Contract contract) async {

  //    final token = await _getToken();
  //   if (token == null) throw Exception("Aucun token trouvé");

  //   final url = Uri.parse('${UrlApi}contracts/${contract.contractId}');
  //   try {
  //     final response = await http.put(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization':' Bearer $token',
  //         },
  //       body: jsonEncode(contract.toJson()),
  //     );
  //     if (response.statusCode == 200) {
  //       return Contract.fromJson(jsonDecode(response.body));
  //     } else {
  //       print('❌ API Error: Status ${response.statusCode}, Body: ${response.body}');
  //       throw Exception('Failed to update contract, status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Error updating contract: $e');
  //     return null;
  //   }
  // }

  Future<Contract?> updateContract(Contract contract) async {
  // Debug: Log the start of the update process
  print("🔵 [DEBUG] Starting updateContract process for contractId: ${contract.contractId}");

  // Debug: Retrieve and validate token
  print("🔑 [DEBUG] Retrieving token...");
  final token = await _getToken();
  print("🔑 [DEBUG] Retrieved token: ${token != null ? token.substring(0, 10) + '...' : 'null'}");
  if (token == null) {
    print("❌ [DEBUG] Error: No token found");
    throw Exception("Aucun token trouvé");
  }

  // Debug: Prepare the request URL
  final url = Uri.parse('${UrlApi}contracts/${contract.contractId}');
  print("➡️ [DEBUG] Preparing PUT request to: $url");

  // Debug: Prepare the request body
  final jsonBody = jsonEncode(contract.toJson());
  print("➡️ [DEBUG] Request body: $jsonBody");

  try {
    // Debug: Sending the request
    print("🚀 [DEBUG] Sending PUT request with Authorization: Bearer $token");
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonBody,
    );

    // Debug: Log the raw response
    print("⬅️ [DEBUG] Received response - Status Code: ${response.statusCode}");
    print("⬅️ [DEBUG] Raw Response Body: ${response.body}");

    if (response.statusCode == 200) {
      // Debug: Successful response handling
      print("✅ [DEBUG] Successfully received 200 OK response");
      final decodedResponse = jsonDecode(response.body);
      print("📦 [DEBUG] Decoded JSON Response: $decodedResponse");
      final updatedContract = Contract.fromJson(decodedResponse);
      print("✅ [DEBUG] Contract updated: $updatedContract");
      return updatedContract;
    } else {
      // Debug: Error response handling
      print("❌ [DEBUG] Non-200 status code received: ${response.statusCode}");
      print("❌ [DEBUG] Response Body: ${response.body}");
      throw Exception('Failed to update contract, status code: ${response.statusCode}');
    }
  } catch (e) {
    // Debug: Catch and log any exceptions
    print("❌ [DEBUG] Error updating contract: $e");
    return null;
  }
}

  Future<void> deleteContract(int contractId) async {

     final token = await _getToken();
    if (token == null) throw Exception("Aucun token trouvé");

    final url = Uri.parse('${UrlApi}contracts/$contractId');
    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        });
      print('✅ Delete Response: Status ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        print('✅ Contract deleted successfully: $contractId');
      } else {
        print('❌ API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete contract, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting contract: $e');
      throw e;
    }
  }
}