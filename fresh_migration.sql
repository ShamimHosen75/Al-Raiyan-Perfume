-- =============================================
-- AL-RAIYAN PERFUME - FRESH DATABASE MIGRATION
-- Run this in Supabase SQL Editor (fresh start)
-- =============================================

-- =========================================
-- STEP 1: ENUMS
-- =========================================
DO $$ BEGIN
  CREATE TYPE public.order_status AS ENUM ('pending','processing','shipped','delivered','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.app_role AS ENUM ('admin','customer','manager','order_handler');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;


-- =========================================
-- STEP 2: TABLES
-- =========================================

-- User roles
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role app_role NOT NULL DEFAULT 'customer',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (user_id, role)
);

-- Profiles
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    full_name TEXT,
    phone TEXT,
    email TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Categories
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    image TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Products
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
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Product Variants
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

-- Slider Slides
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

-- Payment Methods
CREATE TABLE IF NOT EXISTS public.payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    description TEXT,
    instructions TEXT,
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    allow_partial_delivery_payment BOOLEAN NOT NULL DEFAULT false,
    partial_type TEXT DEFAULT 'delivery_charge',
    fixed_partial_amount NUMERIC,
    require_transaction_id BOOLEAN NOT NULL DEFAULT false,
    provider_fields JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Orders
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
    payment_method_id UUID REFERENCES public.payment_methods(id),
    payment_method_name TEXT,
    payment_status TEXT NOT NULL DEFAULT 'unpaid',
    paid_amount NUMERIC NOT NULL DEFAULT 0,
    due_amount NUMERIC NOT NULL DEFAULT 0,
    transaction_id TEXT,
    partial_rule_snapshot JSONB,
    subtotal DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    status order_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    courier_provider TEXT,
    courier_status TEXT,
    courier_tracking_id TEXT,
    courier_consignment_id TEXT,
    courier_reference TEXT,
    courier_payload JSONB,
    courier_response JSONB,
    courier_created_at TIMESTAMP WITH TIME ZONE,
    courier_updated_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Order Items
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    product_image TEXT,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    line_total NUMERIC GENERATED ALWAYS AS (price * quantity) STORED,
    variant_info JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Store Settings (key-value pairs)
CREATE TABLE IF NOT EXISTS public.store_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE,
    value TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Site Settings (single global row)
CREATE TABLE IF NOT EXISTS public.site_settings (
    id TEXT PRIMARY KEY DEFAULT 'global',
    default_country_code TEXT NOT NULL DEFAULT 'BD',
    default_country_name TEXT NOT NULL DEFAULT 'Bangladesh',
    currency_code TEXT NOT NULL DEFAULT 'BDT',
    currency_symbol TEXT NOT NULL DEFAULT '৳',
    currency_locale TEXT NOT NULL DEFAULT 'bn-BD',
    language TEXT NOT NULL DEFAULT 'en' CHECK (language IN ('en', 'hi', 'bn')),
    fb_pixel_enabled BOOLEAN NOT NULL DEFAULT false,
    fb_pixel_id TEXT,
    fb_pixel_test_event_code TEXT,
    cookie_consent_enabled BOOLEAN NOT NULL DEFAULT false,
    theme_accent_color TEXT DEFAULT '#e85a4f',
    brand_primary TEXT DEFAULT '#1a1a2e',
    brand_secondary TEXT DEFAULT '#f0f0f0',
    brand_accent TEXT DEFAULT '#e85a4f',
    brand_background TEXT DEFAULT '#faf9f7',
    brand_foreground TEXT DEFAULT '#1a1a2e',
    brand_muted TEXT DEFAULT '#6b7280',
    brand_border TEXT DEFAULT '#e5e7eb',
    brand_card TEXT DEFAULT '#ffffff',
    brand_radius TEXT DEFAULT '0.5',
    fb_capi_enabled BOOLEAN NOT NULL DEFAULT false,
    fb_capi_dataset_id TEXT DEFAULT NULL,
    fb_capi_test_event_code TEXT DEFAULT NULL,
    fb_capi_api_version TEXT NOT NULL DEFAULT 'v20.0',
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Reviews
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Shipping Methods
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

-- Courier Settings
CREATE TABLE IF NOT EXISTS public.courier_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider TEXT NOT NULL UNIQUE,
    enabled BOOLEAN DEFAULT false,
    api_base_url TEXT,
    api_key TEXT,
    api_secret TEXT,
    merchant_id TEXT,
    pickup_address TEXT,
    pickup_phone TEXT,
    default_weight NUMERIC DEFAULT 0.5,
    cod_enabled BOOLEAN DEFAULT true,
    show_tracking_to_customer BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Courier Logs
CREATE TABLE IF NOT EXISTS public.courier_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    provider TEXT NOT NULL,
    action TEXT NOT NULL,
    status TEXT,
    message TEXT,
    request_payload JSONB,
    response_payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Checkout Leads
CREATE TABLE IF NOT EXISTS public.checkout_leads (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    lead_no TEXT NOT NULL UNIQUE,
    lead_token TEXT NOT NULL UNIQUE DEFAULT gen_random_uuid()::TEXT,
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new','contacted','converted','invalid')),
    source TEXT NOT NULL DEFAULT 'checkout',
    customer_name TEXT,
    phone TEXT NOT NULL,
    email TEXT,
    address TEXT,
    city TEXT,
    country TEXT,
    notes TEXT,
    items JSONB NOT NULL DEFAULT '[]'::JSONB,
    subtotal NUMERIC NOT NULL DEFAULT 0,
    shipping_fee NUMERIC NOT NULL DEFAULT 0,
    total NUMERIC NOT NULL DEFAULT 0,
    currency_code TEXT NOT NULL DEFAULT 'BDT',
    page_url TEXT,
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign TEXT,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    last_activity_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    converted_order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL
);

-- Wishlists
CREATE TABLE IF NOT EXISTS public.wishlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id TEXT,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (user_id, product_id),
    UNIQUE (session_id, product_id)
);

-- CAPI Secrets (service_role only)
CREATE TABLE IF NOT EXISTS public.capi_secrets (
    id TEXT PRIMARY KEY DEFAULT 'global',
    access_token TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Coupons
CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    description TEXT,
    discount_type TEXT NOT NULL DEFAULT 'percentage',
    discount_value NUMERIC NOT NULL DEFAULT 0,
    min_order_amount NUMERIC NOT NULL DEFAULT 0,
    max_uses INT,
    used_count INT NOT NULL DEFAULT 0,
    starts_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);


-- =========================================
-- STEP 3: ENABLE ROW LEVEL SECURITY
-- =========================================
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.slider_slides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courier_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courier_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.checkout_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.capi_secrets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;


-- =========================================
-- STEP 4: HELPER FUNCTIONS
-- =========================================
CREATE OR REPLACE FUNCTION public.is_admin(_user_id UUID)
RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = 'admin')
$$;

CREATE OR REPLACE FUNCTION public.has_any_staff_role(_user_id UUID)
RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role IN ('admin','manager','order_handler'))
$$;

CREATE OR REPLACE FUNCTION public.can_manage_orders(_user_id UUID)
RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role IN ('admin','manager','order_handler'))
$$;

CREATE OR REPLACE FUNCTION public.can_manage_products(_user_id UUID)
RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role IN ('admin','manager'))
$$;

CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$ LANGUAGE plpgsql SET search_path = public;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (user_id, email, is_active) VALUES (NEW.id, NEW.email, true) ON CONFLICT DO NOTHING;
  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'customer') ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.generate_lead_number()
RETURNS TRIGGER AS $$
DECLARE
  year_str TEXT;
  seq_num INTEGER;
BEGIN
  year_str := to_char(now(), 'YYYY');
  SELECT COALESCE(MAX(CAST(NULLIF(regexp_replace(lead_no, '^LEAD-' || year_str || '-', ''), '') AS INTEGER)), 0) + 1
    INTO seq_num
    FROM public.checkout_leads
    WHERE lead_no LIKE 'LEAD-' || year_str || '-%';
  NEW.lead_no := 'LEAD-' || year_str || '-' || LPAD(seq_num::TEXT, 4, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;


-- =========================================
-- STEP 5: TRIGGERS
-- =========================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_categories_updated_at ON public.categories;
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_products_updated_at ON public.products;
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_product_variants_updated_at ON public.product_variants;
CREATE TRIGGER update_product_variants_updated_at BEFORE UPDATE ON public.product_variants FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_slider_slides_updated_at ON public.slider_slides;
CREATE TRIGGER update_slider_slides_updated_at BEFORE UPDATE ON public.slider_slides FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_store_settings_updated_at ON public.store_settings;
CREATE TRIGGER update_store_settings_updated_at BEFORE UPDATE ON public.store_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_site_settings_updated_at ON public.site_settings;
CREATE TRIGGER update_site_settings_updated_at BEFORE UPDATE ON public.site_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_shipping_methods_updated_at ON public.shipping_methods;
CREATE TRIGGER update_shipping_methods_updated_at BEFORE UPDATE ON public.shipping_methods FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_courier_settings_updated_at ON public.courier_settings;
CREATE TRIGGER update_courier_settings_updated_at BEFORE UPDATE ON public.courier_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_payment_methods_updated_at ON public.payment_methods;
CREATE TRIGGER update_payment_methods_updated_at BEFORE UPDATE ON public.payment_methods FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_coupons_updated_at ON public.coupons;
CREATE TRIGGER update_coupons_updated_at BEFORE UPDATE ON public.coupons FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_generate_lead_number ON public.checkout_leads;
CREATE TRIGGER trigger_generate_lead_number
  BEFORE INSERT ON public.checkout_leads
  FOR EACH ROW WHEN (NEW.lead_no IS NULL OR NEW.lead_no = '')
  EXECUTE FUNCTION public.generate_lead_number();

DROP TRIGGER IF EXISTS update_checkout_leads_updated_at ON public.checkout_leads;
CREATE TRIGGER update_checkout_leads_updated_at BEFORE UPDATE ON public.checkout_leads FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


-- =========================================
-- STEP 6: RLS POLICIES
-- =========================================
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
  DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
  CREATE POLICY "Admins can view all profiles" ON public.profiles FOR SELECT USING (public.is_admin(auth.uid()));

  -- categories
  DROP POLICY IF EXISTS "Anyone can view active categories" ON public.categories;
  CREATE POLICY "Anyone can view active categories" ON public.categories FOR SELECT USING (is_active = true OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage categories" ON public.categories;
  CREATE POLICY "Admins can manage categories" ON public.categories FOR ALL USING (public.is_admin(auth.uid()));

  -- products
  DROP POLICY IF EXISTS "Anyone can view active products" ON public.products;
  CREATE POLICY "Anyone can view active products" ON public.products FOR SELECT USING (is_active = true OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Staff can manage products" ON public.products;
  CREATE POLICY "Staff can manage products" ON public.products FOR ALL USING (can_manage_products(auth.uid()));

  -- product_variants
  DROP POLICY IF EXISTS "Anyone can view active variants" ON public.product_variants;
  CREATE POLICY "Anyone can view active variants" ON public.product_variants FOR SELECT USING ((is_active = true) OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage variants" ON public.product_variants;
  CREATE POLICY "Admins can manage variants" ON public.product_variants FOR ALL USING (public.is_admin(auth.uid()));

  -- slider_slides
  DROP POLICY IF EXISTS "Anyone can view active slides" ON public.slider_slides;
  CREATE POLICY "Anyone can view active slides" ON public.slider_slides FOR SELECT USING (is_active = true OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage slides" ON public.slider_slides;
  CREATE POLICY "Admins can manage slides" ON public.slider_slides FOR ALL USING (public.is_admin(auth.uid()));

  -- payment_methods
  DROP POLICY IF EXISTS "Anyone can view enabled payment methods" ON public.payment_methods;
  CREATE POLICY "Anyone can view enabled payment methods" ON public.payment_methods FOR SELECT USING (is_enabled = true OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage payment methods" ON public.payment_methods;
  CREATE POLICY "Admins can manage payment methods" ON public.payment_methods FOR ALL USING (public.is_admin(auth.uid()));

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
    EXISTS (SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND (orders.user_id = auth.uid() OR public.is_admin(auth.uid()) OR orders.user_id IS NULL))
  );
  DROP POLICY IF EXISTS "Anyone can create order items" ON public.order_items;
  CREATE POLICY "Anyone can create order items" ON public.order_items FOR INSERT WITH CHECK (true);

  -- store_settings
  DROP POLICY IF EXISTS "Anyone can view settings" ON public.store_settings;
  CREATE POLICY "Anyone can view settings" ON public.store_settings FOR SELECT USING (true);
  DROP POLICY IF EXISTS "Admins can manage settings" ON public.store_settings;
  CREATE POLICY "Admins can manage settings" ON public.store_settings FOR ALL USING (public.is_admin(auth.uid()));

  -- site_settings
  DROP POLICY IF EXISTS "Anyone can view site settings" ON public.site_settings;
  CREATE POLICY "Anyone can view site settings" ON public.site_settings FOR SELECT USING (true);
  DROP POLICY IF EXISTS "Admins can update site settings" ON public.site_settings;
  CREATE POLICY "Admins can update site settings" ON public.site_settings FOR UPDATE USING (public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can insert site settings" ON public.site_settings;
  CREATE POLICY "Admins can insert site settings" ON public.site_settings FOR INSERT WITH CHECK (public.is_admin(auth.uid()));

  -- reviews
  DROP POLICY IF EXISTS "Anyone can view approved reviews" ON public.reviews;
  CREATE POLICY "Anyone can view approved reviews" ON public.reviews FOR SELECT USING (is_approved = true OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Anyone can submit reviews" ON public.reviews;
  CREATE POLICY "Anyone can submit reviews" ON public.reviews FOR INSERT WITH CHECK (name IS NOT NULL AND text IS NOT NULL AND rating >= 1 AND rating <= 5);
  DROP POLICY IF EXISTS "Admins can manage reviews" ON public.reviews;
  CREATE POLICY "Admins can manage reviews" ON public.reviews FOR ALL USING (public.is_admin(auth.uid()));

  -- shipping_methods
  DROP POLICY IF EXISTS "Anyone can view active shipping methods" ON public.shipping_methods;
  CREATE POLICY "Anyone can view active shipping methods" ON public.shipping_methods FOR SELECT USING (is_active = true OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage shipping methods" ON public.shipping_methods;
  CREATE POLICY "Admins can manage shipping methods" ON public.shipping_methods FOR ALL USING (public.is_admin(auth.uid()));

  -- courier_settings
  DROP POLICY IF EXISTS "Admins can manage courier settings" ON public.courier_settings;
  CREATE POLICY "Admins can manage courier settings" ON public.courier_settings FOR ALL USING (public.is_admin(auth.uid()));

  -- courier_logs
  DROP POLICY IF EXISTS "Admins can view courier logs" ON public.courier_logs;
  CREATE POLICY "Admins can view courier logs" ON public.courier_logs FOR SELECT USING (public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can insert courier logs" ON public.courier_logs;
  CREATE POLICY "Admins can insert courier logs" ON public.courier_logs FOR INSERT WITH CHECK (public.is_admin(auth.uid()));

  -- checkout_leads
  DROP POLICY IF EXISTS "Anyone can create leads" ON public.checkout_leads;
  CREATE POLICY "Anyone can create leads" ON public.checkout_leads FOR INSERT WITH CHECK (true);
  DROP POLICY IF EXISTS "Admins can view all leads" ON public.checkout_leads;
  CREATE POLICY "Admins can view all leads" ON public.checkout_leads FOR SELECT USING (public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can update all leads" ON public.checkout_leads;
  CREATE POLICY "Admins can update all leads" ON public.checkout_leads FOR UPDATE USING (public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can delete leads" ON public.checkout_leads;
  CREATE POLICY "Admins can delete leads" ON public.checkout_leads FOR DELETE USING (public.is_admin(auth.uid()));

  -- wishlists
  DROP POLICY IF EXISTS "Users can manage their own wishlist" ON public.wishlists;
  CREATE POLICY "Users can manage their own wishlist" ON public.wishlists FOR ALL USING (
    (user_id IS NOT NULL AND auth.uid() = user_id) OR user_id IS NULL
  );
  DROP POLICY IF EXISTS "Anyone can view wishlists" ON public.wishlists;
  CREATE POLICY "Anyone can view wishlists" ON public.wishlists FOR SELECT USING (true);
  DROP POLICY IF EXISTS "Anyone can insert wishlist items" ON public.wishlists;
  CREATE POLICY "Anyone can insert wishlist items" ON public.wishlists FOR INSERT WITH CHECK (true);
  DROP POLICY IF EXISTS "Anyone can delete wishlist items" ON public.wishlists;
  CREATE POLICY "Anyone can delete wishlist items" ON public.wishlists FOR DELETE USING (
    (user_id IS NOT NULL AND auth.uid() = user_id) OR user_id IS NULL
  );

  -- coupons
  DROP POLICY IF EXISTS "Anyone can view active coupons" ON public.coupons;
  CREATE POLICY "Anyone can view active coupons" ON public.coupons FOR SELECT USING (is_active = true OR public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can manage coupons" ON public.coupons;
  CREATE POLICY "Admins can manage coupons" ON public.coupons FOR ALL USING (public.is_admin(auth.uid()));

END $$;


-- =========================================
-- STEP 7: INDEXES
-- =========================================
CREATE INDEX IF NOT EXISTS idx_orders_courier_tracking     ON public.orders(courier_tracking_id);
CREATE INDEX IF NOT EXISTS idx_orders_courier_consignment  ON public.orders(courier_consignment_id);
CREATE INDEX IF NOT EXISTS idx_courier_logs_order_id       ON public.courier_logs(order_id);
CREATE INDEX IF NOT EXISTS idx_checkout_leads_phone_created ON public.checkout_leads(phone, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_checkout_leads_status       ON public.checkout_leads(status);
CREATE INDEX IF NOT EXISTS idx_checkout_leads_lead_token   ON public.checkout_leads(lead_token);
CREATE INDEX IF NOT EXISTS idx_wishlists_user_id           ON public.wishlists(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlists_session_id        ON public.wishlists(session_id);
CREATE INDEX IF NOT EXISTS idx_wishlists_product_id        ON public.wishlists(product_id);


-- =========================================
-- STEP 8: STORAGE BUCKET
-- =========================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('shop-images', 'shop-images', true)
ON CONFLICT (id) DO NOTHING;

DO $$ BEGIN
  DROP POLICY IF EXISTS "Public can view shop images" ON storage.objects;
  CREATE POLICY "Public can view shop images" ON storage.objects FOR SELECT USING (bucket_id = 'shop-images');
  DROP POLICY IF EXISTS "Admins can upload shop images" ON storage.objects;
  CREATE POLICY "Admins can upload shop images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'shop-images' AND public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can update shop images" ON storage.objects;
  CREATE POLICY "Admins can update shop images" ON storage.objects FOR UPDATE USING (bucket_id = 'shop-images' AND public.is_admin(auth.uid()));
  DROP POLICY IF EXISTS "Admins can delete shop images" ON storage.objects;
  CREATE POLICY "Admins can delete shop images" ON storage.objects FOR DELETE USING (bucket_id = 'shop-images' AND public.is_admin(auth.uid()));
END $$;


-- =========================================
-- STEP 9: DEFAULT DATA
-- =========================================

-- Site settings
INSERT INTO public.site_settings (id) VALUES ('global') ON CONFLICT (id) DO NOTHING;

-- CAPI secrets
INSERT INTO public.capi_secrets (id) VALUES ('global') ON CONFLICT (id) DO NOTHING;

-- Store settings
INSERT INTO public.store_settings (key, value) VALUES
  ('store_name',        'Al-Raiyan Perfume'),
  ('store_email',       'alraiyan0166@gmail.com'),
  ('store_phone',       '+880 1633 666834'),
  ('store_address',     'Bangladesh'),
  ('shipping_inside_dhaka',  '60'),
  ('shipping_outside_dhaka', '120'),
  ('site_title',        'Al-Raiyan Perfume - Pure Natural Attar'),
  ('meta_description',  'Al-Raiyan Perfume - 100% pure natural attars crafted from the finest essences.')
ON CONFLICT (key) DO NOTHING;

-- Slider slides
INSERT INTO public.slider_slides (image, heading, text, cta_text, cta_link, sort_order) VALUES
  ('/al-raiyan-banner.jpg',     'Al-Raiyan Perfume', 'Exquisite Scents of Purity & Luxury', 'Shop Now',   '/shop', 1),
  ('/special-combo-banner.jpg', 'Special Combo',     'Best Selling Three Products',           'View Combo', '/shop', 2)
ON CONFLICT DO NOTHING;

-- Default reviews
INSERT INTO public.reviews (name, rating, text, is_approved) VALUES
  ('Sarah Johnson', 5, 'Absolutely love the quality! The fragrance lasts all day.', true),
  ('Ahmed Khan',    5, 'Kasturi Gold is amazing. Pure and long-lasting!',           true),
  ('Fatima Rahman', 5, 'Best attar I have ever used. Will order again!',            true)
ON CONFLICT DO NOTHING;

-- Shipping methods
INSERT INTO public.shipping_methods (name, description, base_rate, estimated_days, sort_order) VALUES
  ('Inside Dhaka',  'Standard delivery within Dhaka city', 60,  '1-2 days', 1),
  ('Outside Dhaka', 'Delivery outside Dhaka',              120, '2-4 days', 2)
ON CONFLICT DO NOTHING;

-- Default payment method (COD)
INSERT INTO public.payment_methods (name, code, description, sort_order) VALUES
  ('Cash on Delivery', 'cod', 'Pay when you receive your order', 0)
ON CONFLICT (code) DO NOTHING;


DO $$ BEGIN RAISE NOTICE 'Fresh migration completed successfully! All tables, policies, and default data are ready.'; END $$;
