import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router';
import { describe, expect, it } from 'vitest';
import { Navbar } from '../components/Navbar';
import { CartProvider } from '../context/CartProvider';
import { ProductsProvider } from '../context/ProductsProvider';
import { CartPage } from '../pages/CartPage';
import { ShopPage } from '../pages/ShopPage';
import { MOCK_PRODUCTS } from './fixtures';

describe('Shopping Cart real-time synchronization flow', () => {
  it('keeps Navbar badge, Shop product cards, and CartPage synchronized as the user shops', async () => {
    const user = userEvent.setup();
    const [backpack, shirt] = MOCK_PRODUCTS;

    render(
      <MemoryRouter initialEntries={['/shop']}>
        <ProductsProvider initialProducts={MOCK_PRODUCTS}>
          <CartProvider initialItems={[]} persist={false}>
            <Navbar />
            <ShopPage />
            <CartPage />
          </CartProvider>
        </ProductsProvider>
      </MemoryRouter>
    );

    // Initially cart is empty and navbar shows no count badge
    expect(screen.queryByTestId('cart-badge')).not.toBeInTheDocument();
    expect(
      screen.getByRole('heading', { name: /your cart is empty/i })
    ).toBeInTheDocument();

    // Add 2 backpacks via stepper + Add To Cart
    const backpackCard = screen.getByTestId(`product-card-${backpack.id}`);
    await user.click(
      within(backpackCard).getByRole('button', {
        name: `Increase quantity for ${backpack.title}`,
      })
    );
    await user.click(
      within(backpackCard).getByRole('button', { name: /add to cart/i })
    );

    expect(screen.getByTestId('cart-badge')).toHaveTextContent('2');
    expect(within(backpackCard).getByText('In cart: 2')).toBeInTheDocument();

    // Add 3 shirts via manual input typing
    const shirtCard = screen.getByTestId(`product-card-${shirt.id}`);
    const shirtQtyInput = within(shirtCard).getByRole('spinbutton', {
      name: /quantity/i,
    });
    await user.clear(shirtQtyInput);
    await user.type(shirtQtyInput, '3');
    await user.click(
      within(shirtCard).getByRole('button', { name: /add to cart/i })
    );

    // Navbar badge now reflects 2 + 3 = 5 total items
    expect(screen.getByTestId('cart-badge')).toHaveTextContent('5');

    // Cart displays both items and exact combined total: (2 * 109.95) + (3 * 22.30) = 286.80 (free shipping)
    expect(screen.getByTestId('cart-subtotal')).toHaveTextContent('$286.80');
    expect(screen.getByTestId('cart-shipping')).toHaveTextContent('Free');
    expect(screen.getByTestId('cart-total')).toHaveTextContent('$286.80');

    // Decrement backpack quantity inside the cart from 2 -> 1
    const backpackCartRow = screen.getByTestId(`cart-item-${backpack.id}`);
    await user.click(
      within(backpackCartRow).getByRole('button', {
        name: `Decrease quantity for ${backpack.title}`,
      })
    );

    // Navbar, Shop card, and Cart totals all update in real time
    expect(screen.getByTestId('cart-badge')).toHaveTextContent('4');
    expect(within(backpackCard).getByText('In cart: 1')).toBeInTheDocument();
    expect(screen.getByTestId('cart-total')).toHaveTextContent('$176.85');

    // Remove shirts completely from cart
    await user.click(
      within(screen.getByTestId(`cart-item-${shirt.id}`)).getByRole('button', {
        name: `Remove ${shirt.title} from cart`,
      })
    );

    expect(screen.getByTestId('cart-badge')).toHaveTextContent('1');
    expect(screen.getByTestId('cart-total')).toHaveTextContent('$109.95');
  });
});
