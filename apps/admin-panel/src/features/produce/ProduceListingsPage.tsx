import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
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
import { DataSourceBanner, StatusBadge } from '../../components/common/AdminPrimitives';
import { adminApi } from '../../services/adminApi';

export const ProduceListingsPage: React.FC = () => {
  const [listings, setListings] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [filter, setFilter] = useState('ALL');

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchProduceListings();
    setListings(data);
    setIsLive(live);
  };

  useEffect(() => {
    load();
  }, []);

  const visible = listings.filter((l) => filter === 'ALL' || l.status === filter);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Farmer Produce Listings & Sourcing Desk</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Farmer Produce Listings" />

      <Stack direction="row" spacing={1} useFlexGap sx={{ mb: 2, flexWrap: 'wrap' }}>
        {['ALL', 'ACTIVE', 'PAUSED', 'SOLD_OUT'].map((s) => (
          <Chip key={s} label={s} color={filter === s ? 'primary' : 'default'} onClick={() => setFilter(s)} />
        ))}
      </Stack>

      <Card>
        <CardContent>
          {visible.length === 0 ? (
            <Alert severity="info">No produce listings found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Product</TableCell>
                    <TableCell>Farmer</TableCell>
                    <TableCell>Available Qty</TableCell>
                    <TableCell>Price / Unit</TableCell>
                    <TableCell>Grade</TableCell>
                    <TableCell>Harvest Date</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {visible.map((l) => (
                    <TableRow key={l.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{l.productName}</TableCell>
                      <TableCell>{l.farmerName}</TableCell>
                      <TableCell>{l.quantityAvailable} {l.unit}</TableCell>
                      <TableCell>₹{l.pricePerUnit}</TableCell>
                      <TableCell>{l.qualityGrade}</TableCell>
                      <TableCell>{l.harvestDate ?? '—'}</TableCell>
                      <TableCell><StatusBadge status={l.status ?? 'ACTIVE'} /></TableCell>
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
