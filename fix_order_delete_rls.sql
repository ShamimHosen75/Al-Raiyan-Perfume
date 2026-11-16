-- =============================================
-- Fix: Allow Admins to DELETE orders & order_items
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor)
-- =============================================

-- 1. Allow admins to delete orders
CREATE POLICY "Admins can delete orders"
  ON public.orders
  FOR DELETE
  USING (public.is_admin(auth.uid()));

-- 2. Allow admins to delete order_items
CREATE POLICY "Admins can delete order items"
  ON public.order_items
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND public.is_admin(auth.uid())
    )
  );

-- Verify policies were created
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('orders', 'order_items')
ORDER BY tablename, cmd;
