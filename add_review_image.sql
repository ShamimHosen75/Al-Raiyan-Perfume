-- Add image_url to reviews table
ALTER TABLE public.reviews
ADD COLUMN IF NOT EXISTS image_url TEXT;
