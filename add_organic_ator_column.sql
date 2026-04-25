-- Migration: Add is_organic_ator column to products table
-- Run this in your Supabase SQL editor

ALTER TABLE products
ADD COLUMN IF NOT EXISTS is_organic_ator BOOLEAN NOT NULL DEFAULT FALSE;

-- Optional: Create an index for faster filtering
CREATE INDEX IF NOT EXISTS idx_products_is_organic_ator ON products (is_organic_ator);
