import { useEffect } from 'react';
import '../styles/GameModal.css';

function GameModal({
  status,
  score,
  totalCards,
  bestScore,
  newRecordThisRound,
  repeatCard,
  nextDifficultyLabel,
  onReplaySameDeck,
  onDealNewDeck,
  onStepUpDifficulty,
}) {
  useEffect(() => {
    if (status === 'playing') return undefined;

    function handleKeyDown(event) {
      if (event.key === 'Escape') {
        onReplaySameDeck();
      }
    }

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [status, onReplaySameDeck]);

  if (status === 'playing') {
    return null;
  }

  const isVictory = status === 'won';

  return (
    <div
      className="modal-backdrop"
      role="dialog"
      aria-modal="true"
      aria-labelledby="game-modal-title"
    >
      <div
        className={`modal-panel ${
          isVictory ? 'modal-panel--won' : 'modal-panel--lost'
        }`}
      >
        <span
          className={`modal-badge ${
            isVictory ? 'modal-badge--won' : 'modal-badge--lost'
          }`}
        >
          {isVictory ? 'Perfect Recall' : 'Duplicate Pick'}
        </span>

        <h2 id="game-modal-title" className="modal-title">
          {isVictory ? 'Deck Mastered!' : 'Streak Ended'}
        </h2>

        {isVictory ? (
          <p className="modal-subtitle">
            You remembered every single one of the{' '}
            <strong>{totalCards} Pokémon</strong> without a repeat.
          </p>
        ) : (
          <p className="modal-subtitle">
            You already clicked{' '}
            <strong>{repeatCard ? repeatCard.name : 'that card'}</strong>{' '}
            earlier in this round.
          </p>
        )}

        {!isVictory && repeatCard?.image && (
          <div className="modal-culprit">
            <img src={repeatCard.image} alt={repeatCard.name} />
          </div>
        )}

        <div className="modal-stats">
          <div className="modal-stat-box">
            <span className="modal-stat-label">Round Score</span>
            <span className="modal-stat-number">
              {score} / {totalCards}
            </span>
          </div>
          <div className="modal-stat-box">
            <span className="modal-stat-label">Best Score</span>
            <span className="modal-stat-number modal-stat-number--gold">
              {bestScore}
            </span>
          </div>
        </div>

        {newRecordThisRound && (
          <p className="modal-record-note">New personal Best Score!</p>
        )}

        <div className="modal-actions">
          {isVictory && nextDifficultyLabel ? (
            <>
              <button
                type="button"
                className="modal-btn modal-btn--primary"
                onClick={onStepUpDifficulty}
              >
                Try {nextDifficultyLabel}
              </button>
              <button
                type="button"
                className="modal-btn modal-btn--secondary"
                onClick={onDealNewDeck}
              >
                Deal New Deck
              </button>
            </>
          ) : (
            <>
              <button
                type="button"
                className="modal-btn modal-btn--primary"
                onClick={onReplaySameDeck}
              >
                Try Same Deck
              </button>
              <button
                type="button"
                className="modal-btn modal-btn--secondary"
                onClick={onDealNewDeck}
              >
                Deal New Deck
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default GameModal;
