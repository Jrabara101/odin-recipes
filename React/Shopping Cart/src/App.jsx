import { Route, Routes } from 'react-router';
import { Layout } from './components/Layout';
import { CartProvider } from './context/CartProvider';
import { ProductsProvider } from './context/ProductsProvider';
import { CartPage } from './pages/CartPage';
import { HomePage } from './pages/HomePage';
import { NotFoundPage } from './pages/NotFoundPage';
import { ShopPage } from './pages/ShopPage';

export function App({
  initialProducts = null,
  productFetcher,
  initialCartItems = null,
  persistCart = true,
}) {
  return (
    <ProductsProvider
      initialProducts={initialProducts}
      fetcher={productFetcher}
    >
      <CartProvider initialItems={initialCartItems} persist={persistCart}>
        <Routes>
          <Route element={<Layout />}>
            <Route index element={<HomePage />} />
            <Route path="shop" element={<ShopPage />} />
            <Route path="cart" element={<CartPage />} />
            <Route path="*" element={<NotFoundPage />} />
          </Route>
        </Routes>
      </CartProvider>
    </ProductsProvider>
  );
}

export default App;
