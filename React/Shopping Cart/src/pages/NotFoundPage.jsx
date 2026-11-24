import { ArrowLeft } from 'lucide-react';
import { Link } from 'react-router';
import '../styles/NotFoundPage.css';

export function NotFoundPage() {
  return (
    <section className="not-found-page">
      <p className="not-found-code">404</p>
      <h1 className="not-found-title">Page not found</h1>
      <p className="not-found-copy">
        The shelf you’re looking for doesn’t exist or may have moved.
      </p>
      <div className="not-found-actions">
        <Link to="/" className="btn-primary">
          <ArrowLeft size={16} aria-hidden="true" />
          <span>Back to Home</span>
        </Link>
        <Link to="/shop" className="btn-secondary">
          Visit the Shop
        </Link>
      </div>
    </section>
  );
}
