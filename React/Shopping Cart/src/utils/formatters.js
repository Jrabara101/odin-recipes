export const MAX_ITEM_QUANTITY = 99;

const CATEGORY_LABELS = {
  "men's clothing": "Men's Clothing",
  "women's clothing": "Women's Clothing",
  jewelery: 'Jewelry',
  electronics: 'Electronics',
};

const usdFormatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

export function formatCurrency(amount) {
  const numeric = Number(amount);
  if (!Number.isFinite(numeric)) {
    return usdFormatter.format(0);
  }
  return usdFormatter.format(numeric);
}

export function formatCategoryLabel(category) {
  if (!category || typeof category !== 'string') {
    return 'Goods';
  }
  const normalized = category.trim().toLowerCase();
  if (CATEGORY_LABELS[normalized]) {
    return CATEGORY_LABELS[normalized];
  }
  return normalized.replace(/\b\w/g, (char) => char.toUpperCase());
}

export function clampQuantity(value, { min = 1, max = MAX_ITEM_QUANTITY } = {}) {
  const parsed = Number.parseInt(String(value), 10);
  if (!Number.isFinite(parsed) || Number.isNaN(parsed)) {
    return min;
  }
  return Math.min(max, Math.max(min, parsed));
}
