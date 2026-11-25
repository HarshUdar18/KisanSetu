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
import { adminApi } from '../../services/adminApi';

interface FarmerRecord {
  id: string;
  fullName: string;
  village?: string;
  district?: string;
  state?: string;
  pincode?: string;
  primaryCropCategory?: string;
}

export const FarmersPage: React.FC = () => {
  const [farmers, setFarmers] = useState<FarmerRecord[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState<FarmerRecord | null>(null);

  const loadFarmers = async () => {
    setLoading(true);
    const { data, isLive: live } = await adminApi.fetchFarmers();
    setFarmers(data);
    setIsLive(live);
    setLoading(false);
  };

  useEffect(() => {
    loadFarmers();
  }, []);

  const filtered = farmers.filter(
    (f) =>
      (f.fullName ?? '').toLowerCase().includes(search.toLowerCase()) ||
      (f.district ?? '').toLowerCase().includes(search.toLowerCase()) ||
      (f.village ?? '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Registered Farmers Directory</Typography>
        <Button startIcon={<Refresh />} onClick={loadFarmers} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Farmer Registry" />

      <Card sx={{ mb: 2 }}>
        <CardContent>
          <TextField
            size="small"
            fullWidth
            placeholder="Search farmers by name, village, or district..."
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
            <Alert severity="info">No farmer profiles found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Farmer Name</TableCell>
                    <TableCell>Village</TableCell>
                    <TableCell>District</TableCell>
                    <TableCell>Pincode</TableCell>
                    <TableCell>Primary Crop</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell align="right">View</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {filtered.map((f) => (
                    <TableRow key={f.id} hover>
                      <TableCell sx={{ fontWeight: 600 }}>{f.fullName}</TableCell>
                      <TableCell>{f.village ?? '—'}</TableCell>
                      <TableCell>{f.district ?? '—'}</TableCell>
                      <TableCell>{f.pincode ?? '—'}</TableCell>
                      <TableCell>{f.primaryCropCategory ?? '—'}</TableCell>
                      <TableCell><StatusBadge status="ACTIVE" /></TableCell>
                      <TableCell align="right">
                        <Button size="small" startIcon={<Visibility />} onClick={() => setSelected(f)}>Inspect</Button>
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
            <Typography variant="body2">Village: {selected.village ?? '—'}</Typography>
            <Typography variant="body2">District: {selected.district ?? '—'}, {selected.state ?? ''}</Typography>
            <Typography variant="body2">Pincode: {selected.pincode ?? '—'}</Typography>
            <Typography variant="body2">Primary Category: {selected.primaryCropCategory ?? '—'}</Typography>
          </Box>
        )}
      </Drawer>
    </Box>
  );
};
