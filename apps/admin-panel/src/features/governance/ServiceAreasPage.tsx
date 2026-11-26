import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  MenuItem,
  Stack,
  Switch,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Typography,
} from '@mui/material';
import { AddLocationAlt, Refresh } from '@mui/icons-material';
import { apiClient } from '../../api/client';
import { DataSourceBanner, StatusBadge } from '../../components/common/AdminPrimitives';

interface ServiceAreaRow {
  localityId: string;
  localityCode: string;
  localityName: string;
  zoneName: string;
  localityStatus: string;
  hasActiveBoundary: boolean;
  activeBoundaryVersion?: number;
  boundarySource?: string;
  capabilities: {
    customerDeliveryEnabled: boolean;
    farmCollectionEnabled: boolean;
    pincodeFallbackCustomerEnabled: boolean;
    pincodeFallbackFarmerEnabled: boolean;
    ruleStatus: string;
  };
}

interface PincodeRow {
  pincodeId: string;
  pinCode: string;
  stateName: string;
  districtName: string;
  postalLocalityName: string;
  localityId?: string;
  localityName?: string;
  serviceabilityStatus: string;
  customerDeliveryEnabled: boolean;
  farmerCollectionEnabled: boolean;
  dataSource?: string;
  verificationStatus: string;
}

export const ServiceAreasPage: React.FC = () => {
  const [areas, setAreas] = useState<ServiceAreaRow[]>([]);
  const [pincodes, setPincodes] = useState<PincodeRow[]>([]);
  const [auditLogs, setAuditLogs] = useState<any[]>([]);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [isLive, setIsLive] = useState(false);

  const [importOpen, setImportOpen] = useState(false);
  const [pinForm, setPinForm] = useState({
    pinCode: '',
    postalLocalityName: '',
    localityId: '',
    dataSource: 'India Post Postal PIN Code API',
    sourceUrl: 'https://api.postalpincode.in/pincode/',
    customerDeliveryEnabled: true,
    farmerCollectionEnabled: true,
  });

  const loadAll = async () => {
    setError('');
    try {
      const [areasRes, pinsRes, auditRes] = await Promise.all([
        apiClient.get('/service-areas'),
        apiClient.get('/admin/super/geofences/pincodes').catch(() => ({ data: { data: [] } })),
        apiClient.get('/admin/super/geofences/audit').catch(() => ({ data: { data: [] } })),
      ]);
      setAreas(areasRes.data?.data ?? []);
      setPincodes(pinsRes.data?.data ?? []);
      setAuditLogs(auditRes.data?.data ?? []);
      setIsLive(true);
    } catch {
      setError('Unable to load serviceability data. Ensure you are signed in as Super Admin.');
      setIsLive(false);
    }
  };

  useEffect(() => {
    loadAll();
  }, []);

  const handleToggleRule = async (
    row: ServiceAreaRow,
    patch: Partial<ServiceAreaRow['capabilities']>,
  ) => {
    setError('');
    setNotice('');
    try {
      await apiClient.put(`/admin/super/geofences/localities/${row.localityId}/rules`, {
        customerDeliveryEnabled:
          patch.customerDeliveryEnabled ?? row.capabilities.customerDeliveryEnabled,
        collectionEnabled:
          patch.farmCollectionEnabled ?? row.capabilities.farmCollectionEnabled,
        pincodeFallbackCustomerEnabled:
          patch.pincodeFallbackCustomerEnabled ??
          row.capabilities.pincodeFallbackCustomerEnabled,
        pincodeFallbackFarmerEnabled:
          patch.pincodeFallbackFarmerEnabled ??
          row.capabilities.pincodeFallbackFarmerEnabled,
        status: 'ACTIVE',
        reason: 'Updated via Super Admin Serviceability Console',
      });
      setNotice(`Updated rules for ${row.localityName}.`);
      await loadAll();
    } catch {
      setError(`Failed to update ${row.localityName}. Super Admin role is required.`);
    }
  };

  const handleReviewPincode = async (
    pin: PincodeRow,
    verificationStatus: string,
    serviceabilityStatus: string,
  ) => {
    setError('');
    setNotice('');
    try {
      await apiClient.post(`/admin/super/geofences/pincodes/${pin.pincodeId}/review`, {
        verificationStatus,
        serviceabilityStatus,
        reason: `Super Admin set ${verificationStatus}/${serviceabilityStatus}`,
      });
      setNotice(`Updated PIN ${pin.pinCode} (${pin.postalLocalityName}).`);
      await loadAll();
    } catch {
      setError('Failed to review PIN-code mapping. Super Admin role is required.');
    }
  };

  const handleImportPincode = async () => {
    setError('');
    setNotice('');
    try {
      await apiClient.post('/admin/super/geofences/pincodes/import', {
        ...pinForm,
        stateName: 'Maharashtra',
        districtName: 'Pune',
        localityId: pinForm.localityId || null,
      });
      setImportOpen(false);
      setNotice(`Imported PIN ${pinForm.pinCode} as PENDING/UNVERIFIED.`);
      await loadAll();
    } catch {
      setError('Failed to import PIN-code mapping.');
    }
  };

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="h4">Service Area & PIN-Code Management</Typography>
        <Stack direction="row" spacing={1}>
          <Button variant="outlined" startIcon={<Refresh />} onClick={loadAll}>
            Refresh
          </Button>
          <Button
            variant="contained"
            startIcon={<AddLocationAlt />}
            onClick={() => setImportOpen(true)}
          >
            Import PIN Code
          </Button>
        </Stack>
      </Stack>

      <DataSourceBanner
        isLive={isLive}
        label="PostGIS Geofence & India Post PIN-Code Double Verification"
      />
      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}
      {notice && (
        <Alert severity="success" sx={{ mb: 2 }}>
          {notice}
        </Alert>
      )}

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Pilot Localities — Boundary, PIN-Code Fallback & Capabilities
          </Typography>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Locality</TableCell>
                  <TableCell>Boundary</TableCell>
                  <TableCell>PIN Code(s)</TableCell>
                  <TableCell>Customer Delivery</TableCell>
                  <TableCell>Customer Fallback</TableCell>
                  <TableCell>Farmer Collection</TableCell>
                  <TableCell>Farmer Fallback</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {areas.map((a) => {
                  const locPins = pincodes.filter((p) => p.localityId === a.localityId);
                  return (
                    <TableRow key={a.localityId}>
                      <TableCell>
                        <Typography sx={{ fontWeight: 700 }}>{a.localityName}</Typography>
                        <Typography variant="caption" color="text.secondary">
                          {a.zoneName}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <StatusBadge
                          status={a.hasActiveBoundary ? 'ACTIVE' : 'NO_POLYGON'}
                        />
                      </TableCell>
                      <TableCell>
                        {locPins.length === 0 ? (
                          <Chip size="small" label="None" />
                        ) : (
                          <Stack direction="row" spacing={0.5} sx={{ flexWrap: 'wrap', gap: 0.5 }}>
                            {locPins.map((p) => (
                              <Chip
                                key={p.pincodeId}
                                size="small"
                                label={`${p.pinCode} (${p.serviceabilityStatus})`}
                                color={
                                  p.serviceabilityStatus === 'APPROVED'
                                    ? 'success'
                                    : 'default'
                                }
                              />
                            ))}
                          </Stack>
                        )}
                      </TableCell>
                      <TableCell>
                        <Switch
                          checked={a.capabilities.customerDeliveryEnabled}
                          onChange={(e) =>
                            handleToggleRule(a, {
                              customerDeliveryEnabled: e.target.checked,
                            })
                          }
                        />
                      </TableCell>
                      <TableCell>
                        <Switch
                          checked={a.capabilities.pincodeFallbackCustomerEnabled}
                          onChange={(e) =>
                            handleToggleRule(a, {
                              pincodeFallbackCustomerEnabled: e.target.checked,
                            })
                          }
                        />
                      </TableCell>
                      <TableCell>
                        <Switch
                          checked={a.capabilities.farmCollectionEnabled}
                          onChange={(e) =>
                            handleToggleRule(a, {
                              farmCollectionEnabled: e.target.checked,
                            })
                          }
                        />
                      </TableCell>
                      <TableCell>
                        <Switch
                          checked={a.capabilities.pincodeFallbackFarmerEnabled}
                          onChange={(e) =>
                            handleToggleRule(a, {
                              pincodeFallbackFarmerEnabled: e.target.checked,
                            })
                          }
                        />
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            PIN-Code Master Data & Provenance
          </Typography>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>PIN Code</TableCell>
                  <TableCell>Postal Locality</TableCell>
                  <TableCell>Mapped Locality</TableCell>
                  <TableCell>Source</TableCell>
                  <TableCell>Verification</TableCell>
                  <TableCell>Approval</TableCell>
                  <TableCell>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {pincodes.map((p) => (
                  <TableRow key={p.pincodeId}>
                    <TableCell>{p.pinCode}</TableCell>
                    <TableCell>{p.postalLocalityName}</TableCell>
                    <TableCell>{p.localityName ?? 'Unmapped'}</TableCell>
                    <TableCell>{p.dataSource ?? '—'}</TableCell>
                    <TableCell>
                      <StatusBadge status={p.verificationStatus} />
                    </TableCell>
                    <TableCell>
                      <StatusBadge status={p.serviceabilityStatus} />
                    </TableCell>
                    <TableCell>
                      <Stack direction="row" spacing={1}>
                        <Button
                          size="small"
                          variant="outlined"
                          color="success"
                          onClick={() =>
                            handleReviewPincode(p, 'VERIFIED', 'APPROVED')
                          }
                        >
                          Approve
                        </Button>
                        <Button
                          size="small"
                          variant="outlined"
                          color="error"
                          onClick={() =>
                            handleReviewPincode(p, 'REJECTED', 'REJECTED')
                          }
                        >
                          Reject
                        </Button>
                      </Stack>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>

      {auditLogs.length > 0 && (
        <Card>
          <CardContent>
            <Typography variant="h6" gutterBottom>
              Recent Serviceability Audit Logs
            </Typography>
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Action</TableCell>
                    <TableCell>Previous</TableCell>
                    <TableCell>New</TableCell>
                    <TableCell>Reason</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {auditLogs.slice(0, 10).map((log) => (
                    <TableRow key={log.audit_id}>
                      <TableCell>{log.action}</TableCell>
                      <TableCell>{log.previous_state ?? '—'}</TableCell>
                      <TableCell>{log.new_state ?? '—'}</TableCell>
                      <TableCell>{log.reason ?? '—'}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      )}

      <Dialog open={importOpen} onClose={() => setImportOpen(false)} fullWidth maxWidth="sm">
        <DialogTitle>Import Verified PIN-Code Mapping</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField
              label="6-Digit PIN Code"
              value={pinForm.pinCode}
              onChange={(e) => setPinForm({ ...pinForm, pinCode: e.target.value })}
            />
            <TextField
              label="Postal Locality / Post Office Name"
              value={pinForm.postalLocalityName}
              onChange={(e) =>
                setPinForm({ ...pinForm, postalLocalityName: e.target.value })
              }
            />
            <TextField
              select
              label="Operational Locality"
              value={pinForm.localityId}
              onChange={(e) =>
                setPinForm({ ...pinForm, localityId: e.target.value })
              }
            >
              {areas.map((a) => (
                <MenuItem key={a.localityId} value={a.localityId}>
                  {a.localityName} ({a.zoneName})
                </MenuItem>
              ))}
            </TextField>
            <TextField
              label="Data Source"
              value={pinForm.dataSource}
              onChange={(e) =>
                setPinForm({ ...pinForm, dataSource: e.target.value })
              }
            />
            <TextField
              label="Source URL"
              value={pinForm.sourceUrl}
              onChange={(e) =>
                setPinForm({ ...pinForm, sourceUrl: e.target.value })
              }
            />
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setImportOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleImportPincode}>
            Import
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
