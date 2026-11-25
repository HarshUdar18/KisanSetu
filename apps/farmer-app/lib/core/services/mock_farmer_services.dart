/// Isolated mock data for Farmer App modules whose Spring Boot endpoints
/// are not yet implemented (see FARMER_API_INTEGRATION.md).
class MockFarmerServices {
  MockFarmerServices._();

  static final List<Map<String, dynamic>> mandiSpotRates = [
    {'crop': 'Baby Spinach (पालक)', 'mandi': 'Pune Gultekdi', 'rate': 38.0, 'unit': 'kg', 'trend': '+18%'},
    {'crop': 'Desi Red Tomatoes (टोमॅटो)', 'mandi': 'Mulshi FPO', 'rate': 32.0, 'unit': 'kg', 'trend': '+6%'},
    {'crop': 'Coriander & Methi', 'mandi': 'Nashik APMC', 'rate': 18.0, 'unit': 'bundle', 'trend': '+12%'},
    {'crop': 'Purandar Sweet Figs (अंजीर)', 'mandi': 'Pune Export Hub', 'rate': 120.0, 'unit': 'kg', 'trend': '+9%'},
  ];

  static final List<Map<String, dynamic>> demandRequests = [
    {
      'id': 'dem-101',
      'buyer': 'Kothrud Urban Society',
      'crop': '120 kg Spinach • Spearmint',
      'rate': 38.0,
      'total': 4560.0,
      'window': '6:00 AM - 7:30 AM',
      'pickup': 'Pickup at Farmgate',
      'escrow': true,
      'status': 'OPEN',
    },
    {
      'id': 'dem-102',
      'buyer': 'Sahyadri Bulk Retail Hub',
      'crop': '250 kg Desi Red Tomatoes',
      'rate': 34.0,
      'total': 8500.0,
      'window': '5:30 AM - 7:00 AM',
      'pickup': 'Drop at Mulshi Dawn Hub',
      'escrow': true,
      'status': 'OPEN',
    },
  ];

  static final List<Map<String, dynamic>> confirmedOrders = [
    {
      'id': 'ord-f-84920',
      'buyer': 'Kothrud Dawn Hub (#KS-84920)',
      'items': '140 kg Organic Coriander Bundles',
      'amount': 5040.0,
      'status': 'PACK_READY',
      'slot': 'Tomorrow 5:15 AM Hub',
    },
  ];

  static final List<Map<String, dynamic>> settlementEntries = [
    {
      'id': 'TXN-90214',
      'title': 'Weekly DBT Payout',
      'subtitle': '480 kg Palak & 210 kg Tomatoes • Zero Mandi Cess',
      'amount': 19250.0,
      'isCredit': true,
      'status': 'CREDITED',
      'date': '25 Oct • 11:42 AM',
    },
    {
      'id': 'TXN-89842',
      'title': 'Produce Dispatch (Escrow)',
      'subtitle': '140 kg Organic Coriander • Settling Friday',
      'amount': 5040.0,
      'isCredit': true,
      'status': 'ESCROW_LOCKED',
      'date': '24 Oct • 06:15 AM',
    },
    {
      'id': 'TXN-89510',
      'title': 'Moisture QC Re-grade',
      'subtitle': 'Lot #SP-412 (-2.1 kg wilting) • APMC Assay Attached',
      'amount': -88.20,
      'isCredit': false,
      'status': 'TRANSIT_ADJUSTMENT',
      'date': '22 Oct • 04:30 PM',
    },
  ];

  static final List<Map<String, dynamic>> govtSchemes = [
    {
      'id': 'sch-pmkisan',
      'title': 'PM-KISAN Samman Nidhi (DBT)',
      'amount': '₹6,000 / year (3 installments)',
      'status': '18th Installment Credited',
      'source': 'pmkisan.gov.in • Updated Nov 2026',
      'route': '/schemes/pm-kisan',
    },
    {
      'id': 'sch-pmfby',
      'title': 'PMFBY Crop Insurance (पीक विमा)',
      'amount': 'Rabi Coverage Active • Sum Insured ₹1,20,000',
      'status': 'Policy Verified',
      'source': 'pmfby.gov.in • Updated Nov 2026',
      'route': '/schemes/pmfby',
    },
    {
      'id': 'sch-kcc',
      'title': 'Kisan Credit Card (KCC) Subvention',
      'amount': 'Limit ₹3,00,000 • 4% Effective Interest',
      'status': 'Active • Bank of Maharashtra',
      'source': 'agristack.gov.in • Updated Nov 2026',
      'route': '/schemes/kcc',
    },
  ];

  static final List<Map<String, dynamic>> storeProducts = [
    {
      'id': 'st-1',
      'name': 'IFFCO Organic Prom & Bio-Fertilizer (50 kg)',
      'category': 'Fertilizers',
      'mrp': 950.0,
      'subsidyPrice': 620.0,
      'poolDiscount': 'FPO Group Pool: Save ₹330',
    },
    {
      'id': 'st-2',
      'name': 'Mahyco Hybrid Spinach Seeds (1 kg Pack)',
      'category': 'Seeds',
      'mrp': 680.0,
      'subsidyPrice': 510.0,
      'poolDiscount': '25% FPO Collective Discount',
    },
    {
      'id': 'st-3',
      'name': 'Battery Knapsack Sprayer (16L)',
      'category': 'Equipment',
      'mrp': 3400.0,
      'subsidyPrice': 2650.0,
      'poolDiscount': 'Subsidized Agri-Equip',
    },
    {
      'id': 'st-4',
      'name': 'Soil pH & Moisture Probe Meter',
      'category': 'Tools',
      'mrp': 1200.0,
      'subsidyPrice': 890.0,
      'poolDiscount': 'FPO Member Rate',
    },
  ];

  static final List<Map<String, dynamic>> notifications = [
    {
      'id': 'fn-1',
      'type': 'DEMAND',
      'title': 'New Direct Demand: 120 kg Spinach',
      'body': 'Kothrud Urban Society requested 120 kg @ ₹38/kg (Escrow Protected).',
      'time': '10 mins ago',
      'read': false,
    },
    {
      'id': 'fn-2',
      'type': 'SETTLEMENT',
      'title': 'Weekly DBT Payout Scheduled Friday',
      'body': '₹24,850.00 verified for auto-credit to SBI A/C ••••4201.',
      'time': '2 hours ago',
      'read': false,
    },
    {
      'id': 'fn-3',
      'type': 'WEATHER',
      'title': 'Optimal Morning Spray Window',
      'body': '21°C, mild dew at 4:00 AM in Mulshi. Ideal leaf moisture.',
      'time': 'Today, 5:30 AM',
      'read': true,
    },
  ];
}
