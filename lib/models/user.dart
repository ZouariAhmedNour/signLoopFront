class User {
  final int? userId;
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String? telephone;
  final String? adresse;
  final String? role;
  final bool emailVerified;

  User({
    this.userId,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    this.telephone,
    this.adresse,
    this.role,
    this.emailVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      password: json['password'], 
      telephone: json['telephone'],
      adresse: json['adresse'],
      role: json['role'],
      emailVerified: json['emailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nom": nom,
      "prenom": prenom,
      "email": email,
      "password": password,
      "telephone": telephone,
      "adresse": adresse,
    };
  }
}
