class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? marathiName;
  final String unit;
  final String? imageUrl;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.marathiName,
    this.unit = 'kg',
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      marathiName: json['marathiName'] as String?,
      unit: json['unit'] as String? ?? 'kg',
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CartModel {
  final String id;
  final List<CartItemModel> items;
  final int itemCount;
  final double subtotal;
  final double deliveryFee;
  final double logisticsFee;
  final double taxAmount;
  final double totalAmount;

  const CartModel({
    required this.id,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.logisticsFee,
    required this.taxAmount,
    required this.totalAmount,
  });

  double get estimatedTotal => totalAmount > 0 ? totalAmount : subtotal;

  factory CartModel.empty() {

    return const CartModel(
      id: '',
      items: [],
      itemCount: 0,
      subtotal: 0.0,
      deliveryFee: 0.0,
      logisticsFee: 0.0,
      taxAmount: 0.0,
      totalAmount: 0.0,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return CartModel(
      id: json['id'] as String? ?? '',
      items: rawItems.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      logisticsFee: (json['logisticsFee'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
