class TrackingEventModel {
  final String id;
  final String status;
  final String title;
  final String? description;
  final String? location;
  final String? occurredAt;
  final bool isCompleted;
  final int displayOrder;

  const TrackingEventModel({
    required this.id,
    required this.status,
    required this.title,
    this.description,
    this.location,
    this.occurredAt,
    required this.isCompleted,
    required this.displayOrder,
  });

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String?,
      occurredAt: json['occurredAt'] as String?,
      isCompleted: json['completed'] as bool? ?? (json['isCompleted'] as bool? ?? false),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderTrackingTimelineModel {
  final String orderId;
  final String orderNumber;
  final String currentStatus;
  final List<TrackingEventModel> events;

  const OrderTrackingTimelineModel({
    required this.orderId,
    required this.orderNumber,
    required this.currentStatus,
    required this.events,
  });

  factory OrderTrackingTimelineModel.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as List<dynamic>? ?? [];
    return OrderTrackingTimelineModel(
      orderId: json['orderId'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      currentStatus: json['currentStatus'] as String? ?? '',
      events: rawEvents.map((e) => TrackingEventModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
