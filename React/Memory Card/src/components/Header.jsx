import '../styles/Header.css';

function Header({
  score,
  bestScore,
  newRecordThisRound,
  difficulties,
  activeDifficulty,
  onSelectDifficulty,
  onNewDeck,
  isLoading,
}) {
  return (
    <header className="game-header">
      <div className="game-header-inner">
        <div className="brand-lockup">
          <div className="brand-emblem" aria-hidden="true">
            <svg width="22" height="22" viewBox="0 0 32 32" fill="none">
              <circle cx="16" cy="16" r="11" stroke="#e8b94d" strokeWidth="2.2" />
              <path d="M5 16h22" stroke="#e8b94d" strokeWidth="2.2" />
              <path
                d="M16 5A11 11 0 0 1 27 16H5A11 11 0 0 1 16 5Z"
                fill="#ef4444"
                fillOpacity="0.85"
              />
              <circle
                cx="16"
                cy="16"
                r="3.5"
                fill="#131b2c"
                stroke="#e8b94d"
                strokeWidth="2.2"
              />
              <circle cx="16" cy="16" r="1.4" fill="#f5f2eb" />
            </svg>
          </div>
          <div>
            <h1 className="brand-title">PokéRecall</h1>
            <p className="brand-tagline">Memory Card Challenge</p>
          </div>
        </div>

        <div className="header-controls">
          <div
            className="difficulty-group"
            role="group"
            aria-label="Deck difficulty"
          >
            {difficulties.map((level) => (
              <button
                key={level.id}
                type="button"
                className={`difficulty-btn ${
                  activeDifficulty === level.id ? 'difficulty-btn--active' : ''
                }`}
                onClick={() => onSelectDifficulty(level.id)}
                disabled={isLoading && activeDifficulty !== level.id}
                aria-pressed={activeDifficulty === level.id}
              >
                {level.label} · {level.count}
              </button>
            ))}
          </div>

          <div className="scoreboard" aria-label="Scoreboard">
            <div className="score-pill">
              <span className="score-pill-label">Score</span>
              <span className="score-pill-value" data-testid="current-score">
                {score}
              </span>
            </div>
            <div
              className={`score-pill score-pill--best ${
                newRecordThisRound ? 'score-pill--record' : ''
              }`}
            >
              <span className="score-pill-label">Best Score</span>
              <span className="score-pill-value" data-testid="best-score">
                {bestScore}
              </span>
            </div>
          </div>

          <button
            type="button"
            className="new-deck-btn"
            onClick={onNewDeck}
            disabled={isLoading}
          >
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.2"
              strokeLinecap="round"
              strokeLinejoin="round"
              aria-hidden="true"
            >
              <polyline points="23 4 23 10 17 10" />
              <polyline points="1 20 1 14 7 14" />
              <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" />
            </svg>
            New Deck
          </button>
        </div>
      </div>
    </header>
  );
}

export default Header;
