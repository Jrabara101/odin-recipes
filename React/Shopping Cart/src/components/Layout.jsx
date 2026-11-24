import { Link, Outlet } from 'react-router';
import { useCart } from '../context/cartContext';
import { Navbar } from './Navbar';
import '../styles/Layout.css';

export function Layout() {
  const { announcement } = useCart();

  return (
    <div className="app-shell">
      <a href="#main-content" className="skip-link">
        Skip to main content
      </a>

      <Navbar />

      <main id="main-content" className="site-main">
        <Outlet />
      </main>

      <footer className="site-footer">
        <div className="footer-inner">
          <div className="footer-brand">
            <span className="footer-wordmark">Vesper Goods</span>
            <p className="footer-tagline">
              Thoughtfully selected wardrobe staples, fine jewelry, and modern
              desk electronics.
            </p>
          </div>

          <nav className="footer-links" aria-label="Footer navigation">
            <Link to="/">Home</Link>
            <Link to="/shop">Shop</Link>
            <Link to="/cart">Cart</Link>
          </nav>

          <p className="footer-credit">
            Catalog powered by{' '}
            <a
              href="https://fakestoreapi.com/"
              target="_blank"
              rel="noreferrer"
            >
              FakeStore API
            </a>
            . Demo storefront — no live checkout.
          </p>
        </div>
      </footer>

      <div className="sr-only" role="status" aria-live="polite" aria-atomic="true">
        {announcement}
      </div>
    </div>
  );
}
