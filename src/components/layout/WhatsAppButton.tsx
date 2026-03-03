import { useLocation } from 'react-router-dom';

/**
 * Floating WhatsApp button — visible on all pages.
 * On the product detail page it rises above the mobile sticky Buy Now bar.
 */
export function WhatsAppButton() {
  const location = useLocation();
  const isProductPage = location.pathname.startsWith('/product/');

  // Store WhatsApp number (international format, no + or spaces)
  const phone = '8801633666834';
  const message = encodeURIComponent('Hello! I am interested in your perfumes.');
  const href = `https://wa.me/${phone}?text=${message}`;

  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Chat on WhatsApp"
      className={`fixed z-50 flex items-center justify-center w-14 h-14 rounded-full shadow-lg
                 bg-[#25D366] hover:bg-[#1ebe5d] active:scale-95
                 transition-all duration-200 ease-in-out right-6
                 hover:shadow-[0_0_0_6px_rgba(37,211,102,0.25)]
                 ${isProductPage
                   ? 'bottom-24 sm:bottom-6'   // raised only on mobile product page
                   : 'bottom-6'                 // normal on all other pages
                 }`}
    >
      {/* WhatsApp SVG icon */}
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 32 32"
        className="w-7 h-7 fill-white"
        aria-hidden="true"
      >
        <path d="M16.003 2.667C8.638 2.667 2.667 8.637 2.667 16c0 2.363.617 4.678 1.79 6.716L2.667 29.333l6.82-1.789A13.29 13.29 0 0 0 16.003 29.333C23.368 29.333 29.333 23.363 29.333 16S23.368 2.667 16.003 2.667zm0 2.4c5.917 0 10.93 5.013 10.93 10.933S21.92 26.933 16.003 26.933a10.9 10.9 0 0 1-5.55-1.516l-.397-.237-4.05 1.063 1.083-3.95-.26-.413A10.893 10.893 0 0 1 5.073 16c0-5.92 5.013-10.933 10.93-10.933zm-3.27 5.2c-.2 0-.527.075-.803.375-.277.3-1.057 1.033-1.057 2.52 0 1.487 1.083 2.923 1.233 3.123.15.2 2.1 3.2 5.17 4.487.72.31 1.283.493 1.72.633.724.23 1.383.197 1.903.12.58-.087 1.793-.733 2.047-1.44.253-.707.253-1.313.177-1.44-.077-.127-.277-.2-.58-.35-.303-.15-1.793-.883-2.07-.983-.277-.1-.477-.15-.677.15-.2.3-.773.983-.947 1.183-.173.2-.347.225-.647.075-.3-.15-1.267-.467-2.413-1.49-.893-.797-1.493-1.78-1.667-2.08-.173-.3-.017-.463.13-.613.133-.133.3-.35.45-.523.15-.173.2-.3.3-.5.1-.2.05-.375-.025-.523-.075-.15-.677-1.633-.927-2.233-.244-.588-.49-.508-.677-.518-.173-.008-.373-.01-.573-.01z" />
      </svg>
    </a>
  );
}
