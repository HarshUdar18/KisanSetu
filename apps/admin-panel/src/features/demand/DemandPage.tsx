import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
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

export const DemandPage: React.FC = () => {
  const [demands, setDemands] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchDemands();
    setDemands(data);
    setIsLive(live);
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Institutional Demand & Reverse B2B Aggregation</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Demand Aggregation Engine" />

      <Card>
        <CardContent>
          {demands.length === 0 ? (
            <Alert severity="info">No demand requests found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Demand ID</TableCell>
                    <TableCell>Required Product</TableCell>
                    <TableCell>Quantity (kg)</TableCell>
                    <TableCell>Target Price / kg</TableCell>
                    <TableCell>Required By</TableCell>
                    <TableCell>Notes</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {demands.map((d) => (
                    <TableRow key={d.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{d.id.slice(0, 8)}</TableCell>
                      <TableCell>{d.productName}</TableCell>
                      <TableCell>{d.quantityKg} kg</TableCell>
                      <TableCell>₹{d.targetPricePerKg}</TableCell>
                      <TableCell>{d.requiredByDate}</TableCell>
                      <TableCell>{d.notes ?? '—'}</TableCell>
                      <TableCell><StatusBadge status={d.status} /></TableCell>
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
