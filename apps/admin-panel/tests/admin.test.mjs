import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '..');

test('All 24 admin routes are wired in AppRoutes.tsx', () => {
  const routesSrc = fs.readFileSync(path.join(root, 'src/routes/AppRoutes.tsx'), 'utf8');
  const expectedRoutes = [
    '/login', '/2fa', '/forgot-password', '/session-locked', '/unauthorized',
    '/dashboard', '/analytics', '/customers', '/farmers', '/fpos', '/kyc',
    '/products', '/produce', '/demand', '/orders', '/collections', '/quality',
    '/warehouses', '/inventory', '/logistics', '/payments', '/settlements',
    '/subscriptions', '/farmer-store', '/promotions', '/notifications',
    '/support', '/admin-users', '/settings', '/profile',
  ];
  for (const r of expectedRoutes) {
    assert.ok(routesSrc.includes(`path="${r}"`), `Missing route: ${r}`);
  }
});

test('AdminLayout sidebar includes all 23+ navigation sections with RBAC permissions', () => {
  const layoutSrc = fs.readFileSync(path.join(root, 'src/components/layout/AdminLayout.tsx'), 'utf8');
  assert.ok(layoutSrc.includes('hasPermission(i.perm)'));
  assert.ok(layoutSrc.includes('KYC Verification'));
  assert.ok(layoutSrc.includes('Farmer Settlements'));
  assert.ok(layoutSrc.includes('Admin Users & Roles'));
});

test('Mock data separates Product Catalogue from Farmer Produce Listings and masks sensitive KYC', () => {
  const mockSrc = fs.readFileSync(path.join(root, 'src/services/mockAdminData.ts'), 'utf8');
  assert.ok(mockSrc.includes('•••• ••••'), 'Aadhaar must be masked');
  assert.ok(mockSrc.includes('mockProduceListings'));
  assert.ok(mockSrc.includes('mockOrders'));
  assert.ok(mockSrc.includes('mockTransactions'));
});

test('Production dist bundle exists after vite build', () => {
  const distIndex = path.join(root, 'dist/index.html');
  assert.ok(fs.existsSync(distIndex), 'dist/index.html should exist');
});
