import { createTheme } from '@mui/material/styles';

export const adminColors = {
  primary: '#005128',
  primaryContainer: '#146B3A',
  onPrimary: '#FFFFFF',
  onPrimaryContainer: '#97E9AB',
  secondary: '#006D36',
  secondaryContainer: '#8FF9AA',
  onSecondaryContainer: '#00743A',
  tertiary: '#584200',
  tertiaryFixed: '#FFDF95',
  tertiaryFixedDim: '#F4BF1B',
  harvestGold: '#FFC928',
  onTertiaryFixed: '#251A00',
  surface: '#F2FCF2',
  surfaceLowest: '#FFFFFF',
  surfaceLow: '#ECF6EC',
  surfaceContainer: '#E6F1E7',
  surfaceHigh: '#E1EBE1',
  surfaceHighest: '#DBE5DB',
  onSurface: '#151E18',
  onSurfaceVariant: '#3F4940',
  outline: '#6F7A70',
  outlineVariant: '#BFC9BE',
  cardBorder: '#E5ECE6',
  error: '#BA1A1A',
  errorContainer: '#FFDAD6',
  onErrorContainer: '#93000A',
  success: '#25834A',
};

export const adminTheme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: adminColors.primary,
      light: adminColors.primaryContainer,
      dark: '#00381A',
      contrastText: '#FFFFFF',
    },
    secondary: {
      main: adminColors.secondary,
      light: adminColors.secondaryContainer,
      contrastText: '#FFFFFF',
    },
    error: {
      main: adminColors.error,
      light: adminColors.errorContainer,
    },
    warning: {
      main: adminColors.tertiaryFixedDim,
      light: adminColors.tertiaryFixed,
    },
    background: {
      default: adminColors.surface,
      paper: adminColors.surfaceLowest,
    },
    text: {
      primary: adminColors.onSurface,
      secondary: adminColors.onSurfaceVariant,
    },
    divider: adminColors.cardBorder,
  },
  typography: {
    fontFamily: '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    h4: { fontWeight: 700, fontSize: '1.65rem', letterSpacing: '-0.01em' },
    h5: { fontWeight: 700, fontSize: '1.35rem' },
    h6: { fontWeight: 600, fontSize: '1.05rem' },
    subtitle1: { fontWeight: 600, fontSize: '0.95rem' },
    body1: { fontSize: '0.875rem' },
    body2: { fontSize: '0.8rem', color: adminColors.onSurfaceVariant },
    button: { textTransform: 'none', fontWeight: 600 },
  },
  shape: {
    borderRadius: 10,
  },
  components: {
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 14,
          border: `1px solid ${adminColors.cardBorder}`,
          boxShadow: '0 2px 6px rgba(20, 40, 25, 0.04)',
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          minHeight: 38,
          boxShadow: 'none',
        },
        contained: {
          backgroundColor: adminColors.primaryContainer,
          '&:hover': {
            backgroundColor: adminColors.primary,
          },
        },
      },
    },
    MuiChip: {
      styleOverrides: {
        root: {
          fontWeight: 600,
          fontSize: '0.75rem',
        },
      },
    },
    MuiTableCell: {
      styleOverrides: {
        head: {
          backgroundColor: adminColors.surfaceLow,
          fontWeight: 700,
          fontSize: '0.72rem',
          textTransform: 'uppercase',
          letterSpacing: '0.04em',
          color: adminColors.onSurfaceVariant,
        },
      },
    },
  },
});
