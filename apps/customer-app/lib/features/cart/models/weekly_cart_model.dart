class WeeklyCartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? marathiName;
  final String unit;
  final String? imageUrl;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  const WeeklyCartItemModel({
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

  factory WeeklyCartItemModel.fromJson(Map<String, dynamic> json) {
    return WeeklyCartItemModel(
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

class WeeklyCartDayModel {
  final String dayOfWeek;
  final List<WeeklyCartItemModel> items;
  final double dayTotal;

  const WeeklyCartDayModel({
    required this.dayOfWeek,
    required this.items,
    required this.dayTotal,
  });

  factory WeeklyCartDayModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return WeeklyCartDayModel(
      dayOfWeek: json['dayOfWeek'] as String? ?? 'MONDAY',
      items: rawItems.map((e) => WeeklyCartItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      dayTotal: (json['dayTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WeeklyCartModel {
  final String id;
  final String title;
  final String status; // DRAFT, SUBMITTED, LOCKED
  final int modificationCount;
  final bool isModifiable;
  final List<WeeklyCartDayModel> days;
  final double weeklyEstimatedTotal;

  const WeeklyCartModel({
    required this.id,
    required this.title,
    required this.status,
    required this.modificationCount,
    required this.isModifiable,
    required this.days,
    required this.weeklyEstimatedTotal,
  });

  factory WeeklyCartModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List<dynamic>? ?? [];
    return WeeklyCartModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'My Weekly Produce Plan',
      status: json['status'] as String? ?? 'DRAFT',
      modificationCount: (json['modificationCount'] as num?)?.toInt() ?? 0,
      isModifiable: json['modifiable'] as bool? ?? (json['isModifiable'] as bool? ?? true),
      days: rawDays.map((e) => WeeklyCartDayModel.fromJson(e as Map<String, dynamic>)).toList(),
      weeklyEstimatedTotal: (json['weeklyEstimatedTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
