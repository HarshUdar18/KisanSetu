import React, { useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Grid,
  MenuItem,
  Stack,
  Switch,
  FormControlLabel,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Typography,
} from '@mui/material';
import { Download, Send } from '@mui/icons-material';
import { DataSourceBanner, KpiCard, StatusBadge } from '../../components/common/AdminPrimitives';
import { useAuth } from '../../context/AuthContext';
import { adminApi } from '../../services/adminApi';
import { apiClient } from '../../api/client';

export const NotificationsPage: React.FC = () => {
  const [audience, setAudience] = useState('All Farmers');
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [sent, setSent] = useState(false);
  const [err, setErr] = useState('');

  const handleSend = async () => {
    setErr('');
    setSent(false);
    try {
      await apiClient.post('/admin/notifications', {
        title: title.trim() || 'Platform Update',
        message: message.trim() || `Broadcast to ${audience}`,
        type: 'ADMIN_BROADCAST',
      });
      setSent(true);
      setTitle('');
      setMessage('');
    } catch {
      setErr('Unable to send notification. Ensure backend is running.');
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>Notification Management</Typography>
      <DataSourceBanner isLive label="Notification Broadcast Center" />
      <Card sx={{ maxWidth: 640 }}>
        <CardContent>
          <Stack spacing={2}>
            <TextField select label="Target Audience" value={audience} onChange={(e) => setAudience(e.target.value)}>
              {['All Customers', 'All Farmers', 'FPO Coordinators', 'Pune Zone'].map((a) => (
                <MenuItem key={a} value={a}>{a}</MenuItem>
              ))}
            </TextField>
            <TextField label="Notification Title" value={title} onChange={(e) => setTitle(e.target.value)} />
            <TextField label="Message Body" multiline rows={3} value={message} onChange={(e) => setMessage(e.target.value)} />
            {err && <Alert severity="error">{err}</Alert>}
            {sent && <Alert severity="success">Notification persisted and queued for {audience}.</Alert>}
            <Button variant="contained" startIcon={<Send />} onClick={handleSend}>
              Send Notification
            </Button>
          </Stack>
        </CardContent>
      </Card>
    </Box>
  );
};

export const SupportPage: React.FC = () => {
  const [tickets, setTickets] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  const loadTickets = async () => {
    const { data, isLive: live } = await adminApi.fetchSupportTickets();
    setTickets(data);
    setIsLive(live);
  };

  React.useEffect(() => {
    loadTickets();
  }, []);

  return (
    <Box>
      <Typography variant="h4" gutterBottom>Support & Complaint Management</Typography>
      <DataSourceBanner isLive={isLive} label="Helpdesk & Redressal" />
      <Card>
        <CardContent>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Ticket ID</TableCell>
                  <TableCell>User</TableCell>
                  <TableCell>Category</TableCell>
                  <TableCell>Subject</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell align="right">Action</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {tickets.map((t) => (
                  <TableRow key={t.id}>
                    <TableCell sx={{ fontWeight: 600 }}>{t.id}</TableCell>
                    <TableCell>{t.user}</TableCell>
                    <TableCell>{t.type}</TableCell>
                    <TableCell>{t.subject}</TableCell>
                    <TableCell><StatusBadge status={t.status} /></TableCell>
                    <TableCell align="right">
                      {t.status !== 'RESOLVED' && (
                        <Button
                          size="small"
                          variant="contained"
                          onClick={() =>
                            setTickets((prev) =>
                              prev.map((x) => (x.id === t.id ? { ...x, status: 'RESOLVED' } : x))
                            )
                          }
                        >
                          Resolve
                        </Button>
                      )}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>
    </Box>
  );
};

export const AnalyticsPage: React.FC = () => {
  const [metrics, setMetrics] = useState<Record<string, number> | null>(null);
  const [isLive, setIsLive] = useState(false);

  React.useEffect(() => {
    adminApi.fetchDashboardAnalytics().then(({ data, isLive: live }) => {
      setMetrics(data);
      setIsLive(live);
    });
  }, []);

  return (
    <Box>
      <Stack direction="row" sx={{ mb: 2, justifyContent: "space-between", alignItems: "center" }}>
        <Typography variant="h4">Financial & Operational Analytics</Typography>
        <Button variant="outlined" startIcon={<Download />} disabled={!isLive}>Export Report</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="Live PostgreSQL Analytics" />
      <Grid container spacing={2}>
        <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Total Revenue" value={`₹${(metrics?.totalRevenue ?? 0).toLocaleString('en-IN')}`} /></Grid>
        <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Pending Settlements" value={`₹${(metrics?.pendingSettlementAmount ?? 0).toLocaleString('en-IN')}`} /></Grid>
        <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Active Produce Listings" value={String(metrics?.activeProduceListings ?? 0)} /></Grid>
      </Grid>
    </Box>
  );
};

export const HubsPage: React.FC = () => {
  const { isSuperAdmin } = useAuth();
  const [hubs, setHubs] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [name, setName] = useState('');
  const [code, setCode] = useState('');
  const [district, setDistrict] = useState('');
  const [pincode, setPincode] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const loadHubs = async () => {
    const { data, isLive: live } = await adminApi.fetchHubs();
    setHubs(data);
    setIsLive(live);
  };

  React.useEffect(() => {
    loadHubs();
  }, []);

  const handleCreateHub = async () => {
    setError('');
    setSuccess('');
    try {
      await adminApi.createHub({ name, code, district, pincode, state: 'Maharashtra' });
      setSuccess(`Hub ${code.toUpperCase()} created and persisted.`);
      setName('');
      setCode('');
      setDistrict('');
      setPincode('');
      await loadHubs();
    } catch (e: any) {
      setError(e?.response?.data?.message ?? 'Failed to create hub.');
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>Operational Hub Management</Typography>
      <DataSourceBanner isLive={isLive} label={isSuperAdmin() ? 'All Platform Hubs (Super Admin)' : 'Assigned Hubs Only'} />
      {isSuperAdmin() && (
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Typography variant="h6" gutterBottom>Create New Hub (Super Admin Only)</Typography>
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} sx={{ mb: 1 }}>
              <TextField label="Hub Name" value={name} onChange={(e) => setName(e.target.value)} size="small" />
              <TextField label="Hub Code (e.g. HUB-PUN-02)" value={code} onChange={(e) => setCode(e.target.value)} size="small" />
              <TextField label="District" value={district} onChange={(e) => setDistrict(e.target.value)} size="small" />
              <TextField label="PIN Code" value={pincode} onChange={(e) => setPincode(e.target.value)} size="small" />
              <Button variant="contained" onClick={handleCreateHub} disabled={!name.trim() || !code.trim()}>
                Create Hub
              </Button>
            </Stack>
            {error && <Alert severity="error" sx={{ mt: 1 }}>{error}</Alert>}
            {success && <Alert severity="success" sx={{ mt: 1 }}>{success}</Alert>}
          </CardContent>
        </Card>
      )}
      <Card>
        <CardContent>
          {hubs.length === 0 ? (
            <Alert severity="info">No hubs found in database.</Alert>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Code</TableCell>
                    <TableCell>Name</TableCell>
                    <TableCell>Type</TableCell>
                    <TableCell>District</TableCell>
                    <TableCell>PIN</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {hubs.map((h) => (
                    <TableRow key={h.id}>
                      <TableCell sx={{ fontWeight: 600 }}>{h.code}</TableCell>
                      <TableCell>{h.name}</TableCell>
                      <TableCell>{h.hubType}</TableCell>
                      <TableCell>{h.district ?? '-'}</TableCell>
                      <TableCell>{h.pincode ?? '-'}</TableCell>
                      <TableCell><StatusBadge status={h.status} /></TableCell>
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

export const AdminUsersPage: React.FC = () => {
  const { isSuperAdmin } = useAuth();
  const [admins, setAdmins] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [fullName, setFullName] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const loadAdmins = async () => {
    const { data, isLive: live } = await adminApi.fetchAdmins();
    setAdmins(data);
    setIsLive(live);
  };

  React.useEffect(() => {
    if (isSuperAdmin()) {
      loadAdmins();
    }
  }, []);

  const handleCreateAdmin = async () => {
    setError('');
    setSuccess('');
    try {
      await adminApi.createAdmin({ phone, email, fullName, password });
      setSuccess(`Admin account created for ${phone}.`);
      setPhone('');
      setEmail('');
      setFullName('');
      setPassword('');
      await loadAdmins();
    } catch (e: any) {
      setError(e?.response?.data?.message ?? 'Failed to create admin account.');
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>Enterprise RBAC & Admin Governance</Typography>
      <DataSourceBanner isLive={isLive} label="Super Admin Account & Role Management" />
      {!isSuperAdmin() ? (
        <Alert severity="warning">Only Super Admin can view or provision Admin accounts.</Alert>
      ) : (
        <>
          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Typography variant="h6" gutterBottom>Provision Regular Admin (Super Admin Only)</Typography>
              <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
                <TextField label="Phone (10 digits)" value={phone} onChange={(e) => setPhone(e.target.value)} size="small" />
                <TextField label="Full Name" value={fullName} onChange={(e) => setFullName(e.target.value)} size="small" />
                <TextField label="Email" value={email} onChange={(e) => setEmail(e.target.value)} size="small" />
                <TextField label="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} size="small" />
                <Button variant="contained" onClick={handleCreateAdmin} disabled={!phone.trim() || !password.trim()}>
                  Create Admin
                </Button>
              </Stack>
              {error && <Alert severity="error" sx={{ mt: 1 }}>{error}</Alert>}
              {success && <Alert severity="success" sx={{ mt: 1 }}>{success}</Alert>}
            </CardContent>
          </Card>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>Persisted Admin Accounts ({admins.length})</Typography>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      <TableCell>Phone</TableCell>
                      <TableCell>Email</TableCell>
                      <TableCell>Roles</TableCell>
                      <TableCell>Status</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {admins.map((a) => (
                      <TableRow key={a.id}>
                        <TableCell sx={{ fontWeight: 600 }}>{a.phone}</TableCell>
                        <TableCell>{a.email ?? '-'}</TableCell>
                        <TableCell>{(a.roles ?? []).join(', ')}</TableCell>
                        <TableCell><StatusBadge status={a.status} /></TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </>
      )}
    </Box>
  );
};

export const SettingsPage: React.FC = () => {
  const [maintenance, setMaintenance] = useState(false);
  return (
    <Box>
      <Typography variant="h4" gutterBottom>System Settings & Compliance Policies</Typography>
      <Card sx={{ maxWidth: 640 }}>
        <CardContent>
          <Stack spacing={2}>
            <Typography variant="h6">Platform Configuration</Typography>
            <TextField label="Platform Name" defaultValue="Kisan Setu (KrishiConnect)" />
            <TextField label="Weekly Settlement Cycle" defaultValue="Every Friday • 11:00 AM IST" />
            <FormControlLabel
              control={<Switch checked={maintenance} onChange={(e) => setMaintenance(e.target.checked)} />}
              label="Maintenance Mode (Restricts non-admin traffic)"
            />
          </Stack>
        </CardContent>
      </Card>
    </Box>
  );
};

export const AdminProfilePage: React.FC = () => {
  const { user } = useAuth();
  return (
    <Box>
      <Typography variant="h4" gutterBottom>Admin Profile & Security</Typography>
      <Card sx={{ maxWidth: 540 }}>
        <CardContent>
          <Typography variant="h6">{user?.fullName ?? 'Authenticated Admin'}</Typography>
          <Typography variant="body2">Roles: {(user?.roles ?? []).join(', ') || user?.adminRole || '-'}</Typography>
          <Typography variant="body2">Phone: {user?.phoneNumber ?? '-'}</Typography>
          <Typography variant="body2">Email: {user?.email ?? '-'}</Typography>
        </CardContent>
      </Card>
    </Box>
  );
};
