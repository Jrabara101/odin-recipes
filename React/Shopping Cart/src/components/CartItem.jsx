import { Minus, Plus, Trash2 } from 'lucide-react';
import { useId, useState } from 'react';
import {
  MAX_ITEM_QUANTITY,
  clampQuantity,
  formatCategoryLabel,
  formatCurrency,
} from '../utils/formatters';

export function CartItem({
  item,
  onIncrement,
  onDecrement,
  onUpdateQuantity,
  onRemove,
}) {
  const { product, quantity } = item;
  const [draftValue, setDraftValue] = useState(null);
  const qtyInputId = useId();

  const displayValue = draftValue ?? String(quantity);
  const lineTotal = (Math.round(product.price * 100) * quantity) / 100;

  function handleChange(event) {
    const raw = event.target.value;
    if (raw !== '' && !/^\d{0,3}$/.test(raw)) {
      return;
    }

    setDraftValue(raw);

    if (raw === '') {
      return;
    }

    const parsed = Number.parseInt(raw, 10);
    if (Number.isFinite(parsed) && parsed >= 1) {
      onUpdateQuantity(
        product.id,
        clampQuantity(parsed, { min: 1, max: MAX_ITEM_QUANTITY })
      );
    }
  }

  function handleBlur() {
    if (draftValue === null) return;

    if (draftValue === '') {
      setDraftValue(null);
      return;
    }

    const parsed = Number.parseInt(draftValue, 10);
    if (!Number.isFinite(parsed) || parsed <= 0) {
      setDraftValue(null);
      onUpdateQuantity(product.id, 0);
      return;
    }

    const clamped = clampQuantity(parsed, { min: 1, max: MAX_ITEM_QUANTITY });
    onUpdateQuantity(product.id, clamped);
    setDraftValue(null);
  }

  function handleDecrementClick() {
    setDraftValue(null);
    onDecrement(product.id);
  }

  function handleIncrementClick() {
    setDraftValue(null);
    onIncrement(product.id);
  }

  return (
    <li className="cart-item" data-testid={`cart-item-${product.id}`}>
      <div className="cart-item-thumb">
        <img src={product.image} alt={product.title} />
      </div>

      <div className="cart-item-info">
        <span className="cart-item-category">
          {formatCategoryLabel(product.category)}
        </span>
        <h3 className="cart-item-title">{product.title}</h3>
        <p className="cart-item-unit-price">
          {formatCurrency(product.price)} each
        </p>
      </div>

      <div className="cart-item-controls">
        <div className="cart-stepper">
          <button
            type="button"
            className="cart-stepper-btn"
            onClick={handleDecrementClick}
            aria-label={
              quantity === 1
                ? `Decrease quantity and remove ${product.title}`
                : `Decrease quantity for ${product.title}`
            }
          >
            <Minus size={14} aria-hidden="true" />
          </button>

          <label htmlFor={qtyInputId} className="sr-only">
            Quantity for {product.title}
          </label>
          <input
            id={qtyInputId}
            type="number"
            inputMode="numeric"
            min={0}
            max={MAX_ITEM_QUANTITY}
            value={displayValue}
            onFocus={() => setDraftValue(String(quantity))}
            onChange={handleChange}
            onBlur={handleBlur}
            className="cart-stepper-input"
            aria-label={`Quantity for ${product.title}`}
          />

          <button
            type="button"
            className="cart-stepper-btn"
            onClick={handleIncrementClick}
            disabled={quantity >= MAX_ITEM_QUANTITY}
            aria-label={`Increase quantity for ${product.title}`}
          >
            <Plus size={14} aria-hidden="true" />
          </button>
        </div>

        <p
          className="cart-item-subtotal"
          data-testid={`cart-item-subtotal-${product.id}`}
        >
          {formatCurrency(lineTotal)}
        </p>

        <button
          type="button"
          className="cart-item-remove"
          onClick={() => onRemove(product.id)}
          aria-label={`Remove ${product.title} from cart`}
        >
          <Trash2 size={15} aria-hidden="true" />
          <span>Remove</span>
        </button>
      </div>
    </li>
  );
}
