-- =============================================
-- AL-RAIYAN PERFUME - SEED DATA
-- Run this AFTER the main migration (combined_migration.sql)
-- =============================================

-- Clear old sample data if any
DELETE FROM public.products WHERE sku IN ('KG-001','DS-001','FAN-001','GF-001','TOM-001','BF-001','SO-001','ROM-001','BX-001');
DELETE FROM public.categories WHERE slug = 'perfumes';

-- Insert Perfumes category
INSERT INTO public.categories (name, slug, image, is_active)
VALUES (
  'Perfumes',
  'perfumes',
  'https://images.unsplash.com/photo-1594035910387-fea47794261f?w=600&q=80',
  true
);

-- Insert all 9 Al-Raiyan products
DO $$
DECLARE
    perfumes_id UUID;
BEGIN
    SELECT id INTO perfumes_id FROM public.categories WHERE slug = 'perfumes' LIMIT 1;

    INSERT INTO public.products
      (name, slug, price, sale_price, category_id, stock, sku, short_description, description, images, is_new, is_best_seller, is_featured, is_active)
    VALUES

    ('Kasturi Gold', 'kasturi-gold', 1500, NULL, perfumes_id, 50, 'KG-001',
     'An intense, exotic attar crafted from pure, natural musk essence.',
     'An intense, exotic attar crafted from pure, natural musk essence. Experience the richness and depth of Kasturi Gold, a fragrance that leaves a lasting impression.',
     ARRAY['https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Kasturi%20Gold.jpg'],
     false, true, true, true),

    ('D-Savage', 'd-savage', 1200, NULL, perfumes_id, 45, 'DS-001',
     'An intense, long-lasting attar crafted from 100% pure and natural essences.',
     'An intense, long-lasting attar crafted from 100% pure and natural essences. D-Savage is a bold and captivating scent for those who want to stand out.',
     ARRAY['https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/D-Savage.jpg'],
     true, false, true, true),

    ('Fantasia', 'fantasia', 1100, NULL, perfumes_id, 60, 'FAN-001',
     '100% pure, natural, premium attar without artificial oils.',
     '100% pure, natural, premium attar without artificial oils. Fantasia brings a delicate and enchanting aroma that is both soothing and uplifting.',
     ARRAY['https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Fantasia.jpg'],
     false, true, false, true),

    ('Gucci Flora', 'gucci-flora', 1800, NULL, perfumes_id, 30, 'GF-001',
     'Premium, elegant attar with a rich floral bouquet.',
     'A luxurious and elegant fragrance. Gucci Flora captures the essence of a blossoming garden, perfect for any occasion.',
     ARRAY['https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Gucci%20Flora.jpg'],
     false, false, true, true),

    ('The One Maliki', 'the-one-maliki', 2500, NULL, perfumes_id, 20, 'TOM-001',
     'Exquisite and timeless Arabian oud fragrance.',
     'Exquisite and timeless Arabian oud fragrance. The One Maliki represents the pinnacle of luxury, offering a deep, sophisticated scent that commands attention.',
     ARRAY['https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/The%20one%20Maliki.jpg'],
     false, true, true, true),

    ('Beauty Flora', 'beauty-flora', 1300, NULL, perfumes_id, 40, 'BF-001',
     'A delicate floral attar crafted from pure, natural distilled essences.',
     'A delicate floral attar crafted from pure, natural distilled essences. Beauty Flora is a perfume inspired by the enchanting beauty of blooming flowers, perfect for those who love soft, feminine fragrances.',
     ARRAY['https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Beauty%20Flora.jpg'],
     true, false, true, true),

    ('Saffroni Oud', 'saffroni-oud', 2200, NULL, perfumes_id, 25, 'SO-001',
     'A rich, warm blend of precious saffron and aged oud.',
     'A rich, warm blend of precious saffron and aged oud. Saffroni Oud is a deeply luxurious attar that evokes the grandeur of the Orient, with its complex, spicy, and woody character.',
     ARRAY['https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Saffroni%20Oud.jpg'],
     false, true, true, true),

    ('Romance', 'romance', 1400, NULL, perfumes_id, 35, 'ROM-001',
     'A soft, romantic floral attar with the sweetness of cherry blossoms.',
     'A soft, romantic floral attar with the sweetness of cherry blossoms. Romance captures the essence of love and tenderness, a delightful fragrance for special moments.',
     ARRAY['https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Romance.jpg'],
     true, true, false, true),

    ('Black XXX', 'black-xxx', 1600, NULL, perfumes_id, 30, 'BX-001',
     'রাজকীয় সুভাস — a royal, bold fragrance with commanding presence.',
     'রাজকীয় সুভাস (Royal Fragrance). Black XXX is a bold, powerful attar that makes a lasting statement. Its deep, commanding scent is crafted for those who carry themselves with regal confidence.',
     ARRAY['https://raw.githubusercontent.com/Al-Raiyan-Perfume/assets/main/Black%20XXX.jpg'],
     false, false, true, true);

    RAISE NOTICE 'Successfully inserted 9 Al-Raiyan products!';
END $$;
