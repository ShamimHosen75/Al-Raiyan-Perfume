-- Make SKU column nullable so products can be created without a SKU
ALTER TABLE public.products
ALTER COLUMN sku DROP NOT NULL;
