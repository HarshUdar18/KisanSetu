/// Isolated mock services for features whose Spring Boot backend endpoints
/// are not yet implemented (see CUSTOMER_API_INTEGRATION.md).
class MockCustomerServices {
  MockCustomerServices._();

  static final List<Map<String, dynamic>> coupons = [
    {
      'code': 'KISANFIRST',
      'title': '₹50 Off on Your First Farm Basket',
      'description': 'Valid on orders above ₹299. 100% farmer payout unaffected.',
      'discountAmount': 50.0,
      'minOrder': 299.0,
      'tag': 'FIRST ORDER',
    },
    {
      'code': 'FRESH20',
      'title': '20% Off Morning Leafy Greens',
      'description': 'Up to ₹40 off on Spinach, Methi & Coriander from Purandar FPO.',
      'discountAmount': 40.0,
      'minOrder': 199.0,
      'tag': 'HARVEST SPECIAL',
    },
    {
      'code': 'WEEKLY75',
      'title': '₹75 Off Weekly Kitchen Basket',
      'description': 'Applicable on 5+ day scheduled weekly plans above ₹600.',
      'discountAmount': 75.0,
      'minOrder': 600.0,
      'tag': 'WEEKLY PLAN',
    },
  ];

  static Map<String, dynamic> validateCoupon(String code, double subtotal) {
    final normalized = code.trim().toUpperCase();
    for (final c in coupons) {
      if (c['code'] == normalized) {
        final minOrder = (c['minOrder'] as num).toDouble();
        if (subtotal < minOrder) {
          return {
            'valid': false,
            'message': 'Add ₹${(minOrder - subtotal).toStringAsFixed(0)} more to apply $normalized.',
          };
        }
        return {
          'valid': true,
          'code': normalized,
          'discountAmount': c['discountAmount'],
          'message': '${c['code']} applied! You saved ₹${(c['discountAmount'] as num).toStringAsFixed(0)}.',
        };
      }
    }
    return {
      'valid': false,
      'message': 'Invalid or expired coupon code "$code". Try KISANFIRST.',
    };
  }

  static final List<Map<String, dynamic>> farmers = [
    {
      'id': 'fpo-mahyco',
      'name': 'Mahyco Seed Collective',
      'farmerName': 'Ramesh Shinde',
      'cluster': 'Junnar Cluster',
      'distanceKm': 68,
      'rating': 4.9,
      'deliveries': 1240,
      'crops': ['Pomegranates', 'Baby Corn', 'Green Chillies', 'Desi Tomatoes'],
      'story':
          'Cultivating residue-free produce across 42 smallholder family farms in the Sahyadri foothills using drip irrigation and natural vermicompost.',
      'certified': 'NPOP Organic & Govt. FPO Verified',
    },
    {
      'id': 'fpo-niphad',
      'name': 'Niphad Farmers Collective',
      'farmerName': 'Suresh Patil',
      'cluster': 'Nashik Valley',
      'distanceKm': 142,
      'rating': 4.8,
      'deliveries': 980,
      'crops': ['Desi Red Onions', 'Nashik Grapes', 'Hybrid Tomatoes'],
      'story':
          'Direct-to-kitchen onion and grape cooperative eliminating 4 tiers of mandi brokers so farmers keep 80%+ of your basket value.',
      'certified': 'GI Tagged & Fair-Trade FPO',
    },
    {
      'id': 'fpo-baramati',
      'name': 'Baramati Agro & Dairy Hub',
      'farmerName': 'Sunita Pawar',
      'cluster': 'Baramati Belt',
      'distanceKm': 95,
      'rating': 4.9,
      'deliveries': 1560,
      'crops': ['A2 Gir Cow Milk', 'Tender Bhindi', 'Desi Palak', 'Methi'],
      'story':
          'Women-led FPO specializing in dawn-harvested leafy greens and chilled glass-bottle A2 milk delivered within 12 hours.',
      'certified': 'FSSAI & Cold-Chain Verified',
    },
  ];

  static final List<Map<String, dynamic>> notifications = [
    {
      'id': 'n1',
      'type': 'ORDER',
      'title': 'Fresh Harvest at Baramati',
      'body': 'Your morning basket #KS-2041 is packed at the collection center and out for delivery.',
      'time': '12 mins ago',
      'read': false,
    },
    {
      'id': 'n2',
      'type': 'WEEKLY_CART',
      'title': 'Weekly Cart Cutoff at 9:00 PM',
      'body': 'Finalize your Wednesday produce quantities before 9:00 PM tonight.',
      'time': '2 hours ago',
      'read': false,
    },
    {
      'id': 'n3',
      'type': 'PAYMENT',
      'title': 'Direct Farmer Payout Settled',
      'body': '₹452 from your last order was settled directly to Niphad FPO.',
      'time': 'Yesterday',
      'read': true,
    },
    {
      'id': 'n4',
      'type': 'SUBSCRIPTION',
      'title': 'A2 Gir Cow Milk Resumed',
      'body': 'Morning 6:30 AM glass-bottle delivery resumes tomorrow.',
      'time': '2 days ago',
      'read': true,
    },
    {
      'id': 'n5',
      'type': 'PROMO',
      'title': 'Nashik Grape Harvest Season!',
      'body': 'Use KISANFIRST for ₹50 off on fresh vineyard baskets.',
      'time': '3 days ago',
      'read': true,
    },
  ];

  static final List<Map<String, dynamic>> faqs = [
    {
      'q': 'How does Kisan Setu deliver greens within 12 hours?',
      'a': 'Farmers harvest at dawn (4:30 AM) against pre-confirmed Weekly Cart and Subscription demand, bypassing wholesale mandis straight to local Pune collection hubs.',
    },
    {
      'q': 'Why can I modify a submitted Weekly Cart only once?',
      'a': 'Farmers plan their morning harvest based on your locked weekly quantities. Allowing 1 correction protects both your flexibility and farmer harvest commitments.',
    },
    {
      'q': 'How much of my bill goes directly to the farmer?',
      'a': 'Approximately 80% of your basket value goes directly to the FPO/Farmer collective bank account, with full transparency shown in your Cart and Harvest Impact Ledger.',
    },
    {
      'q': 'What if my PIN code is not serviceable yet?',
      'a': 'We currently serve Pune pilot corridors (411005, 411035, 411038). You can still browse all produce and join the waitlist for your neighborhood.',
    },
  ];

  static final List<Map<String, dynamic>> farmVisits = [
    {
      'id': 'fv1',
      'title': 'Mulshi Organic Farm Trail & Harvest Picnic',
      'date': 'Saturday, 28 Nov • 7:00 AM – 11:30 AM',
      'location': 'Mulshi Valley FPO, Pune',
      'seatsLeft': 6,
      'price': 299.0,
    },
    {
      'id': 'fv2',
      'title': 'Nashik Vineyard & Soil Health Workshop',
      'date': 'Sunday, 6 Dec • 8:00 AM – 1:00 PM',
      'location': 'Sahyadri Collective, Niphad',
      'seatsLeft': 11,
      'price': 499.0,
    },
  ];
}
