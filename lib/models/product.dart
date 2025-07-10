class Product {

  const Product({
    this.id,
    this.name,
    this.description,
    this.image,
    this.serialNumber,
    this.batchCode,
    this.productTypeName,
    this.productTypeManufacturer,
    this.composition,
    this.manufactureDate,
    this.expirationDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      serialNumber: json['serialNumber'] as String?,
      batchCode: json['batchCode'] as String?,
      productTypeName: json['productTypeName'] as String?,
      productTypeManufacturer: json['productTypeManufacturer'] as String?,
      composition: json['composition'] as String?,
      manufactureDate: json['manufactureDate'] != null
          ? DateTime.tryParse(json['manufactureDate'] as String)
          : null,
      expirationDate: json['expirationDate'] != null
          ? DateTime.tryParse(json['expirationDate'] as String)
          : null,
    );
  }
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final String? serialNumber;
  final String? batchCode;
  final String? productTypeName;
  final String? productTypeManufacturer;
  final String? composition;
  final DateTime? manufactureDate;
  final DateTime? expirationDate;

  bool get hasImage => image != null && image!.isNotEmpty;

  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final int daysUntilExpiration = expirationDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiration <= 30 && daysUntilExpiration >= 0;
  }

  int get daysUntilExpiration {
    if (expirationDate == null) return 0;
    return expirationDate!.difference(DateTime.now()).inDays;
  }
}
