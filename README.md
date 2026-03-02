# SwiftCart Commerce

A production-ready, **reusable ecommerce boilerplate** built with React, TypeScript, Vite, and Supabase. Designed for rapid deployment to Vercel with multi-client support.

![SwiftCart Commerce](https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1200&q=80)

## 🚀 Features

- **Modern Stack**: React 18 + TypeScript + Vite + TailwindCSS
- **Backend**: Supabase (PostgreSQL + Auth + Real-time)
- **Admin Panel**: Full CRUD for products, orders, categories, settings
- **Multi-language**: English, Hindi, Bengali support
- **Dynamic Branding**: Configure colors, currency, and locale from admin panel
- **SEO Ready**: Meta tags, Open Graph, Twitter Cards
- **Mobile Responsive**: Works on all devices
- **Fast Deployment**: One-click Vercel deployment

## 📦 Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 18, TypeScript, Vite |
| Styling | TailwindCSS, shadcn/ui |
| State | TanStack Query (React Query) |
| Backend | Supabase (PostgreSQL) |
| Auth | Supabase Auth (admin panel only) |
| Deployment | Vercel |

---

## 🏁 Quick Start

### Prerequisites

- Node.js 18+ 
- npm or bun
- Supabase account (free tier works)
- Vercel account (for deployment)

### 1. Clone & Install

```bash
git clone <your-repo-url>
cd swift-cart-commerce
npm install
```

### 2. Set Up Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to **Settings > API** and copy:
   - Project URL
   - anon/public key

3. Create your `.env` file:

```bash
cp .env.example .env
```

4. Fill in your Supabase credentials:

```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key
VITE_SUPABASE_PROJECT_ID=your-project-id
```

### 3. Run Database Migrations

Option A: **Via Supabase CLI** (recommended)

```bash
npx supabase db push
```

Option B: **Via SQL Editor**

1. Go to Supabase Dashboard > SQL Editor
2. Run each file from `/supabase/migrations/` in order

### 4. Create Admin User

1. Go to Supabase Dashboard > Authentication > Users
2. Create a new user with email/password
3. Go to SQL Editor and run:

```sql
-- Replace 'your-user-id' with the actual user ID
INSERT INTO public.user_roles (user_id, role) 
VALUES ('your-user-id', 'admin');
```

### 5. Start Development Server

```bash
npm run dev
```

Visit: http://localhost:8080

---

## 🚀 Deploy to Vercel

### Option A: One-Click Deploy

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=YOUR_REPO_URL)

### Option B: Manual Deploy

1. Push your code to GitHub
2. Import project in Vercel Dashboard
3. Add environment variables:

| Variable | Value |
|----------|-------|
| `VITE_SUPABASE_URL` | Your Supabase project URL |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | Your Supabase anon key |

4. Deploy!

---

## 🎨 Customization

### Branding (via Admin Panel)

1. Navigate to `/admin/login` and sign in
2. Go to **Settings**
3. Configure:
   - Store name, email, phone, address
   - Currency (code, symbol, locale)
   - Theme colors (primary, accent, etc.)
   - Language preference

### Static Branding (index.html)

Update these files for SEO and social sharing:

- `index.html` - Title, meta description, OG tags
- `public/favicon.ico` - Your favicon
- `public/og-image.png` - Social sharing image (1200x630px recommended)

---

## 📁 Project Structure

```
├── public/                  # Static assets (favicon, images)
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── admin/           # Admin panel components
│   │   └── ui/              # shadcn/ui components
│   ├── contexts/            # React contexts (Cart, SiteSettings)
│   ├── hooks/               # Custom hooks (useShopData, useOrders, etc.)
│   ├── integrations/
│   │   └── supabase/        # Supabase client & types
│   ├── pages/               # Route pages
│   │   └── admin/           # Admin panel pages
│   └── i18n/                # Translation files
├── supabase/
│   └── migrations/          # Database schema migrations
├── .env.example             # Environment template
├── vercel.json              # Vercel deployment config
└── package.json
```

---

## 🗄️ Database Schema

### Core Tables

| Table | Description |
|-------|-------------|
| `products` | Product catalog with variants support |
| `categories` | Product categories |
| `orders` | Customer orders |
| `order_items` | Order line items |
| `reviews` | Customer reviews |
| `site_settings` | Global store configuration |
| `store_settings` | Key-value settings |
| `slider_slides` | Homepage slider content |

### Admin Tables

| Table | Description |
|-------|-------------|
| `user_roles` | Admin/customer role assignment |
| `profiles` | User profile data |
| `payment_methods` | Available payment options |
| `shipping_methods` | Shipping configurations |
| `coupons` | Discount codes |

---

## 🔐 Security

- **Row Level Security (RLS)**: All tables have RLS policies
- **Public Read**: Products, categories, reviews (approved only)
- **Admin Only**: CRUD operations require admin role
- **No Client Auth**: Customer checkout works without login
- **Environment Variables**: Secrets never committed to git

---

## 🔄 Multi-Client Reuse

To deploy for a new client:

1. **Create new Supabase project**
2. **Run migrations** from `/supabase/migrations/`
3. **Create admin user** (see setup instructions)
4. **Deploy to Vercel** with new env variables
5. **Configure branding** via Admin Panel

Each client gets:
- Their own database
- Their own domain
- Independent settings and data
- Same codebase and features

---

## 📝 Available Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build
npm run lint         # Run ESLint
npm test             # Run tests
npm run test:watch   # Run tests in watch mode
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

---

## 📄 License

MIT License - feel free to use for commercial projects.

---

## 🆘 Support

- **Documentation**: This README
- **Issues**: GitHub Issues
- **Supabase Docs**: [supabase.com/docs](https://supabase.com/docs)
- **Vercel Docs**: [vercel.com/docs](https://vercel.com/docs)
# Al-Raiyan-Perfume
