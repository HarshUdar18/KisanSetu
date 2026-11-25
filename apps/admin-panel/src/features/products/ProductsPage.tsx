import React, { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Card,
  CardContent,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Grid,
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

const FALLBACK_CATEGORIES: CategoryDto[] = [
  { id: 'cat-veg', name: 'Vegetables', code: 'VEG', description: 'Fresh farm vegetables', displayOrder: 1 },
  { id: 'cat-fruit', name: 'Fruits', code: 'FRUIT', description: 'Orchard & vineyard fruits', displayOrder: 2 },
  { id: 'cat-grain', name: 'Grains & Pulses', code: 'GRAIN', description: 'Heirloom rice & dals', displayOrder: 3 },
];

const FALLBACK_PRODUCTS: ProductDto[] = [
  { id: 'prod-1', name: 'Desi Red Onions (कांदा)', categoryName: 'Vegetables', unit: 'kg', currentPrice: 28, previousPrice: 35, isAvailable: true },
  { id: 'prod-2', name: 'Fresh Baby Spinach (पालक)', categoryName: 'Vegetables', unit: '250g', currentPrice: 22, previousPrice: 28, isAvailable: true },
  { id: 'prod-3', name: 'Indrayani Aromatic Rice', categoryName: 'Grains & Pulses', unit: '5 kg', currentPrice: 380, previousPrice: 420, isAvailable: true },
];

export const ProductsPage: React.FC = () => {
  const [categories, setCategories] = useState<CategoryDto[]>(FALLBACK_CATEGORIES);
  const [products, setProducts] = useState<ProductDto[]>(FALLBACK_PRODUCTS);
  const [isLive, setIsLive] = useState(false);
  const [openCat, setOpenCat] = useState(false);
  const [catName, setCatName] = useState('');
  const [catCode, setCatCode] = useState('');

  useEffect(() => {
    Promise.all([adminApi.fetchCategories(), adminApi.fetchProducts()]).then(([c, p]) => {
      if (c.isLive && c.data.length > 0) setCategories(c.data);
      if (p.isLive && p.data.length > 0) setProducts(p.data);
      setIsLive(c.isLive || p.isLive);
    });
  }, []);

  const handleAddCategory = async () => {
    if (!catName.trim() || !catCode.trim()) return;
    try {
      const created = await adminApi.createCategory({
        name: catName.trim(),
        code: catCode.trim().toUpperCase(),
        displayOrder: categories.length + 1,
      });
      if (created) setCategories((prev) => [...prev, created]);
    } catch {
      setCategories((prev) => [
        ...prev,
        { id: `cat-${Date.now()}`, name: catName.trim(), code: catCode.trim().toUpperCase(), displayOrder: prev.length + 1 },
      ]);
    }
    setCatName('');
    setCatCode('');
    setOpenCat(false);
  };

  return (
    <Box>
      <Stack direction="row" sx={{ mb: 2, justifyContent: "space-between", alignItems: "center" }}>
        <Box>
          <Typography variant="h4">Master Product Catalogue & Taxonomy</Typography>
          <Typography variant="body2">Defines master SKUs & APMC price bands (separate from Farmer Produce Listings)</Typography>
        </Box>
        <Button variant="contained" startIcon={<Add />} onClick={() => setOpenCat(true)}>
          Add Category
        </Button>
      </Stack>

      <DataSourceBanner isLive={isLive} label="GET /api/v1/admin/categories & /products" />

      <Grid container spacing={2.5}>
        <Grid size={{ xs: 12, md: 4 }}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>Categories ({categories.length})</Typography>
              <Stack spacing={1}>
                {categories.map((c) => (
                  <Box key={c.id} sx={{ p: 1.25, borderRadius: 2, bgcolor: '#ECF6EC' }}>
                    <Stack direction="row" sx={{ justifyContent: "space-between" }}>
                      <Typography variant="subtitle2">{c.name}</Typography>
                      <StatusBadge status={c.code} />
                    </Stack>
                    {c.description && <Typography variant="caption">{c.description}</Typography>}
                  </Box>
                ))}
              </Stack>
            </CardContent>
          </Card>
        </Grid>

        <Grid size={{ xs: 12, md: 8 }}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>Master SKUs ({products.length})</Typography>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      <TableCell>Product Name</TableCell>
                      <TableCell>Category</TableCell>
                      <TableCell>Unit</TableCell>
                      <TableCell>Market Rate</TableCell>
                      <TableCell>Status</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {products.map((p) => (
                      <TableRow key={p.id}>
                        <TableCell sx={{ fontWeight: 600 }}>{p.name}</TableCell>
                        <TableCell>{p.categoryName ?? 'General'}</TableCell>
                        <TableCell>{p.unit}</TableCell>
                        <TableCell>₹{p.currentPrice}</TableCell>
                        <TableCell><StatusBadge status={p.isAvailable === false ? 'INACTIVE' : 'ACTIVE'} /></TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
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
          <Button variant="contained" onClick={handleAddCategory}>Create</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
