import React, { createContext, useContext, useState, useEffect } from 'react';

export type AdminRoleName =
  | 'Super Admin'
  | 'Operations Admin'
  | 'Farmer Management Admin'
  | 'Customer Support Admin'
  | 'Finance Admin'
  | 'Warehouse Admin'
  | 'Logistics Admin';

export interface AdminUser {
  id: string;
  phoneNumber: string;
  email?: string;
  fullName: string;
  roles: string[];
  adminRole?: AdminRoleName;
  permissions?: string[];
}

interface AuthContextType {
  token: string | null;
  user: AdminUser | null;
  isAuthenticated: boolean;
  isLocked: boolean;
  login: (token: string, user: AdminUser) => void;
  logout: () => void;
  lockSession: () => void;
  unlockSession: () => void;
  hasPermission: (permission: string) => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const ROLE_PERMISSIONS: Record<AdminRoleName, string[]> = {
  'Super Admin': ['*'],
  'Operations Admin': ['dashboard', 'orders', 'collections', 'quality', 'warehouses', 'inventory', 'logistics', 'demand', 'produce'],
  'Farmer Management Admin': ['dashboard', 'farmers', 'fpos', 'kyc', 'produce', 'farmer-store'],
  'Customer Support Admin': ['dashboard', 'customers', 'orders', 'support', 'notifications', 'subscriptions'],
  'Finance Admin': ['dashboard', 'payments', 'settlements', 'analytics', 'promotions'],
  'Warehouse Admin': ['dashboard', 'warehouses', 'inventory', 'collections', 'quality'],
  'Logistics Admin': ['dashboard', 'logistics', 'orders', 'collections'],
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('kisansetu_admin_token'));
  const [isLocked, setIsLocked] = useState(false);
  const [user, setUser] = useState<AdminUser | null>(() => {
    const saved = localStorage.getItem('kisansetu_admin_user');
    return saved ? JSON.parse(saved) : null;
  });

  useEffect(() => {
    if (token) localStorage.setItem('kisansetu_admin_token', token);
    else localStorage.removeItem('kisansetu_admin_token');
  }, [token]);

  useEffect(() => {
    if (user) localStorage.setItem('kisansetu_admin_user', JSON.stringify(user));
    else localStorage.removeItem('kisansetu_admin_user');
  }, [user]);

  const login = (newToken: string, newUser: AdminUser) => {
    setToken(newToken);
    setUser({
      ...newUser,
      adminRole: newUser.adminRole ?? 'Super Admin',
    });
    setIsLocked(false);
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    setIsLocked(false);
    localStorage.removeItem('kisansetu_admin_token');
    localStorage.removeItem('kisansetu_admin_user');
  };

  const lockSession = () => setIsLocked(true);
  const unlockSession = () => setIsLocked(false);

  const hasPermission = (permission: string): boolean => {
    if (!user) return false;
    const role = user.adminRole ?? 'Super Admin';
    const perms = user.permissions ?? ROLE_PERMISSIONS[role] ?? ['*'];
    return perms.includes('*') || perms.includes(permission);
  };

  return (
    <AuthContext.Provider
      value={{
        token,
        user,
        isAuthenticated: !!token,
        isLocked,
        login,
        logout,
        lockSession,
        unlockSession,
        hasPermission,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within an AuthProvider');
  return context;
};
