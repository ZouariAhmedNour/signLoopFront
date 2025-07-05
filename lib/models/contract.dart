class Contract {
  final int? contractId;
  final String? type;
  final DateTime? creationDate;
  final String? paymentMode;
  final int? customerId; // Référence au customerId (pas l'objet Customer complet pour simplifier)

  Contract({
    this.contractId,
    this.type,
    this.creationDate,
    this.paymentMode,
    this.customerId,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      contractId: json['contractId'],
      type: json['type'],
      creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate']) : null,
      paymentMode: json['paymentMode'],
      customerId: json['customer_id'], // Correspond à la colonne joinColumn
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'type': type,
      'creationDate': creationDate?.toIso8601String(),
      'paymentMode': paymentMode,
      'customer_id': customerId,
    };
  }
}