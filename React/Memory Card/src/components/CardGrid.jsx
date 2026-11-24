import Card from './Card.jsx';
import '../styles/CardGrid.css';

function CardGrid({
  cards,
  isLoading,
  error,
  skeletonCount,
  isShuffling,
  disabled,
  onCardSelect,
  onRetry,
}) {
  if (error) {
    return (
      <div className="error-panel" role="alert">
        <h2 className="error-panel-title">Could not reach PokéAPI</h2>
        <p className="error-panel-message">{error}</p>
        <button type="button" className="retry-btn" onClick={onRetry}>
          Try Again
        </button>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div
        className="card-grid"
        aria-busy="true"
        aria-label="Loading Pokémon cards"
      >
        {Array.from({ length: skeletonCount }, (_, idx) => (
          <div key={`skeleton-${idx}`} className="skeleton-card">
            <div className="skeleton-bar skeleton-bar--short" />
            <div className="skeleton-orb" />
            <div className="skeleton-bar skeleton-bar--title" />
          </div>
        ))}
      </div>
    );
  }

  return (
    <section
      className={`card-grid ${isShuffling ? 'card-grid--shuffling' : ''}`}
      aria-label="Memory card deck"
    >
      {cards.map((card) => (
        <Card
          key={card.id}
          card={card}
          onSelect={onCardSelect}
          disabled={disabled}
        />
      ))}
    </section>
  );
}

export default CardGrid;
