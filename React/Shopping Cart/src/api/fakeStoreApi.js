const FAKESTORE_API_BASE = 'https://fakestoreapi.com';

export function normalizeProduct(raw) {
  return {
    id: Number(raw.id),
    title: String(raw.title ?? '').trim(),
    price: Number(raw.price ?? 0),
    description: String(raw.description ?? '').trim(),
    category: String(raw.category ?? '').trim(),
    image: String(raw.image ?? '').trim(),
    rating: {
      rate: Number(raw.rating?.rate ?? 0),
      count: Number(raw.rating?.count ?? 0),
    },
  };
}

export async function fetchProducts({ signal } = {}) {
  const response = await fetch(`${FAKESTORE_API_BASE}/products`, { signal });

  if (!response.ok) {
    throw new Error(`Unable to load catalog (HTTP ${response.status}).`);
  }

  const data = await response.json();
  if (!Array.isArray(data)) {
    throw new Error('Unexpected catalog payload received from FakeStore API.');
  }

  return data.map(normalizeProduct);
}
