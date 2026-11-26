import React, { useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  Grid,
  InputAdornment,
  Link,
  Stack,
  TextField,
  ToggleButton,
  ToggleButtonGroup,
  Typography,
} from '@mui/material';
import {
  Lock,
  Security,
  VerifiedUser,
  ArrowForward,
  Phone,
  Email,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { useAuth, type AdminRoleName } from '../../context/AuthContext';
import { adminApi } from '../../services/adminApi';
import { adminColors } from '../../theme/theme';

export const AdminLoginPage: React.FC = () => {
  const [realm, setRealm] = useState<AdminRoleName>('Super Admin');
  const [authMode, setAuthMode] = useState<'password' | 'otp'>('password');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [otp, setOtp] = useState('');
  const [otpSent, setOtpSent] = useState(false);
  const [developmentOtp, setDevelopmentOtp] = useState<string | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const { login } = useAuth();
  const navigate = useNavigate();

  const handleRequestOtp = async () => {
    setError('');
    setDevelopmentOtp(null);
    setLoading(true);
    try {
      const res = await adminApi.sendOtp(phone.trim());
      setOtpSent(true);
      setDevelopmentOtp(res?.developmentOtp ?? null);
    } catch (err: any) {
      setError(err?.response?.data?.message || 'Unable to dispatch OTP. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = authMode === 'otp'
        ? await adminApi.verifyOtp(phone.trim(), otp.trim())
        : await adminApi.login(phone.trim(), password);
      const data = res?.data ?? res;
      const roles: string[] = data?.roles ?? data?.user?.roles ?? [];
      if (!roles.includes('ROLE_ADMIN') && !roles.includes('ROLE_SUPER_ADMIN')) {
        setError('Access denied: Account does not hold ROLE_ADMIN or ROLE_SUPER_ADMIN.');
        setLoading(false);
        return;
      }
      const isSuper = roles.includes('ROLE_SUPER_ADMIN');
      login(data.token, {
        id: data.user?.id ?? data.userId ?? '',
        phoneNumber: phone.trim(),
        email: data.user?.email ?? '',
        fullName: data.user?.fullName ?? (isSuper ? 'Super Admin' : 'Admin'),
        roles,
        adminRole: isSuper ? 'Super Admin' : realm,
      });
      navigate('/dashboard');
    } catch (err: any) {
      if (!err?.response) {
        setError('Unable to reach backend server at http://localhost:8080/api/v1. Please start the Spring Boot backend.');
      } else {
        setError(err.response?.data?.message || 'Invalid administrator credentials.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        bgcolor: adminColors.surface,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        p: { xs: 2, md: 4 },
      }}
    >
      <Box sx={{ maxWidth: 1040, width: '100%', mx: 'auto' }}>
        <Stack direction="row" sx={{ mb: 2, justifyContent: "space-between", alignItems: "center" }}>
          <Stack direction="row" spacing={1.5} sx={{ alignItems: "center" }}>
            <Box
              sx={{
                width: 36,
                height: 36,
                borderRadius: 2,
                bgcolor: adminColors.primary,
                color: adminColors.harvestGold,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 800,
              }}
            >
              KS
            </Box>
            <Typography variant="h6">Kisan Setu Enterprise Portal</Typography>
            <Chip
              size="small"
              label="256-Bit SSL Encrypted"
              sx={{ bgcolor: adminColors.secondaryContainer, color: adminColors.onSecondaryContainer }}
            />
          </Stack>
          <Chip size="small" icon={<Security fontSize="small" />} label="SECURE ACCESS GATEWAY" />
        </Stack>

        <Grid container spacing={3}>
          <Grid size={{ xs: 12, md: 7 }}>
            <Card sx={{ p: { xs: 2, md: 3 } }}>
              <CardContent>
                <Stack direction="row" sx={{ mb: 2, justifyContent: "space-between", alignItems: "center" }}>
                  <Box>
                    <Typography variant="h5">Enterprise Management Portal</Typography>
                    <Typography variant="body2">GOV-TIER 2 • Restricted Administrative Access</Typography>
                  </Box>
                  <Chip
                    size="small"
                    label="RESTRICTED ACCESS"
                    sx={{ bgcolor: adminColors.errorContainer, color: adminColors.onErrorContainer }}
                  />
                </Stack>

                <Typography variant="caption" sx={{ fontWeight: 700, color: adminColors.outline }}>
                  SELECT OPERATIONAL REALM
                </Typography>
                <ToggleButtonGroup
                  exclusive
                  fullWidth
                  size="small"
                  value={realm}
                  onChange={(_, v) => v && setRealm(v)}
                  sx={{ mt: 1, mb: 2.5 }}
                >
                  <ToggleButton value="Super Admin">HQ / Super Admin</ToggleButton>
                  <ToggleButton value="Operations Admin">Hub Ops & QC</ToggleButton>
                  <ToggleButton value="Finance Admin">Finance & Escrow</ToggleButton>
                </ToggleButtonGroup>

                {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

                <ToggleButtonGroup
                  exclusive
                  fullWidth
                  size="small"
                  value={authMode}
                  onChange={(_, v) => {
                    if (v) {
                      setAuthMode(v);
                      setError('');
                    }
                  }}
                  sx={{ mb: 2 }}
                >
                  <ToggleButton value="password">Password Login</ToggleButton>
                  <ToggleButton value="otp">OTP Verification</ToggleButton>
                </ToggleButtonGroup>

                <Box component="form" onSubmit={handleSubmit}>
                  <TextField
                    fullWidth
                    label="Admin Phone / Identity"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    sx={{ mb: 2 }}
                    slotProps={{ input: {
                      startAdornment: (
                        <InputAdornment position="start">
                          <Phone fontSize="small" />
                        </InputAdornment>
                      ),
                    } }}
                  />
                  {authMode === 'password' ? (
                    <TextField
                      fullWidth
                      type="password"
                      label="Master Password"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      sx={{ mb: 1.5 }}
                      slotProps={{ input: {
                        startAdornment: (
                          <InputAdornment position="start">
                            <Lock fontSize="small" />
                          </InputAdornment>
                        ),
                      } }}
                    />
                  ) : (
                    <Box sx={{ mb: 2 }}>
                      <Stack direction="row" spacing={1} sx={{ mb: 1.5 }}>
                        <Button variant="outlined" onClick={handleRequestOtp} disabled={loading}>
                          {otpSent ? 'Resend OTP' : 'Send OTP'}
                        </Button>
                      </Stack>
                      {developmentOtp && (
                        <Alert
                          severity="info"
                          sx={{ mb: 1.5 }}
                          action={
                            <Button color="inherit" size="small" onClick={() => setOtp(developmentOtp)}>
                              Autofill
                            </Button>
                          }
                        >
                          Your Development OTP: <strong>{developmentOtp}</strong>
                        </Alert>
                      )}
                      <TextField
                        fullWidth
                        label="6-Digit OTP"
                        value={otp}
                        onChange={(e) => setOtp(e.target.value)}
                        slotProps={{ htmlInput: { maxLength: 6 } }}
                      />
                    </Box>
                  )}
                  <Stack direction="row" sx={{ mb: 2.5, justifyContent: "space-between", alignItems: "center" }}>
                    <Link component="button" type="button" variant="body2" onClick={() => navigate('/2fa')}>
                      2FA / TOTP Verification
                    </Link>
                    <Link component="button" type="button" variant="body2" onClick={() => navigate('/forgot-password')}>
                      Forgot Password?
                    </Link>
                  </Stack>

                  <Button
                    type="submit"
                    fullWidth
                    size="large"
                    variant="contained"
                    disabled={loading}
                    endIcon={<ArrowForward />}
                  >
                    {loading ? 'Authenticating...' : 'Authenticate to Secure Console'}
                  </Button>
                </Box>
              </CardContent>
            </Card>
          </Grid>

          <Grid size={{ xs: 12, md: 5 }}>
            <Stack spacing={2}>
              <Card>
                <CardContent>
                  <Stack direction="row" sx={{ mb: 1, justifyContent: "space-between", alignItems: "center" }}>
                    <Typography variant="subtitle2">AUTHENTICATION POLICY</Typography>
                    <Chip size="small" label="RBAC" sx={{ bgcolor: adminColors.secondaryContainer }} />
                  </Stack>
                  <Typography variant="h6">Role-Scoped Access</Typography>
                  <Typography variant="body2">Sign in with an authorized Admin or Super Admin account provisioned on the backend.</Typography>
                </CardContent>
              </Card>
              <Card>
                <CardContent>
                  <Typography variant="subtitle2" gutterBottom>Audit & Security</Typography>
                  <Typography variant="body2">All administrative actions, hub assignments, and KYC approvals are logged in PostgreSQL.</Typography>
                </CardContent>
              </Card>
            </Stack>
          </Grid>
        </Grid>
      </Box>
    </Box>
  );
};

export const Admin2FAPage: React.FC = () => {
  const [code, setCode] = useState('123456');
  const navigate = useNavigate();
  return (
    <Box sx={{ minHeight: '100vh', bgcolor: adminColors.surface, display: 'flex', alignItems: 'center', justifyContent: 'center', p: 2 }}>
      <Card sx={{ maxWidth: 420, width: '100%', p: 2 }}>
        <CardContent>
          <VerifiedUser color="primary" sx={{ fontSize: 40, mb: 1 }} />
          <Typography variant="h5" gutterBottom>2FA Multi-Factor Verification</Typography>
          <Typography variant="body2" sx={{ mb: 2 }}>Enter the 6-digit TOTP from your hardware key or authenticator app.</Typography>
          <TextField fullWidth label="6-Digit Code" value={code} onChange={(e) => setCode(e.target.value)} sx={{ mb: 2 }} />
          <Button fullWidth variant="contained" onClick={() => navigate('/dashboard')}>Verify & Enter Console</Button>
        </CardContent>
      </Card>
    </Box>
  );
};

export const AdminForgotPasswordPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);
  const navigate = useNavigate();
  return (
    <Box sx={{ minHeight: '100vh', bgcolor: adminColors.surface, display: 'flex', alignItems: 'center', justifyContent: 'center', p: 2 }}>
      <Card sx={{ maxWidth: 440, width: '100%', p: 2 }}>
        <CardContent>
          <Email color="primary" sx={{ fontSize: 40, mb: 1 }} />
          <Typography variant="h5" gutterBottom>Admin Password Recovery</Typography>
          {sent ? (
            <Alert severity="success" sx={{ mb: 2 }}>Recovery instructions dispatched to {email}.</Alert>
          ) : (
            <TextField fullWidth label="Official Work Email" value={email} onChange={(e) => setEmail(e.target.value)} sx={{ mb: 2 }} />
          )}
          <Stack direction="row" spacing={1}>
            <Button variant="outlined" onClick={() => navigate('/login')}>Back to Login</Button>
            {!sent && <Button variant="contained" onClick={() => email && setSent(true)}>Send Reset Link</Button>}
          </Stack>
        </CardContent>
      </Card>
    </Box>
  );
};

export const AdminSessionLockedPage: React.FC = () => {
  const { unlockSession, logout } = useAuth();
  const navigate = useNavigate();
  return (
    <Box sx={{ minHeight: '100vh', bgcolor: adminColors.surface, display: 'flex', alignItems: 'center', justifyContent: 'center', p: 2 }}>
      <Card sx={{ maxWidth: 420, width: '100%', p: 2, textAlign: 'center' }}>
        <CardContent>
          <Lock color="warning" sx={{ fontSize: 48, mb: 1 }} />
          <Typography variant="h5" gutterBottom>Session Locked</Typography>
          <Typography variant="body2" sx={{ mb: 3 }}>Your workstation has been locked to protect sensitive KYC & Escrow records.</Typography>
          <Stack spacing={1.5}>
            <Button variant="contained" onClick={() => { unlockSession(); navigate('/dashboard'); }}>Resume Session</Button>
            <Button variant="outlined" color="error" onClick={() => { logout(); navigate('/login'); }}>Sign Out</Button>
          </Stack>
        </CardContent>
      </Card>
    </Box>
  );
};

export const UnauthorizedPage: React.FC = () => {
  const navigate = useNavigate();
  return (
    <Box sx={{ p: 4, textAlign: 'center' }}>
      <Typography variant="h4" gutterBottom>403 — Unauthorized Access</Typography>
      <Typography variant="body1" sx={{ mb: 2 }}>Your assigned RBAC role does not grant permission for this module.</Typography>
      <Button variant="contained" onClick={() => navigate('/dashboard')}>Return to Dashboard</Button>
    </Box>
  );
};
