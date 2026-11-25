import '../../location/models/address_model.dart';

class OrderItemModel {
  final String id;
  final String? productId;
  final String productName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;

  const OrderItemModel({
    required this.id,
    this.productId,
    required this.productName,
    required this.quantity,
    this.unit = 'kg',
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String?,
      productName: json['productName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'kg',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String deliveryDate;
  final String deliverySlot;
  final String orderStatus;
  final double subtotal;
  final double deliveryFee;
  final double logisticsFee;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentStatus;
  final String? paymentReference;
  final AddressModel? address;
  final String? deliveryAddressJson;
  final List<OrderItemModel> items;
  final String? createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.deliveryDate,
    required this.deliverySlot,
    required this.orderStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.logisticsFee,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentReference,
    this.address,
    this.deliveryAddressJson,
    required this.items,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      deliveryDate: json['deliveryDate'] as String? ?? '',
      deliverySlot: json['deliverySlot'] as String? ?? 'Morning',
      orderStatus: json['orderStatus'] as String? ?? 'PENDING_PAYMENT',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      logisticsFee: (json['logisticsFee'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      paymentReference: json['paymentReference'] as String?,
      address: json['address'] != null ? AddressModel.fromJson(json['address'] as Map<String, dynamic>) : null,
      deliveryAddressJson: json['deliveryAddressJson'] as String?,
      items: rawItems.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: json['createdAt'] as String?,
    );
  }

  String get status => orderStatus;
  DateTime get createdDateTime => createdAt != null ? DateTime.tryParse(createdAt!) ?? DateTime.now() : DateTime.now();
  AddressModel get deliveryAddress => address ?? const AddressModel(id: '', addressLine1: 'Shivajinagar', city: 'Pune', pincode: '411005');
  String get deliveryNotes => '';
}

