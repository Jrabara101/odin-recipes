import { AlertCircle, RefreshCw, Search, SlidersHorizontal, X } from 'lucide-react';
import { useMemo, useState } from 'react';
import { useSearchParams } from 'react-router';
import { ProductCard } from '../components/ProductCard';
import { useCart } from '../context/cartContext';
import { useProducts } from '../context/productsContext';
import { formatCategoryLabel } from '../utils/formatters';
import '../styles/ShopPage.css';

const SORT_OPTIONS = [
  { value: 'featured', label: 'Featured' },
  { value: 'price-asc', label: 'Price: Low to High' },
  { value: 'price-desc', label: 'Price: High to Low' },
  { value: 'rating-desc', label: 'Top Rated' },
];

export function ShopPage() {
  const { products, categories, isLoading, error, retry } = useProducts();
  const { addToCart, getProductQuantity } = useCart();
  const [searchParams, setSearchParams] = useSearchParams();

  const activeCategory = searchParams.get('category') ?? 'all';
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState('featured');

  function handleSelectCategory(category) {
    const nextParams = new URLSearchParams(searchParams);
    if (category === 'all') {
      nextParams.delete('category');
    } else {
      nextParams.set('category', category);
    }
    setSearchParams(nextParams, { replace: true });
  }

  function handleResetFilters() {
    setSearchQuery('');
    setSortBy('featured');
    handleSelectCategory('all');
  }

  const visibleProducts = useMemo(() => {
    const normalizedQuery = searchQuery.trim().toLowerCase();

    const filtered = products.filter((product) => {
      const matchesCategory =
        activeCategory === 'all' || product.category === activeCategory;
      const matchesSearch =
        normalizedQuery === '' ||
        product.title.toLowerCase().includes(normalizedQuery) ||
        product.category.toLowerCase().includes(normalizedQuery) ||
        product.description.toLowerCase().includes(normalizedQuery);
      return matchesCategory && matchesSearch;
    });

    if (sortBy === 'price-asc') {
      return [...filtered].sort((a, b) => a.price - b.price);
    }
    if (sortBy === 'price-desc') {
      return [...filtered].sort((a, b) => b.price - a.price);
    }
    if (sortBy === 'rating-desc') {
      return [...filtered].sort(
        (a, b) => (b.rating?.rate ?? 0) - (a.rating?.rate ?? 0)
      );
    }
    return filtered;
  }, [products, activeCategory, searchQuery, sortBy]);

  return (
    <div className="shop-page">
      <header className="shop-header">
        <div>
          <p className="shop-eyebrow">Storefront Catalog</p>
          <h1 className="shop-title">The Shop</h1>
          <p className="shop-subtitle">
            Set your desired quantity directly on any item and add it straight
            to your bag.
          </p>
        </div>

        {!isLoading && !error && (
          <p className="shop-result-count" aria-live="polite">
            Showing <strong>{visibleProducts.length}</strong> of{' '}
            <strong>{products.length}</strong> items
          </p>
        )}
      </header>

      <section className="shop-toolbar" aria-label="Catalog filters">
        <div className="category-pills" role="group" aria-label="Filter by category">
          <button
            type="button"
            className={
              activeCategory === 'all'
                ? 'category-pill category-pill--active'
                : 'category-pill'
            }
            aria-pressed={activeCategory === 'all'}
            onClick={() => handleSelectCategory('all')}
          >
            All
          </button>
          {categories.map((category) => (
            <button
              key={category}
              type="button"
              className={
                activeCategory === category
                  ? 'category-pill category-pill--active'
                  : 'category-pill'
              }
              aria-pressed={activeCategory === category}
              onClick={() => handleSelectCategory(category)}
            >
              {formatCategoryLabel(category)}
            </button>
          ))}
        </div>

        <div className="toolbar-controls">
          <div className="search-field">
            <Search size={16} className="search-icon" aria-hidden="true" />
            <label htmlFor="shop-search" className="sr-only">
              Search products
            </label>
            <input
              id="shop-search"
              type="search"
              value={searchQuery}
              onChange={(event) => setSearchQuery(event.target.value)}
              placeholder="Search items..."
              className="search-input"
            />
            {searchQuery && (
              <button
                type="button"
                className="search-clear-btn"
                onClick={() => setSearchQuery('')}
                aria-label="Clear search"
              >
                <X size={14} aria-hidden="true" />
              </button>
            )}
          </div>

          <div className="sort-field">
            <SlidersHorizontal size={15} aria-hidden="true" />
            <label htmlFor="shop-sort" className="sr-only">
              Sort products
            </label>
            <select
              id="shop-sort"
              value={sortBy}
              onChange={(event) => setSortBy(event.target.value)}
              className="sort-select"
            >
              {SORT_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>
        </div>
      </section>

      {isLoading && (
        <div className="shop-loading" role="status" aria-label="Loading products">
          <p className="sr-only">Loading products...</p>
          <div className="product-grid">
            {Array.from({ length: 8 }, (_, index) => (
              <div key={index} className="skeleton-card" aria-hidden="true">
                <div className="skeleton-media" />
                <div className="skeleton-line skeleton-line--short" />
                <div className="skeleton-line" />
                <div className="skeleton-line skeleton-line--btn" />
              </div>
            ))}
          </div>
        </div>
      )}

      {!isLoading && error && (
        <div className="shop-state-panel" role="alert">
          <AlertCircle size={32} className="state-icon state-icon--error" aria-hidden="true" />
          <h2>Could not load products</h2>
          <p>{error}</p>
          <button type="button" className="btn-primary" onClick={retry}>
            <RefreshCw size={15} aria-hidden="true" />
            <span>Try Again</span>
          </button>
        </div>
      )}

      {!isLoading && !error && visibleProducts.length === 0 && (
        <div className="shop-state-panel">
          <h2>No matching items</h2>
          <p>
            Try adjusting your search term or selecting a different department.
          </p>
          <button
            type="button"
            className="btn-secondary"
            onClick={handleResetFilters}
          >
            Reset Filters
          </button>
        </div>
      )}

      {!isLoading && !error && visibleProducts.length > 0 && (
        <div className="product-grid">
          {visibleProducts.map((product) => (
            <ProductCard
              key={product.id}
              product={product}
              onAddToCart={addToCart}
              cartQuantity={getProductQuantity(product.id)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
