import { useCallback, useEffect, useMemo, useState } from 'react';
import { fetchProducts } from '../api/fakeStoreApi';
import { ProductsContext } from './productsContext';

export function ProductsProvider({
  children,
  initialProducts = null,
  fetcher = fetchProducts,
}) {
  const [products, setProducts] = useState(
    Array.isArray(initialProducts) ? initialProducts : []
  );
  const [status, setStatus] = useState(
    Array.isArray(initialProducts) ? 'success' : 'loading'
  );
  const [error, setError] = useState(null);
  const [reloadToken, setReloadToken] = useState(0);

  useEffect(() => {
    if (Array.isArray(initialProducts) && reloadToken === 0) {
      return undefined;
    }

    const controller = new AbortController();
    let active = true;

    async function loadCatalog() {
      setStatus('loading');
      setError(null);
      try {
        const result = await fetcher({ signal: controller.signal });
        if (!active) return;
        setProducts(result);
        setStatus('success');
      } catch (err) {
        if (!active || err?.name === 'AbortError') return;
        setError(err instanceof Error ? err.message : 'Failed to load products.');
        setStatus('error');
      }
    }

    loadCatalog();

    return () => {
      active = false;
      controller.abort();
    };
  }, [fetcher, initialProducts, reloadToken]);

  const retry = useCallback(() => {
    setReloadToken((count) => count + 1);
  }, []);

  const categories = useMemo(() => {
    const unique = new Set(products.map((product) => product.category));
    return Array.from(unique);
  }, [products]);

  const value = useMemo(
    () => ({
      products,
      categories,
      status,
      isLoading: status === 'loading',
      error,
      retry,
    }),
    [products, categories, status, error, retry]
  );

  return (
    <ProductsContext.Provider value={value}>
      {children}
    </ProductsContext.Provider>
  );
}
