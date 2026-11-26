import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { AdminLayout } from '../components/layout/AdminLayout';
import {
  Admin2FAPage,
  AdminForgotPasswordPage,
  AdminLoginPage,
  AdminSessionLockedPage,
  UnauthorizedPage,
} from '../features/auth/AuthPages';
import { DashboardPage } from '../features/dashboard/DashboardPage';
import { CustomersPage } from '../features/customers/CustomersPage';
import { FarmersPage } from '../features/farmers/FarmersPage';
import { FposPage } from '../features/fpos/FposPage';
import { KycPage } from '../features/kyc/KycPage';
import { ProductsPage } from '../features/products/ProductsPage';
import { ProduceListingsPage } from '../features/produce/ProduceListingsPage';
import { DemandPage } from '../features/demand/DemandPage';
import { OrdersPage } from '../features/orders/OrdersPage';
import {
  CollectionsPage,
  InventoryPage,
  LogisticsPage,
  QualityPage,
  WarehousesPage,
} from '../features/supplychain/SupplyChainPages';
import { PaymentsPage, SettlementsPage } from '../features/finance/FinancePages';
import {
  FarmerStorePage,
  PromotionsPage,
  SubscriptionsPage,
} from '../features/commerce/CommercePages';
import {
  AdminProfilePage,
  AdminUsersPage,
  AnalyticsPage,
  HubsPage,
  NotificationsPage,
  SettingsPage,
  SupportPage,
} from '../features/governance/GovernancePages';
import { ServiceAreasPage } from '../features/governance/ServiceAreasPage';

const ProtectedRoute: React.FC<{
  children: React.ReactNode;
  permission?: string;
}> = ({ children, permission }) => {
  const { isAuthenticated, isLocked, hasPermission } = useAuth();
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  if (isLocked) return <Navigate to="/session-locked" replace />;
  if (permission && !hasPermission(permission)) {
    return <Navigate to="/unauthorized" replace />;
  }
  return <>{children}</>;
};

export const AppRoutes: React.FC = () => {
  const { isAuthenticated } = useAuth();

  return (
    <Routes>
      <Route path="/login" element={isAuthenticated ? <Navigate to="/dashboard" replace /> : <AdminLoginPage />} />
      <Route path="/2fa" element={<Admin2FAPage />} />
      <Route path="/forgot-password" element={<AdminForgotPasswordPage />} />
      <Route path="/session-locked" element={<AdminSessionLockedPage />} />
      <Route path="/unauthorized" element={<UnauthorizedPage />} />

      <Route
        element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        }
      >
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/analytics" element={<ProtectedRoute permission="analytics"><AnalyticsPage /></ProtectedRoute>} />
        <Route path="/customers" element={<ProtectedRoute permission="customers"><CustomersPage /></ProtectedRoute>} />
        <Route path="/farmers" element={<ProtectedRoute permission="farmers"><FarmersPage /></ProtectedRoute>} />
        <Route path="/fpos" element={<ProtectedRoute permission="fpos"><FposPage /></ProtectedRoute>} />
        <Route path="/kyc" element={<ProtectedRoute permission="kyc"><KycPage /></ProtectedRoute>} />
        <Route path="/products" element={<ProtectedRoute permission="products"><ProductsPage /></ProtectedRoute>} />
        <Route path="/produce" element={<ProtectedRoute permission="produce"><ProduceListingsPage /></ProtectedRoute>} />
        <Route path="/demand" element={<ProtectedRoute permission="demand"><DemandPage /></ProtectedRoute>} />
        <Route path="/orders" element={<ProtectedRoute permission="orders"><OrdersPage /></ProtectedRoute>} />
        <Route path="/collections" element={<ProtectedRoute permission="collections"><CollectionsPage /></ProtectedRoute>} />
        <Route path="/quality" element={<ProtectedRoute permission="quality"><QualityPage /></ProtectedRoute>} />
        <Route path="/warehouses" element={<ProtectedRoute permission="warehouses"><WarehousesPage /></ProtectedRoute>} />
        <Route path="/inventory" element={<ProtectedRoute permission="inventory"><InventoryPage /></ProtectedRoute>} />
        <Route path="/logistics" element={<ProtectedRoute permission="logistics"><LogisticsPage /></ProtectedRoute>} />
        <Route path="/payments" element={<ProtectedRoute permission="payments"><PaymentsPage /></ProtectedRoute>} />
        <Route path="/settlements" element={<ProtectedRoute permission="settlements"><SettlementsPage /></ProtectedRoute>} />
        <Route path="/subscriptions" element={<ProtectedRoute permission="subscriptions"><SubscriptionsPage /></ProtectedRoute>} />
        <Route path="/farmer-store" element={<ProtectedRoute permission="farmer-store"><FarmerStorePage /></ProtectedRoute>} />
        <Route path="/promotions" element={<ProtectedRoute permission="promotions"><PromotionsPage /></ProtectedRoute>} />
        <Route path="/notifications" element={<ProtectedRoute permission="notifications"><NotificationsPage /></ProtectedRoute>} />
        <Route path="/support" element={<ProtectedRoute permission="support"><SupportPage /></ProtectedRoute>} />
        <Route path="/admin-users" element={<ProtectedRoute permission="admin-users"><AdminUsersPage /></ProtectedRoute>} />
        <Route path="/hubs" element={<ProtectedRoute permission="hubs"><HubsPage /></ProtectedRoute>} />
        <Route path="/service-areas" element={<ProtectedRoute permission="settings"><ServiceAreasPage /></ProtectedRoute>} />
        <Route path="/settings" element={<ProtectedRoute permission="settings"><SettingsPage /></ProtectedRoute>} />
        <Route path="/profile" element={<AdminProfilePage />} />
      </Route>

      <Route path="*" element={<Navigate to={isAuthenticated ? '/dashboard' : '/login'} replace />} />
    </Routes>
  );
};
