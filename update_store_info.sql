-- Update store contact information
INSERT INTO store_settings (key, value) VALUES
  ('store_name',    'Al-Raiyan Perfume'),
  ('store_email',   'alraiyan0166@gmail.com'),
  ('store_phone',   '01712345678'),
  ('store_address', 'Dhaka'),
  ('store_city',    'Dhaka'),
  ('store_tagline', 'Exquisite Scents of Purity & Luxury')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
