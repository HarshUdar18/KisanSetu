import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Drawer,
  InputAdornment,
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
import { Refresh, Search, Visibility } from '@mui/icons-material';
import { DataSourceBanner, StatusBadge } from '../../components/common/AdminPrimitives';
import { adminApi, type PlatformUserDto } from '../../services/adminApi';

export const CustomersPage: React.FC = () => {
  const [customers, setCustomers] = useState<PlatformUserDto[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState<PlatformUserDto | null>(null);

  const load = async () => {
    setLoading(true);
    const { data, isLive: live } = await adminApi.fetchUsers();
    setCustomers(data.filter((u) => u.roles.includes('ROLE_CUSTOMER')));
    setIsLive(live);
    setLoading(false);
  };

  useEffect(() => {
    load();
  }, []);

  const filtered = customers.filter(
    (c) =>
      (c.fullName ?? '').toLowerCase().includes(search.toLowerCase()) ||
      (c.phoneNumber ?? '').includes(search)
  );

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Customers Directory</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Customer Registry" />

      <Card sx={{ mb: 2 }}>
        <CardContent>
          <TextField
            size="small"
            fullWidth
            placeholder="Search customers by name or phone..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            slotProps={{
              input: {
                startAdornment: (
                  <InputAdornment position="start"><Search fontSize="small" /></InputAdornment>
                ),
              },
            }}
          />
        </CardContent>
      </Card>

      <Card>
        <CardContent>
          {!loading && filtered.length === 0 ? (
            <Alert severity="info">No customer accounts found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Name</TableCell>
                    <TableCell>Phone</TableCell>
                    <TableCell>Email</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell align="right">Action</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {filtered.map((c) => (
                    <TableRow key={c.id} hover>
                      <TableCell sx={{ fontWeight: 600 }}>{c.fullName}</TableCell>
                      <TableCell>{c.phoneNumber}</TableCell>
                      <TableCell>{c.email ?? '—'}</TableCell>
                      <TableCell><StatusBadge status={c.status} /></TableCell>
                      <TableCell align="right">
                        <Button size="small" startIcon={<Visibility />} onClick={() => setSelected(c)}>View</Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>

      <Drawer anchor="right" open={!!selected} onClose={() => setSelected(null)} slotProps={{ paper: { sx: { width: { xs: '100%', sm: 400 }, p: 3 } } }}>
        {selected && (
          <Box>
            <Typography variant="h5" gutterBottom>{selected.fullName}</Typography>
            <Typography variant="body2">Phone: {selected.phoneNumber}</Typography>
            <Typography variant="body2">Email: {selected.email ?? '—'}</Typography>
            <Typography variant="body2">Status: {selected.status}</Typography>
          </Box>
        )}
      </Drawer>
    </Box>
  );
};
