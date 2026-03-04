import { supabase } from '@/integrations/supabase/client';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';

export interface Product {
  id: string;
  name: string;
  slug: string;
  price: number;
  sale_price: number | null;
  category_id: string | null;
  category?: Category;
  stock: number;
  sku: string;
  short_description: string | null;
  description: string | null;
  images: string[];
  is_new: boolean;
  is_best_seller: boolean;
  is_featured: boolean;
  is_combo: boolean;
  created_at: string;
  updated_at: string;
  has_variants?: boolean;
  /** Lowest active variant price (price_adjustment). Only set when has_variants=true. */
  min_variant_price?: number;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  image: string;
  created_at: string;
  updated_at: string;
  product_count?: number;
}

export interface SliderSlide {
  id: string;
  image: string;
  heading: string;
  text: string;
  cta_text: string;
  cta_link: string;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Review {
  id: string;
  name: string;
  rating: number;
  text: string;
  is_approved: boolean;
  created_at: string;
}

// ─── Mock data fallback (used when Supabase is not configured) ─────────────────
const MOCK_CATEGORY: Category = {
  id: 'cat-1',
  name: 'Perfumes',
  slug: 'perfumes',
  image: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?w=600&q=80',
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  product_count: 9,
};

const MOCK_PRODUCTS: (Product & { category: Category | null })[] = [
  {
    id: '1', name: 'Kasturi Gold', slug: 'kasturi-gold', price: 1500, sale_price: null,
    category_id: 'cat-1', stock: 50, sku: 'KG-001',
    short_description: 'An intense, exotic attar crafted from pure, natural musk essence.',
    description: 'An intense, exotic attar crafted from pure, natural musk essence. Experience the richness and depth of Kasturi Gold, a fragrance that leaves a lasting impression.',
    images: ['https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600&q=80'],
    is_new: false, is_best_seller: true, is_featured: true, is_combo: false,
    created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z',
    category: MOCK_CATEGORY,
  },
  {
    id: '2', name: 'D-Savage', slug: 'd-savage', price: 1200, sale_price: null,
    category_id: 'cat-1', stock: 45, sku: 'DS-001',
    short_description: 'An intense, long-lasting attar crafted from 100% pure and natural essences.',
    description: 'An intense, long-lasting attar crafted from 100% pure and natural essences. D-Savage is a bold and captivating scent for those who want to stand out.',
    images: ['https://images.unsplash.com/photo-1541643600914-78b084683702?w=600&q=80'],
    is_new: true, is_best_seller: false, is_featured: true, is_combo: false,
    created_at: '2024-01-02T00:00:00Z', updated_at: '2024-01-02T00:00:00Z',
    category: MOCK_CATEGORY,
  },
  {
    id: '3', name: 'Fantasia', slug: 'fantasia', price: 1100, sale_price: null,
    category_id: 'cat-1', stock: 60, sku: 'FAN-001',
    short_description: '100% pure, natural, premium attar without artificial oils.',
    description: '100% pure, natural, premium attar without artificial oils. Fantasia brings a delicate and enchanting aroma that is both soothing and uplifting.',
    images: ['https://images.unsplash.com/photo-1588776814546-1ffbb3f4a5f8?w=600&q=80'],
    is_new: false, is_best_seller: true, is_featured: false, is_combo: false,
    created_at: '2024-01-03T00:00:00Z', updated_at: '2024-01-03T00:00:00Z',
    category: MOCK_CATEGORY,
  },
  {
    id: '4', name: 'Gucci Flora', slug: 'gucci-flora', price: 1800, sale_price: null,
    category_id: 'cat-1', stock: 30, sku: 'GF-001',
    short_description: 'Premium, elegant attar with a rich floral bouquet.',
    description: 'A luxurious and elegant fragrance. Gucci Flora captures the essence of a blossoming garden, perfect for any occasion.',
    images: ['https://images.unsplash.com/photo-1600612253971-cafc60f4e6f3?w=600&q=80'],
    is_new: false, is_best_seller: false, is_featured: true, is_combo: false,
    created_at: '2024-01-04T00:00:00Z', updated_at: '2024-01-04T00:00:00Z',
    category: MOCK_CATEGORY,
  },
  {
    id: '5', name: 'The One Maliki', slug: 'the-one-maliki', price: 2500, sale_price: null,
    category_id: 'cat-1', stock: 20, sku: 'TOM-001',
    short_description: 'Exquisite and timeless Arabian oud fragrance.',
    description: 'Exquisite and timeless Arabian oud fragrance. The One Maliki represents the pinnacle of luxury, offering a deep, sophisticated scent that commands attention.',
    images: ['https://images.unsplash.com/photo-1547887537-6158d64c35b3?w=600&q=80'],
    is_new: false, is_best_seller: true, is_featured: true, is_combo: false,
    created_at: '2024-01-05T00:00:00Z', updated_at: '2024-01-05T00:00:00Z',
    category: MOCK_CATEGORY,
  },
  {
    id: '6', name: 'Beauty Flora', slug: 'beauty-flora', price: 1300, sale_price: null,
    category_id: 'cat-1', stock: 40, sku: 'BF-001',
    short_description: 'A delicate floral attar crafted from pure, natural distilled essences.',
    description: 'A delicate floral attar crafted from pure, natural distilled essences. Beauty Flora is a perfume inspired by the enchanting beauty of blooming flowers, perfect for those who love soft, feminine fragrances.',
    images: ['https://images.unsplash.com/photo-1615634260167-c8cdede054de?w=600&q=80'],
    is_new: true, is_best_seller: false, is_featured: true, is_combo: false,
    created_at: '2024-01-06T00:00:00Z', updated_at: '2024-01-06T00:00:00Z',
    category: MOCK_CATEGORY,
  },
  {
    id: '7', name: 'Saffroni Oud', slug: 'saffroni-oud', price: 2200, sale_price: null,
    category_id: 'cat-1', stock: 25, sku: 'SO-001',
    short_description: 'A rich, warm blend of precious saffron and aged oud.',
    description: 'A rich, warm blend of precious saffron and aged oud. Saffroni Oud is a deeply luxurious attar that evokes the grandeur of the Orient, with its complex, spicy, and woody character.',
    images: ['https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=600&q=80'],
    is_new: false, is_best_seller: true, is_featured: true, is_combo: false,
    created_at: '2024-01-07T00:00:00Z', updated_at: '2024-01-07T00:00:00Z',
    category: MOCK_CATEGORY,
  },
  {
    id: '8', name: 'Romance', slug: 'romance', price: 1400, sale_price: null,
    category_id: 'cat-1', stock: 35, sku: 'ROM-001',
    short_description: 'A soft, romantic floral attar with the sweetness of cherry blossoms.',
    description: 'A soft, romantic floral attar with the sweetness of cherry blossoms. Romance captures the essence of love and tenderness, a delightful fragrance for special moments.',
    images: ['https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=600&q=80'],
    is_new: true, is_best_seller: true, is_featured: false, is_combo: false,
    created_at: '2024-01-08T00:00:00Z', updated_at: '2024-01-08T00:00:00Z',
    category: MOCK_CATEGORY,
  },
  {
    id: '9', name: 'Black XXX', slug: 'black-xxx', price: 1600, sale_price: null,
    category_id: 'cat-1', stock: 30, sku: 'BX-001',
    short_description: 'রাজকীয় সুভাস — a royal, bold fragrance with commanding presence.',
    description: 'রাজকীয় সুভাস (Royal Fragrance). Black XXX is a bold, powerful attar that makes a lasting statement. Its deep, commanding scent is crafted for those who carry themselves with regal confidence.',
    images: ['https://images.unsplash.com/photo-1607930654830-6f8b7c85a2f5?w=600&q=80'],
    is_new: false, is_best_seller: false, is_featured: true, is_combo: false,
    created_at: '2024-01-09T00:00:00Z', updated_at: '2024-01-09T00:00:00Z',
    category: MOCK_CATEGORY,
  },
];
// ──────────────────────────────────────────────────────────────────────────────

/** Transform raw Supabase product row (with product_variants) into a clean Product */
function mapProduct(p: any): Product & { category: Category | null } {
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

// Products - for Shop page (all products)
export const useProducts = () => {
  return useQuery({
    queryKey: ['products'],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from('products')
          .select('*, category:categories(*), product_variants(price_adjustment, sale_price, is_active)')
          .eq('is_active', true)
          .order('created_at', { ascending: false })
          .limit(20);
        if (error) throw error;
        if (data && data.length > 0) return data.map(mapProduct);
      } catch (_) { /* fall through to mock */ }
      return MOCK_PRODUCTS;
    },
  });
};

export const useProduct = (slug: string) => {
  return useQuery({
    queryKey: ['product', slug],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from('products')
          .select('*, category:categories(*)')
          .eq('slug', slug)
          .maybeSingle();
        if (error) throw error;
        if (data) return data as (Product & { category: Category | null });
      } catch (_) { /* fall through to mock */ }
      return MOCK_PRODUCTS.find(p => p.slug === slug) ?? null;
    },
    enabled: !!slug,
  });
};

// Featured products for home page (limit 12)
export const useFeaturedProducts = () => {
  return useQuery({
    queryKey: ['products', 'featured'],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from('products')
          .select('*, category:categories(*), product_variants(price_adjustment, sale_price, is_active)')
          .eq('is_active', true)
          .order('created_at', { ascending: false })
          .limit(12);
        if (error) throw error;
        if (data && data.length > 0) return data.map(mapProduct);
      } catch (_) { /* fall through to mock */ }
      return MOCK_PRODUCTS;
    },
  });
};

export const useBestSellers = () => {
  return useQuery({
    queryKey: ['products', 'bestsellers'],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from('products')
          .select('*, category:categories(*), product_variants(price_adjustment, sale_price, is_active)')
          .eq('is_best_seller', true)
          .order('created_at', { ascending: false });
        if (error) throw error;
        if (data && data.length > 0) return data.map(mapProduct);
      } catch (_) { /* fall through to mock */ }
      return MOCK_PRODUCTS.filter(p => p.is_best_seller);
    },
  });
};

export const useNewArrivals = () => {
  return useQuery({
    queryKey: ['products', 'new'],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from('products')
          .select('*, category:categories(*), product_variants(price_adjustment, sale_price, is_active)')
          .eq('is_new', true)
          .order('created_at', { ascending: false });
        if (error) throw error;
        if (data && data.length > 0) return data.map(mapProduct);
      } catch (_) { /* fall through to mock */ }
      return MOCK_PRODUCTS.filter(p => p.is_new);
    },
  });
};

export const useProductsByCategory = (categorySlug: string) => {
  return useQuery({
    queryKey: ['products', 'category', categorySlug],
    queryFn: async () => {
      try {
        const { data: category, error: catError } = await supabase
          .from('categories')
          .select('id')
          .eq('slug', categorySlug)
          .maybeSingle();
        if (catError) throw catError;
        if (category) {
          const { data, error } = await supabase
            .from('products')
            .select('*, category:categories(*), product_variants(price_adjustment, sale_price, is_active)')
            .eq('category_id', category.id)
            .order('created_at', { ascending: false });
          if (error) throw error;
          if (data && data.length > 0) return data.map(mapProduct);
        }
      } catch (_) { /* fall through to mock */ }
      return MOCK_PRODUCTS.filter(p => p.category?.slug === categorySlug);
    },
    enabled: !!categorySlug,
  });
};

export const useRelatedProducts = (product: Product | null, limit = 4) => {
  return useQuery({
    queryKey: ['products', 'related', product?.id],
    queryFn: async () => {
      if (!product) return [];
      try {
        if (product.category_id) {
          const { data, error } = await supabase
            .from('products')
            .select('*, category:categories(*), product_variants(price_adjustment, sale_price, is_active)')
            .eq('category_id', product.category_id)
            .neq('id', product.id)
            .limit(limit);
          if (error) throw error;
          if (data && data.length > 0) return data.map(mapProduct);
        }
      } catch (_) { /* fall through to mock */ }
      return MOCK_PRODUCTS.filter(p => p.id !== product.id).slice(0, limit);
    },
    enabled: !!product,
  });
};

// Categories
export const useCategories = () => {
  return useQuery({
    queryKey: ['categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('categories')
        .select('*')
        .order('name');
      if (error) {
        console.error('Failed to load categories:', error.message);
        return [] as Category[];
      }
      return (data || []) as Category[];
    },
    retry: 2,
  });
};

export const useCategory = (slug: string) => {
  return useQuery({
    queryKey: ['category', slug],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from('categories')
          .select('*')
          .eq('slug', slug)
          .maybeSingle();
        if (error) throw error;
        if (data) return data as Category;
      } catch (_) { /* fall through to mock */ }
      return MOCK_CATEGORY.slug === slug ? MOCK_CATEGORY : null;
    },
    enabled: !!slug,
  });
};

// Slider
export const useSliderSlides = (activeOnly = true) => {
  return useQuery({
    queryKey: ['slider_slides', activeOnly],
    queryFn: async () => {
      let query = supabase.from('slider_slides').select('*').order('sort_order');
      if (activeOnly) {
        query = query.eq('is_active', true);
      }
      const { data, error } = await query;
      if (error) throw error;
      return data as SliderSlide[];
    },
  });
};

// Reviews
export const useReviews = (approvedOnly = true) => {
  return useQuery({
    queryKey: ['reviews', approvedOnly],
    queryFn: async () => {
      let query = supabase.from('reviews').select('*').order('created_at', { ascending: false });
      if (approvedOnly) {
        query = query.eq('is_approved', true);
      }
      const { data, error } = await query;
      if (error) throw error;
      return data as Review[];
    },
  });
};

// Mutations
export const useCreateProduct = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (product: Omit<Product, 'id' | 'created_at' | 'updated_at' | 'category'>) => {
      const { data, error } = await supabase
        .from('products')
        .insert(product)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      toast.success('Product created');
    },
    onError: (error) => {
      toast.error('Failed to create product: ' + error.message);
    },
  });
};

export const useUpdateProduct = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async ({ id, ...product }: Partial<Product> & { id: string }) => {
      const { data, error } = await supabase
        .from('products')
        .update(product)
        .eq('id', id)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      toast.success('Product updated');
    },
    onError: (error) => {
      toast.error('Failed to update product: ' + error.message);
    },
  });
};

export const useDeleteProduct = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('products').delete().eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      toast.success('Product deleted');
    },
    onError: (error) => {
      toast.error('Failed to delete product: ' + error.message);
    },
  });
};

// Category mutations
export const useCreateCategory = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (category: Omit<Category, 'id' | 'created_at' | 'updated_at' | 'product_count'>) => {
      const { data, error } = await supabase
        .from('categories')
        .insert(category)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] });
      toast.success('Category created');
    },
    onError: (error) => {
      toast.error('Failed to create category: ' + error.message);
    },
  });
};

export const useUpdateCategory = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async ({ id, ...category }: Partial<Category> & { id: string }) => {
      const { data, error } = await supabase
        .from('categories')
        .update(category)
        .eq('id', id)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] });
      toast.success('Category updated');
    },
    onError: (error) => {
      toast.error('Failed to update category: ' + error.message);
    },
  });
};

export const useDeleteCategory = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('categories').delete().eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] });
      toast.success('Category deleted');
    },
    onError: (error) => {
      toast.error('Failed to delete category: ' + error.message);
    },
  });
};

// Slider mutations
export const useCreateSlide = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (slide: Omit<SliderSlide, 'id' | 'created_at' | 'updated_at'>) => {
      const { data, error } = await supabase
        .from('slider_slides')
        .insert(slide)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['slider_slides'] });
      toast.success('Slide created');
    },
    onError: (error) => {
      toast.error('Failed to create slide: ' + error.message);
    },
  });
};

export const useUpdateSlide = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async ({ id, ...slide }: Partial<SliderSlide> & { id: string }) => {
      const { data, error } = await supabase
        .from('slider_slides')
        .update(slide)
        .eq('id', id)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['slider_slides'] });
      toast.success('Slide updated');
    },
    onError: (error) => {
      toast.error('Failed to update slide: ' + error.message);
    },
  });
};

export const useDeleteSlide = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('slider_slides').delete().eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['slider_slides'] });
      toast.success('Slide deleted');
    },
    onError: (error) => {
      toast.error('Failed to delete slide: ' + error.message);
    },
  });
};
