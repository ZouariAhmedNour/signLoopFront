import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../global.dart';
import '../models/user.dart';

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
    throw Exception(_extractErrorMessage(response));
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
      final data = jsonDecode(response.body);
      final token = data["token"];
      final userJson = data["user"];

      // Sauvegarder le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", token);

      return User.fromJson(userJson);
    }
    throw Exception(_extractErrorMessage(response));
  }

  /// Récupère le token stocké
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  /// Récupérer le profil de l'utilisateur connecté
  Future<User> getMyProfile() async {
    final url = Uri.parse('${UrlApi}user/me');
    final token = await _getToken();
    if (token == null) throw Exception("Aucun token trouvé, veuillez vous reconnecter.");

    print("➡️ GET $url");
    print("   avec Authorization: Bearer $token");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception(_extractErrorMessage(response));
  }

  /// Mettre à jour le profil
  Future<User> updateMyProfile(User user) async {
    final url = Uri.parse('${UrlApi}user/me');
    final token = await _getToken();
    if (token == null) throw Exception("Aucun token trouvé, veuillez vous reconnecter.");

    print("➡️ PUT $url");
    print("   avec Authorization: Bearer $token");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(user.toJson()),
    );

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception(_extractErrorMessage(response));
  }

  /// Demande de reset password
  Future<String> requestResetPassword(String email) async {
    final url = Uri.parse('${UrlApi}auth/reset-password-request?email=$email');
    print("➡️ POST $url");

    final response = await http.post(url);

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      return "Email de réinitialisation envoyé";
    }
    throw Exception(_extractErrorMessage(response));
  }

  /// Confirmation reset password
  Future<String> confirmResetPassword(String token, String newPassword) async {
    final url = Uri.parse('${UrlApi}reset-password-confirm');
    print("➡️ POST $url");

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
    throw Exception(_extractErrorMessage(response));
  }

  /// Renvoyer email de vérification
  Future<String> resendVerificationEmail(String email) async {
    final url = Uri.parse('${UrlApi}auth/resend-verification?email=$email');
    print("➡️ POST $url");

    final response = await http.post(url);

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      return "Email de vérification renvoyé.";
    }
    throw Exception(_extractErrorMessage(response));
  }

  /// Utilitaire pour extraire proprement un message d'erreur
  String _extractErrorMessage(http.Response response) {
    if (response.body.isEmpty) return "Erreur ${response.statusCode}";

    try {
      final json = jsonDecode(response.body);
      if (json is Map && json.containsKey("error")) {
        return json["error"].toString();
      }
      return response.body;
    } catch (_) {
      return response.body;
    }
  }
}
