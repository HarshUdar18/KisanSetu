/**
 * Isolated mock datasets for Admin Panel modules whose backend endpoints
 * are not yet implemented in Spring Boot (see ADMIN_API_INTEGRATION.md).
 */

export const mockDashboardMetrics = {
  gmv: '₹1,42,85,620',
  activeFarmers: '24,892',
  pendingKyc: 14,
  totalOrders: '3,840',
  escrowBalance: '₹38,40,500',
  activeFpos: 184,
  todayIntakeMt: '94.2 MT',
  coldStorageUtil: '78.4%',
  avgRealization: '₹38.50/kg',
  totalCustomers: '41,210',
  activeListings: 612,
  activeWarehouses: 12,
};

export const mockVelocitySeries = [
  { day: 'Mon (14)', intake: 32, dispatched: 29, unmet: 3 },
  { day: 'Tue (15)', intake: 35, dispatched: 33, unmet: 2 },
  { day: 'Wed (16)', intake: 37, dispatched: 35, unmet: 2 },
  { day: 'Thu (17)', intake: 40, dispatched: 38, unmet: 2 },
  { day: 'Fri (18)', intake: 34, dispatched: 32, unmet: 2 },
  { day: 'Sat (19)', intake: 31, dispatched: 29, unmet: 2 },
  { day: 'Sun (Today)', intake: 36, dispatched: 35, unmet: 1 },
];

export const mockClusters = [
  { name: 'Pune Agri-Hub', sub: 'Mulshi, Junnar, Paud', farmers: 8420, volume: '1,420 MT', gmv: '₹54,20,000', qcPass: 99.1, status: 'Optimal' },
  { name: 'Nashik Valley Belt', sub: 'Dindori, Niphad, Lasalgaon', farmers: 6890, volume: '1,890 MT', gmv: '₹48,60,000', qcPass: 96.4, status: 'High Surge' },
  { name: 'Kolhapur Sugar & Veg', sub: 'Karveer, Shirol', farmers: 4780, volume: '890 MT', gmv: '₹24,80,000', qcPass: 98.0, status: 'Optimal' },
  { name: 'Ahmednagar North', sub: 'Rahata, Kopargaon', farmers: 3450, volume: '720 MT', gmv: '₹15,20,000', qcPass: 92.8, status: 'Inspection Alert' },
];

export const mockCustomers = [
  { id: 'CUS-1001', name: 'Sunita Deshmukh', phone: '9876543211', city: 'Kothrud, Pune 411038', orders: 14, spent: 12450, subscription: 'A2 Milk Daily', status: 'ACTIVE' },
  { id: 'CUS-1002', name: 'Ananya Sharma', phone: '9876501122', city: 'Shivajinagar, Pune 411005', orders: 9, spent: 7820, subscription: 'Weekly Veg Box', status: 'ACTIVE' },
  { id: 'CUS-1003', name: 'Rohan Kulkarni', phone: '9822011455', city: 'Akurdi, Pune 411035', orders: 3, spent: 1890, subscription: 'None', status: 'BLOCKED' },
];

export const mockFarmers = [
  { id: 'FM-8821', name: 'Dnyaneshwar Bapu Patil', phone: '9822100010', fpo: 'Mulshi Valley FPO', district: 'Pune', area: '4.80 Acres', kyc: 'IN_REVIEW', status: 'ACTIVE' },
  { id: 'FM-3012', name: 'Ramesh Balasaheb Shinde', phone: '9876543212', fpo: 'Mulshi Organic Cluster', district: 'Pune', area: '3.40 Acres', kyc: 'APPROVED', status: 'ACTIVE' },
  { id: 'FM-9402', name: 'Anusaya R. Gadakh', phone: '9823019944', fpo: 'Junnar Women Agri FPO', district: 'Pune', area: '2.90 Acres', kyc: 'APPROVED', status: 'ACTIVE' },
];

export const mockFpos = [
  { id: 'FPO-01', name: 'Mulshi Valley Farmers Producer Co. Ltd.', regNo: 'CIN-U01409PN2021PTC', farmers: 420, district: 'Pune', compliance: 'VERIFIED', status: 'ACTIVE' },
  { id: 'FPO-02', name: 'Sahyadri Organic Collective', regNo: 'CIN-U01110MH2019PTC', farmers: 1250, district: 'Nashik', compliance: 'VERIFIED', status: 'ACTIVE' },
  { id: 'FPO-03', name: 'Dindori Tomato Alliance', regNo: 'CIN-U01200MH2022PTC', farmers: 310, district: 'Nashik', compliance: 'AUDIT_DUE', status: 'PENDING' },
];

export const mockKycQueue = [
  {
    id: 'KYC-MH-2024-9941',
    farmerId: 'FM-8821',
    name: 'Dnyaneshwar Bapu Patil',
    phone: '+91 98221 ••••10',
    location: 'Paud, Mulshi, Pune (412108)',
    fpo: 'Mulshi Valley Farmer Producer Co.',
    gutNo: 'Gut 142/2A',
    area: '4.80 Acres',
    aadhaarMasked: '•••• •••• 4912',
    bankMasked: 'SBI •••• 7731 (PFMS Active)',
    ocrMatch: '99.4%',
    status: 'PENDING',
  },
  {
    id: 'KYC-MH-2024-9942',
    farmerId: 'FM-4410',
    name: 'Suresh B. Chavan',
    phone: '+91 98112 ••••44',
    location: 'Dindori, Nashik (422202)',
    fpo: 'Dindori Tomato Alliance',
    gutNo: 'Gut 88/1',
    area: '6.20 Acres',
    aadhaarMasked: '•••• •••• 1104',
    bankMasked: 'Bank of Maharashtra •••• 2201',
    ocrMatch: '97.8%',
    status: 'PENDING',
  },
];

export const mockProduceListings = [
  { id: 'LOT-SP-9021', farmer: 'Ramesh Shinde', product: 'Fresh Baby Spinach (Palak)', qty: 180, unit: 'kg', price: 42, harvestDate: '25 Nov 2026', grade: 'Grade A+', status: 'ACTIVE' },
  { id: 'LOT-TM-8419', farmer: 'Suresh Chavan', product: 'Hybrid Tomato (Abhinav)', qty: 4200, unit: 'kg', price: 32, harvestDate: '25 Nov 2026', grade: 'Grade B', status: 'PENDING' },
  { id: 'LOT-CP-8839', farmer: 'Anusaya Gadakh', product: 'Shimla Mirch (Capsicum)', qty: 850, unit: 'kg', price: 46, harvestDate: '24 Nov 2026', grade: 'Grade A', status: 'ACTIVE' },
];

export const mockDemands = [
  { id: 'DEM-401', buyer: 'Star Bazaar Mega-DC', product: 'Desi Palak', qty: '1,200 kg', expectedPrice: '₹38/kg', deliveryDate: '26 Nov 2026', quotes: 4, status: 'OPEN' },
  { id: 'DEM-402', buyer: 'Kothrud Urban Society', product: 'Hybrid Tomatoes', qty: '450 kg', expectedPrice: '₹34/kg', deliveryDate: '26 Nov 2026', quotes: 2, status: 'MATCHED' },
];

export const mockOrders = [
  { id: 'ORD-2024-9982', customer: 'Star Bazaar Mega-DC', farmer: 'Sahyadri Organic FPO', date: 'Today, 08:30 AM', items: 'Desi Palak • 1,200 kg', amount: 48500, payment: 'ESCROW_LOCKED', stage: 'IN_TRANSIT', vehicle: 'MH-15-EG-4421' },
  { id: 'ORD-2024-9980', customer: 'Natures Basket Pune', farmer: 'Baramati Organic Cluster', date: 'Today, 07:15 AM', items: 'Hybrid Tomato • 4,500 kg', amount: 144000, payment: 'ESCROW_LOCKED', stage: 'QUALITY_INSPECTION', vehicle: 'MH-12-KS-3310' },
  { id: 'ORD-2024-9944', customer: 'Sunita Deshmukh', farmer: 'Mulshi Valley FPO', date: 'Yesterday', items: 'Indrayani Rice & Onions', amount: 530, payment: 'PAID', stage: 'DELIVERED', vehicle: 'MH-12-KS-4410' },
];

export const mockCollections = [
  { id: 'COL-901', farmer: 'Dnyaneshwar Patil', point: 'Paud FPO Hub (Gate 4)', product: 'Desi Spinach', qty: '1,500 kg', date: '25 Nov, 05:30 AM', status: 'COLLECTED' },
  { id: 'COL-902', farmer: 'Suresh Chavan', point: 'Nashik Valley Cold Gate', product: 'Hybrid Tomato', qty: '4,200 kg', date: '25 Nov, 06:00 AM', status: 'PENDING_QC' },
];

export const mockInspections = [
  { id: 'QC-7821', lotId: 'LOT-SP-9021', product: 'Desi Palak', inspector: 'Chemist Patil', acceptedQty: 1200, rejectedQty: 0, grade: 'Grade A', result: 'APPROVED', time: '06:20 AM' },
  { id: 'QC-7822', lotId: 'LOT-TOM-8419', product: 'Hybrid Tomato', inspector: 'Chemist Kulkarni', acceptedQty: 3900, rejectedQty: 300, grade: 'Grade B', result: 'DISPUTED', time: '06:45 AM' },
];

export const mockWarehouses = [
  { id: 'WH-PUN-01', name: 'Pune West Cold Hub (Kothrud)', capacityMt: 500, occupiedMt: 392, temp: '4.1°C', status: 'OPERATIONAL' },
  { id: 'WH-NSK-02', name: 'Nashik Reefer & Packhouse', capacityMt: 800, occupiedMt: 640, temp: '3.8°C', status: 'OPERATIONAL' },
];

export const mockInventory = [
  { sku: 'SKU-PAL-01', product: 'Desi Baby Spinach', warehouse: 'Pune West Cold Hub', available: 1200, reserved: 450, sold: 2400, damaged: 18, fifoRisk: 'LOW' },
  { sku: 'SKU-TOM-02', product: 'Hybrid Tomato', warehouse: 'Nashik Packhouse', available: 3900, reserved: 1200, sold: 5100, damaged: 110, fifoRisk: 'HIGH (24h)' },
];

export const mockLogistics = [
  { id: 'TRK-01', vehicle: 'MH-15-EG-4421', driver: 'Tukaram Garud', route: 'Dindori -> Thane DC', temp: '3.4°C', status: 'IN_TRANSIT', sla: '99.1%' },
  { id: 'TRK-02', vehicle: 'MH-12-QB-8419', driver: 'Vikram Kadam', route: 'Paud -> Pune West', temp: '7.8°C (ALERT)', status: 'TEMP_SPIKE', sla: '94.0%' },
];

export const mockTransactions = [
  { id: 'TXN-90214', user: 'Mulshi Valley FPO', userType: 'FARMER_FPO', orderId: 'ORD-2024-8835', amount: 67200, method: 'PFMS DBT', status: 'COMPLETED', date: '25 Nov 2026', ref: 'DBT-882910' },
  { id: 'TXN-90215', user: 'Dindori Tomato Alliance', userType: 'FARMER_FPO', orderId: 'ORD-2024-8841', amount: 48500, method: 'ESCROW_HOLD', status: 'PENDING', date: '25 Nov 2026', ref: 'ESC-441022' },
  { id: 'TXN-90216', user: 'Sunita Deshmukh', userType: 'CUSTOMER', orderId: 'ORD-2024-9944', amount: 530, method: 'UPI_GPAY', status: 'COMPLETED', date: '24 Nov 2026', ref: 'UPI-991021' },
];
