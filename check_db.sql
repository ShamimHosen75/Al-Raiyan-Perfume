-- SIMPLE PRODUCT SEED - Copy and paste this into Supabase SQL Editor
-- Run this AFTER the main migration

-- First, let's check if products exist
SELECT COUNT(*) as product_count FROM products;

-- Get category IDs
SELECT id, name, slug FROM categories;
