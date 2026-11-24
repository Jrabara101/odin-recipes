import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router';
import { describe, expect, it, vi } from 'vitest';
import { CartProvider } from '../context/CartProvider';
import { ProductsProvider } from '../context/ProductsProvider';
import { ShopPage } from '../pages/ShopPage';
import { MOCK_PRODUCTS } from './fixtures';

function renderShop({
  initialProducts = null,
  fetcher,
  initialCartItems = [],
} = {}) {
  return render(
    <MemoryRouter initialEntries={['/shop']}>
      <ProductsProvider initialProducts={initialProducts} fetcher={fetcher}>
        <CartProvider initialItems={initialCartItems} persist={false}>
          <ShopPage />
        </CartProvider>
      </ProductsProvider>
    </MemoryRouter>
  );
}

describe('ShopPage', () => {
  it('shows a loading status while products are being fetched, then renders products', async () => {
    let resolveFetch;
    const pendingFetcher = vi.fn(
      () =>
        new Promise((resolve) => {
          resolveFetch = resolve;
        })
    );

    renderShop({ fetcher: pendingFetcher });

    expect(
      screen.getByRole('status', { name: /loading products/i })
    ).toBeInTheDocument();

    resolveFetch(MOCK_PRODUCTS);

    expect(
      await screen.findByRole('heading', { name: MOCK_PRODUCTS[0].title })
    ).toBeInTheDocument();
    expect(screen.getAllByRole('article')).toHaveLength(MOCK_PRODUCTS.length);
  });

  it('shows an error alert when fetching fails and retries on button click', async () => {
    const user = userEvent.setup();
    const flakyFetcher = vi
      .fn()
      .mockRejectedValueOnce(new Error('Network unavailable'))
      .mockResolvedValueOnce(MOCK_PRODUCTS);

    renderShop({ fetcher: flakyFetcher });

    const alert = await screen.findByRole('alert');
    expect(alert).toHaveTextContent(/network unavailable/i);

    await user.click(screen.getByRole('button', { name: /try again/i }));

    expect(
      await screen.findByRole('heading', { name: MOCK_PRODUCTS[0].title })
    ).toBeInTheDocument();
    expect(flakyFetcher).toHaveBeenCalledTimes(2);
  });

  it('filters products by category and search query, and resets empty filter states', async () => {
    const user = userEvent.setup();
    renderShop({ initialProducts: MOCK_PRODUCTS });

    expect(screen.getAllByRole('article')).toHaveLength(5);

    await user.click(screen.getByRole('button', { name: 'Jewelry' }));
    expect(screen.getAllByRole('article')).toHaveLength(1);
    expect(
      screen.getByRole('heading', { name: /dragon station bracelet/i })
    ).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'All' }));
    expect(screen.getAllByRole('article')).toHaveLength(5);

    const searchInput = screen.getByLabelText(/search products/i);
    await user.type(searchInput, 'backpack');
    expect(screen.getAllByRole('article')).toHaveLength(1);
    expect(
      screen.getByRole('heading', { name: /fjallraven foldsack/i })
    ).toBeInTheDocument();

    await user.clear(searchInput);
    await user.type(searchInput, 'nonexistent-item-xyz');
    expect(screen.getByText(/no matching items/i)).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /reset filters/i }));
    expect(screen.getAllByRole('article')).toHaveLength(5);
  });

  it('sorts products by price low-to-high and high-to-low', async () => {
    const user = userEvent.setup();
    renderShop({ initialProducts: MOCK_PRODUCTS });

    const sortSelect = screen.getByLabelText(/sort products/i);

    await user.selectOptions(sortSelect, 'price-asc');
    let headings = screen
      .getAllByRole('article')
      .map((card) => within(card).getByRole('heading').textContent);
    expect(headings[0]).toBe('Slim Fit Henley T-Shirt');
    expect(headings[headings.length - 1]).toBe(
      'Fjallraven Foldsack No. 1 Backpack'
    );

    await user.selectOptions(sortSelect, 'price-desc');
    headings = screen
      .getAllByRole('article')
      .map((card) => within(card).getByRole('heading').textContent);
    expect(headings[0]).toBe('Fjallraven Foldsack No. 1 Backpack');
    expect(headings[headings.length - 1]).toBe('Slim Fit Henley T-Shirt');
  });

  it('updates a product card In cart badge after adding items to the cart', async () => {
    const user = userEvent.setup();
    renderShop({ initialProducts: MOCK_PRODUCTS });

    const firstCard = screen.getByTestId(`product-card-${MOCK_PRODUCTS[0].id}`);
    const qtyInput = within(firstCard).getByRole('spinbutton', {
      name: /quantity/i,
    });

    await user.clear(qtyInput);
    await user.type(qtyInput, '3');
    await user.click(within(firstCard).getByRole('button', { name: /add to cart/i }));

    expect(within(firstCard).getByText('In cart: 3')).toBeInTheDocument();
  });
});
