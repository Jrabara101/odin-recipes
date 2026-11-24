import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router';
import { describe, expect, it } from 'vitest';
import { ProductsProvider } from '../context/ProductsProvider';
import { HomePage } from '../pages/HomePage';
import { MOCK_PRODUCTS } from './fixtures';

describe('HomePage', () => {
  it('renders the hero section, primary shop CTA, departments, and highest-rated picks', () => {
    render(
      <MemoryRouter>
        <ProductsProvider initialProducts={MOCK_PRODUCTS}>
          <HomePage />
        </ProductsProvider>
      </MemoryRouter>
    );

    expect(
      screen.getByRole('heading', { level: 1, name: /objects crafted for/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('link', { name: /explore the shop/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('heading', { name: /browse by category/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('heading', { name: /editor’s picks/i })
    ).toBeInTheDocument();
    expect(
      screen.getByText('Gold & Silver Dragon Station Bracelet')
    ).toBeInTheDocument();
  });
});
