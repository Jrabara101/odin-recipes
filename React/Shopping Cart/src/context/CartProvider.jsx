import { useCallback, useEffect, useMemo, useReducer, useState } from 'react';
import { CartContext } from './cartContext';
import {
  CART_ACTIONS,
  FREE_SHIPPING_THRESHOLD,
  cartReducer,
  getCartSubtotal,
  getItemQuantity,
  getShippingCost,
  getTotalItemCount,
} from './cartReducer';

const STORAGE_KEY = 'vesper_goods_cart_v1';

function readStoredCart() {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.filter(
      (entry) =>
        entry &&
        entry.product &&
        entry.product.id != null &&
        Number.isInteger(entry.quantity) &&
        entry.quantity > 0
    );
  } catch {
    return [];
  }
}

export function CartProvider({ children, initialItems = null, persist = true }) {
  const [items, dispatch] = useReducer(
    cartReducer,
    initialItems,
    (provided) => {
      if (Array.isArray(provided)) {
        return provided;
      }
      return persist ? readStoredCart() : [];
    }
  );

  const [announcement, setAnnouncement] = useState('');

  useEffect(() => {
    if (!persist) return;
    try {
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
    } catch {
      // Ignore storage quota or private-mode restrictions.
    }
  }, [items, persist]);

  const addToCart = useCallback((product, quantity = 1) => {
    const qty = Number.parseInt(String(quantity), 10);
    if (!Number.isFinite(qty) || qty <= 0) return;

    dispatch({
      type: CART_ACTIONS.ADD_ITEM,
      payload: { product, quantity: qty },
    });
    setAnnouncement(
      `Added ${qty} ${qty === 1 ? 'item' : 'items'} of ${product.title} to your cart.`
    );
  }, []);

  const updateQuantity = useCallback((productId, quantity) => {
    dispatch({
      type: CART_ACTIONS.UPDATE_QUANTITY,
      payload: { productId, quantity },
    });
  }, []);

  const incrementItem = useCallback((productId) => {
    dispatch({
      type: CART_ACTIONS.INCREMENT_ITEM,
      payload: { productId },
    });
  }, []);

  const decrementItem = useCallback((productId) => {
    dispatch({
      type: CART_ACTIONS.DECREMENT_ITEM,
      payload: { productId },
    });
  }, []);

  const removeItem = useCallback((productId) => {
    dispatch({
      type: CART_ACTIONS.REMOVE_ITEM,
      payload: { productId },
    });
  }, []);

  const clearCart = useCallback(() => {
    dispatch({ type: CART_ACTIONS.CLEAR_CART });
    setAnnouncement('Cleared all items from your cart.');
  }, []);

  const value = useMemo(() => {
    const totalItems = getTotalItemCount(items);
    const subtotal = getCartSubtotal(items);
    const shipping = getShippingCost(subtotal);
    const total = Math.round((subtotal + shipping) * 100) / 100;
    const freeShippingRemaining = Math.max(
      0,
      Math.round((FREE_SHIPPING_THRESHOLD - subtotal) * 100) / 100
    );

    return {
      items,
      totalItems,
      subtotal,
      shipping,
      total,
      freeShippingThreshold: FREE_SHIPPING_THRESHOLD,
      freeShippingRemaining,
      announcement,
      getProductQuantity: (productId) => getItemQuantity(items, productId),
      addToCart,
      updateQuantity,
      incrementItem,
      decrementItem,
      removeItem,
      clearCart,
    };
  }, [
    items,
    announcement,
    addToCart,
    updateQuantity,
    incrementItem,
    decrementItem,
    removeItem,
    clearCart,
  ]);

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
}
