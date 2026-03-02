-- =============================================
-- FIX RLS POLICIES FOR PUBLIC ACCESS
-- Run this in Supabase SQL Editor
-- =============================================

-- First check product status
SELECT name, is_active FROM products LIMIT 5;

-- Fix products RLS - allow anonymous users to read
DROP POLICY IF EXISTS "Anyone can view active products" ON public.products;
DROP POLICY IF EXISTS "Public can view active products" ON public.products;

CREATE POLICY "Public can view active products" 
ON public.products 
FOR SELECT 
TO anon, authenticated
USING (is_active = true);

-- Fix categories RLS
DROP POLICY IF EXISTS "Anyone can view active categories" ON public.categories;
DROP POLICY IF EXISTS "Public can view active categories" ON public.categories;

CREATE POLICY "Public can view active categories" 
ON public.categories 
FOR SELECT 
TO anon, authenticated
USING (is_active = true);

-- Fix slider RLS  
DROP POLICY IF EXISTS "Anyone can view active slides" ON public.slider_slides;
DROP POLICY IF EXISTS "Public can view active slides" ON public.slider_slides;

CREATE POLICY "Public can view active slides" 
ON public.slider_slides 
FOR SELECT 
TO anon, authenticated
USING (is_active = true);

-- Fix reviews RLS
DROP POLICY IF EXISTS "Anyone can view approved reviews" ON public.reviews;
DROP POLICY IF EXISTS "Public can view approved reviews" ON public.reviews;

CREATE POLICY "Public can view approved reviews" 
ON public.reviews 
FOR SELECT 
TO anon, authenticated
USING (is_approved = true);

-- Fix site_settings RLS
DROP POLICY IF EXISTS "Anyone can view site settings" ON public.site_settings;
DROP POLICY IF EXISTS "Public can view site settings" ON public.site_settings;

CREATE POLICY "Public can view site settings" 
ON public.site_settings 
FOR SELECT 
TO anon, authenticated
USING (true);

-- Fix store_settings RLS
DROP POLICY IF EXISTS "Anyone can view settings" ON public.store_settings;
DROP POLICY IF EXISTS "Public can view settings" ON public.store_settings;

CREATE POLICY "Public can view settings" 
ON public.store_settings 
FOR SELECT 
TO anon, authenticated
USING (true);

-- Verify products are accessible
SELECT 'Products accessible: ' || COUNT(*)::text FROM products WHERE is_active = true;
