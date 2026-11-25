class AddressModel {
  final String id;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressModel({
    required this.id,
    this.label = 'Home',
    required this.addressLine1,
    this.addressLine2,
    this.city = 'Pune',
    this.state = 'Maharashtra',
    required this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? 'Home',
      addressLine1: json['addressLine1'] as String? ?? '',
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String? ?? 'Pune',
      state: json['state'] as String? ?? 'Maharashtra',
      pincode: json['pincode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? (json['default'] as bool? ?? false),
    );
  }

  String get fullAddressText {
    final parts = [addressLine1];
    if (addressLine2 != null && addressLine2!.isNotEmpty) parts.add(addressLine2!);
    parts.add('$city, $state - $pincode');
    return parts.join(', ');
  }

  String get fullAddress => fullAddressText;

  Map<String, dynamic> toJson() => {
        'label': label,
        'addressLine1': addressLine1,
        if (addressLine2 != null) 'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'isDefault': isDefault,
      };
}
