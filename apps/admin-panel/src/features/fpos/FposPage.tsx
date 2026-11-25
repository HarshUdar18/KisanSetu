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

export const FposPage: React.FC = () => {
  const [fpos, setFpos] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const load = async () => {
    const { data, isLive: live } = await adminApi.fetchFpos();
    setFpos(data);
    setIsLive(live);
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">FPO Organizations & Collectives</Typography>
        <Button startIcon={<Refresh />} onClick={load} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="FPO Directory" />

      <Card>
        <CardContent>
          {fpos.length === 0 ? (
            <Alert severity="info">No FPO organizations found.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>FPO Name</TableCell>
                    <TableCell>Reg Number</TableCell>
                    <TableCell>District</TableCell>
                    <TableCell>Members</TableCell>
                    <TableCell>Contact</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {fpos.map((f) => (
                    <TableRow key={f.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{f.name}</TableCell>
                      <TableCell>{f.registrationNumber}</TableCell>
                      <TableCell>{f.district}, {f.state}</TableCell>
                      <TableCell>{f.memberCount}</TableCell>
                      <TableCell>{f.contactPhone ?? '—'}</TableCell>
                      <TableCell><StatusBadge status={f.status} /></TableCell>
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
