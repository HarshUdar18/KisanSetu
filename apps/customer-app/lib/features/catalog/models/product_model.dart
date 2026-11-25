class ProductModel {
  final String id;
  final String? categoryId;
  final String? categoryName;
  final String name;
  final String? marathiName;
  final String? description;
  final String unit;
  final String? imageUrl;
  final bool isAvailable;
  final double currentPrice;
  final double? previousPrice;
  final double stockQuantity;

  const ProductModel({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    this.marathiName,
    this.description,
    this.unit = 'kg',
    this.imageUrl,
    this.isAvailable = true,
    required this.currentPrice,
    this.previousPrice,
    this.stockQuantity = 100.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      name: json['name'] as String? ?? '',
      marathiName: json['marathiName'] as String?,
      description: json['description'] as String?,
      unit: json['unit'] as String? ?? 'kg',
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? (json['available'] as bool? ?? true),
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      previousPrice: (json['previousPrice'] as num?)?.toDouble(),
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 100.0,
    );
  }

  bool get isOrganic =>
      (categoryName ?? '').toLowerCase().contains('fpo') ||
      name.toLowerCase().contains('organic') ||
      name.toLowerCase().contains('a2') ||
      name.toLowerCase().contains('wood-pressed');
}
