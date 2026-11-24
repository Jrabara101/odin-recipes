import '../styles/Card.css';

function Card({ card, onSelect, disabled }) {
  return (
    <button
      type="button"
      className={`poke-card poke-card--${card.primaryType}`}
      onClick={() => onSelect(card)}
      disabled={disabled}
      aria-label={`Select ${card.name}, ${card.pokedexNumber}, ${card.types.join(' / ')} type`}
    >
      <div className="poke-card-top">
        <span className="poke-dex-number">{card.pokedexNumber}</span>
        <span className="poke-bst">BST {card.baseStatTotal}</span>
      </div>

      <div className="poke-art-stage">
        <img
          src={card.image}
          alt={card.name}
          className="poke-artwork"
          width="160"
          height="160"
          draggable="false"
        />
      </div>

      <div className="poke-card-footer">
        <h2 className="poke-name">{card.name}</h2>
        <div className="poke-type-row">
          {card.types.map((type, index) => (
            <span
              key={type}
              className={`poke-type-pill ${
                index === 0 ? 'poke-type-pill--primary' : ''
              }`}
            >
              {type}
            </span>
          ))}
        </div>
      </div>
    </button>
  );
}

export default Card;
