import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:signloop/global.dart';
import 'package:signloop/models/user.dart';

class UserApi {
 

  /// Enregistre un utilisateur
  Future<String> register(User user) async {
    final url = Uri.parse('${UrlApi}auth/register'); 
    print("➡️ POST $url");
    print("➡️ Body: ${jsonEncode(user.toJson())}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      return "Compte créé, email de vérification envoyé";
    }
    throw Exception(response.body);
  }

  /// Connexion
  Future<User> login(String email, String password) async {
     final url = Uri.parse('${UrlApi}auth/login');
    final payload = {"email": email, "password": password};

    print("➡️ POST $url");
    print("➡️ Body: ${jsonEncode(payload)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception(response.body);
  }

  /// Demande de reset password
  Future<String> requestResetPassword(String email) async {
    final url = Uri.parse('${UrlApi}auth/reset-password-request?email=$email');
    print("➡️ POST $url");
    print("➡️ Body: email=$email");

    final response = await http.post(
      url);

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      return "Email de réinitialisation envoyé";
    }
    throw Exception(response.body);
  }

  /// Confirmation reset password
  Future<String> confirmResetPassword(String token, String newPassword) async {
     final url = Uri.parse('${UrlApi}reset-password-confirm');
    print("➡️ POST $url");
    print("➡️ Body: token=$token, newPassword=***");

    final response = await http.post(
      url,
      body: {
        "token": token,
        "newPassword": newPassword,
      },
    );

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      return "Mot de passe réinitialisé";
    }
    throw Exception(response.body);
  }

  // VERIFIER COMPTE PAR E-MAIL

  Future<String> resendVerificationEmail(String email) async {
  final url = Uri.parse('${UrlApi}auth/resend-verification?email=$email');
  print("➡️ POST $url");

  final response = await http.post(url);

  print("⬅️ Status: ${response.statusCode}");
  print("⬅️ Body: ${response.body}");

  if (response.statusCode == 200) {
    return "Email de vérification renvoyé.";
  } else {
    throw Exception(response.body);
  }
}

}
