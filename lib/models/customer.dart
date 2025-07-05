import 'package:signloop/models/contract.dart';

class Customer {
  final int? customerId;
  final String nom;
  final String prenom;
  final DateTime birthdate;
  final List<Contract> contracts;

  Customer({
    this.customerId,
    required this.nom,
    required this.prenom,
    required this.birthdate,
    this.contracts = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      nom: json['nom'],
      prenom: json['prenom'],
      birthdate: DateTime.parse(json['birthdate']),
      contracts: (json['contracts'] as List<dynamic>)
          .map((contract) => Contract.fromJson(contract))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'nom': nom,
      'prenom': prenom,
      'birthdate': birthdate.toIso8601String(),
      'contracts': contracts.map((contract) => contract.toJson()).toList(),
    };
  }
}
