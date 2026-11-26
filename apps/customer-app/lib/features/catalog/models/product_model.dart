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
  final String stockStatus;
  final int activeListingCount;
  final double? lowestListingPrice;

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
    this.stockQuantity = 0.0,
    this.stockStatus = 'OUT_OF_STOCK',
    this.activeListingCount = 0,
    this.lowestListingPrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['stockQuantity'] as num?)?.toDouble() ?? 0.0;
    final avail = json['isAvailable'] as bool? ?? (json['available'] as bool? ?? true);
    final rawStatus = json['stockStatus'] as String?;
    final computedStatus = rawStatus ??
        (!avail
            ? 'UNAVAILABLE'
            : (qty <= 0 ? 'OUT_OF_STOCK' : (qty <= 10 ? 'LOW_STOCK' : 'IN_STOCK')));
    return ProductModel(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      name: json['name'] as String? ?? '',
      marathiName: json['marathiName'] as String?,
      description: json['description'] as String?,
      unit: json['unit'] as String? ?? 'kg',
      imageUrl: json['imageUrl'] as String?,
      isAvailable: avail,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      previousPrice: (json['previousPrice'] as num?)?.toDouble(),
      stockQuantity: qty,
      stockStatus: computedStatus,
      activeListingCount: json['activeListingCount'] as int? ?? 0,
      lowestListingPrice: (json['lowestListingPrice'] as num?)?.toDouble(),
    );
  }

  bool get isInStock => stockStatus == 'IN_STOCK' || stockStatus == 'LOW_STOCK';

  bool get isOrganic =>
      (categoryName ?? '').toLowerCase().contains('fpo') ||
      name.toLowerCase().contains('organic') ||
      name.toLowerCase().contains('a2') ||
      name.toLowerCase().contains('wood-pressed');
}
