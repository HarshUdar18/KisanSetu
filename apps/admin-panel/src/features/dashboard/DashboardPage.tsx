import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Grid,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
} from '@mui/material';
import { Download, Refresh } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { DataSourceBanner, KpiCard, StatusBadge } from '../../components/common/AdminPrimitives';
import { adminApi } from '../../services/adminApi';

export const DashboardPage: React.FC = () => {
  const [kpis, setKpis] = useState<Record<string, number> | null>(null);
  const [orders, setOrders] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);
  const navigate = useNavigate();

  const loadDashboard = async () => {
    const [analyticsRes, ordersRes] = await Promise.all([
      adminApi.fetchDashboardAnalytics(),
      adminApi.fetchOrders(),
    ]);
    setKpis(analyticsRes.data);
    setOrders(ordersRes.data.slice(0, 10));
    setIsLive(analyticsRes.isLive || ordersRes.isLive);
  };

  useEffect(() => {
    loadDashboard();
  }, []);

  const exportCsv = () => {
    const headers = 'OrderNumber,Status,PaymentStatus,TotalAmount\n';
    const rows = orders
      .map((o) => `${o.orderNumber || o.id},${o.orderStatus},${o.paymentStatus},${o.totalAmount}`)
      .join('\n');
    const blob = new Blob([headers + rows], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'kisansetu-orders.csv';
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <Box>
      <Stack direction={{ xs: 'column', sm: 'row' }} sx={{ justifyContent: 'space-between', alignItems: { sm: 'center' }, mb: 2 }} spacing={1.5}>
        <Box>
          <Typography variant="h4">Kisan Setu Command Center</Typography>
          <Typography variant="body2" color="text.secondary">
            Live marketplace, supply-chain, KYC, and settlement metrics
          </Typography>
        </Box>
        <Stack direction="row" spacing={1}>
          <Button variant="outlined" startIcon={<Refresh />} onClick={loadDashboard}>Refresh</Button>
          <Button variant="contained" startIcon={<Download />} onClick={exportCsv} disabled={orders.length === 0}>
            Export CSV
          </Button>
        </Stack>
      </Stack>

      <DataSourceBanner isLive={isLive} label="Platform Analytics & Orders" />

      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid size={{ xs: 6, md: 3 }}>
          <KpiCard title="Total Orders" value={String(kpis?.totalOrders ?? orders.length)} />
        </Grid>
        <Grid size={{ xs: 6, md: 3 }}>
          <KpiCard title="Gross Revenue" value={`₹${Number(kpis?.totalRevenue ?? 0).toLocaleString()}`} />
        </Grid>
        <Grid size={{ xs: 6, md: 3 }}>
          <KpiCard title="Registered Farmers" value={String(kpis?.totalFarmers ?? 0)} />
        </Grid>
        <Grid size={{ xs: 6, md: 3 }}>
          <KpiCard title="Active Listings" value={String(kpis?.activeProduceListings ?? 0)} />
        </Grid>
        <Grid size={{ xs: 6, md: 3 }}>
          <KpiCard title="Pending KYC" value={String(kpis?.pendingKycCount ?? 0)} />
        </Grid>
        <Grid size={{ xs: 6, md: 3 }}>
          <KpiCard title="Open Demands" value={String(kpis?.openDemandCount ?? 0)} />
        </Grid>
        <Grid size={{ xs: 6, md: 3 }}>
          <KpiCard title="Pending DBT Pool" value={`₹${Number(kpis?.pendingSettlementAmount ?? 0).toLocaleString()}`} />
        </Grid>
        <Grid size={{ xs: 6, md: 3 }}>
          <KpiCard title="Open Tickets" value={String(kpis?.openSupportTickets ?? 0)} />
        </Grid>
      </Grid>

      <Card>
        <CardContent>
          <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1.5 }}>
            <Typography variant="h6">Recent Orders</Typography>
            <Button size="small" onClick={() => navigate('/orders')}>View All Orders</Button>
          </Stack>
          {orders.length === 0 ? (
            <Alert severity="info">No orders recorded yet.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Order #</TableCell>
                    <TableCell>Delivery Date</TableCell>
                    <TableCell>Amount</TableCell>
                    <TableCell>Payment</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {orders.map((o) => (
                    <TableRow key={o.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{o.orderNumber || o.id.slice(0, 8)}</TableCell>
                      <TableCell>{o.deliveryDate ?? '—'}</TableCell>
                      <TableCell>₹{Number(o.totalAmount ?? 0).toLocaleString()}</TableCell>
                      <TableCell><StatusBadge status={o.paymentStatus ?? 'PENDING'} /></TableCell>
                      <TableCell><StatusBadge status={o.orderStatus ?? 'PENDING'} /></TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>
    </Box>
  );
};
