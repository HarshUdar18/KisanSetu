export const config = {
  apiUrl: import.meta.env.VITE_API_URL || 'http://localhost:8080/api/v1',
  appName: 'KisanSetu Admin Portal',
  env: import.meta.env.MODE || 'development',
};
