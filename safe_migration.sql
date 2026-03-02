-- =============================================
-- AL-RAIYAN PERFUME - SAFE MIGRATION (OPTION B)
-- Idempotent: safe to run even if tables/types already exist
-- Run this in Supabase SQL Editor
-- =============================================

-- Step 1: Enums (safe re-run)
DO $$ BEGIN CREATE TYPE public.order_status AS ENUM ('pending','processing','shipped','delivered','cancelled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.app_role AS ENUM ('admin','customer'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'manager'; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'order_handler'; EXCEPTION WHEN others THEN NULL; END $$;

-- Step 2: Core tables (IF NOT EXISTS)
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role app_role NOT NULL DEFAULT 'customer',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (user_id, role)
);

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    full_name TEXT,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    image TEXT NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    sale_price DECIMAL(10,2),
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    sku TEXT NOT NULL UNIQUE,
    short_description TEXT,
    description TEXT,
    images TEXT[] NOT NULL DEFAULT '{}',
    is_new BOOLEAN DEFAULT false,
    is_best_seller BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    is_active boolean NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    size TEXT,
    color TEXT,
    sku TEXT NOT NULL,
    price_adjustment NUMERIC DEFAULT 0,
    stock INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.slider_slides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    image TEXT NOT NULL,
    heading TEXT NOT NULL,
    text TEXT NOT NULL,
    cta_text TEXT NOT NULL,
    cta_link TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT NOT NULL UNIQUE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    customer_email TEXT,
    shipping_address TEXT NOT NULL,
    shipping_city TEXT NOT NULL,
    shipping_method TEXT NOT NULL,
    shipping_cost DECIMAL(10,2) NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'cod',
    subtotal DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    status order_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    courier_provider text,
    courier_status text,
    courier_tracking_id text,
    courier_consignment_id text,
    courier_reference text,
    courier_payload jsonb,
    courier_response jsonb,
    courier_created_at timestamp with time zone,
    courier_updated_at timestamp with time zone,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    product_image TEXT,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    line_total numeric GENERATED ALWAYS AS (price * quantity) STORED,
    variant_info JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.store_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE,
    value TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.site_settings (
    id text PRIMARY KEY DEFAULT 'global',
    default_country_code text NOT NULL DEFAULT 'BD',
    default_country_name text NOT NULL DEFAULT 'Bangladesh',
    currency_code text NOT NULL DEFAULT 'BDT',
    currency_symbol text NOT NULL DEFAULT '৳',
    currency_locale text NOT NULL DEFAULT 'bn-BD',
    language text NOT NULL DEFAULT 'en' CHECK (language IN ('en', 'hi', 'bn')),
    fb_pixel_enabled boolean NOT NULL DEFAULT false,
    fb_pixel_id text,
    fb_pixel_test_event_code text,
    cookie_consent_enabled boolean NOT NULL DEFAULT false,
    theme_accent_color TEXT DEFAULT '#e85a4f',
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.shipping_methods (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    base_rate NUMERIC NOT NULL DEFAULT 0,
    estimated_days TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.courier_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    provider text NOT NULL UNIQUE,
    enabled boolean DEFAULT false,
    api_base_url text, api_key text, api_secret text,
    merchant_id text, pickup_address text, pickup_phone text,
    default_weight numeric DEFAULT 0.5,
    cod_enabled boolean DEFAULT true,
    show_tracking_to_customer boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.courier_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
    provider text NOT NULL, action text NOT NULL,
    status text, message text,
    request_payload jsonb, response_payload jsonb,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.checkout_leads (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    lead_no TEXT NOT NULL UNIQUE,
    lead_token TEXT NOT NULL UNIQUE DEFAULT gen_random_uuid()::text,
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new','contacted','converted','invalid')),
    source TEXT NOT NULL DEFAULT 'checkout',
    customer_name TEXT, phone TEXT NOT NULL, email TEXT,
    address TEXT, city TEXT, country TEXT, notes TEXT,
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    subtotal NUMERIC NOT NULL DEFAULT 0,
    shipping_fee NUMERIC NOT NULL DEFAULT 0,
    total NUMERIC NOT NULL DEFAULT 0,
    currency_code TEXT NOT NULL DEFAULT 'BDT',
    page_url TEXT, utm_source TEXT, utm_medium TEXT, utm_campaign TEXT, user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    last_activity_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    converted_order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL
);

-- Step 3: Enable RLS (safe to run multiple times)
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.slider_slides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courier_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courier_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.checkout_leads ENABLE ROW LEVEL SECURITY;

-- Step 4: Functions
CREATE OR REPLACE FUNCTION public.is_admin(_user_id UUID)
RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = 'admin')
$$;

CREATE OR REPLACE FUNCTION public.has_any_staff_role(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role IN ('admin','manager','order_handler'))
$$;

CREATE OR REPLACE FUNCTION public.can_manage_orders(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role IN ('admin','manager','order_handler'))
$$;

CREATE OR REPLACE FUNCTION public.can_manage_products(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role IN ('admin','manager'))
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$ LANGUAGE plpgsql SET search_path = public;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (user_id, email) VALUES (NEW.id, NEW.email) ON CONFLICT DO NOTHING;
  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'customer') ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

-- Step 5: Triggers (drop first to avoid duplicates)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_categories_updated_at ON public.categories;
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_products_updated_at ON public.products;
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_store_settings_updated_at ON public.store_settings;
CREATE TRIGGER update_store_settings_updated_at BEFORE UPDATE ON public.store_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_product_variants_updated_at ON public.product_variants;
CREATE TRIGGER update_product_variants_updated_at BEFORE UPDATE ON public.product_variants FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_shipping_methods_updated_at ON public.shipping_methods;
CREATE TRIGGER update_shipping_methods_updated_at BEFORE UPDATE ON public.shipping_methods FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_site_settings_updated_at ON public.site_settings;
CREATE TRIGGER update_site_settings_updated_at BEFORE UPDATE ON public.site_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_courier_settings_updated_at ON public.courier_settings;
CREATE TRIGGER update_courier_settings_updated_at BEFORE UPDATE ON public.courier_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Step 6: RLS Policies (drop & recreate safely)
DO $$ BEGIN

  -- user_roles
  DROP POLICY IF EXISTS "Users can view their own role" ON public.user_roles;
  CREATE POLICY "Users can view their own role" ON public.user_roles FOR SELECT USING (auth.uid() = user_id);
  DROP POLICY IF EXISTS "Admins can manage all roles" ON public.user_roles;
  CREATE POLICY "Admins can manage all roles" ON public.user_roles FOR ALL USING (public.is_admin(auth.uid()));

  -- profiles
  DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
  CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = user_id);
  DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
  CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
  DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
  CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);

  -- categories
  DROP POLICY IF EXISTS "Anyone can view active categories" ON public.categories;
  CREATE POLICY "Anyone can view active categories" ON public.categories FOR SELECT USING (is_active = true OR is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage categories" ON public.categories;
  CREATE POLICY "Admins can manage categories" ON public.categories FOR ALL USING (public.is_admin(auth.uid()));

  -- products
  DROP POLICY IF EXISTS "Anyone can view active products" ON public.products;
  CREATE POLICY "Anyone can view active products" ON public.products FOR SELECT USING (is_active = true OR is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Staff can manage products" ON public.products;
  CREATE POLICY "Staff can manage products" ON public.products FOR ALL USING (can_manage_products(auth.uid()));

  -- product_variants
  DROP POLICY IF EXISTS "Anyone can view active variants" ON public.product_variants;
  CREATE POLICY "Anyone can view active variants" ON public.product_variants FOR SELECT USING ((is_active = true) OR is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage variants" ON public.product_variants;
  CREATE POLICY "Admins can manage variants" ON public.product_variants FOR ALL USING (is_admin(auth.uid()));

  -- slider_slides
  DROP POLICY IF EXISTS "Anyone can view active slides" ON public.slider_slides;
  CREATE POLICY "Anyone can view active slides" ON public.slider_slides FOR SELECT USING (is_active = true OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage slides" ON public.slider_slides;
  CREATE POLICY "Admins can manage slides" ON public.slider_slides FOR ALL USING (public.is_admin(auth.uid()));

  -- orders
  DROP POLICY IF EXISTS "Users can view their own orders or staff all" ON public.orders;
  CREATE POLICY "Users can view their own orders or staff all" ON public.orders FOR SELECT USING ((user_id = auth.uid()) OR can_manage_orders(auth.uid()) OR (user_id IS NULL));
  DROP POLICY IF EXISTS "Anyone can create orders" ON public.orders;
  CREATE POLICY "Anyone can create orders" ON public.orders FOR INSERT WITH CHECK (true);
  DROP POLICY IF EXISTS "Staff can update orders" ON public.orders;
  CREATE POLICY "Staff can update orders" ON public.orders FOR UPDATE USING (can_manage_orders(auth.uid()));

  -- order_items
  DROP POLICY IF EXISTS "Users can view order items" ON public.order_items;
  CREATE POLICY "Users can view order items" ON public.order_items FOR SELECT USING (
    EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND (orders.user_id = auth.uid() OR is_admin(auth.uid()) OR orders.user_id IS NULL))
  );
  DROP POLICY IF EXISTS "Anyone can create order items" ON public.order_items;
  CREATE POLICY "Anyone can create order items" ON public.order_items FOR INSERT WITH CHECK (true);

  -- store_settings
  DROP POLICY IF EXISTS "Anyone can view settings" ON public.store_settings;
  CREATE POLICY "Anyone can view settings" ON public.store_settings FOR SELECT USING (true);
  DROP POLICY IF EXISTS "Admins can manage settings" ON public.store_settings;
  CREATE POLICY "Admins can manage settings" ON public.store_settings FOR ALL USING (public.is_admin(auth.uid()));

  -- reviews
  DROP POLICY IF EXISTS "Anyone can view approved reviews" ON public.reviews;
  CREATE POLICY "Anyone can view approved reviews" ON public.reviews FOR SELECT USING (is_approved = true OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Anyone can submit reviews" ON public.reviews;
  CREATE POLICY "Anyone can submit reviews" ON public.reviews FOR INSERT WITH CHECK (name IS NOT NULL AND text IS NOT NULL AND rating >= 1 AND rating <= 5);
  DROP POLICY IF EXISTS "Admins can manage reviews" ON public.reviews;
  CREATE POLICY "Admins can manage reviews" ON public.reviews FOR ALL USING (public.is_admin(auth.uid()));

  -- site_settings
  DROP POLICY IF EXISTS "Anyone can view site settings" ON public.site_settings;
  CREATE POLICY "Anyone can view site settings" ON public.site_settings FOR SELECT USING (true);
  DROP POLICY IF EXISTS "Admins can update site settings" ON public.site_settings;
  CREATE POLICY "Admins can update site settings" ON public.site_settings FOR UPDATE USING (is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can insert site settings" ON public.site_settings;
  CREATE POLICY "Admins can insert site settings" ON public.site_settings FOR INSERT WITH CHECK (is_admin(auth.uid()));

  -- shipping_methods
  DROP POLICY IF EXISTS "Anyone can view active shipping methods" ON public.shipping_methods;
  CREATE POLICY "Anyone can view active shipping methods" ON public.shipping_methods FOR SELECT USING (is_active = true OR is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage shipping methods" ON public.shipping_methods;
  CREATE POLICY "Admins can manage shipping methods" ON public.shipping_methods FOR ALL USING (is_admin(auth.uid()));

  -- courier_settings
  DROP POLICY IF EXISTS "Admins can manage courier settings" ON public.courier_settings;
  CREATE POLICY "Admins can manage courier settings" ON public.courier_settings FOR ALL USING (is_admin(auth.uid()));

  -- courier_logs
  DROP POLICY IF EXISTS "Admins can view courier logs" ON public.courier_logs;
  CREATE POLICY "Admins can view courier logs" ON public.courier_logs FOR SELECT USING (is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can insert courier logs" ON public.courier_logs;
  CREATE POLICY "Admins can insert courier logs" ON public.courier_logs FOR INSERT WITH CHECK (is_admin(auth.uid()));

  -- checkout_leads
  DROP POLICY IF EXISTS "Anyone can create leads" ON public.checkout_leads;
  CREATE POLICY "Anyone can create leads" ON public.checkout_leads FOR INSERT WITH CHECK (true);
  DROP POLICY IF EXISTS "Admins can view all leads" ON public.checkout_leads;
  CREATE POLICY "Admins can view all leads" ON public.checkout_leads FOR SELECT USING (is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can update all leads" ON public.checkout_leads;
  CREATE POLICY "Admins can update all leads" ON public.checkout_leads FOR UPDATE USING (is_admin(auth.uid()));

END $$;

-- Step 7: Indexes
CREATE INDEX IF NOT EXISTS idx_orders_courier_tracking ON public.orders(courier_tracking_id);
CREATE INDEX IF NOT EXISTS idx_orders_courier_consignment ON public.orders(courier_consignment_id);
CREATE INDEX IF NOT EXISTS idx_courier_logs_order_id ON public.courier_logs(order_id);
CREATE INDEX IF NOT EXISTS idx_checkout_leads_phone_created ON public.checkout_leads(phone, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_checkout_leads_status ON public.checkout_leads(status);
CREATE INDEX IF NOT EXISTS idx_checkout_leads_lead_token ON public.checkout_leads(lead_token);

-- Step 8: Storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('shop-images', 'shop-images', true)
ON CONFLICT (id) DO NOTHING;

DO $$ BEGIN
  DROP POLICY IF EXISTS "Public can view shop images" ON storage.objects;
  CREATE POLICY "Public can view shop images" ON storage.objects FOR SELECT USING (bucket_id = 'shop-images');
  DROP POLICY IF EXISTS "Admins can upload shop images" ON storage.objects;
  CREATE POLICY "Admins can upload shop images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'shop-images' AND is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can update shop images" ON storage.objects;
  CREATE POLICY "Admins can update shop images" ON storage.objects FOR UPDATE USING (bucket_id = 'shop-images' AND is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can delete shop images" ON storage.objects;
  CREATE POLICY "Admins can delete shop images" ON storage.objects FOR DELETE USING (bucket_id = 'shop-images' AND is_admin(auth.uid()));
END $$;

-- Step 9: Default data (ON CONFLICT DO NOTHING = safe to re-run)
INSERT INTO public.site_settings (id) VALUES ('global') ON CONFLICT (id) DO NOTHING;

INSERT INTO public.store_settings (key, value) VALUES
  ('store_name', 'Al-Raiyan Perfume'),
  ('store_email', 'alraiyan0166@gmail.com'),
  ('store_phone', '+880 1633 666834'),
  ('store_address', 'Bangladesh'),
  ('shipping_inside_dhaka', '60'),
  ('shipping_outside_dhaka', '120'),
  ('site_title', 'Al-Raiyan Perfume - Pure Natural Attar'),
  ('meta_description', 'Al-Raiyan Perfume - 100% pure natural attars crafted from the finest essences.')
ON CONFLICT (key) DO NOTHING;

INSERT INTO public.slider_slides (image, heading, text, cta_text, cta_link, sort_order) VALUES
  ('/al-raiyan-banner.jpg', 'Al-Raiyan Perfume', 'Exquisite Scents of Purity & Luxury', 'Shop Now', '/shop', 1),
  ('/special-combo-banner.jpg', 'Special Combo', 'Best Selling Three Products', 'View Combo', '/shop', 2)
ON CONFLICT DO NOTHING;

INSERT INTO public.reviews (name, rating, text, is_approved) VALUES
  ('Sarah Johnson', 5, 'Absolutely love the quality! The fragrance lasts all day.', true),
  ('Ahmed Khan', 5, 'Kasturi Gold is amazing. Pure and long-lasting!', true),
  ('Fatima Rahman', 5, 'Best attar I have ever used. Will order again!', true)
ON CONFLICT DO NOTHING;

INSERT INTO public.shipping_methods (name, description, base_rate, estimated_days, sort_order) VALUES
  ('Inside Dhaka', 'Standard delivery within Dhaka city', 60, '1-2 days', 1),
  ('Outside Dhaka', 'Delivery outside Dhaka', 120, '2-4 days', 2)
ON CONFLICT DO NOTHING;

RAISE NOTICE 'Safe migration completed successfully!';
