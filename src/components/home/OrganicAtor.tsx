import { ProductCard } from '@/components/products/ProductCard';
import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';

function mapProduct(p: any) {
  const variantRows: { price_adjustment: number; sale_price: number | null; is_active: boolean }[] =
    p.product_variants || [];
  const activePrices = variantRows
    .filter((v) => v.is_active && v.price_adjustment > 0)
    .map((v) => v.sale_price != null && v.sale_price < v.price_adjustment ? v.sale_price : v.price_adjustment);
  const hasVariants = activePrices.length > 0;
  return {
    ...p,
    product_variants: undefined,
    has_variants: hasVariants,
    min_variant_price: hasVariants ? Math.min(...activePrices) : undefined,
  };
}

export function OrganicAtor() {
  const { data: products = [], isLoading } = useQuery({
    queryKey: ['products', 'organic_ator'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('products')
        .select('*, category:categories(*), product_variants(price_adjustment, sale_price, is_active)')
        .eq('is_active', true)
        .eq('is_organic_ator', true)
        .order('created_at', { ascending: false });
      if (error) throw error;
      return (data || []).map(mapProduct);
    },
  });

  if (isLoading) {
    return (
      <section className="section-padding">
        <div className="container-shop">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="text-2xl md:text-3xl font-bold">Organic Ator</h2>
              <p className="text-muted-foreground mt-1">প্রাকৃতিক উপাদানে তৈরি আতর</p>
            </div>
          </div>
          <div className="product-grid">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="aspect-product rounded-xl bg-muted animate-pulse" />
            ))}
          </div>
        </div>
      </section>
    );
  }

  if (products.length === 0) return null;

  return (
    <section className="section-padding">
      <div className="container-shop">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h2 className="text-2xl md:text-3xl font-bold">Organic Ator</h2>
            <p className="text-muted-foreground mt-1">প্রাকৃতিক উপাদানে তৈরি আতর</p>
          </div>
          <Link
            to="/shop?filter=organic"
            className="hidden sm:flex items-center gap-2 text-sm font-medium text-accent hover:underline"
          >
            View All <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        <div className="product-grid">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>

        <Link
          to="/shop?filter=organic"
          className="mt-6 flex sm:hidden items-center justify-center gap-2 text-sm font-medium text-accent hover:underline"
        >
          View All Organic Ator <ArrowRight className="h-4 w-4" />
        </Link>
      </div>
    </section>
  );
}
