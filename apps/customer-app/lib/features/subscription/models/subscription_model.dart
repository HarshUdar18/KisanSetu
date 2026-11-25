import '../../location/models/address_model.dart';

class SubscriptionItemModel {
  final String id;
  final String productId;
  final String productName;
  final String unit;
  final String dayOfWeek;
  final double quantity;
  final double currentPrice;

  const SubscriptionItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.dayOfWeek,
    required this.quantity,
    required this.currentPrice,
  });

  factory SubscriptionItemModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionItemModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      unit: json['unit'] as String? ?? 'kg',
      dayOfWeek: json['dayOfWeek'] as String? ?? 'MONDAY',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SubscriptionModel {
  final String id;
  final String? weeklyCartId;
  final String frequency;
  final String startDate;
  final String status;
  final String? deliveryPreferences;
  final AddressModel? address;
  final List<SubscriptionItemModel> items;

  const SubscriptionModel({
    required this.id,
    this.weeklyCartId,
    required this.frequency,
    required this.startDate,
    required this.status,
    this.deliveryPreferences,
    this.address,
    required this.items,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return SubscriptionModel(
      id: json['id'] as String? ?? '',
      weeklyCartId: json['weeklyCartId'] as String?,
      frequency: json['frequency'] as String? ?? 'WEEKLY',
      startDate: json['startDate'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      deliveryPreferences: json['deliveryPreferences'] as String?,
      address: json['address'] != null ? AddressModel.fromJson(json['address'] as Map<String, dynamic>) : null,
      items: rawItems.map((e) => SubscriptionItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  String get weeklyCartTitle => items.isNotEmpty
      ? items.map((e) => e.productName).join(', ')
      : 'Kisan Setu $frequency Farm Basket';

  double get totalPerCycle => items.isNotEmpty
      ? items.fold(0.0, (s, i) => s + (i.currentPrice * i.quantity))
      : 117.0;

  String get nextDeliveryDate =>
      startDate.isNotEmpty ? startDate : 'Tomorrow, 6:30 AM';
}
