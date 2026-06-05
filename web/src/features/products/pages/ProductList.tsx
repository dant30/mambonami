import { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useProducts } from '../../../core/hooks/useProducts';
import { formatCurrency } from '../../../core/utils';
import Badge from '../../../shared/components/ui/Badge';
import Button from '../../../shared/components/ui/Button';
import Card from '../../../shared/components/ui/Card';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../../shared/components/tables/Table';

export default function ProductList() {
  const { products, loading, error, listProducts } = useProducts();

  useEffect(() => {
    listProducts({ page_size: 50 }).catch(() => {});
  }, [listProducts]);

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-slate-900">Products</h1>
          <p className="mt-2 text-sm text-slate-600">Browse, manage, and update the products available for orders.</p>
        </div>
        <div className="flex flex-wrap items-center gap-3">
          <Link
            to="create"
            className="inline-flex items-center rounded-full bg-emerald-600 px-4 py-2 text-sm font-semibold text-white shadow-soft transition hover:bg-emerald-700"
          >
            Create product
          </Link>
          <Button type="button" variant="secondary" className="rounded-full" onClick={() => listProducts({ page_size: 50 }).catch(() => {})}>
            Refresh
          </Button>
        </div>
      </div>

      {error ? (
        <div className="rounded-3xl border border-red-200 bg-red-50 px-4 py-4 text-sm text-red-700 shadow-soft">
          {error}
        </div>
      ) : null}

      <Card className="overflow-hidden p-0">
        <Table className="min-w-full text-left text-sm text-slate-700">
          <TableHeader className="bg-slate-50 text-slate-900">
            <TableRow>
              <TableHead className="px-4 py-4">Product</TableHead>
              <TableHead className="px-4 py-4">Price</TableHead>
              <TableHead className="px-4 py-4">Stock</TableHead>
              <TableHead className="px-4 py-4">Status</TableHead>
              <TableHead className="px-4 py-4">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={5} className="px-4 py-8 text-center text-slate-500">
                  Loading products...
                </TableCell>
              </TableRow>
            ) : products.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} className="px-4 py-8 text-center text-slate-500">
                  No products available. Create a product to get started.
                </TableCell>
              </TableRow>
            ) : (
              products.map((product) => (
                <TableRow key={product.uuid ?? product.id}>
                  <TableCell className="px-4 py-4 font-medium text-slate-900">
                    {product.name || product.description || `Product ${product.uuid ?? product.id}`}
                  </TableCell>
                  <TableCell className="px-4 py-4">{formatCurrency(Number(product.price ?? 0), product.currency || 'USD')}</TableCell>
                  <TableCell className="px-4 py-4">{product.stock ?? '—'}</TableCell>
                  <TableCell className="px-4 py-4">
                    <Badge className={product.available ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-700'}>
                      {product.available ? 'Available' : 'Inactive'}
                    </Badge>
                  </TableCell>
                  <TableCell className="px-4 py-4 space-x-3">
                    <Link to={`${product.uuid}`} className="text-emerald-600 hover:text-emerald-700">
                      View
                    </Link>
                    <Link to={`${product.uuid}/edit`} className="text-slate-600 hover:text-slate-900">
                      Edit
                    </Link>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </Card>
    </div>
  );
}

