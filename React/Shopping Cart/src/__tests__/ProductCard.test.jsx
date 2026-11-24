import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { ProductCard } from '../components/ProductCard';
import { MOCK_PRODUCTS } from './fixtures';

describe('ProductCard', () => {
  const product = MOCK_PRODUCTS[0];

  it('displays product details, default quantity of 1, stepper buttons, and Add To Cart button', () => {
    render(<ProductCard product={product} onAddToCart={vi.fn()} />);

    expect(screen.getByRole('heading', { name: product.title })).toBeInTheDocument();
    expect(screen.getByText('$109.95')).toBeInTheDocument();
    expect(screen.getByText("Men's Clothing")).toBeInTheDocument();
    expect(screen.getByAltText(product.title)).toHaveAttribute('src', product.image);

    const qtyInput = screen.getByLabelText(`Quantity for ${product.title}`);
    expect(qtyInput).toHaveValue(1);

    expect(
      screen.getByRole('button', { name: `Decrease quantity for ${product.title}` })
    ).toBeDisabled();
    expect(
      screen.getByRole('button', { name: `Increase quantity for ${product.title}` })
    ).toBeEnabled();
    expect(screen.getByRole('button', { name: /add to cart/i })).toBeInTheDocument();
  });

  it('increments and decrements quantity with stepper buttons without going below 1', async () => {
    const user = userEvent.setup();
    render(<ProductCard product={product} onAddToCart={vi.fn()} />);

    const qtyInput = screen.getByLabelText(`Quantity for ${product.title}`);
    const incBtn = screen.getByRole('button', {
      name: `Increase quantity for ${product.title}`,
    });
    const decBtn = screen.getByRole('button', {
      name: `Decrease quantity for ${product.title}`,
    });

    await user.click(incBtn);
    await user.click(incBtn);
    expect(qtyInput).toHaveValue(3);
    expect(decBtn).toBeEnabled();

    await user.click(decBtn);
    expect(qtyInput).toHaveValue(2);

    await user.click(decBtn);
    expect(qtyInput).toHaveValue(1);
    expect(decBtn).toBeDisabled();
  });

  it('allows manually typing a quantity and submits that exact quantity to onAddToCart', async () => {
    const user = userEvent.setup();
    const handleAddToCart = vi.fn();

    render(<ProductCard product={product} onAddToCart={handleAddToCart} />);

    const qtyInput = screen.getByLabelText(`Quantity for ${product.title}`);
    await user.clear(qtyInput);
    await user.type(qtyInput, '7');
    expect(qtyInput).toHaveValue(7);

    await user.click(screen.getByRole('button', { name: /add to cart/i }));

    expect(handleAddToCart).toHaveBeenCalledTimes(1);
    expect(handleAddToCart).toHaveBeenCalledWith(product, 7);
    expect(qtyInput).toHaveValue(1);
    expect(screen.getByRole('button', { name: /added!/i })).toBeInTheDocument();
  });

  it('clamps empty or excessive manual input back into valid bounds on blur', async () => {
    const user = userEvent.setup();
    render(<ProductCard product={product} onAddToCart={vi.fn()} />);

    const qtyInput = screen.getByLabelText(`Quantity for ${product.title}`);

    await user.clear(qtyInput);
    await user.tab();
    expect(qtyInput).toHaveValue(1);

    await user.clear(qtyInput);
    await user.type(qtyInput, '250');
    await user.tab();
    expect(qtyInput).toHaveValue(99);
  });

  it('displays the In cart indicator when cartQuantity is greater than zero', () => {
    render(
      <ProductCard product={product} onAddToCart={vi.fn()} cartQuantity={4} />
    );

    expect(screen.getByText('In cart: 4')).toBeInTheDocument();
  });
});
