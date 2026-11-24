import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router';
import { describe, expect, it } from 'vitest';
import { Navbar } from '../components/Navbar';
import { CartProvider } from '../context/CartProvider';
import { useCart } from '../context/cartContext';
import { MOCK_PRODUCTS } from './fixtures';

function CartMutatorHarness() {
  const { addToCart, removeItem, clearCart } = useCart();
  return (
    <div>
      <button type="button" onClick={() => addToCart(MOCK_PRODUCTS[0], 2)}>
        Add Two
      </button>
      <button type="button" onClick={() => addToCart(MOCK_PRODUCTS[1], 3)}>
        Add Three
      </button>
      <button type="button" onClick={() => removeItem(MOCK_PRODUCTS[0].id)}>
        Remove First
      </button>
      <button type="button" onClick={clearCart}>
        Clear All
      </button>
    </div>
  );
}

describe('Navbar', () => {
  it('renders Home, Shop, and Cart navigation links without a badge when cart is empty', () => {
    render(
      <MemoryRouter>
        <CartProvider initialItems={[]} persist={false}>
          <Navbar />
        </CartProvider>
      </MemoryRouter>
    );

    expect(screen.getByRole('link', { name: /^home$/i })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /^shop$/i })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /cart/i })).toBeInTheDocument();
    expect(screen.queryByTestId('cart-badge')).not.toBeInTheDocument();
  });

  it('shows the total number of items in the cart when non-empty', () => {
    const initialItems = [
      { product: MOCK_PRODUCTS[0], quantity: 2 },
      { product: MOCK_PRODUCTS[1], quantity: 4 },
    ];

    render(
      <MemoryRouter>
        <CartProvider initialItems={initialItems} persist={false}>
          <Navbar />
        </CartProvider>
      </MemoryRouter>
    );

    expect(screen.getByTestId('cart-badge')).toHaveTextContent('6');
  });

  it('updates the cart count badge in real time as items are added and removed', async () => {
    const user = userEvent.setup();

    render(
      <MemoryRouter>
        <CartProvider initialItems={[]} persist={false}>
          <Navbar />
          <CartMutatorHarness />
        </CartProvider>
      </MemoryRouter>
    );

    expect(screen.queryByTestId('cart-badge')).not.toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /add two/i }));
    expect(screen.getByTestId('cart-badge')).toHaveTextContent('2');

    await user.click(screen.getByRole('button', { name: /add three/i }));
    expect(screen.getByTestId('cart-badge')).toHaveTextContent('5');

    await user.click(screen.getByRole('button', { name: /remove first/i }));
    expect(screen.getByTestId('cart-badge')).toHaveTextContent('3');

    await user.click(screen.getByRole('button', { name: /clear all/i }));
    expect(screen.queryByTestId('cart-badge')).not.toBeInTheDocument();
  });
});
