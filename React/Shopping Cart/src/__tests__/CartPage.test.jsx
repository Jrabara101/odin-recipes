import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router';
import { describe, expect, it } from 'vitest';
import { CartProvider } from '../context/CartProvider';
import { CartPage } from '../pages/CartPage';
import { MOCK_PRODUCTS } from './fixtures';

function renderCart(initialItems = []) {
  return render(
    <MemoryRouter initialEntries={['/cart']}>
      <CartProvider initialItems={initialItems} persist={false}>
        <CartPage />
      </CartProvider>
    </MemoryRouter>
  );
}

describe('CartPage', () => {
  const [backpack, shirt] = MOCK_PRODUCTS;

  it('renders an empty state with a link to the shop when cart has no items', () => {
    renderCart([]);

    expect(
      screen.getByRole('heading', { name: /your cart is empty/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('link', { name: /browse the shop/i })
    ).toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: /clear cart/i })
    ).not.toBeInTheDocument();
  });

  it('displays items, quantities, subtotals, shipping, and total accurately', () => {
    renderCart([
      { product: shirt, quantity: 2 }, // 2 * 22.30 = 44.60 (+ $8.00 shipping = $52.60)
    ]);

    const itemRow = screen.getByTestId(`cart-item-${shirt.id}`);
    expect(within(itemRow).getByText(shirt.title)).toBeInTheDocument();
    expect(
      within(itemRow).getByRole('spinbutton', { name: /quantity/i })
    ).toHaveValue(2);
    expect(
      screen.getByTestId(`cart-item-subtotal-${shirt.id}`)
    ).toHaveTextContent('$44.60');
    expect(screen.getByTestId('cart-subtotal')).toHaveTextContent('$44.60');
    expect(screen.getByTestId('cart-shipping')).toHaveTextContent('$8.00');
    expect(screen.getByTestId('cart-total')).toHaveTextContent('$52.60');
  });

  it('increases and decreases item quantity and removes item when decremented past 1', async () => {
    const user = userEvent.setup();
    renderCart([{ product: shirt, quantity: 1 }]);

    const incBtn = screen.getByRole('button', {
      name: `Increase quantity for ${shirt.title}`,
    });

    await user.click(incBtn);
    expect(
      screen.getByLabelText(`Quantity for ${shirt.title}`)
    ).toHaveValue(2);
    expect(screen.getByTestId('cart-subtotal')).toHaveTextContent('$44.60');

    const decBtn = screen.getByRole('button', {
      name: `Decrease quantity for ${shirt.title}`,
    });
    await user.click(decBtn);
    expect(
      screen.getByLabelText(`Quantity for ${shirt.title}`)
    ).toHaveValue(1);

    const removeViaDecBtn = screen.getByRole('button', {
      name: `Decrease quantity and remove ${shirt.title}`,
    });
    await user.click(removeViaDecBtn);

    expect(
      screen.getByRole('heading', { name: /your cart is empty/i })
    ).toBeInTheDocument();
  });

  it('allows manually editing item quantity and unlocks free shipping over $100', async () => {
    const user = userEvent.setup();
    renderCart([{ product: shirt, quantity: 1 }]);

    expect(screen.getByTestId('cart-shipping')).toHaveTextContent('$8.00');

    const qtyInput = screen.getByLabelText(`Quantity for ${shirt.title}`);
    await user.clear(qtyInput);
    await user.type(qtyInput, '5'); // 5 * 22.30 = $111.50 -> Free shipping
    await user.tab();

    expect(qtyInput).toHaveValue(5);
    expect(screen.getByTestId('cart-subtotal')).toHaveTextContent('$111.50');
    expect(screen.getByTestId('cart-shipping')).toHaveTextContent('Free');
    expect(screen.getByTestId('cart-total')).toHaveTextContent('$111.50');
    expect(
      screen.getByText(/complimentary shipping unlocked/i)
    ).toBeInTheDocument();
  });

  it('removes a single item via the Remove button and clears all items via Clear Cart', async () => {
    const user = userEvent.setup();
    renderCart([
      { product: backpack, quantity: 1 },
      { product: shirt, quantity: 2 },
    ]);

    expect(screen.getAllByRole('listitem')).toHaveLength(2);

    await user.click(
      screen.getByRole('button', { name: `Remove ${backpack.title} from cart` })
    );
    expect(screen.getAllByRole('listitem')).toHaveLength(1);
    expect(screen.queryByText(backpack.title)).not.toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /clear cart/i }));
    expect(
      screen.getByRole('heading', { name: /your cart is empty/i })
    ).toBeInTheDocument();
  });
});
