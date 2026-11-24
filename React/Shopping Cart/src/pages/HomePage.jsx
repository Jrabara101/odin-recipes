import { ArrowRight, PackageCheck, ShieldCheck, Sparkles, Star } from 'lucide-react';
import { Link } from 'react-router';
import { useProducts } from '../context/productsContext';
import { formatCategoryLabel, formatCurrency } from '../utils/formatters';
import '../styles/HomePage.css';

const CATEGORY_SHOWCASE = [
  {
    slug: "men's clothing",
    title: "Men's Clothing",
    blurb: 'Structured outerwear, packs, and everyday cotton layers.',
  },
  {
    slug: "women's clothing",
    title: "Women's Clothing",
    blurb: 'Tailored silhouettes, transitional jackets, and soft knitwear.',
  },
  {
    slug: 'jewelery',
    title: 'Jewelry',
    blurb: 'Fine metals, sculpted bands, and heirloom-inspired accents.',
  },
  {
    slug: 'electronics',
    title: 'Electronics',
    blurb: 'High-speed storage and ultrawide displays for focused desks.',
  },
];

const STORE_PILLARS = [
  {
    icon: Sparkles,
    title: 'Curated Edit',
    description:
      'Every item in our catalog is sourced live from FakeStore API across four focused departments.',
  },
  {
    icon: PackageCheck,
    title: 'Complimentary Shipping',
    description:
      'Orders over $100 automatically unlock free standard delivery in your cart summary.',
  },
  {
    icon: ShieldCheck,
    title: 'Effortless Bag Control',
    description:
      'Adjust item quantities directly from any product card or fine-tune everything inside your cart.',
  },
];

export function HomePage() {
  const { products, isLoading } = useProducts();

  const heroItems = products.slice(0, 4);
  const featuredItems = [...products]
    .sort((a, b) => (b.rating?.rate ?? 0) - (a.rating?.rate ?? 0))
    .slice(0, 4);

  return (
    <div className="home-page">
      <section className="hero-section">
        <div className="hero-copy">
          <p className="hero-eyebrow">Curated Concept Store · Issue 04</p>
          <h1 className="hero-title">
            Objects crafted for <em>everyday</em> rituals.
          </h1>
          <p className="hero-description">
            Discover Vesper Goods — a calm, editorial edit of wardrobe
            essentials, sculptural jewelry, and crisp workspace hardware. Pick
            exact quantities from the shelf and watch your bag update in real
            time.
          </p>

          <div className="hero-actions">
            <Link to="/shop" className="btn-primary">
              <span>Explore the Shop</span>
              <ArrowRight size={17} aria-hidden="true" />
            </Link>
            <Link to="/cart" className="btn-secondary">
              View Your Cart
            </Link>
          </div>

          <dl className="hero-stats">
            <div>
              <dt>Catalog</dt>
              <dd>{products.length > 0 ? `${products.length} Pieces` : 'Live API'}</dd>
            </div>
            <div>
              <dt>Departments</dt>
              <dd>4 Curated</dd>
            </div>
            <div>
              <dt>Shipping</dt>
              <dd>Free $100+</dd>
            </div>
          </dl>
        </div>

        <div className="hero-gallery" aria-label="Featured catalog preview">
          {isLoading && heroItems.length === 0
            ? Array.from({ length: 4 }, (_, index) => (
                <div
                  key={index}
                  className="hero-tile hero-tile--skeleton"
                  aria-hidden="true"
                />
              ))
            : heroItems.map((product) => (
                <Link
                  key={product.id}
                  to={`/shop?category=${encodeURIComponent(product.category)}`}
                  className="hero-tile"
                >
                  <div className="hero-tile-stage">
                    <img src={product.image} alt={product.title} />
                  </div>
                  <div className="hero-tile-caption">
                    <span className="hero-tile-label">
                      {formatCategoryLabel(product.category)}
                    </span>
                    <span className="hero-tile-price">
                      {formatCurrency(product.price)}
                    </span>
                  </div>
                </Link>
              ))}
        </div>
      </section>

      <section className="home-section" aria-labelledby="departments-heading">
        <div className="section-header">
          <div>
            <p className="section-eyebrow">Departments</p>
            <h2 id="departments-heading" className="section-title">
              Browse by Category
            </h2>
          </div>
          <Link to="/shop" className="section-link">
            View all goods <ArrowRight size={15} aria-hidden="true" />
          </Link>
        </div>

        <div className="category-grid">
          {CATEGORY_SHOWCASE.map((cat, index) => {
            const count = products.filter(
              (item) => item.category === cat.slug
            ).length;
            return (
              <Link
                key={cat.slug}
                to={`/shop?category=${encodeURIComponent(cat.slug)}`}
                className="category-card"
              >
                <span className="category-index">0{index + 1}</span>
                <h3 className="category-card-title">{cat.title}</h3>
                <p className="category-card-blurb">{cat.blurb}</p>
                <span className="category-card-footer">
                  <span>{count > 0 ? `${count} items` : 'Explore'}</span>
                  <ArrowRight size={15} aria-hidden="true" />
                </span>
              </Link>
            );
          })}
        </div>
      </section>

      {featuredItems.length > 0 && (
        <section className="home-section" aria-labelledby="featured-heading">
          <div className="section-header">
            <div>
              <p className="section-eyebrow">Highest Rated</p>
              <h2 id="featured-heading" className="section-title">
                Editor’s Picks
              </h2>
            </div>
            <Link to="/shop" className="section-link">
              Shop the full shelf <ArrowRight size={15} aria-hidden="true" />
            </Link>
          </div>

          <div className="featured-grid">
            {featuredItems.map((product) => (
              <Link key={product.id} to="/shop" className="featured-card">
                <div className="featured-card-stage">
                  <img src={product.image} alt={product.title} loading="lazy" />
                </div>
                <div className="featured-card-body">
                  <div className="featured-card-meta">
                    <span className="featured-card-cat">
                      {formatCategoryLabel(product.category)}
                    </span>
                    <span className="featured-card-rating">
                      <Star size={12} fill="currentColor" aria-hidden="true" />
                      {product.rating.rate.toFixed(1)}
                    </span>
                  </div>
                  <h3 className="featured-card-title">{product.title}</h3>
                  <p className="featured-card-price">
                    {formatCurrency(product.price)}
                  </p>
                </div>
              </Link>
            ))}
          </div>
        </section>
      )}

      <section className="pillars-band" aria-label="Store highlights">
        {STORE_PILLARS.map((pillar) => {
          const Icon = pillar.icon;
          return (
            <div key={pillar.title} className="pillar-card">
              <div className="pillar-icon" aria-hidden="true">
                <Icon size={20} />
              </div>
              <h3 className="pillar-title">{pillar.title}</h3>
              <p className="pillar-description">{pillar.description}</p>
            </div>
          );
        })}
      </section>
    </div>
  );
}
