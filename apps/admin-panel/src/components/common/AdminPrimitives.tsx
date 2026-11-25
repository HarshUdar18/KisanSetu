import React from 'react';
import {
  Box,
  Card,
  CardContent,
  Chip,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Button,
  Typography,
  Stack,
  Alert,
} from '@mui/material';
import { adminColors } from '../../theme/theme';

export const StatusBadge: React.FC<{ status: string }> = ({ status }) => {
  const s = status.toUpperCase();
  const isSuccess =
    s.includes('ACTIVE') ||
    s.includes('APPROVED') ||
    s.includes('COMPLETED') ||
    s.includes('PAID') ||
    s.includes('DELIVERED') ||
    s.includes('VERIFIED') ||
    s.includes('OPTIMAL') ||
    s.includes('OPERATIONAL') ||
    s.includes('GRADE A');
  const isError =
    s.includes('REJECT') ||
    s.includes('BLOCK') ||
    s.includes('FAIL') ||
    s.includes('DISPUTE') ||
    s.includes('HIGH') ||
    s.includes('SPIKE') ||
    s.includes('CANCEL');

  return (
    <Chip
      size="small"
      label={status.replaceAll('_', ' ')}
      sx={{
        bgcolor: isSuccess
          ? adminColors.secondaryContainer
          : isError
          ? adminColors.errorContainer
          : adminColors.tertiaryFixed,
        color: isSuccess
          ? adminColors.onSecondaryContainer
          : isError
          ? adminColors.onErrorContainer
          : adminColors.onTertiaryFixed,
        fontWeight: 700,
        fontSize: '0.7rem',
      }}
    />
  );
};

export const KpiCard: React.FC<{
  title: string;
  value: string | number;
  subtitle?: string;
  badge?: string;
  icon?: React.ReactNode;
}> = ({ title, value, subtitle, badge, icon }) => (
  <Card sx={{ height: '100%' }}>
    <CardContent sx={{ p: 2.25 }}>
      <Stack direction="row" sx={{ mb: 1, justifyContent: "space-between", alignItems: "flex-start" }}>
        <Typography
          variant="caption"
          sx={{ fontWeight: 700, color: adminColors.outline, letterSpacing: '0.05em', textTransform: 'uppercase' }}
        >
          {title}
        </Typography>
        {icon && (
          <Box
            sx={{
              p: 0.75,
              borderRadius: 2,
              bgcolor: adminColors.surfaceContainer,
              color: adminColors.primary,
              display: 'flex',
            }}
          >
            {icon}
          </Box>
        )}
      </Stack>
      <Typography variant="h4" sx={{ color: adminColors.onSurface, mb: 0.5 }}>
        {value}
      </Typography>
      <Stack direction="row" spacing={1} sx={{ alignItems: "center", flexWrap: "wrap" }}>
        {badge && (
          <Chip
            size="small"
            label={badge}
            sx={{
              height: 20,
              fontSize: '0.68rem',
              bgcolor: adminColors.secondaryContainer,
              color: adminColors.onSecondaryContainer,
            }}
          />
        )}
        {subtitle && (
          <Typography variant="body2" sx={{ fontSize: '0.75rem' }}>
            {subtitle}
          </Typography>
        )}
      </Stack>
    </CardContent>
  </Card>
);

export const DataSourceBanner: React.FC<{ isLive: boolean; label: string }> = ({ isLive, label }) => (
  <Alert
    severity={isLive ? 'success' : 'info'}
    sx={{ mb: 2, borderRadius: 2, py: 0.25 }}
  >
    {isLive
      ? `Connected to Live Spring Boot API (${label})`
      : `Offline / Prototype Fallback Active (${label}) — isolated mock dataset shown.`}
  </Alert>
);

export const ConfirmActionDialog: React.FC<{
  open: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  destructive?: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}> = ({ open, title, message, confirmLabel = 'Confirm', destructive = false, onCancel, onConfirm }) => (
  <Dialog open={open} onClose={onCancel} maxWidth="xs" fullWidth>
    <DialogTitle sx={{ fontWeight: 700 }}>{title}</DialogTitle>
    <DialogContent>
      <Typography variant="body1">{message}</Typography>
    </DialogContent>
    <DialogActions sx={{ p: 2 }}>
      <Button onClick={onCancel}>Cancel</Button>
      <Button
        variant="contained"
        color={destructive ? 'error' : 'primary'}
        onClick={onConfirm}
      >
        {confirmLabel}
      </Button>
    </DialogActions>
  </Dialog>
);
