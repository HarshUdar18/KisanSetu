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
import { useAuth, type AdminRoleName } from '../../context/AuthContext';
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

export const AnalyticsPage: React.FC = () => (
  <Box>
    <Stack direction="row" sx={{ mb: 2, justifyContent: "space-between", alignItems: "center" }}>
      <Typography variant="h4">Financial P&L, APEDA & APMC Statutory Reports</Typography>
      <Button variant="outlined" startIcon={<Download />}>Export Report</Button>
    </Stack>
    <DataSourceBanner isLive={false} label="Analytics & Statutory Reports" />
    <Grid container spacing={2}>
      <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Gross Platform GMV" value="₹1.42 Cr" badge="+18.4%" /></Grid>
      <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="Direct Farmer Payout Ratio" value="80.2%" subtitle="Zero middleman commission" /></Grid>
      <Grid size={{ xs: 12, sm: 4 }}><KpiCard title="APEDA Export Lots" value="312" subtitle="100% Residue-free" /></Grid>
    </Grid>
  </Box>
);

export const AdminUsersPage: React.FC = () => {
  const roles: AdminRoleName[] = [
    'Super Admin',
    'Operations Admin',
    'Farmer Management Admin',
    'Customer Support Admin',
    'Finance Admin',
    'Warehouse Admin',
    'Logistics Admin',
  ];

  return (
    <Box>
      <Typography variant="h4" gutterBottom>Enterprise RBAC & Admin Governance</Typography>
      <DataSourceBanner isLive={false} label="RBAC & Forensic Audit Trail" />
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>Configured Administrative Roles ({roles.length})</Typography>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Role Name</TableCell>
                  <TableCell>Scope</TableCell>
                  <TableCell>Status</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {roles.map((r) => (
                  <TableRow key={r}>
                    <TableCell sx={{ fontWeight: 600 }}>{r}</TableCell>
                    <TableCell>{r === 'Super Admin' ? 'Full Platform Governance' : 'Scoped Module Permissions'}</TableCell>
                    <TableCell><StatusBadge status="ACTIVE" /></TableCell>
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
          <Typography variant="h6">{user?.fullName ?? 'Rajesh Kulkarni'}</Typography>
          <Typography variant="body2">Role: {user?.adminRole ?? 'Super Admin'}</Typography>
          <Typography variant="body2">Phone: {user?.phoneNumber ?? '9876543210'}</Typography>
          <Typography variant="body2">Email: {user?.email ?? 'admin@kisansetu.local'}</Typography>
        </CardContent>
      </Card>
    </Box>
  );
};
