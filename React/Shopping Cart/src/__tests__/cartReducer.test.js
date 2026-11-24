import { describe, expect, it } from 'vitest';
import {
  CART_ACTIONS,
  cartReducer,
  getCartSubtotal,
  getItemQuantity,
  getShippingCost,
  getTotalItemCount,
} from '../context/cartReducer';
import {
  clampQuantity,
  formatCategoryLabel,
  formatCurrency,
} from '../utils/formatters';
import { MOCK_PRODUCTS } from './fixtures';

describe('cartReducer', () => {
  const [backpack, shirt] = MOCK_PRODUCTS;

  it('adds a new item with the requested quantity', () => {
    const next = cartReducer([], {
      type: CART_ACTIONS.ADD_ITEM,
      payload: { product: backpack, quantity: 3 },
    });

    expect(next).toHaveLength(1);
    expect(next[0].quantity).toBe(3);
    expect(getTotalItemCount(next)).toBe(3);
  });

  it('merges quantities when adding a product already in the cart', () => {
    const initial = [{ product: shirt, quantity: 2 }];
    const next = cartReducer(initial, {
      type: CART_ACTIONS.ADD_ITEM,
      payload: { product: shirt, quantity: 4 },
    });

    expect(next).toHaveLength(1);
    expect(next[0].quantity).toBe(6);
  });

  it('ignores non-positive quantities when adding items', () => {
    const next = cartReducer([], {
      type: CART_ACTIONS.ADD_ITEM,
      payload: { product: backpack, quantity: 0 },
    });

    expect(next).toEqual([]);
  });

  it('increments and decrements item quantities, removing at zero', () => {
    let state = [{ product: shirt, quantity: 1 }];

    state = cartReducer(state, {
      type: CART_ACTIONS.INCREMENT_ITEM,
      payload: { productId: shirt.id },
    });
    expect(getItemQuantity(state, shirt.id)).toBe(2);

    state = cartReducer(state, {
      type: CART_ACTIONS.DECREMENT_ITEM,
      payload: { productId: shirt.id },
    });
    expect(getItemQuantity(state, shirt.id)).toBe(1);

    state = cartReducer(state, {
      type: CART_ACTIONS.DECREMENT_ITEM,
      payload: { productId: shirt.id },
    });
    expect(state).toHaveLength(0);
  });

  it('updates quantity directly and removes item when updated to 0', () => {
    let state = [{ product: backpack, quantity: 2 }];

    state = cartReducer(state, {
      type: CART_ACTIONS.UPDATE_QUANTITY,
      payload: { productId: backpack.id, quantity: 5 },
    });
    expect(getItemQuantity(state, backpack.id)).toBe(5);

    state = cartReducer(state, {
      type: CART_ACTIONS.UPDATE_QUANTITY,
      payload: { productId: backpack.id, quantity: 0 },
    });
    expect(state).toEqual([]);
  });

  it('removes a single item and clears the full cart', () => {
    const initial = [
      { product: backpack, quantity: 1 },
      { product: shirt, quantity: 3 },
    ];

    const afterRemove = cartReducer(initial, {
      type: CART_ACTIONS.REMOVE_ITEM,
      payload: { productId: backpack.id },
    });
    expect(afterRemove).toHaveLength(1);
    expect(afterRemove[0].product.id).toBe(shirt.id);

    const afterClear = cartReducer(afterRemove, {
      type: CART_ACTIONS.CLEAR_CART,
    });
    expect(afterClear).toEqual([]);
  });

  it('computes subtotal accurately using integer cents and shipping threshold', () => {
    const items = [
      { product: { id: 101, price: 19.99 }, quantity: 3 },
      { product: { id: 102, price: 0.1 }, quantity: 2 },
    ];

    expect(getCartSubtotal(items)).toBe(60.17);
    expect(getShippingCost(0)).toBe(0);
    expect(getShippingCost(60.17)).toBe(8);
    expect(getShippingCost(100)).toBe(0);
  });
});

describe('formatters', () => {
  it('formats USD currency and handles invalid values safely', () => {
    expect(formatCurrency(109.95)).toBe('$109.95');
    expect(formatCurrency(22.3)).toBe('$22.30');
    expect(formatCurrency(NaN)).toBe('$0.00');
  });

  it('maps FakeStore category labels including the jewelery spelling fix', () => {
    expect(formatCategoryLabel('jewelery')).toBe('Jewelry');
    expect(formatCategoryLabel("men's clothing")).toBe("Men's Clothing");
    expect(formatCategoryLabel("women's clothing")).toBe("Women's Clothing");
    expect(formatCategoryLabel('electronics')).toBe('Electronics');
  });

  it('clamps quantity values within bounds', () => {
    expect(clampQuantity('12')).toBe(12);
    expect(clampQuantity('0')).toBe(1);
    expect(clampQuantity('500')).toBe(99);
    expect(clampQuantity('abc')).toBe(1);
  });
});
