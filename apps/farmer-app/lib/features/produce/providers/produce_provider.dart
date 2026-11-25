import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';

/// Farmer produce listing (separate entity from master Product Catalog).
class FarmerListing {
  final String id;
  final String productId;
  final String cropName;
  final String marathiName;
  final String category;
  final String variety;
  final double availableQty;
  final double committedQty;
  final String unit;
  final double pricePerUnit;
  final double minOrderQty;
  final String qualityGrade;
  final bool isOrganic;
  final String harvestDate;
  final String status; // ACTIVE, PLANNED, PAUSED, SOLD_OUT, LAB_HOLD
  final bool isSurplus;

  const FarmerListing({
    required this.id,
    required this.productId,
    required this.cropName,
    required this.marathiName,
    required this.category,
    required this.variety,
    required this.availableQty,
    this.committedQty = 0.0,
    required this.unit,
    required this.pricePerUnit,
    this.minOrderQty = 10.0,
    required this.qualityGrade,
    this.isOrganic = true,
    required this.harvestDate,
    this.status = 'ACTIVE',
    this.isSurplus = false,
  });

  FarmerListing copyWith({
    double? availableQty,
    double? pricePerUnit,
    String? status,
  }) {
    return FarmerListing(
      id: id,
      productId: productId,
      cropName: cropName,
      marathiName: marathiName,
      category: category,
      variety: variety,
      availableQty: availableQty ?? this.availableQty,
      committedQty: committedQty,
      unit: unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      minOrderQty: minOrderQty,
      qualityGrade: qualityGrade,
      isOrganic: isOrganic,
      harvestDate: harvestDate,
      status: status ?? this.status,
      isSurplus: isSurplus,
    );
  }
}

class ProduceProvider extends ChangeNotifier {
  final DioClient dioClient;
  final bool enableMockFallback;

  ProduceProvider({required this.dioClient, this.enableMockFallback = false}) {
    if (enableMockFallback) _listings = _seededListings;
  }

  List<FarmerListing> _listings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FarmerListing> get listings =>
      _listings.where((l) => !l.isSurplus).toList();
  List<FarmerListing> get surplusListings =>
      _listings.where((l) => l.isSurplus).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalActiveKg => _listings
      .where((l) => l.status == 'ACTIVE')
      .fold(0.0, (s, l) => s + l.availableQty);

  double get totalEstimatedValue => _listings
      .where((l) => l.status == 'ACTIVE')
      .fold(0.0, (s, l) => s + (l.availableQty * l.pricePerUnit));

  FarmerListing? getById(String id) {
    for (final l in _listings) {
      if (l.id == id) return l;
    }
    return _listings.isNotEmpty ? _listings.first : null;
  }

  Future<void> fetchMyListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await dioClient.get('/farmer/listings');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      _listings = raw.map((e) {
        final m = e as Map<String, dynamic>;
        return FarmerListing(
          id: m['id'] as String? ?? '',
          productId: m['productId'] as String? ?? '',
          cropName: m['productName'] as String? ?? 'Produce Lot',
          marathiName: m['marathiName'] as String? ?? '',
          category: m['categoryName'] as String? ?? 'Vegetables',
          variety: m['variety'] as String? ?? 'Local',
          availableQty: (m['quantityAvailable'] as num?)?.toDouble() ?? 0.0,
          unit: m['unit'] as String? ?? 'kg',
          pricePerUnit: (m['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
          qualityGrade: m['qualityGrade'] as String? ?? 'Grade A',
          harvestDate: m['harvestDate'] as String? ?? 'Today',
          status: (m['isAvailable'] as bool? ?? true) ? 'ACTIVE' : 'PAUSED',
        );
      }).toList();
    } catch (_) {
      if (enableMockFallback) {
        if (_listings.isEmpty) _listings = _seededListings;
      } else {
        _errorMessage = 'Unable to load produce listings. Please retry.';
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createListing(FarmerListing listing) async {
    if (listing.availableQty <= 0 || listing.pricePerUnit <= 0) {
      _errorMessage = 'Quantity and price must be greater than zero.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await dioClient.post('/farmer/listings', data: {
        'productId': listing.productId,
        'quantityAvailable': listing.availableQty,
        'unit': listing.unit,
        'pricePerUnit': listing.pricePerUnit,
        'harvestDate': listing.harvestDate,
        'qualityGrade': listing.qualityGrade,
      });
    } catch (_) {}

    _listings.insert(0, listing);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> updateListing(String id, {double? qty, double? price, String? status}) async {
    final idx = _listings.indexWhere((l) => l.id == id);
    if (idx < 0) return;
    _listings[idx] = _listings[idx].copyWith(
      availableQty: qty,
      pricePerUnit: price,
      status: status,
    );
    try {
      await dioClient.patch('/farmer/listings/$id/availability', data: {
        'isAvailable': (_listings[idx].status == 'ACTIVE'),
        'quantityAvailable': _listings[idx].availableQty,
      });
    } catch (_) {}
    notifyListeners();
  }

  void deleteListing(String id) {
    _listings.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  static final List<FarmerListing> _seededListings = [
    const FarmerListing(
      id: 'LOT-SP-9021',
      productId: 'prod-palak',
      cropName: 'Fresh Baby Spinach (पालक)',
      marathiName: 'पालक',
      category: 'Leafy Greens',
      variety: 'All Green Organic',
      availableQty: 180,
      committedQty: 60,
      unit: 'kg',
      pricePerUnit: 42.0,
      qualityGrade: 'Organic A+',
      isOrganic: true,
      harvestDate: 'Plucked 4:30 AM',
      status: 'ACTIVE',
    ),
    const FarmerListing(
      id: 'LOT-TM-204',
      productId: 'prod-tomato',
      cropName: 'Desi Red Tomatoes (टोमॅटो)',
      marathiName: 'टोमॅटो',
      category: 'Vegetables',
      variety: 'Abhinav Hybrid',
      availableQty: 180,
      committedQty: 120,
      unit: 'kg',
      pricePerUnit: 32.0,
      qualityGrade: 'Residue-Free Grade A',
      isOrganic: false,
      harvestDate: 'Today Dawn',
      status: 'ACTIVE',
    ),
    const FarmerListing(
      id: 'LOT-CR-118',
      productId: 'prod-coriander',
      cropName: 'Coriander & Mint (कोथिंबीर)',
      marathiName: 'कोथिंबीर',
      category: 'Leafy Greens',
      variety: 'Hydroponic Fresh',
      availableQty: 80,
      unit: 'bundle',
      pricePerUnit: 18.0,
      qualityGrade: 'Premium',
      isOrganic: true,
      harvestDate: 'Tomorrow 6 AM',
      status: 'PLANNED',
    ),
    const FarmerListing(
      id: 'LOT-SUR-77',
      productId: 'prod-onion',
      cropName: 'Surplus Red Onions Lot',
      marathiName: 'कांदा',
      category: 'Surplus',
      variety: 'Nashik N-53',
      availableQty: 400,
      unit: 'kg',
      pricePerUnit: 24.0,
      qualityGrade: 'Grade B Bulk',
      isOrganic: false,
      harvestDate: 'Ready Now',
      status: 'ACTIVE',
      isSurplus: true,
    ),
  ];
}
