import { ProductCard } from '@/components/products/ProductCard';
import { useSiteSettings } from '@/contexts/SiteSettingsContext';
import { useFeaturedProducts } from '@/hooks/useShopData';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';

export function FeaturedProducts() {
  const { data: products = [], isLoading, isError } = useFeaturedProducts();
  const { t } = useSiteSettings();

  if (isError) return null;

  if (isLoading) {
    return (
      <section className="section-padding bg-secondary/50">
        <div className="container-shop">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="text-2xl md:text-3xl font-bold">{t('home.featuredProducts')}</h2>
              <p className="text-muted-foreground mt-1">Our top-selling perfumes</p>
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
    <section className="section-padding bg-secondary/50">
      <div className="container-shop">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h2 className="text-2xl md:text-3xl font-bold">{t('home.featuredProducts')}</h2>
            <p className="text-muted-foreground mt-1">Our top-selling perfumes</p>
          </div>
          <Link
            to="/shop"
            className="hidden sm:flex items-center gap-2 text-sm font-medium text-accent hover:underline"
          >
            {t('common.viewAll')} <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        <div className="product-grid">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>

        <Link
          to="/shop"
          className="mt-8 flex sm:hidden items-center justify-center gap-2 text-sm font-medium text-accent hover:underline"
        >
          {t('common.viewAll')} <ArrowRight className="h-4 w-4" />
        </Link>
      </div>
    </section>
  );
}
