import React, { useState } from 'react';
import {
  AppBar,
  Avatar,
  Badge,
  Box,
  Breadcrumbs,
  Chip,
  Divider,
  Drawer,
  IconButton,
  InputAdornment,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Menu,
  MenuItem,
  Stack,
  TextField,
  Toolbar,
  Tooltip,
  Typography,
  useMediaQuery,
  useTheme,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  Analytics as AnalyticsIcon,
  People as CustomersIcon,
  Agriculture as FarmersIcon,
  CorporateFare as FpoIcon,
  VerifiedUser as KycIcon,
  Category as CatalogIcon,
  Inventory2 as ProduceIcon,
  TrendingUp as DemandIcon,
  ReceiptLong as OrdersIcon,
  LocalShipping as CollectionIcon,
  Science as QualityIcon,
  Warehouse as WarehouseIcon,
  FactCheck as InventoryIcon,
  Route as LogisticsIcon,
  Payments as PaymentsIcon,
  AccountBalanceWallet as SettlementsIcon,
  Autorenew as SubscriptionsIcon,
  Storefront as StoreIcon,
  LocalOffer as CouponsIcon,
  Notifications as NotificationsIcon,
  SupportAgent as SupportIcon,
  AdminPanelSettings as RbacIcon,
  Settings as SettingsIcon,
  Hub as HubIcon,
  Menu as MenuIcon,
  ChevronLeft,
  ChevronRight,
  Search as SearchIcon,
  Add as AddIcon,
  HelpOutlined,
  Logout,
  Lock,
  Person,
} from '@mui/icons-material';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { adminApi } from '../../services/adminApi';
import { adminColors } from '../../theme/theme';
import { ConfirmActionDialog } from '../common/AdminPrimitives';

interface NavItem {
  label: string;
  path: string;
  perm: string;
  icon: React.ReactNode;
  badge?: string;
}

interface NavGroup {
  title: string;
  items: NavItem[];
}

const NAV_GROUPS: NavGroup[] = [
  {
    title: 'MAIN',
    items: [
      { label: 'Dashboard', path: '/dashboard', perm: 'dashboard', icon: <DashboardIcon fontSize="small" /> },
      { label: 'Analytics & Reports', path: '/analytics', perm: 'analytics', icon: <AnalyticsIcon fontSize="small" /> },
    ],
  },
  {
    title: 'STAKEHOLDERS',
    items: [
      { label: 'Customers', path: '/customers', perm: 'customers', icon: <CustomersIcon fontSize="small" /> },
      { label: 'Farmers', path: '/farmers', perm: 'farmers', icon: <FarmersIcon fontSize="small" /> },
      { label: 'FPOs', path: '/fpos', perm: 'fpos', icon: <FpoIcon fontSize="small" /> },
      { label: 'KYC Verification', path: '/kyc', perm: 'kyc', icon: <KycIcon fontSize="small" /> },
    ],
  },
  {
    title: 'SUPPLY CHAIN & CATALOG',
    items: [
      { label: 'Hub Management', path: '/hubs', perm: 'hubs', icon: <HubIcon fontSize="small" /> },
      { label: 'Product Catalogue', path: '/products', perm: 'products', icon: <CatalogIcon fontSize="small" /> },
      { label: 'Produce Listings', path: '/produce', perm: 'produce', icon: <ProduceIcon fontSize="small" /> },
      { label: 'Demand Management', path: '/demand', perm: 'demand', icon: <DemandIcon fontSize="small" /> },
      { label: 'Order Management', path: '/orders', perm: 'orders', icon: <OrdersIcon fontSize="small" /> },
      { label: 'Collection Points', path: '/collections', perm: 'collections', icon: <CollectionIcon fontSize="small" /> },
      { label: 'Quality Inspection', path: '/quality', perm: 'quality', icon: <QualityIcon fontSize="small" /> },
      { label: 'Warehouses', path: '/warehouses', perm: 'warehouses', icon: <WarehouseIcon fontSize="small" /> },
      { label: 'Inventory', path: '/inventory', perm: 'inventory', icon: <InventoryIcon fontSize="small" /> },
      { label: 'Logistics & Fleet', path: '/logistics', perm: 'logistics', icon: <LogisticsIcon fontSize="small" /> },
    ],
  },
  {
    title: 'FINANCE & COMMERCE',
    items: [
      { label: 'Payments & Escrow', path: '/payments', perm: 'payments', icon: <PaymentsIcon fontSize="small" /> },
      { label: 'Farmer Settlements', path: '/settlements', perm: 'settlements', icon: <SettlementsIcon fontSize="small" /> },
      { label: 'Subscriptions', path: '/subscriptions', perm: 'subscriptions', icon: <SubscriptionsIcon fontSize="small" /> },
      { label: 'Farmer Store', path: '/farmer-store', perm: 'farmer-store', icon: <StoreIcon fontSize="small" /> },
      { label: 'Coupons & Offers', path: '/promotions', perm: 'promotions', icon: <CouponsIcon fontSize="small" /> },
    ],
  },
  {
    title: 'SYSTEM & GOVERNANCE',
    items: [
      { label: 'Notifications', path: '/notifications', perm: 'notifications', icon: <NotificationsIcon fontSize="small" /> },
      { label: 'Support & Complaints', path: '/support', perm: 'support', icon: <SupportIcon fontSize="small" /> },
      { label: 'Admin Users & Roles', path: '/admin-users', perm: 'admin-users', icon: <RbacIcon fontSize="small" /> },
      { label: 'Service Areas & PINs', path: '/service-areas', perm: 'settings', icon: <HubIcon fontSize="small" /> },
      { label: 'System Settings', path: '/settings', perm: 'settings', icon: <SettingsIcon fontSize="small" /> },
    ],
  },
];

export const AdminLayout: React.FC = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [globalSearch, setGlobalSearch] = useState('');
  const [profileMenuEl, setProfileMenuEl] = useState<null | HTMLElement>(null);
  const [logoutOpen, setLogoutOpen] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);

  React.useEffect(() => {
    adminApi.fetchNotifications().then(({ data, isLive }) => {
      if (isLive) {
        setUnreadCount(data.filter((n: any) => !n.read).length);
      }
    });
  }, []);

  const location = useLocation();
  const navigate = useNavigate();
  const { user, logout, lockSession, hasPermission } = useAuth();

  const drawerWidth = collapsed && !isMobile ? 74 : 254;
  const currentSegment = location.pathname.split('/')[1] || 'dashboard';

  const sidebarContent = (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%', bgcolor: adminColors.surfaceLowest }}>
      {/* Brand Header */}
      <Stack
        direction="row"
        sx={{ px: 2, height: 64, borderBottom: `1px solid ${adminColors.cardBorder}` , justifyContent: collapsed && !isMobile ? 'center' : 'space-between', alignItems: "center" }}
      >
        {(!collapsed || isMobile) && (
          <Stack direction="row" spacing={1.2} sx={{ alignItems: "center" }}>
            <Box
              sx={{
                width: 34,
                height: 34,
                borderRadius: 2,
                bgcolor: adminColors.primary,
                color: adminColors.harvestGold,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 800,
              }}
            >
              KS
            </Box>
            <Box>
              <Typography variant="subtitle1" sx={{ lineHeight: 1.1, fontWeight: 700 }}>
                Kisan Setu
              </Typography>
              <Typography variant="caption" sx={{ color: adminColors.outline }}>
                Enterprise Admin
              </Typography>
            </Box>
          </Stack>
        )}
        {!isMobile && (
          <IconButton size="small" onClick={() => setCollapsed((c) => !c)}>
            {collapsed ? <ChevronRight /> : <ChevronLeft />}
          </IconButton>
        )}
      </Stack>

      {/* Scrollable Navigation Groups */}
      <Box sx={{ flex: 1, overflowY: 'auto', py: 1.5, px: 1 }}>
        {NAV_GROUPS.map((group) => {
          const visibleItems = group.items.filter((i) => hasPermission(i.perm));
          if (visibleItems.length === 0) return null;
          return (
            <Box key={group.title} sx={{ mb: 1.5 }}>
              {(!collapsed || isMobile) && (
                <Typography
                  variant="caption"
                  sx={{
                    px: 1.5,
                    py: 0.5,
                    display: 'block',
                    fontWeight: 700,
                    fontSize: '0.65rem',
                    color: adminColors.outline,
                    letterSpacing: '0.06em',
                  }}
                >
                  {group.title}
                </Typography>
              )}
              <List dense disablePadding>
                {visibleItems.map((item) => {
                  const active = location.pathname.startsWith(item.path);
                  const btn = (
                    <ListItemButton
                      key={item.path}
                      onClick={() => {
                        navigate(item.path);
                        if (isMobile) setMobileOpen(false);
                      }}
                      sx={{
                        borderRadius: 2,
                        mb: 0.25,
                        px: collapsed && !isMobile ? 1.5 : 1.5,
                        justifyContent: collapsed && !isMobile ? 'center' : 'flex-start',
                        bgcolor: active ? adminColors.primary : 'transparent',
                        color: active ? '#FFFFFF' : adminColors.onSurface,
                        '&:hover': {
                          bgcolor: active ? adminColors.primaryContainer : adminColors.surfaceLow,
                        },
                      }}
                    >
                      <ListItemIcon
                        sx={{
                          minWidth: collapsed && !isMobile ? 0 : 34,
                          color: active ? '#FFFFFF' : adminColors.onSurfaceVariant,
                        }}
                      >
                        {item.icon}
                      </ListItemIcon>
                      {(!collapsed || isMobile) && (
                        <>
                          <ListItemText
                            primary={item.label}
                            slotProps={{ primary: { sx: {
                              fontSize: '0.82rem',
                              fontWeight: active ? 600 : 500,
                            } } }}
                          />
                          {item.badge && (
                            <Chip
                              size="small"
                              label={item.badge}
                              sx={{
                                height: 18,
                                fontSize: '0.65rem',
                                bgcolor: item.badge === 'Due' ? adminColors.errorContainer : adminColors.tertiaryFixed,
                                color: item.badge === 'Due' ? adminColors.onErrorContainer : adminColors.onTertiaryFixed,
                              }}
                            />
                          )}
                        </>
                      )}
                    </ListItemButton>
                  );
                  return collapsed && !isMobile ? (
                    <Tooltip key={item.path} title={item.label} placement="right">
                      {btn}
                    </Tooltip>
                  ) : (
                    btn
                  );
                })}
              </List>
            </Box>
          );
        })}
      </Box>

      {/* Admin Footer */}
      <Divider />
      <Box sx={{ p: 1.5 }}>
        <Stack direction="row" spacing={1.2} sx={{ justifyContent: collapsed && !isMobile ? 'center' : 'flex-start', alignItems: "center" }}>
          <Avatar sx={{ width: 32, height: 32, bgcolor: adminColors.primary, fontSize: 13 }}>
            {(user?.fullName ?? user?.phoneNumber ?? 'AD').slice(0, 2).toUpperCase()}
          </Avatar>
          {(!collapsed || isMobile) && (
            <Box sx={{ minWidth: 0 }}>
              <Typography variant="subtitle2" noWrap>
                {user?.fullName ?? user?.phoneNumber ?? 'Admin'}
              </Typography>
              <Typography variant="caption" noWrap sx={{ color: adminColors.outline }}>
                {user?.adminRole ?? (user?.roles?.includes('ROLE_SUPER_ADMIN') ? 'Super Admin' : 'Admin')}
              </Typography>
            </Box>
          )}
        </Stack>
      </Box>
    </Box>
  );

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: adminColors.surface }}>
      {/* Sidebar Drawer */}
      <Box component="nav" sx={{ width: { md: drawerWidth }, flexShrink: { md: 0 } }}>
        {isMobile ? (
          <Drawer
            variant="temporary"
            open={mobileOpen}
            onClose={() => setMobileOpen(false)}
            slotProps={{ paper: { sx: { width: 254 } } }}
          >
            {sidebarContent}
          </Drawer>
        ) : (
          <Drawer
            variant="permanent"
            open
            slotProps={{ paper: {
              sx: {
                width: drawerWidth,
                borderRight: `1px solid ${adminColors.cardBorder}`,
                transition: 'width 0.2s ease',
              },
            } }}
          >
            {sidebarContent}
          </Drawer>
        )}
      </Box>

      {/* Main Content Area */}
      <Box sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
        {/* Sticky Top Header */}
        <AppBar
          position="sticky"
          elevation={0}
          sx={{
            bgcolor: 'rgba(242, 252, 242, 0.92)',
            backdropFilter: 'blur(10px)',
            color: adminColors.onSurface,
            borderBottom: `1px solid ${adminColors.cardBorder}`,
          }}
        >
          <Toolbar sx={{ gap: 1.5, minHeight: 64 }}>
            {isMobile && (
              <IconButton onClick={() => setMobileOpen(true)}>
                <MenuIcon />
              </IconButton>
            )}
            <Breadcrumbs sx={{ display: { xs: 'none', sm: 'flex' } }}>
              <Typography variant="body2" sx={{ cursor: 'pointer' }} onClick={() => navigate('/dashboard')}>
                Home
              </Typography>
              <Typography variant="body2" sx={{ textTransform: 'capitalize', fontWeight: 600, color: adminColors.onSurface }}>
                {currentSegment.replaceAll('-', ' ')}
              </Typography>
            </Breadcrumbs>

            <Box sx={{ flexGrow: 1 }} />

            <TextField
              size="small"
              placeholder="Search farmers, orders, lots..."
              value={globalSearch}
              onChange={(e) => setGlobalSearch(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && globalSearch.trim()) {
                  navigate(`/orders?q=${encodeURIComponent(globalSearch.trim())}`);
                }
              }}
              sx={{
                width: { xs: 150, sm: 250 },
                '& .MuiOutlinedInput-root': { bgcolor: adminColors.surfaceLowest, borderRadius: 2 },
              }}
              slotProps={{ input: {
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon fontSize="small" />
                  </InputAdornment>
                ),
              } }}
            />

            <Chip
              size="small"
              label="Services Live"
              sx={{
                display: { xs: 'none', lg: 'inline-flex' },
                bgcolor: adminColors.secondaryContainer,
                color: adminColors.onSecondaryContainer,
              }}
            />

            <Tooltip title="Register New FPO">
              <Chip
                icon={<AddIcon />}
                label="Quick Action"
                color="primary"
                onClick={() => navigate('/fpos')}
                sx={{ display: { xs: 'none', sm: 'inline-flex' } }}
              />
            </Tooltip>

            <IconButton onClick={() => navigate('/notifications')}>
              <Badge badgeContent={unreadCount} color="error">
                <NotificationsIcon fontSize="small" />
              </Badge>
            </IconButton>

            <IconButton onClick={() => navigate('/support')} sx={{ display: { xs: 'none', sm: 'inline-flex' } }}>
              <HelpOutlined fontSize="small" />
            </IconButton>

            <IconButton onClick={(e) => setProfileMenuEl(e.currentTarget)}>
              <Avatar sx={{ width: 32, height: 32, bgcolor: adminColors.primary, fontSize: 13 }}>
                {(user?.fullName ?? user?.phoneNumber ?? 'AD').slice(0, 2).toUpperCase()}
              </Avatar>
            </IconButton>

            <Menu
              anchorEl={profileMenuEl}
              open={!!profileMenuEl}
              onClose={() => setProfileMenuEl(null)}
            >
              <MenuItem onClick={() => { setProfileMenuEl(null); navigate('/profile'); }}>
                <ListItemIcon><Person fontSize="small" /></ListItemIcon>
                Admin Profile
              </MenuItem>
              <MenuItem onClick={() => { setProfileMenuEl(null); lockSession(); navigate('/session-locked'); }}>
                <ListItemIcon><Lock fontSize="small" /></ListItemIcon>
                Lock Console
              </MenuItem>
              <Divider />
              <MenuItem onClick={() => { setProfileMenuEl(null); setLogoutOpen(true); }}>
                <ListItemIcon><Logout fontSize="small" color="error" /></ListItemIcon>
                Logout
              </MenuItem>
            </Menu>
          </Toolbar>
        </AppBar>

        {/* Page Body */}
        <Box component="main" sx={{ flexGrow: 1, p: { xs: 2, md: 3 } }}>
          <Outlet />
        </Box>
      </Box>

      <ConfirmActionDialog
        open={logoutOpen}
        title="Logout from Admin Console?"
        message="Your current administrative session will be terminated."
        confirmLabel="Logout"
        destructive
        onCancel={() => setLogoutOpen(false)}
        onConfirm={() => {
          setLogoutOpen(false);
          logout();
          navigate('/login');
        }}
      />
    </Box>
  );
};
