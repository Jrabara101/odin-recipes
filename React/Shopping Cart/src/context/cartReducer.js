import { MAX_ITEM_QUANTITY, clampQuantity } from '../utils/formatters';

export const FREE_SHIPPING_THRESHOLD = 100;
export const STANDARD_SHIPPING_FEE = 8;

export const CART_ACTIONS = {
  ADD_ITEM: 'ADD_ITEM',
  UPDATE_QUANTITY: 'UPDATE_QUANTITY',
  INCREMENT_ITEM: 'INCREMENT_ITEM',
  DECREMENT_ITEM: 'DECREMENT_ITEM',
  REMOVE_ITEM: 'REMOVE_ITEM',
  CLEAR_CART: 'CLEAR_CART',
};

export function cartReducer(state, action) {
  switch (action.type) {
    case CART_ACTIONS.ADD_ITEM: {
      const { product, quantity = 1 } = action.payload;
      if (!product || product.id == null) {
        return state;
      }

      const parsedQty = Number.parseInt(String(quantity), 10);
      if (!Number.isFinite(parsedQty) || parsedQty <= 0) {
        return state;
      }

      const existingIndex = state.findIndex(
        (entry) => entry.product.id === product.id
      );

      if (existingIndex === -1) {
        return [
          ...state,
          {
            product,
            quantity: clampQuantity(parsedQty, { min: 1, max: MAX_ITEM_QUANTITY }),
          },
        ];
      }

      return state.map((entry, index) =>
        index === existingIndex
          ? {
              ...entry,
              product,
              quantity: clampQuantity(entry.quantity + parsedQty, {
                min: 1,
                max: MAX_ITEM_QUANTITY,
              }),
            }
          : entry
      );
    }

    case CART_ACTIONS.UPDATE_QUANTITY: {
      const { productId, quantity } = action.payload;
      const parsedQty = Number.parseInt(String(quantity), 10);

      if (!Number.isFinite(parsedQty) || parsedQty <= 0) {
        return state.filter((entry) => entry.product.id !== productId);
      }

      const clamped = clampQuantity(parsedQty, {
        min: 1,
        max: MAX_ITEM_QUANTITY,
      });

      return state.map((entry) =>
        entry.product.id === productId
          ? { ...entry, quantity: clamped }
          : entry
      );
    }

    case CART_ACTIONS.INCREMENT_ITEM: {
      const { productId } = action.payload;
      return state.map((entry) =>
        entry.product.id === productId
          ? {
              ...entry,
              quantity: Math.min(MAX_ITEM_QUANTITY, entry.quantity + 1),
            }
          : entry
      );
    }

    case CART_ACTIONS.DECREMENT_ITEM: {
      const { productId } = action.payload;
      return state.flatMap((entry) => {
        if (entry.product.id !== productId) {
          return [entry];
        }
        if (entry.quantity <= 1) {
          return [];
        }
        return [{ ...entry, quantity: entry.quantity - 1 }];
      });
    }

    case CART_ACTIONS.REMOVE_ITEM: {
      const { productId } = action.payload;
      return state.filter((entry) => entry.product.id !== productId);
    }

    case CART_ACTIONS.CLEAR_CART:
      return [];

    default:
      return state;
  }
}

export function getTotalItemCount(items) {
  return items.reduce((sum, entry) => sum + entry.quantity, 0);
}

export function getCartSubtotal(items) {
  const totalCents = items.reduce((sum, entry) => {
    const unitCents = Math.round(Number(entry.product.price) * 100);
    return sum + unitCents * entry.quantity;
  }, 0);
  return totalCents / 100;
}

export function getItemQuantity(items, productId) {
  const match = items.find((entry) => entry.product.id === productId);
  return match ? match.quantity : 0;
}

export function getShippingCost(subtotal) {
  if (subtotal <= 0 || subtotal >= FREE_SHIPPING_THRESHOLD) {
    return 0;
  }
  return STANDARD_SHIPPING_FEE;
}
