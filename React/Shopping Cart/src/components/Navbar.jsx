import { ShoppingBag } from 'lucide-react';
import { Link, NavLink } from 'react-router';
import { useCart } from '../context/cartContext';
import '../styles/Navbar.css';

export function Navbar() {
  const { totalItems } = useCart();

  return (
    <header className="site-header">
      <div className="navbar-inner">
        <Link to="/" className="brand-link" aria-label="Vesper Goods Home">
          <span className="brand-mark" aria-hidden="true">
            V
          </span>
          <span className="brand-text">
            <span className="brand-name">Vesper Goods</span>
            <span className="brand-sub">Concept Store</span>
          </span>
        </Link>

        <nav className="primary-nav" aria-label="Primary navigation">
          <ul className="nav-list">
            <li>
              <NavLink
                to="/"
                end
                className={({ isActive }) =>
                  isActive ? 'nav-link nav-link--active' : 'nav-link'
                }
              >
                Home
              </NavLink>
            </li>
            <li>
              <NavLink
                to="/shop"
                className={({ isActive }) =>
                  isActive ? 'nav-link nav-link--active' : 'nav-link'
                }
              >
                Shop
              </NavLink>
            </li>
            <li>
              <NavLink
                to="/cart"
                className={({ isActive }) =>
                  isActive
                    ? 'nav-link nav-link--cart nav-link--active'
                    : 'nav-link nav-link--cart'
                }
              >
                <ShoppingBag className="nav-cart-icon" size={17} aria-hidden="true" />
                <span>Cart</span>
                {totalItems > 0 && (
                  <span className="cart-badge" data-testid="cart-badge">
                    {totalItems}
                  </span>
                )}
              </NavLink>
            </li>
          </ul>
        </nav>
      </div>
    </header>
  );
}
