import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
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
import { Refresh } from '@mui/icons-material';
import { DataSourceBanner, KpiCard, StatusBadge } from '../../components/common/AdminPrimitives';
import { adminApi } from '../../services/adminApi';

export const PaymentsPage: React.FC = () => {
  const [orders, setOrders] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [filter, setFilter] = useState('ALL');

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchOrders();
    setOrders(data);
    setIsLive(live);
  };

  useEffect(() => {
    load();
  }, []);

  const visible = orders.filter((o) => filter === 'ALL' || o.paymentStatus === filter);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Payments & Escrow Clearing Ledger</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Payments & Escrow Gateway" />

      <Stack direction="row" spacing={1} sx={{ mb: 2 }}>
        {['ALL', 'COMPLETED', 'PENDING', 'FAILED'].map((s) => (
          <Chip key={s} label={s} color={filter === s ? 'primary' : 'default'} onClick={() => setFilter(s)} />
        ))}
      </Stack>

      <Card>
        <CardContent>
          {visible.length === 0 ? (
            <Alert severity="info">No payment records found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Order #</TableCell>
                    <TableCell>Amount</TableCell>
                    <TableCell>Payment Ref</TableCell>
                    <TableCell>Payment Status</TableCell>
                    <TableCell>Order Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {visible.map((o) => (
                    <TableRow key={o.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{o.orderNumber || o.id.slice(0, 8)}</TableCell>
                      <TableCell>₹{Number(o.totalAmount ?? 0).toLocaleString()}</TableCell>
                      <TableCell>{o.paymentReference ?? '—'}</TableCell>
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

export const SettlementsPage: React.FC = () => {
  const [txns, setTxns] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchSettlements();
    setTxns(data);
    setIsLive(live);
  };

  useEffect(() => {
    load();
  }, []);

  const totalPending = txns
    .filter((t) => t.status === 'PENDING')
    .reduce((sum, t) => sum + Number(t.netAmount ?? 0), 0);

  const handleAuthorize = async (id: string) => {
    try {
      await adminApi.authorizeSettlement(id, 'Authorized via Admin Panel');
      await load();
    } catch {}
  };

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Farmer Weekly Settlements & PFMS DBT Gateway</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Weekly Settlement Engine" />

      <Grid container spacing={2} sx={{ mb: 2.5 }}>
        <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Pending Settlement Pool" value={`₹${totalPending.toLocaleString()}`} /></Grid>
        <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Total Records" value={String(txns.length)} /></Grid>
        <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Authorized" value={String(txns.filter((t) => t.status === 'AUTHORIZED' || t.status === 'PAID').length)} /></Grid>
      </Grid>

      <Card>
        <CardContent>
          {txns.length === 0 ? (
            <Alert severity="info">No farmer settlements found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Settlement ID</TableCell>
                    <TableCell>Farmer</TableCell>
                    <TableCell>Gross</TableCell>
                    <TableCell>Net Amount</TableCell>
                    <TableCell>Bank</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell align="right">Action</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {txns.map((t) => (
                    <TableRow key={t.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{t.id.slice(0, 8)}</TableCell>
                      <TableCell>{t.farmerPhone || t.farmerId?.slice(0, 8)}</TableCell>
                      <TableCell>₹{Number(t.grossAmount ?? 0).toLocaleString()}</TableCell>
                      <TableCell>₹{Number(t.netAmount ?? 0).toLocaleString()}</TableCell>
                      <TableCell>{t.bankAccountMasked ?? '—'}</TableCell>
                      <TableCell><StatusBadge status={t.status} /></TableCell>
                      <TableCell align="right">
                        {t.status === 'PENDING' && (
                          <Button size="small" variant="contained" onClick={() => handleAuthorize(t.id)}>
                            Authorize DBT
                          </Button>
                        )}
                      </TableCell>
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
