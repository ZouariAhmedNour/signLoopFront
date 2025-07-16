
import 'dart:convert';

class Contract {
  final int? contractId;
  final String? type;
  final DateTime? creationDate;
  final String? paymentMode;
  final Map<String, dynamic>? customer; 
  final int? customerId; 
  final String? cinPicBase64; 

  Contract({
    this.contractId,
    this.type,
    this.creationDate,
    this.paymentMode,
    this.customer,
    this.customerId,
    this.cinPicBase64, 
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
      print("✅ CinPic type: ${json['cinPic']?.runtimeType}");
  print("✅ CinPic value: ${json['cinPic']}");
    return Contract(
      contractId: json['contractId'],
      type: json['type'],
      creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate']) : null,
      paymentMode: json['paymentMode'],
      customer: json['customer'] != null ? Map<String, dynamic>.from(json['customer']) : null,
      customerId: json['customerId'] ?? (json['customer']?['customerId'] as int?),
      cinPicBase64: json['cinPic'] != null
    ? (json['cinPic'] is String
        ? json['cinPic']
        : base64Encode(List<int>.from(json['cinPic'])))
    : null,
    );
  }

Map<String, dynamic> toJson() {
  final data = <String, dynamic>{
    'contractId': contractId,
    'type': type,
    'creationDate': creationDate?.toIso8601String(),
    'paymentMode': paymentMode,
    'customer': customer != null
        ? {'customerId': customer!['customerId']}
        : null,
  };


  if (cinPicBase64?.isNotEmpty ?? false) {
    data['cinPic'] = cinPicBase64;
  } else {
    // Ne rien mettre = ne pas toucher à l'image existante
    // OU
     data['cinPic'] = null; 
  }

  return data;
}

int? get effectiveCustomerId {
  if (customerId != null) return customerId;
  if (customer != null && customer!.containsKey('customerId')) {
    return customer!['customerId'] as int?;
  }
  return null;
}
}