import { ArrowLeft, ArrowRight, ShoppingBag, Trash2, Truck } from 'lucide-react';
import { Link } from 'react-router';
import { CartItem } from '../components/CartItem';
import { useCart } from '../context/cartContext';
import { formatCurrency } from '../utils/formatters';
import '../styles/CartPage.css';

export function CartPage() {
  const {
    items,
    totalItems,
    subtotal,
    shipping,
    total,
    freeShippingThreshold,
    freeShippingRemaining,
    incrementItem,
    decrementItem,
    updateQuantity,
    removeItem,
    clearCart,
  } = useCart();

  const shippingProgress = Math.min(
    100,
    Math.round((subtotal / freeShippingThreshold) * 100)
  );

  return (
    <div className="cart-page">
      <header className="cart-header">
        <div>
          <p className="cart-eyebrow">Shopping Bag</p>
          <h1 className="cart-title">Your Cart</h1>
        </div>

        {items.length > 0 && (
          <div className="cart-header-actions">
            <span className="cart-item-summary-pill">
              {totalItems} {totalItems === 1 ? 'item' : 'items'}
            </span>
            <button
              type="button"
              className="clear-cart-btn"
              onClick={clearCart}
            >
              <Trash2 size={15} aria-hidden="true" />
              <span>Clear Cart</span>
            </button>
          </div>
        )}
      </header>

      {items.length === 0 ? (
        <section className="cart-empty" aria-label="Empty shopping cart">
          <div className="cart-empty-icon" aria-hidden="true">
            <ShoppingBag size={32} />
          </div>
          <h2>Your cart is empty</h2>
          <p>
            Looks like you haven’t added any pieces yet. Explore the shop to
            pick out items and customize quantities.
          </p>
          <Link to="/shop" className="btn-primary">
            <span>Browse the Shop</span>
            <ArrowRight size={16} aria-hidden="true" />
          </Link>
        </section>
      ) : (
        <div className="cart-layout">
          <section className="cart-items-section" aria-label="Cart items">
            <ul className="cart-items-list">
              {items.map((entry) => (
                <CartItem
                  key={entry.product.id}
                  item={entry}
                  onIncrement={incrementItem}
                  onDecrement={decrementItem}
                  onUpdateQuantity={updateQuantity}
                  onRemove={removeItem}
                />
              ))}
            </ul>

            <Link to="/shop" className="continue-shopping-link">
              <ArrowLeft size={15} aria-hidden="true" />
              <span>Continue Shopping</span>
            </Link>
          </section>

          <aside className="order-summary" aria-label="Order summary">
            <h2 className="order-summary-title">Order Summary</h2>

            <div className="shipping-meter">
              <div className="shipping-meter-header">
                <Truck size={15} aria-hidden="true" />
                <span>
                  {freeShippingRemaining === 0 ? (
                    <strong>Complimentary shipping unlocked!</strong>
                  ) : (
                    <>
                      Add <strong>{formatCurrency(freeShippingRemaining)}</strong>{' '}
                      more for free shipping
                    </>
                  )}
                </span>
              </div>
              <div className="shipping-bar" aria-hidden="true">
                <div
                  className="shipping-bar-fill"
                  style={{ width: `${shippingProgress}%` }}
                />
              </div>
            </div>

            <dl className="summary-rows">
              <div className="summary-row">
                <dt>
                  Items ({totalItems})
                </dt>
                <dd data-testid="cart-subtotal">{formatCurrency(subtotal)}</dd>
              </div>
              <div className="summary-row">
                <dt>Estimated Shipping</dt>
                <dd data-testid="cart-shipping">
                  {shipping === 0 ? 'Free' : formatCurrency(shipping)}
                </dd>
              </div>
              <div className="summary-row summary-row--total">
                <dt>Total</dt>
                <dd data-testid="cart-total">{formatCurrency(total)}</dd>
              </div>
            </dl>

            <p className="checkout-note">
              Demo storefront — checkout and payment processing are
              intentionally omitted.
            </p>
          </aside>
        </div>
      )}
    </div>
  );
}
