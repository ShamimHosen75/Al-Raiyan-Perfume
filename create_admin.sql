-- =============================================
-- CREATE ADMIN USER - Al-Raiyan Perfume
-- Run this in Supabase SQL Editor
-- =============================================

DO $$
DECLARE
  new_user_id UUID;
BEGIN
  -- Check if user already exists
  SELECT id INTO new_user_id FROM auth.users WHERE email = 'alraiyan0166@gmail.com';

  -- Only create if they don't exist yet
  IF new_user_id IS NULL THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      aud,
      role,
      created_at,
      updated_at
    )
    VALUES (
      gen_random_uuid(),
      '00000000-0000-0000-0000-000000000000',
      'alraiyan0166@gmail.com',
      crypt('#Alraiyan#0166@', gen_salt('bf')),
      now(),
      '{"provider": "email", "providers": ["email"]}',
      '{"full_name": "Al-Raiyan Admin"}',
      'authenticated',
      'authenticated',
      now(),
      now()
    )
    RETURNING id INTO new_user_id;

    RAISE NOTICE 'New user created with ID: %', new_user_id;
  ELSE
    RAISE NOTICE 'User already exists with ID: %', new_user_id;
  END IF;

  -- Create profile (skip if exists)
  INSERT INTO public.profiles (user_id, full_name, email)
  VALUES (new_user_id, 'Al-Raiyan Admin', 'alraiyan0166@gmail.com')
  ON CONFLICT (user_id) DO NOTHING;

  -- Assign admin role (skip if exists)
  INSERT INTO public.user_roles (user_id, role)
  VALUES (new_user_id, 'admin')
  ON CONFLICT (user_id, role) DO NOTHING;

  RAISE NOTICE 'Admin setup complete! User ID: %', new_user_id;
END $$;
