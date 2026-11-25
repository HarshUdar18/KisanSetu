import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Grid,
  LinearProgress,
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

export const CollectionsPage: React.FC = () => {
  const [rows, setRows] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchCollections();
    setRows(data);
    setIsLive(live);
  };

  useEffect(() => { load(); }, []);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Collection Point Operations & Intake Gate Pass</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Collection Management" />
      <Card>
        <CardContent>
          {rows.length === 0 ? (
            <Alert severity="info">No scheduled collections found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Gate Pass</TableCell>
                    <TableCell>Collection Point</TableCell>
                    <TableCell>Quantity (kg)</TableCell>
                    <TableCell>Scheduled Date</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {rows.map((c) => (
                    <TableRow key={c.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{c.gatePassCode || c.id.slice(0, 8)}</TableCell>
                      <TableCell>{c.collectionPoint}</TableCell>
                      <TableCell>{c.quantityKg} kg</TableCell>
                      <TableCell>{c.scheduledDate}</TableCell>
                      <TableCell><StatusBadge status={c.status} /></TableCell>
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

export const QualityPage: React.FC = () => {
  const [rows, setRows] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchQualityInspections();
    setRows(data);
    setIsLive(live);
  };

  useEffect(() => { load(); }, []);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Quality Inspection & Grading Records</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Quality Inspection" />
      <Card>
        <CardContent>
          {rows.length === 0 ? (
            <Alert severity="info">No quality inspection records found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Inspection ID</TableCell>
                    <TableCell>Grade</TableCell>
                    <TableCell>Accepted (kg)</TableCell>
                    <TableCell>Rejected (kg)</TableCell>
                    <TableCell>Notes</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {rows.map((q) => (
                    <TableRow key={q.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{q.id.slice(0, 8)}</TableCell>
                      <TableCell>{q.grade}</TableCell>
                      <TableCell>{q.acceptedKg} kg</TableCell>
                      <TableCell>{q.rejectedKg} kg</TableCell>
                      <TableCell>{q.inspectorNotes ?? '—'}</TableCell>
                      <TableCell><StatusBadge status={q.status} /></TableCell>
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

export const WarehousesPage: React.FC = () => {
  const [rows, setRows] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchWarehouses();
    setRows(data);
    setIsLive(live);
  };

  useEffect(() => { load(); }, []);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Cold-Chain Hubs & Warehouses</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Warehouse Management" />
      {rows.length === 0 ? (
        <Alert severity="info">No warehouses configured.</Alert>
      ) : (
        <Grid container spacing={2}>
          {rows.map((w) => {
            const pct = w.capacityTons > 0 ? Math.min(100, Math.round((w.usedTons / w.capacityTons) * 100)) : 0;
            return (
              <Grid key={w.id} size={{ xs: 12, md: 6 }}>
                <Card>
                  <CardContent>
                    <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                      <Typography variant="h6">{w.name}</Typography>
                      <StatusBadge status={w.status} />
                    </Stack>
                    <Typography variant="body2" color="text.secondary" sx={{ mb: 1.5 }}>
                      {w.code} • {w.location}
                    </Typography>
                    <LinearProgress variant="determinate" value={pct} sx={{ height: 8, borderRadius: 4, mb: 1 }} />
                    <Typography variant="caption">{w.usedTons} / {w.capacityTons} Tons ({pct}% utilized)</Typography>
                  </CardContent>
                </Card>
              </Grid>
            );
          })}
        </Grid>
      )}
    </Box>
  );
};

export const InventoryPage: React.FC = () => {
  const [rows, setRows] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchInventory();
    setRows(data);
    setIsLive(live);
  };

  useEffect(() => { load(); }, []);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Central Inventory & Stock Reservations</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Inventory Ledger" />
      <Grid container spacing={2} sx={{ mb: 2 }}>
        <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Tracked SKUs" value={String(rows.length)} /></Grid>
        <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Available (kg)" value={String(rows.reduce((s, r) => s + Number(r.availableKg ?? 0), 0))} /></Grid>
        <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Reserved (kg)" value={String(rows.reduce((s, r) => s + Number(r.reservedKg ?? 0), 0))} /></Grid>
      </Grid>
      <Card>
        <CardContent>
          {rows.length === 0 ? (
            <Alert severity="info">No inventory stock records found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Product ID</TableCell>
                    <TableCell>Available (kg)</TableCell>
                    <TableCell>Reserved (kg)</TableCell>
                    <TableCell>Reorder Level (kg)</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {rows.map((i) => (
                    <TableRow key={i.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{i.productId?.slice(0, 8)}</TableCell>
                      <TableCell>{i.availableKg}</TableCell>
                      <TableCell>{i.reservedKg}</TableCell>
                      <TableCell>{i.reorderLevelKg}</TableCell>
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

export const LogisticsPage: React.FC = () => {
  const [rows, setRows] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchShipments();
    setRows(data);
    setIsLive(live);
  };

  useEffect(() => { load(); }, []);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Last-Mile Logistics & Shipments</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Logistics & Dispatch" />
      <Card>
        <CardContent>
          {rows.length === 0 ? (
            <Alert severity="info">No active shipments assigned.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Shipment ID</TableCell>
                    <TableCell>Partner</TableCell>
                    <TableCell>Vehicle</TableCell>
                    <TableCell>Origin Hub</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {rows.map((s) => (
                    <TableRow key={s.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{s.id.slice(0, 8)}</TableCell>
                      <TableCell>{s.deliveryPartnerName ?? '—'}</TableCell>
                      <TableCell>{s.vehicleNumber ?? '—'}</TableCell>
                      <TableCell>{s.originHub ?? '—'}</TableCell>
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
