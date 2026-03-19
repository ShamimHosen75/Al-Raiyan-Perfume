import { ProductCard } from '@/components/products/ProductCard';
import { useNewArrivals } from '@/hooks/useShopData';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';

export function NewArrivals() {
  const { data: newArrivals = [], isLoading } = useNewArrivals();

  if (isLoading) {
    return (
      <section className="section-padding">
        <div className="container-shop">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="text-2xl md:text-3xl font-bold">Perfume Tips</h2>
              <p className="text-muted-foreground mt-1">Fresh styles just landed</p>
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

  if (newArrivals.length === 0) return null;

  return (
    <section className="section-padding">
      <div className="container-shop">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h2 className="text-2xl md:text-3xl font-bold">Perfume Tips</h2>
            <p className="text-muted-foreground mt-1">Fresh styles just landed</p>
          </div>
          <Link
            to="/shop?filter=new"
            className="hidden sm:flex items-center gap-2 text-sm font-medium text-accent hover:underline"
          >
            View All <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        <div className="product-grid">
          {newArrivals.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </div>
    </section>
  );
}
