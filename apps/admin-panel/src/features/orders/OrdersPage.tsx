import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  Drawer,
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
import { CheckCircle, Refresh } from '@mui/icons-material';
import { DataSourceBanner, KpiCard, StatusBadge } from '../../components/common/AdminPrimitives';
import { adminApi } from '../../services/adminApi';

interface OrderRecord {
  id: string;
  orderNumber: string;
  orderStatus: string;
  paymentStatus: string;
  totalAmount: number;
  deliveryDate?: string;
  deliverySlot?: string;
  createdAt?: string;
}

const TRACEABILITY_STEPS = [
  '1. Order Placed & Price Locked',
  '2. Payment Verified',
  '3. Farmer Harvest Scheduled',
  '4. Collection Center Weighment',
  '5. Quality & Residue Assay',
  '6. Warehouse Cold-Chain Intake',
  '7. Out for Delivery',
  '8. Delivered & Settlement Queued',
];

export const OrdersPage: React.FC = () => {
  const [orders, setOrders] = useState<OrderRecord[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [loading, setLoading] = useState(true);
  const [stageFilter, setStageFilter] = useState('ALL');
  const [selected, setSelected] = useState<OrderRecord | null>(null);

  const loadOrders = async () => {
    setLoading(true);
    const { data, isLive: live } = await adminApi.fetchOrders();
    setOrders(data);
    setIsLive(live);
    setLoading(false);
  };

  useEffect(() => {
    loadOrders();
  }, []);

  const visible = orders.filter((o) => stageFilter === 'ALL' || o.orderStatus === stageFilter);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Active Sourcing & Multi-Stage Order Tracker</Typography>
        <Button startIcon={<Refresh />} onClick={loadOrders} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Order Management & Traceability" />

      <Grid container spacing={2} sx={{ mb: 2.5 }}>
        <Grid size={{ xs: 6, md: 3 }}><KpiCard title="Total Orders" value={String(orders.length)} /></Grid>
        <Grid size={{ xs: 6, md: 3 }}><KpiCard title="Confirmed" value={String(orders.filter((o) => o.orderStatus === 'CONFIRMED').length)} /></Grid>
        <Grid size={{ xs: 6, md: 3 }}><KpiCard title="Pending Payment" value={String(orders.filter((o) => o.orderStatus === 'PENDING_PAYMENT').length)} /></Grid>
        <Grid size={{ xs: 6, md: 3 }}><KpiCard title="Delivered" value={String(orders.filter((o) => o.orderStatus === 'DELIVERED').length)} /></Grid>
      </Grid>

      <Stack direction="row" spacing={1} useFlexGap sx={{ mb: 2, flexWrap: 'wrap' }}>
        {['ALL', 'PENDING_PAYMENT', 'CONFIRMED', 'DELIVERED', 'CANCELLED'].map((s) => (
          <Chip key={s} label={s.replaceAll('_', ' ')} color={stageFilter === s ? 'primary' : 'default'} onClick={() => setStageFilter(s)} />
        ))}
      </Stack>

      <Card>
        <CardContent>
          {!loading && visible.length === 0 ? (
            <Alert severity="info">No orders found in the database matching this filter.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Order #</TableCell>
                    <TableCell>Delivery Date</TableCell>
                    <TableCell>Slot</TableCell>
                    <TableCell>Total</TableCell>
                    <TableCell>Payment</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {visible.map((o) => (
                    <TableRow key={o.id} hover sx={{ cursor: 'pointer' }} onClick={() => setSelected(o)}>
                      <TableCell sx={{ fontWeight: 600 }}>{o.orderNumber || o.id.slice(0, 8)}</TableCell>
                      <TableCell>{o.deliveryDate ?? '—'}</TableCell>
                      <TableCell>{o.deliverySlot ?? '—'}</TableCell>
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

      <Drawer anchor="right" open={!!selected} onClose={() => setSelected(null)} slotProps={{ paper: { sx: { width: { xs: '100%', sm: 420 }, p: 3 } } }}>
        {selected && (
          <Box>
            <Typography variant="h5" gutterBottom>Order {selected.orderNumber || selected.id}</Typography>
            <Typography variant="body2" sx={{ mb: 2 }}>
              Amount: ₹{Number(selected.totalAmount ?? 0).toLocaleString()} • Status: {selected.orderStatus}
            </Typography>
            <Typography variant="h6" gutterBottom>Supply Chain Timeline</Typography>
            <Stack spacing={1.2}>
              {TRACEABILITY_STEPS.map((step, i) => (
                <Stack key={step} direction="row" spacing={1.5} sx={{ alignItems: 'center' }}>
                  <CheckCircle fontSize="small" color={i === 0 || selected.orderStatus === 'DELIVERED' ? 'success' : 'disabled'} />
                  <Typography variant="body2">{step}</Typography>
                </Stack>
              ))}
            </Stack>
          </Box>
        )}
      </Drawer>
    </Box>
  );
};
