/**
 * @deprecated LEGACY MOCK DATA FILE
 * 
 * This file contains static mock data for development reference ONLY.
 * All production data comes from Supabase via hooks in:
 *   - src/hooks/useShopData.ts (products, categories, reviews, slider)
 *   - src/hooks/useOrders.ts (orders)
 * 
 * DO NOT import from this file in production code.
 * This file will be removed in a future version.
 */

export interface Product {
  id: string;
  name: string;
  slug: string;
  price: number;
  salePrice?: number;
  category: string;
  categorySlug: string;
  stock: number;
  sku: string;
  shortDescription: string;
  description: string;
  images: string[];
  isNew?: boolean;
  isBestSeller?: boolean;
  isFeatured?: boolean;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  image: string;
  productCount: number;
}

export interface SliderSlide {
  id: string;
  image: string;
  heading: string;
  text: string;
  ctaText: string;
  ctaLink: string;
}

export interface Review {
  id: string;
  name: string;
  rating: number;
  text: string;
  date: string;
  avatar?: string;
}

// Sample Categories
export const categories: Category[] = [
  {
    id: '1',
    name: 'Perfumes',
    slug: 'perfumes',
    image: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?w=600&q=80',
    productCount: 9,
  }
];

// Sample Products
export const products: Product[] = [
  {
    id: '1',
    name: 'Kasturi Gold',
    slug: 'kasturi-gold',
    price: 1500,
    category: 'Perfumes',
    categorySlug: 'perfumes',
    stock: 50,
    sku: 'KG-001',
    shortDescription: 'An intense, exotic attar crafted from pure, natural musk essence.',
    description: 'An intense, exotic attar crafted from pure, natural musk essence. Experience the richness and depth of Kasturi Gold, a fragrance that leaves a lasting impression.',
    images: [
      'https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Kasturi%20Gold.jpg'
    ],
    isBestSeller: true,
    isFeatured: true,
  },
  {
    id: '2',
    name: 'D-Savage',
    slug: 'd-savage',
    price: 1200,
    category: 'Perfumes',
    categorySlug: 'perfumes',
    stock: 45,
    sku: 'DS-001',
    shortDescription: 'An intense, long-lasting attar crafted from 100% pure and natural essences.',
    description: 'An intense, long-lasting attar crafted from 100% pure and natural essences. D-Savage is a bold and captivating scent for those who want to stand out.',
    images: [
      'https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/D-Savage.jpg'
    ],
    isNew: true,
    isFeatured: true,
  },
  {
    id: '3',
    name: 'Fantasia',
    slug: 'fantasia',
    price: 1100,
    category: 'Perfumes',
    categorySlug: 'perfumes',
    stock: 60,
    sku: 'FAN-001',
    shortDescription: '100% pure, natural, premium attar without artificial oils.',
    description: '100% pure, natural, premium attar without artificial oils. Fantasia brings a delicate and enchanting aroma that is both soothing and uplifting.',
    images: [
      'https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Fantasia.jpg'
    ],
    isBestSeller: true,
  },
  {
    id: '4',
    name: 'Gucci Flora',
    slug: 'gucci-flora',
    price: 1800,
    category: 'Perfumes',
    categorySlug: 'perfumes',
    stock: 30,
    sku: 'GF-001',
    shortDescription: 'Premium, elegant attar with a rich floral bouquet.',
    description: 'A luxurious and elegant fragrance. Gucci Flora captures the essence of a blossoming garden, perfect for any occasion.',
    images: [
      'https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Gucci%20Flora.jpg'
    ],
    isFeatured: true,
  },
  {
    id: '5',
    name: 'The One Maliki',
    slug: 'the-one-maliki',
    price: 2500,
    category: 'Perfumes',
    categorySlug: 'perfumes',
    stock: 20,
    sku: 'TOM-001',
    shortDescription: 'Exquisite and timeless Arabian oud fragrance.',
    description: 'Exquisite and timeless Arabian oud fragrance. The One Maliki represents the pinnacle of luxury, offering a deep, sophisticated scent that commands attention.',
    images: [
      'https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/The%20one%20Maliki.jpg'
    ],
    isBestSeller: true,
    isFeatured: true,
  },
  {
    id: '6',
    name: 'Beauty Flora',
    slug: 'beauty-flora',
    price: 1300,
    category: 'Perfumes',
    categorySlug: 'perfumes',
    stock: 40,
    sku: 'BF-001',
    shortDescription: 'A delicate floral attar crafted from pure, natural distilled essences.',
    description: 'A delicate floral attar crafted from pure, natural distilled essences. Beauty Flora is a perfume inspired by the enchanting beauty of blooming flowers, perfect for those who love soft, feminine fragrances.',
    images: [
      'https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Beauty%20Flora.jpg'
    ],
    isNew: true,
    isFeatured: true,
  },
  {
    id: '7',
    name: 'Saffroni Oud',
    slug: 'saffroni-oud',
    price: 2200,
    category: 'Perfumes',
    categorySlug: 'perfumes',
    stock: 25,
    sku: 'SO-001',
    shortDescription: 'A rich, warm blend of precious saffron and aged oud.',
    description: 'A rich, warm blend of precious saffron and aged oud. Saffroni Oud is a deeply luxurious attar that evokes the grandeur of the Orient, with its complex, spicy, and woody character.',
    images: [
      'https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Saffroni%20Oud.jpg'
    ],
    isBestSeller: true,
    isFeatured: true,
  },
  {
    id: '8',
    name: 'Romance',
    slug: 'romance',
    price: 1400,
    category: 'Perfumes',
    categorySlug: 'perfumes',
    stock: 35,
    sku: 'ROM-001',
    shortDescription: 'A soft, romantic floral attar with the sweetness of cherry blossoms.',
    description: 'A soft, romantic floral attar with the sweetness of cherry blossoms. Romance captures the essence of love and tenderness, a delightful fragrance for special moments.',
    images: [
      'https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Romance.jpg'
    ],
    isNew: true,
    isBestSeller: true,
  },
  {
    id: '9',
    name: 'Black XXX',
    slug: 'black-xxx',
    price: 1600,
    category: 'Perfumes',
    categorySlug: 'perfumes',
    stock: 30,
    sku: 'BX-001',
    shortDescription: 'রাজকীয় সুভাস — a royal, bold fragrance with commanding presence.',
    description: 'রাজকীয় সুভাস (Royal Fragrance). Black XXX is a bold, powerful attar that makes a lasting statement. Its deep, commanding scent is crafted for those who carry themselves with regal confidence.',
    images: [
      'https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Black%20XXX.jpg'
    ],
    isFeatured: true,
  },
];

// Sample Slider Slides
export const sliderSlides: SliderSlide[] = [
  {
    id: '1',
    image: '/al-raiyan-banner.jpg',
    heading: 'Al-Raiyan Perfume',
    text: 'Exquisite Scents of Purity & Luxury',
    ctaText: 'Shop Now',
    ctaLink: '/shop',
  },
  {
    id: '2',
    image: '/special-combo-banner.jpg',
    heading: 'Special Combo',
    text: 'Best Selling Three Product',
    ctaText: 'View Combo',
    ctaLink: '/shop',
  }
];

// Sample Reviews
export const reviews: Review[] = [
  {
    id: '1',
    name: 'Sarah Johnson',
    rating: 5,
    text: 'Absolutely love the quality of products here! Fast shipping and excellent customer service.',
    date: '2024-01-15',
  },
  {
    id: '2',
    name: 'Michael Chen',
    rating: 5,
    text: 'The headphones I bought exceeded my expectations. Will definitely shop here again!',
    date: '2024-01-10',
  },
  {
    id: '3',
    name: 'Emily Davis',
    rating: 4,
    text: 'Great selection and competitive prices. The checkout process was smooth and easy.',
    date: '2024-01-05',
  },
];

// Helper functions
export const getProductBySlug = (slug: string): Product | undefined => {
  return products.find(p => p.slug === slug);
};

export const getProductsByCategory = (categorySlug: string): Product[] => {
  return products.filter(p => p.categorySlug === categorySlug);
};

export const getFeaturedProducts = (): Product[] => {
  return products.filter(p => p.isFeatured);
};

export const getBestSellers = (): Product[] => {
  return products.filter(p => p.isBestSeller);
};

export const getNewArrivals = (): Product[] => {
  return products.filter(p => p.isNew);
};

export const getCategoryBySlug = (slug: string): Category | undefined => {
  return categories.find(c => c.slug === slug);
};

export const getRelatedProducts = (product: Product, limit = 4): Product[] => {
  return products
    .filter(p => p.categorySlug === product.categorySlug && p.id !== product.id)
    .slice(0, limit);
};
