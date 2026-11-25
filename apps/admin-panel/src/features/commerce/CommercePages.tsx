import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Typography,
} from '@mui/material';
import { Add, Refresh } from '@mui/icons-material';
import { DataSourceBanner, StatusBadge } from '../../components/common/AdminPrimitives';
import { adminApi } from '../../services/adminApi';

export const SubscriptionsPage: React.FC = () => {
  const [subs, setSubs] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchSubscriptions();
    setSubs(data);
    setIsLive(live);
  };

  useEffect(() => { load(); }, []);

  return (
    <Box>
      <Stack direction="row" sx={{ mb: 1, justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h4">Customer Subscription Management</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Subscription Plans & Orders" />
      <Card>
        <CardContent>
          {subs.length === 0 ? (
            <Alert severity="info">No customer subscriptions found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Sub ID</TableCell>
                    <TableCell>Frequency</TableCell>
                    <TableCell>Start Date</TableCell>
                    <TableCell>Preferences</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {subs.map((s) => (
                    <TableRow key={s.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{String(s.id).slice(0, 8)}</TableCell>
                      <TableCell>{s.frequency}</TableCell>
                      <TableCell>{s.startDate}</TableCell>
                      <TableCell>{s.deliveryPreferences ?? '—'}</TableCell>
                      <TableCell><StatusBadge status={s.status} /></TableCell>
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

export const FarmerStorePage: React.FC = () => {
  const [products, setProducts] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [open, setOpen] = useState(false);
  const [name, setName] = useState('');
  const [category, setCategory] = useState('Seeds');
  const [mrp, setMrp] = useState('500');
  const [subsidizedPrice, setSubsidizedPrice] = useState('350');

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchStoreProducts();
    setProducts(data);
    setIsLive(live);
  };

  useEffect(() => { load(); }, []);

  const handleCreate = async () => {
    if (!name.trim()) return;
    try {
      await adminApi.createStoreProduct({
        name: name.trim(),
        category,
        unit: 'packet',
        mrp: Number(mrp) || 500,
        subsidizedPrice: Number(subsidizedPrice) || 350,
        stockQuantity: 100,
      });
      setName('');
      setOpen(false);
      await load();
    } catch {}
  };

  return (
    <Box>
      <Stack direction="row" sx={{ mb: 1, justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h4">Farmer Agri-Input Store Management</Typography>
        <Stack direction="row" spacing={1}>
          <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
          <Button variant="contained" startIcon={<Add />} onClick={() => setOpen(true)}>Add Input SKU</Button>
        </Stack>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Farmer Store Catalog" />
      <Card>
        <CardContent>
          {products.length === 0 ? (
            <Alert severity="info">No Farmer Store products found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Input Product</TableCell>
                    <TableCell>Category</TableCell>
                    <TableCell>MRP</TableCell>
                    <TableCell>Subsidized Rate</TableCell>
                    <TableCell>Stock</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {products.map((p) => (
                    <TableRow key={p.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{p.name}</TableCell>
                      <TableCell>{p.category}</TableCell>
                      <TableCell>₹{p.mrp}</TableCell>
                      <TableCell>₹{p.subsidizedPrice}</TableCell>
                      <TableCell>{p.stockQuantity} {p.unit}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>
      <Dialog open={open} onClose={() => setOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Add Farmer Store SKU</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField label="Product Name" value={name} onChange={(e) => setName(e.target.value)} />
            <TextField label="Category" value={category} onChange={(e) => setCategory(e.target.value)} />
            <TextField label="MRP (₹)" value={mrp} onChange={(e) => setMrp(e.target.value)} />
            <TextField label="Subsidized Price (₹)" value={subsidizedPrice} onChange={(e) => setSubsidizedPrice(e.target.value)} />
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleCreate}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export const PromotionsPage: React.FC = () => {
  const [coupons, setCoupons] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [open, setOpen] = useState(false);
  const [code, setCode] = useState('');
  const [discountValue, setDiscountValue] = useState('50');

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchCoupons();
    setCoupons(data);
    setIsLive(live);
  };

  useEffect(() => { load(); }, []);

  const handleCreate = async () => {
    if (!code.trim()) return;
    try {
      await adminApi.createCoupon({
        code: code.trim().toUpperCase(),
        discountType: 'FLAT',
        discountValue: Number(discountValue) || 50,
        minOrderAmount: 249,
      });
      setCode('');
      setOpen(false);
      await load();
    } catch {}
  };

  return (
    <Box>
      <Stack direction="row" sx={{ mb: 1, justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h4">Coupons & Promotions</Typography>
        <Stack direction="row" spacing={1}>
          <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
          <Button variant="contained" startIcon={<Add />} onClick={() => setOpen(true)}>Create Coupon</Button>
        </Stack>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Coupons & Promotions" />
      <Card>
        <CardContent>
          {coupons.length === 0 ? (
            <Alert severity="info">No active coupons found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Code</TableCell>
                    <TableCell>Type</TableCell>
                    <TableCell>Discount Value</TableCell>
                    <TableCell>Min Order</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {coupons.map((c) => (
                    <TableRow key={c.code}>
                      <TableCell sx={{ fontWeight: 700 }}>{c.code}</TableCell>
                      <TableCell>{c.discountType}</TableCell>
                      <TableCell>{c.discountValue}</TableCell>
                      <TableCell>₹{c.minOrderAmount}</TableCell>
                      <TableCell><StatusBadge status={c.active !== false ? 'ACTIVE' : 'INACTIVE'} /></TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>

      <Dialog open={open} onClose={() => setOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Create Promotion Coupon</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField label="Coupon Code" value={code} onChange={(e) => setCode(e.target.value)} />
            <TextField label="Discount Value (₹)" value={discountValue} onChange={(e) => setDiscountValue(e.target.value)} />
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleCreate}>Create</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
