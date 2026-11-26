import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CatalogProvider extends ChangeNotifier {
  final DioClient dioClient;
  final bool enableMockFallback;

  CatalogProvider({required this.dioClient, this.enableMockFallback = false});

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  String _sortBy = 'relevance';
  bool _onlyOrganic = false;
  bool _onlySeasonal = false;
  bool _isLoading = false;
  String? _errorMessage;
  final List<String> _recentSearches = [
    'Desi Onions',
    'A2 Milk',
    'Spinach',
    'Indrayani Rice',
  ];

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<ProductModel> get allProducts => List.unmodifiable(_products);
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get onlyOrganic => _onlyOrganic;
  bool get onlySeasonal => _onlySeasonal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  List<ProductModel> get filteredProducts {
    var list = _products.where((p) {
      if (_selectedCategoryId != null &&
          _selectedCategoryId!.isNotEmpty &&
          p.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = p.name.toLowerCase().contains(q) ||
            (p.marathiName?.toLowerCase().contains(q) ?? false) ||
            (p.categoryName?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }
      if (_onlyOrganic && !p.isOrganic) return false;
      return true;
    }).toList();

    int rank(ProductModel p) => switch (p.stockStatus) {
      'IN_STOCK' => 0,
      'LOW_STOCK' => 1,
      'OUT_OF_STOCK' => 2,
      _ => 3,
    };

    list.sort((a, b) {
      final stockCmp = rank(a).compareTo(rank(b));
      if (stockCmp != 0) return stockCmp;
      if (_sortBy == 'price_low') {
        return a.currentPrice.compareTo(b.currentPrice);
      } else if (_sortBy == 'price_high') {
        return b.currentPrice.compareTo(a.currentPrice);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        dioClient.get('/categories'),
        dioClient.get('/products'),
      ]);
      final rawCats = results[0].data['data'] as List<dynamic>? ?? [];
      _categories = rawCats
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final rawProds = results[1].data['data'] as List<dynamic>? ?? [];
      _products = rawProds
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      if (enableMockFallback) {
        if (_categories.isEmpty) _categories = _seededCategories;
        if (_products.isEmpty) _products = _seededProducts;
      } else {
        _errorMessage = 'Unable to load catalog. Please check your connection and retry.';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchListingsForProduct(String productId) async {
    final res = await dioClient.get('/products/$productId/listings');
    final raw = res.data['data'] as List<dynamic>? ?? [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  ProductModel? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return _seededProducts.isNotEmpty ? _seededProducts.first : null;
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.trim().isNotEmpty && !_recentSearches.contains(query.trim())) {
      _recentSearches.insert(0, query.trim());
      if (_recentSearches.length > 6) _recentSearches.removeLast();
    }
    notifyListeners();
  }

  void setFilters({String? sortBy, bool? onlyOrganic, bool? onlySeasonal}) {
    if (sortBy != null) _sortBy = sortBy;
    if (onlyOrganic != null) _onlyOrganic = onlyOrganic;
    if (onlySeasonal != null) _onlySeasonal = onlySeasonal;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategoryId = null;
    _searchQuery = '';
    _sortBy = 'relevance';
    _onlyOrganic = false;
    _onlySeasonal = false;
    notifyListeners();
  }

  static final List<CategoryModel> _seededCategories = [
    const CategoryModel(id: 'cat-veg', name: 'Fresh Veggies', code: 'VEG', description: 'Dawn-harvested farm vegetables', displayOrder: 1, productCount: 3),
    const CategoryModel(id: 'cat-fruit', name: 'Fruits', code: 'FRUIT', description: 'Vineyard & orchard seasonal fruits', displayOrder: 2, productCount: 1),
    const CategoryModel(id: 'cat-grain', name: 'Grains & Rice', code: 'GRAIN', description: 'Heirloom unpolished rice & millets', displayOrder: 3, productCount: 1),
    const CategoryModel(id: 'cat-pulse', name: 'Pulses', code: 'PULSE', description: 'Unpolished farm-direct dals', displayOrder: 4, productCount: 1),
    const CategoryModel(id: 'cat-dairy', name: 'Farm Dairy', code: 'DAIRY', description: 'Chilled A2 Gir cow milk & ghee', displayOrder: 5, productCount: 1),
    const CategoryModel(id: 'cat-oil', name: 'Cold-pressed Oils', code: 'OIL', description: 'Wood-pressed groundnut & sesame oils', displayOrder: 6, productCount: 1),
  ];

  static final List<ProductModel> _seededProducts = [
    const ProductModel(
      id: 'prod-onion',
      name: 'Desi Red Onions (कांदा)',
      marathiName: 'कांदा',
      categoryId: 'cat-veg',
      categoryName: 'Niphad Farmers Collective',
      unit: 'kg',
      currentPrice: 28.0,
      previousPrice: 35.0,
      description: 'Crisp, sun-cured Niphad red onions harvested 4 hours ago from smallholder FPO farms.',
    ),
    const ProductModel(
      id: 'prod-bhindi',
      name: 'Tender Bhindi',
      marathiName: 'भेंडी',
      categoryId: 'cat-veg',
      categoryName: 'Baramati Agro Hub',
      unit: '500g',
      currentPrice: 42.0,
      previousPrice: 48.0,
      description: 'Grade A certified tender okra hand-picked at dawn.',
    ),
    const ProductModel(
      id: 'prod-palak',
      name: 'Fresh Organic Spinach / Palak',
      marathiName: 'पालक',
      categoryId: 'cat-veg',
      categoryName: 'Purandar FPO',
      unit: '250g bunch',
      currentPrice: 22.0,
      previousPrice: 28.0,
      description: 'Pesticide-free dew-fresh spinach harvested within 12 hours of delivery.',
    ),
    const ProductModel(
      id: 'prod-rice',
      name: 'Indrayani Aromatic Rice (Unpolished)',
      marathiName: 'इंद्रायणी तांदूळ',
      categoryId: 'cat-grain',
      categoryName: 'Maval Farmers',
      unit: '5 kg bag',
      currentPrice: 380.0,
      previousPrice: 420.0,
      description: 'Heirloom Maval valley Indrayani rice, naturally aged and unpolished.',
    ),
    const ProductModel(
      id: 'prod-milk',
      name: 'A2 Gir Cow Farm Milk',
      marathiName: 'देशी गायीचे दूध',
      categoryId: 'cat-dairy',
      categoryName: 'Bhor Dairy Hub',
      unit: '1L Glass Bottle',
      currentPrice: 85.0,
      previousPrice: 90.0,
      description: 'Chilled raw A2 Gir cow milk delivered in returnable sterile glass bottles by 7:00 AM.',
    ),
    const ProductModel(
      id: 'prod-grapes',
      name: 'Nashik Sonaka Seedless Grapes',
      marathiName: 'द्राक्षे',
      categoryId: 'cat-fruit',
      categoryName: 'Sahyadri Collective',
      unit: '1 kg',
      currentPrice: 95.0,
      previousPrice: 120.0,
      description: 'Sweet export-grade vineyard grapes direct from Nashik.',
    ),
    const ProductModel(
      id: 'prod-toor',
      name: 'Unpolished Latur Toor Dal',
      marathiName: 'तूर डाळ',
      categoryId: 'cat-pulse',
      categoryName: 'Marathwada FPO',
      unit: '1 kg',
      currentPrice: 145.0,
      previousPrice: 165.0,
      description: 'Stone-milled unpolished pigeon peas with zero artificial polish.',
    ),
    const ProductModel(
      id: 'prod-oil',
      name: 'Wood-Pressed Groundnut Oil',
      marathiName: 'शेंगदाणा तेल',
      categoryId: 'cat-oil',
      categoryName: 'Sangli Kisan Ghani',
      unit: '1L Bottle',
      currentPrice: 290.0,
      previousPrice: 320.0,
      description: 'Traditional cold-pressed virgin groundnut oil from Sangli farmers.',
    ),
  ];
}
