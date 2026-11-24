import { Check, Minus, Plus, ShoppingBag, Star } from 'lucide-react';
import { useEffect, useId, useState } from 'react';
import {
  MAX_ITEM_QUANTITY,
  clampQuantity,
  formatCategoryLabel,
  formatCurrency,
} from '../utils/formatters';
import '../styles/ProductCard.css';

export function ProductCard({ product, onAddToCart, cartQuantity = 0 }) {
  const [quantityInput, setQuantityInput] = useState('1');
  const [justAdded, setJustAdded] = useState(false);
  const inputId = useId();

  useEffect(() => {
    if (!justAdded) return undefined;
    const timer = window.setTimeout(() => setJustAdded(false), 1400);
    return () => window.clearTimeout(timer);
  }, [justAdded]);

  const parsedQty = Number.parseInt(quantityInput, 10);
  const currentNumericQty = Number.isFinite(parsedQty) ? parsedQty : 1;

  function handleInputChange(event) {
    const raw = event.target.value;
    if (raw === '' || /^\d{0,3}$/.test(raw)) {
      setQuantityInput(raw);
    }
  }

  function handleInputBlur() {
    const clamped = clampQuantity(quantityInput, {
      min: 1,
      max: MAX_ITEM_QUANTITY,
    });
    setQuantityInput(String(clamped));
  }

  function handleDecrement() {
    const base = Number.isFinite(parsedQty) ? parsedQty : 1;
    const next = Math.max(1, base - 1);
    setQuantityInput(String(next));
  }

  function handleIncrement() {
    const base = Number.isFinite(parsedQty) ? parsedQty : 0;
    const next = Math.min(MAX_ITEM_QUANTITY, base + 1);
    setQuantityInput(String(next));
  }

  function handleSubmit(event) {
    event.preventDefault();
    const finalQuantity = clampQuantity(quantityInput, {
      min: 1,
      max: MAX_ITEM_QUANTITY,
    });
    onAddToCart(product, finalQuantity);
    setQuantityInput('1');
    setJustAdded(true);
  }

  return (
    <article className="product-card" data-testid={`product-card-${product.id}`}>
      <div className="product-card-media">
        <span className="product-card-category">
          {formatCategoryLabel(product.category)}
        </span>
        {cartQuantity > 0 && (
          <span className="product-card-in-cart">In cart: {cartQuantity}</span>
        )}
        <img
          src={product.image}
          alt={product.title}
          className="product-card-image"
          loading="lazy"
        />
      </div>

      <div className="product-card-body">
        <div className="product-card-meta">
          <span className="product-card-price">
            {formatCurrency(product.price)}
          </span>
          {product.rating && product.rating.rate > 0 && (
            <span
              className="product-card-rating"
              aria-label={`Rated ${product.rating.rate} out of 5 from ${product.rating.count} reviews`}
            >
              <Star size={13} fill="currentColor" aria-hidden="true" />
              <span>{product.rating.rate.toFixed(1)}</span>
              <span className="product-card-rating-count">
                ({product.rating.count})
              </span>
            </span>
          )}
        </div>

        <h3 className="product-card-title" title={product.title}>
          {product.title}
        </h3>

        <form className="product-card-actions" onSubmit={handleSubmit}>
          <div className="quantity-stepper">
            <button
              type="button"
              className="stepper-btn"
              onClick={handleDecrement}
              disabled={quantityInput !== '' && currentNumericQty <= 1}
              aria-label={`Decrease quantity for ${product.title}`}
            >
              <Minus size={14} aria-hidden="true" />
            </button>

            <label htmlFor={inputId} className="sr-only">
              Quantity for {product.title}
            </label>
            <input
              id={inputId}
              type="number"
              inputMode="numeric"
              min={1}
              max={MAX_ITEM_QUANTITY}
              value={quantityInput}
              onChange={handleInputChange}
              onBlur={handleInputBlur}
              className="stepper-input"
              aria-label={`Quantity for ${product.title}`}
            />

            <button
              type="button"
              className="stepper-btn"
              onClick={handleIncrement}
              disabled={currentNumericQty >= MAX_ITEM_QUANTITY}
              aria-label={`Increase quantity for ${product.title}`}
            >
              <Plus size={14} aria-hidden="true" />
            </button>
          </div>

          <button
            type="submit"
            className={
              justAdded
                ? 'add-to-cart-btn add-to-cart-btn--added'
                : 'add-to-cart-btn'
            }
          >
            {justAdded ? (
              <>
                <Check size={15} aria-hidden="true" />
                <span>Added!</span>
              </>
            ) : (
              <>
                <ShoppingBag size={15} aria-hidden="true" />
                <span>Add To Cart</span>
              </>
            )}
          </button>
        </form>
      </div>
    </article>
  );
}
