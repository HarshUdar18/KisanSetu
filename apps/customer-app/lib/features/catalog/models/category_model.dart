class CategoryModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? iconUrl;
  final int displayOrder;
  final int productCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.iconUrl,
    required this.displayOrder,
    required this.productCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
    );
  }
}
