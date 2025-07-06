// class Contract {
//   final int? contractId;
//   final String? type;
//   final DateTime? creationDate;
//   final String? paymentMode;
//   final int? customerId; // Référence au customerId (pas l'objet Customer complet pour simplifier)

//   Contract({
//     this.contractId,
//     this.type,
//     this.creationDate,
//     this.paymentMode,
//     this.customerId,
//   });

//   factory Contract.fromJson(Map<String, dynamic> json) {
//     return Contract(
//       contractId: json['contractId'],
//       type: json['type'],
//       creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate']) : null,
//       paymentMode: json['paymentMode'],
//       customerId: json['customerId'], // Corriger de 'customer_id' à 'customerId'
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'contractId': contractId,
//       'type': type,
//       'creationDate': creationDate?.toIso8601String(),
//       'paymentMode': paymentMode,
//       'customerId': customerId,
//     };
//   }
// }

class Contract {
  final int? contractId;
  final String? type;
  final DateTime? creationDate;
  final String? paymentMode;
  final Map<String, dynamic>? customer; // Objet customer avec customerId
  final int? customerId; // Champ supplémentaire pour compatibilité

  Contract({
    this.contractId,
    this.type,
    this.creationDate,
    this.paymentMode,
    this.customer,
    this.customerId,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      contractId: json['contractId'],
      type: json['type'],
      creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate']) : null,
      paymentMode: json['paymentMode'],
      customer: json['customer'] != null ? Map<String, dynamic>.from(json['customer']) : null,
      customerId: json['customerId'] ?? (json['customer']?['customerId'] as int?), // Prendre customerId si disponible
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'type': type,
      'creationDate': creationDate?.toIso8601String(),
      'paymentMode': paymentMode,
      'customer': customer != null ? {'customerId': customer!['customerId']} : null,
    };
  }
}