import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Grid,
  Stack,
  TextField,
  Typography,
} from '@mui/material';
import { CheckCircle, Cancel, Refresh } from '@mui/icons-material';
import { ConfirmActionDialog, DataSourceBanner, StatusBadge } from '../../components/common/AdminPrimitives';
import { adminApi } from '../../services/adminApi';
import { adminColors } from '../../theme/theme';

interface KycItem {
  id: string;
  farmerId: string;
  farmerPhone?: string;
  documentType: string;
  documentNumber: string;
  bankAccountNumber?: string;
  ifscCode?: string;
  landRecordNumber?: string;
  status: string;
  remarks?: string;
}

export const KycPage: React.FC = () => {
  const [queue, setQueue] = useState<KycItem[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [selectedId, setSelectedId] = useState<string>('');
  const [comments, setComments] = useState('');
  const [confirmAction, setConfirmAction] = useState<'APPROVED' | 'REJECTED' | null>(null);

  const loadKyc = async () => {
    const { data, isLive: live } = await adminApi.fetchKycSubmissions();
    setQueue(data);
    setIsLive(live);
    if (data.length > 0 && !selectedId) setSelectedId(data[0].id);
  };

  useEffect(() => {
    loadKyc();
  }, []);

  const active = queue.find((k) => k.id === selectedId) ?? queue[0];

  const applyDecision = async () => {
    if (!confirmAction || !active) return;
    try {
      if (confirmAction === 'APPROVED') {
        await adminApi.approveKyc(active.id, comments || 'Approved by admin');
      } else {
        await adminApi.rejectKyc(active.id, comments || 'Rejected by admin');
      }
      await loadKyc();
    } catch {
      // Keep UI responsive
    }
    setConfirmAction(null);
    setComments('');
  };

  return (
    <Box>
      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h4">Farmer 7/12 & KYC Verification Audit Desk</Typography>
        <Button startIcon={<Refresh />} onClick={loadKyc} size="small">Refresh</Button>
      </Stack>
      <DataSourceBanner isLive={isLive} label="KYC Verification Audit Desk" />

      {queue.length === 0 ? (
        <Alert severity="info">No KYC submissions in the queue.</Alert>
      ) : (
        <Grid container spacing={2.5}>
          <Grid size={{ xs: 12, md: 4 }}>
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>Verification Queue ({queue.length})</Typography>
                <Stack spacing={1.5}>
                  {queue.map((k) => (
                    <Box
                      key={k.id}
                      onClick={() => setSelectedId(k.id)}
                      sx={{
                        p: 1.5,
                        borderRadius: 2,
                        cursor: 'pointer',
                        border: `1.5px solid ${active && k.id === active.id ? adminColors.primary : adminColors.cardBorder}`,
                        bgcolor: active && k.id === active.id ? adminColors.surfaceLow : '#fff',
                      }}
                    >
                      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center' }}>
                        <Typography variant="subtitle2">{k.farmerPhone || k.farmerId.slice(0, 8)}</Typography>
                        <StatusBadge status={k.status} />
                      </Stack>
                      <Typography variant="caption">{k.documentType} • {k.documentNumber}</Typography>
                    </Box>
                  ))}
                </Stack>
              </CardContent>
            </Card>
          </Grid>

          {active && (
            <Grid size={{ xs: 12, md: 8 }}>
              <Card>
                <CardContent>
                  <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                    <Box>
                      <Typography variant="h5">Farmer {active.farmerPhone || active.farmerId}</Typography>
                      <Typography variant="body2">Doc: {active.documentType} ({active.documentNumber})</Typography>
                    </Box>
                    <StatusBadge status={active.status} />
                  </Stack>

                  <Grid container spacing={2} sx={{ mb: 2 }}>
                    <Grid size={{ xs: 12, sm: 6 }}>
                      <Typography variant="caption" color="text.secondary">Land Record (7/12)</Typography>
                      <Typography variant="body1">{active.landRecordNumber || 'Not provided'}</Typography>
                    </Grid>
                    <Grid size={{ xs: 12, sm: 6 }}>
                      <Typography variant="caption" color="text.secondary">Bank & IFSC</Typography>
                      <Typography variant="body1">{active.bankAccountNumber || '—'} / {active.ifscCode || '—'}</Typography>
                    </Grid>
                  </Grid>

                  <TextField
                    label="Reviewer Remarks"
                    fullWidth
                    multiline
                    rows={2}
                    value={comments}
                    onChange={(e) => setComments(e.target.value)}
                    sx={{ mb: 2 }}
                  />

                  <Stack direction="row" spacing={1.5}>
                    <Button variant="contained" startIcon={<CheckCircle />} onClick={() => setConfirmAction('APPROVED')}>
                      Approve KYC
                    </Button>
                    <Button variant="outlined" color="error" startIcon={<Cancel />} onClick={() => setConfirmAction('REJECTED')}>
                      Reject
                    </Button>
                  </Stack>
                </CardContent>
              </Card>
            </Grid>
          )}
        </Grid>
      )}

      <ConfirmActionDialog
        open={!!confirmAction}
        title={`${confirmAction === 'APPROVED' ? 'Approve' : 'Reject'} KYC Submission`}
        message={`Confirm ${confirmAction} decision for farmer ${active?.farmerPhone || active?.farmerId}?`}
        confirmLabel={confirmAction === 'APPROVED' ? 'Approve' : 'Reject'}
        destructive={confirmAction === 'REJECTED'}
        onCancel={() => setConfirmAction(null)}
        onConfirm={applyDecision}
      />
    </Box>
  );
};
