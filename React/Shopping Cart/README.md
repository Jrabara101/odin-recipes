# Vesper Goods — Shopping Cart

A modern React storefront and shopping cart built for [The Odin Project — Shopping Cart](https://www.theodinproject.com/lessons/react-new-shopping-cart).

## Architecture & Component Plan

```text
src/
├── api/
│   └── fakeStoreApi.js        # FakeStore API client with AbortController & normalization
├── components/
│   ├── Layout.jsx             # Shared page shell (Navbar, Outlet, Footer, live announcements)
│   ├── Navbar.jsx             # Persistent navigation bar with real-time Cart item badge
│   ├── ProductCard.jsx        # Product card with manual quantity input, -/+ steppers, Add To Cart
│   └── CartItem.jsx           # Cart line item with quantity controls, subtotal, and removal
├── context/
│   ├── cartReducer.js         # Pure cart reducer & integer-cent pricing selectors
│   ├── cartContext.js         # CartContext + useCart hook
│   ├── CartProvider.jsx       # Cart state provider with localStorage persistence
│   ├── productsContext.js     # ProductsContext + useProducts hook
│   └── ProductsProvider.jsx   # Shared catalog fetch with loading, error, and retry
├── pages/
│   ├── HomePage.jsx           # Editorial concept-store landing page, categories, editor's picks
│   ├── ShopPage.jsx           # Live catalog with category pills, search, sort, and product cards
│   ├── CartPage.jsx           # Itemized bag, quantity updates/removal, and order summary
│   └── NotFoundPage.jsx       # Fallback route inside the shared layout
├── styles/                    # Modular CSS stylesheets with warm editorial design tokens
├── utils/
│   └── formatters.js          # Currency formatting, category labels, quantity clamping
├── test/
│   └── setup.js               # Vitest + @testing-library/jest-dom setup
├── __tests__/                 # React Testing Library & reducer unit tests
├── App.jsx
└── main.jsx
```

## Features

- **Three Pages & Persistent Navigation Bar**: Navigate seamlessly between **Home** (`/`), **Shop** (`/shop`), and **Cart** (`/cart`) with active-route indicators and a real-time item count badge in the navbar whenever the cart has items.
- **Live FakeStore API Integration**: Fetches product data from [FakeStore API](https://fakestoreapi.com/) with skeleton loading states, graceful error handling + retry, category filters, search, and sorting.
- **Per-Card Quantity Controls**: Each product card features a numeric input for manual typing, decrement (`-`) and increment (`+`) buttons, an "In cart" badge when already added, and an **Add To Cart** button with confirmation feedback.
- **Full Cart Management**: View items and quantities, adjust counts via `-`/`+` or direct typing, automatically remove an item when decremented to zero (or via **Remove** / **Clear Cart**), and inspect live subtotal, shipping threshold progress, and order total.
- **Thorough React Testing Library Suite**: Tests application components, reducer logic, API states, and shopping workflows without testing `react-router` internals.
- **SPA Deployment Ready**: Includes `vercel.json` (Vercel rewrites) and `public/_redirects` (Netlify fallback), and works natively on Cloudflare Pages.

## Scripts

```bash
npm install
npm run dev
npm test
npm run lint
npm run build
```
