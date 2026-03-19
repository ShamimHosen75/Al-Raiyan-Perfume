import { lazy, Suspense } from "react";
import { Loader2 } from "lucide-react";
import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { CartProvider } from "@/contexts/CartContext";
import { AuthProvider } from "@/hooks/useAuth";
import { SiteSettingsProvider } from "@/contexts/SiteSettingsContext";
import { ErrorBoundary } from "@/components/ErrorBoundary";
import { DebugPanel } from "@/components/DebugPanel";
import { FacebookPixelProvider } from "@/components/FacebookPixelProvider";
import { CookieConsentBanner } from "@/components/CookieConsentBanner";
import { ScrollToTop } from "@/components/ScrollToTop";
// Store pages
const Index = lazy(() => import("./pages/Index"));
const ShopPage = lazy(() => import("./pages/ShopPage"));
const CategoriesPage = lazy(() => import("./pages/CategoriesPage"));
const CategoryPage = lazy(() => import("./pages/CategoryPage"));
const ProductDetailsPage = lazy(() => import("./pages/ProductDetailsPage"));
const CartPage = lazy(() => import("./pages/CartPage"));
const CheckoutPage = lazy(() => import("./pages/CheckoutPage"));
const OrderSuccessPage = lazy(() => import("./pages/OrderSuccessPage"));
const ContactPage = lazy(() => import("./pages/ContactPage"));
const AboutPage = lazy(() => import("./pages/AboutPage"));
const FAQPage = lazy(() => import("./pages/FAQPage"));
const NotFound = lazy(() => import("./pages/NotFound"));

// Admin pages
const AdminLoginPage = lazy(() => import("./pages/admin/AdminLoginPage"));
const AdminRegisterPage = lazy(() => import("./pages/admin/AdminRegisterPage"));
const AdminLayout = lazy(() => import("./pages/admin/AdminLayout"));
const AdminDashboard = lazy(() => import("./pages/admin/AdminDashboard"));
const AdminProducts = lazy(() => import("./pages/admin/AdminProducts"));
const AdminCategories = lazy(() => import("./pages/admin/AdminCategories"));
const AdminOrders = lazy(() => import("./pages/admin/AdminOrders"));
const AdminSlider = lazy(() => import("./pages/admin/AdminSlider"));
const AdminSettings = lazy(() => import("./pages/admin/AdminSettings"));
const AdminCourierSettings = lazy(() => import("./pages/admin/AdminCourierSettings"));
const AdminCoupons = lazy(() => import("./pages/admin/AdminCoupons"));
const AdminShipping = lazy(() => import("./pages/admin/AdminShipping"));
const AdminShippingMethods = lazy(() => import("./pages/admin/AdminShippingMethods"));
const AdminReviews = lazy(() => import("./pages/admin/AdminReviews"));
const AdminCheckoutLeads = lazy(() => import("./pages/admin/AdminCheckoutLeads"));
const AdminUsers = lazy(() => import("./pages/admin/AdminUsers"));
const AdminPaymentMethods = lazy(() => import("./pages/admin/AdminPaymentMethods"));
const TrackOrderPage = lazy(() => import("./pages/TrackOrderPage"));
import ProtectedAdminRoute from "./components/admin/ProtectedAdminRoute";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      staleTime: 5 * 60 * 1000,
      refetchOnWindowFocus: false,
    },
  },
});

const App = () => (
  <ErrorBoundary>
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <SiteSettingsProvider>
          <CartProvider>
            <TooltipProvider>
              <Toaster />
              <Sonner />
              <BrowserRouter>
                <FacebookPixelProvider>
                  <ScrollToTop />
                  <Suspense fallback={
                    <div className="min-h-screen flex items-center justify-center">
                      <Loader2 className="h-8 w-8 animate-spin text-primary" />
                    </div>
                  }>
                    <Routes>
                    {/* Public Store Routes - No auth required */}
                    <Route path="/" element={<Index />} />
                    <Route path="/shop" element={<ShopPage />} />
                    <Route path="/categories" element={<CategoriesPage />} />
                    <Route path="/category/:slug" element={<CategoryPage />} />
                    <Route path="/product/:slug" element={<ProductDetailsPage />} />
                    <Route path="/cart" element={<CartPage />} />
                    <Route path="/checkout" element={<CheckoutPage />} />
                    <Route path="/order-success" element={<OrderSuccessPage />} />
                    <Route path="/contact" element={<ContactPage />} />
                    <Route path="/about" element={<AboutPage />} />
                    <Route path="/faq" element={<FAQPage />} />
                    <Route path="/track-order" element={<TrackOrderPage />} />

                    {/* Admin Auth Routes - No protection */}
                    <Route path="/admin/login" element={<AdminLoginPage />} />
                    <Route path="/admin/register" element={<AdminRegisterPage />} />

                    {/* Protected Admin Routes */}
                    <Route element={<ProtectedAdminRoute />}>
                      <Route path="/admin" element={<AdminLayout />}>
                        <Route index element={<AdminDashboard />} />
                        <Route path="products" element={<AdminProducts />} />
                        <Route path="categories" element={<AdminCategories />} />
                        <Route path="orders" element={<AdminOrders />} />
                        <Route path="slider" element={<AdminSlider />} />
                        <Route path="settings" element={<AdminSettings />} />
                        <Route path="courier" element={<AdminCourierSettings />} />
                        <Route path="coupons" element={<AdminCoupons />} />
                        <Route path="shipping" element={<AdminShipping />} />
                        <Route path="shipping-methods" element={<AdminShippingMethods />} />
                        <Route path="reviews" element={<AdminReviews />} />
                        <Route path="leads" element={<AdminCheckoutLeads />} />
                        <Route path="users" element={<AdminUsers />} />
                        <Route path="payment-methods" element={<AdminPaymentMethods />} />
                      </Route>
                    </Route>

                    {/* Catch-all */}
                    <Route path="*" element={<NotFound />} />
                  </Routes>
                  </Suspense>
                  <CookieConsentBanner />
                  <DebugPanel />
                </FacebookPixelProvider>
              </BrowserRouter>
            </TooltipProvider>
          </CartProvider>
        </SiteSettingsProvider>
      </AuthProvider>
    </QueryClientProvider>
  </ErrorBoundary>
);

export default App;
