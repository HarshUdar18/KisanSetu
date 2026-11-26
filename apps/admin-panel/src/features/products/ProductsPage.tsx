import React, { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Grid,
  MenuItem,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Typography,
} from '@mui/material';
import { Add } from '@mui/icons-material';
import { DataSourceBanner, StatusBadge } from '../../components/common/AdminPrimitives';
import { adminApi, type CategoryDto, type ProductDto } from '../../services/adminApi';

export const ProductsPage: React.FC = () => {
  const [categories, setCategories] = useState<CategoryDto[]>([]);
  const [products, setProducts] = useState<ProductDto[]>([]);
  const [units, setUnits] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [selectedCat, setSelectedCat] = useState('');

  const [openCat, setOpenCat] = useState(false);
  const [catName, setCatName] = useState('');
  const [catCode, setCatCode] = useState('');

  const [openProd, setOpenProd] = useState(false);
  const [prodCatId, setProdCatId] = useState('');
  const [prodCode, setProdCode] = useState('');
  const [prodName, setProdName] = useState('');
  const [prodMarathi, setProdMarathi] = useState('');
  const [prodUnit, setProdUnit] = useState('kg');
  const [prodPrice, setProdPrice] = useState('');

  const loadAll = async () => {
    const [c, p, u] = await Promise.all([
      adminApi.fetchCategories(),
      adminApi.fetchProducts(),
      adminApi.fetchUnits(),
    ]);
    setCategories(c.data);
    setProducts(p.data);
    setUnits(u.data);
    setIsLive(c.isLive && p.isLive);
    if (!prodCatId && c.data.length > 0) setProdCatId(c.data[0].id);
  };

  useEffect(() => {
    loadAll();
  }, []);

  const handleAddCategory = async () => {
    if (!catName.trim() || !catCode.trim()) return;
    setError('');
    try {
      await adminApi.createCategory({
        name: catName.trim(),
        code: catCode.trim().toUpperCase(),
        displayOrder: categories.length + 1,
      });
      setCatName('');
      setCatCode('');
      setOpenCat(false);
      await loadAll();
    } catch (e: any) {
      setError(e?.response?.data?.message ?? 'Failed to create category.');
    }
  };

  const handleAddProduct = async () => {
    if (!prodCatId || !prodCode.trim() || !prodName.trim()) return;
    setError('');
    try {
      await adminApi.createProduct({
        categoryId: prodCatId,
        productCode: prodCode.trim().toUpperCase(),
        name: prodName.trim(),
        marathiName: prodMarathi.trim() || undefined,
        unit: prodUnit,
        currentPrice: prodPrice ? Number(prodPrice) : 0,
        isPerishable: true,
      });
      setProdCode('');
      setProdName('');
      setProdMarathi('');
      setProdPrice('');
      setOpenProd(false);
      await loadAll();
    } catch (e: any) {
      setError(e?.response?.data?.message ?? 'Failed to create product.');
    }
  };

  const handleToggleStatus = async (p: ProductDto) => {
    try {
      await adminApi.toggleProductStatus(p.id, p.isAvailable === false);
      await loadAll();
    } catch (e: any) {
      setError(e?.response?.data?.message ?? 'Failed to update product status.');
    }
  };

  const filtered = products.filter((p) => {
    const matchesCat = !selectedCat || p.categoryId === selectedCat;
    const q = search.trim().toLowerCase();
    const matchesQ =
      !q ||
      p.name.toLowerCase().includes(q) ||
      (p.productCode ?? '').toLowerCase().includes(q) ||
      (p.marathiName ?? '').toLowerCase().includes(q);
    return matchesCat && matchesQ;
  });

  return (
    <Box>
      <Stack direction="row" sx={{ mb: 2, justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Typography variant="h4">Master Product Catalogue & Taxonomy</Typography>
          <Typography variant="body2">Defines master UUID products, codes & units (separate from Farmer Produce Listings)</Typography>
        </Box>
        <Stack direction="row" spacing={1}>
          <Button variant="outlined" startIcon={<Add />} onClick={() => setOpenCat(true)}>
            Add Category
          </Button>
          <Button variant="contained" startIcon={<Add />} onClick={() => setOpenProd(true)}>
            Add Product
          </Button>
        </Stack>
      </Stack>

      <DataSourceBanner isLive={isLive} label="GET /api/v1/admin/categories, /products & /units" />
      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      <Grid container spacing={2.5}>
        <Grid size={{ xs: 12, md: 4 }}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>Categories ({categories.length})</Typography>
              {categories.length === 0 ? (
                <Alert severity="info">No categories found in PostgreSQL.</Alert>
              ) : (
                <Stack spacing={1}>
                  {categories.map((c) => (
                    <Box
                      key={c.id}
                      onClick={() => setSelectedCat(selectedCat === c.id ? '' : c.id)}
                      sx={{
                        p: 1.25,
                        borderRadius: 2,
                        cursor: 'pointer',
                        bgcolor: selectedCat === c.id ? '#CFE8CF' : '#ECF6EC',
                      }}
                    >
                      <Stack direction="row" sx={{ justifyContent: 'space-between' }}>
                        <Typography variant="subtitle2">{c.name}</Typography>
                        <StatusBadge status={c.code} />
                      </Stack>
                      {c.description && <Typography variant="caption">{c.description}</Typography>}
                    </Box>
                  ))}
                </Stack>
              )}
            </CardContent>
          </Card>
        </Grid>

        <Grid size={{ xs: 12, md: 8 }}>
          <Card>
            <CardContent>
              <Stack direction="row" sx={{ mb: 2, justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography variant="h6">Master Products ({filtered.length})</Typography>
                <TextField
                  size="small"
                  placeholder="Search name, code, Marathi..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                />
              </Stack>
              {filtered.length === 0 ? (
                <Alert severity="info">No matching products found.</Alert>
              ) : (
                <TableContainer>
                  <Table size="small">
                    <TableHead>
                      <TableRow>
                        <TableCell>Code</TableCell>
                        <TableCell>Product Name</TableCell>
                        <TableCell>Category</TableCell>
                        <TableCell>Unit</TableCell>
                        <TableCell>Market Rate</TableCell>
                        <TableCell>Status</TableCell>
                        <TableCell align="right">Action</TableCell>
                      </TableRow>
                    </TableHead>
                    <TableBody>
                      {filtered.map((p) => (
                        <TableRow key={p.id}>
                          <TableCell sx={{ fontFamily: 'monospace', fontSize: 12 }}>{p.productCode ?? '-'}</TableCell>
                          <TableCell sx={{ fontWeight: 600 }}>
                            {p.name} {p.marathiName ? `(${p.marathiName})` : ''}
                          </TableCell>
                          <TableCell>{p.categoryName ?? '-'}</TableCell>
                          <TableCell>{p.unit}</TableCell>
                          <TableCell>₹{p.currentPrice}</TableCell>
                          <TableCell><StatusBadge status={p.isAvailable === false ? 'INACTIVE' : 'ACTIVE'} /></TableCell>
                          <TableCell align="right">
                            <Button size="small" onClick={() => handleToggleStatus(p)}>
                              {p.isAvailable === false ? 'Activate' : 'Deactivate'}
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </TableContainer>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Dialog open={openCat} onClose={() => setOpenCat(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Create Product Category</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField label="Category Name" value={catName} onChange={(e) => setCatName(e.target.value)} fullWidth />
            <TextField label="Category Code (e.g. SPICES)" value={catCode} onChange={(e) => setCatCode(e.target.value)} fullWidth />
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenCat(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleAddCategory}>Create Category</Button>
        </DialogActions>
      </Dialog>

      <Dialog open={openProd} onClose={() => setOpenProd(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Create Master Product</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField select label="Category" value={prodCatId} onChange={(e) => setProdCatId(e.target.value)} fullWidth>
              {categories.map((c) => (
                <MenuItem key={c.id} value={c.id}>{c.name} ({c.code})</MenuItem>
              ))}
            </TextField>
            <TextField label="Product Code (e.g. VEG-CAR-002)" value={prodCode} onChange={(e) => setProdCode(e.target.value)} fullWidth />
            <TextField label="Canonical Name" value={prodName} onChange={(e) => setProdName(e.target.value)} fullWidth />
            <TextField label="Marathi Name (optional)" value={prodMarathi} onChange={(e) => setProdMarathi(e.target.value)} fullWidth />
            <TextField select label="Default Unit" value={prodUnit} onChange={(e) => setProdUnit(e.target.value)} fullWidth>
              {(units.length > 0 ? units : [{ code: 'kg', name: 'Kilogram' }, { code: 'piece', name: 'Piece' }, { code: 'dozen', name: 'Dozen' }, { code: 'bunch', name: 'Bunch' }]).map((u: any) => (
                <MenuItem key={u.code} value={u.code}>{u.name} ({u.code})</MenuItem>
              ))}
            </TextField>
            <TextField label="Initial Market Price (₹)" type="number" value={prodPrice} onChange={(e) => setProdPrice(e.target.value)} fullWidth />
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenProd(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleAddProduct}>Create Product</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
