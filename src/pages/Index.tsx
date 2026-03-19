import { BestSellers } from '@/components/home/BestSellers';
import { CustomerReviews } from '@/components/home/CustomerReviews';
import { FeaturedCategories } from '@/components/home/FeaturedCategories';
import { FeaturedProducts } from '@/components/home/FeaturedProducts';
import { ComboProducts } from '@/components/home/ComboProducts';
import { NewArrivals } from '@/components/home/NewArrivals';
import { HeroSlider } from '@/components/home/HeroSlider';
import { LazySection } from '@/components/LazySection';
import { Layout } from '@/components/layout/Layout';

const Index = () => {
  return (
    <Layout>
      {/* Hero Slider — loads immediately */}
      <HeroSlider />

      {/* Featured Categories — loads immediately (visible right after hero) */}
      <FeaturedCategories />

      {/* Below-the-fold sections: only fetch data when scrolled near */}
      <LazySection>
        <FeaturedProducts />
      </LazySection>

      <LazySection>
        <NewArrivals />
      </LazySection>

      <LazySection>
        <BestSellers />
      </LazySection>

      <LazySection>
        <ComboProducts />
      </LazySection>

      <LazySection>
        <CustomerReviews />
      </LazySection>

      {/* Newsletter CTA — static content, no data fetch needed */}
      <section className="section-padding bg-secondary/50">
        <div className="container-shop">
          <div className="max-w-2xl mx-auto text-center">
            <h2 className="text-2xl md:text-3xl font-bold mb-4">Stay in the Loop</h2>
            <p className="text-muted-foreground mb-8">
              Subscribe to our newsletter for exclusive offers and new arrivals
            </p>
            <form className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto">
              <input
                type="email"
                placeholder="Enter your email"
                className="input-shop flex-1"
              />
              <button type="submit" className="btn-accent px-6 py-3 rounded-lg font-medium">
                Subscribe
              </button>
            </form>
          </div>
        </div>
      </section>
    </Layout>
  );
};

export default Index;

