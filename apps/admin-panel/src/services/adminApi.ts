import { apiClient } from '../api/client';

export interface PlatformUserDto {
  id: string;
  phoneNumber: string;
  email?: string;
  fullName: string;
  status: string;
  roles: string[];
}

export interface CategoryDto {
  id: string;
  name: string;
  code: string;
  description?: string;
  displayOrder: number;
}

export interface ProductDto {
  id: string;
  productCode?: string;
  name: string;
  canonicalName?: string;
  marathiName?: string;
  categoryId?: string;
  categoryName?: string;
  unit: string;
  currentPrice: number;
  previousPrice?: number;
  isAvailable?: boolean;
  isPerishable?: boolean;
}

export const adminApi = {
  async login(phoneNumber: string, password: string) {
    const res = await apiClient.post('/auth/login', { identifier: phoneNumber, phoneNumber, password });
    return res.data;
  },

  async sendOtp(phone: string): Promise<{ phone: string; message: string; developmentOtp?: string | null; resendCooldownSeconds?: number }> {
    const res = await apiClient.post('/auth/send-otp', { phone });
    return res.data?.data ?? res.data;
  },

  async verifyOtp(phone: string, otp: string) {
    const res = await apiClient.post('/auth/verify-otp', { phone, otp });
    return res.data;
  },

  async fetchUsers(): Promise<{ data: PlatformUserDto[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/users');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchCategories(): Promise<{ data: CategoryDto[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/categories');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async createCategory(payload: {
    name: string;
    code: string;
    description?: string;
    displayOrder: number;
  }) {
    const res = await apiClient.post('/admin/categories', payload);
    return res.data?.data;
  },

  async fetchProducts(): Promise<{ data: ProductDto[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/products');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchOrders(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/orders');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchFarmers(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/farmers');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchKycSubmissions(status?: string): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/kyc', { params: status ? { status } : undefined });
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async approveKyc(id: string, remarks?: string) {
    const res = await apiClient.put(`/admin/kyc/${id}/approve`, { remarks });
    return res.data?.data;
  },

  async rejectKyc(id: string, remarks?: string) {
    const res = await apiClient.put(`/admin/kyc/${id}/reject`, { remarks });
    return res.data?.data;
  },

  async fetchSettlements(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/settlements');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async authorizeSettlement(id: string, remarks?: string) {
    const res = await apiClient.post(`/admin/settlements/${id}/authorize`, { remarks });
    return res.data?.data;
  },

  async fetchDashboardAnalytics(): Promise<{ data: Record<string, number> | null; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/analytics/dashboard');
      return { data: res.data?.data ?? null, isLive: true };
    } catch {
      return { data: null, isLive: false };
    }
  },

  async fetchProduceListings(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/produce');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchDemands(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/demands');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchFpos(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/fpos');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchWarehouses(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/warehouses');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchInventory(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/inventory');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchCollections(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/collections');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchQualityInspections(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/quality');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchShipments(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/logistics');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchNotifications(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/notifications');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchSupportTickets(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/support/tickets');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async resolveTicket(id: string, resolutionNotes?: string) {
    const res = await apiClient.put(`/admin/support/tickets/${id}/resolve`, { resolutionNotes });
    return res.data?.data;
  },

  async fetchCoupons(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/coupons');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async createCoupon(payload: { code: string; discountType: string; discountValue: number; minOrderAmount: number }) {
    const res = await apiClient.post('/admin/coupons', payload);
    return res.data?.data;
  },

  async fetchSubscriptions(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/subscriptions');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async fetchStoreProducts(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/farmer-store/products');
      return { data: res.data?.data ?? [], isLive: true };
    } catch {
      return { data: [], isLive: false };
    }
  },

  async createStoreProduct(payload: { name: string; category: string; unit: string; mrp: number; subsidizedPrice: number; stockQuantity: number }) {
    const res = await apiClient.post('/admin/farmer-store/products', payload);
    return res.data?.data;
  },

  async fetchHubs(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/hubs');
      return { data: res.data?.data ?? [], isLive: true };
    } catch { return { data: [], isLive: false }; }
  },

  async createHub(payload: { name: string; code: string; hubType?: string; addressLine?: string; village?: string; district?: string; state?: string; pincode?: string; contactName?: string; contactPhone?: string }) {
    const res = await apiClient.post('/admin/hubs', payload);
    return res.data?.data;
  },

  async fetchAdmins(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/admin/admins');
      return { data: res.data?.data ?? [], isLive: true };
    } catch { return { data: [], isLive: false }; }
  },

  async createAdmin(payload: { phone: string; password: string; email?: string; fullName: string }) {
    const res = await apiClient.post('/admin/admins', payload);
    return res.data?.data;
  },

  async createProduct(payload: {
    categoryId: string;
    productCode: string;
    name: string;
    marathiName?: string;
    unit: string;
    currentPrice?: number;
    isPerishable?: boolean;
  }) {
    const res = await apiClient.post('/admin/products', payload);
    return res.data?.data;
  },

  async toggleProductStatus(id: string, isAvailable: boolean) {
    const res = await apiClient.patch(`/admin/products/${id}/status`, { isAvailable });
    return res.data?.data;
  },

  async fetchUnits(): Promise<{ data: any[]; isLive: boolean }> {
    try {
      const res = await apiClient.get('/units');
      return { data: res.data?.data ?? [], isLive: true };
    } catch { return { data: [], isLive: false }; }
  },
};
