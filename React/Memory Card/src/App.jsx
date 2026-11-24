import { useEffect, useState } from 'react';
import Header from './components/Header.jsx';
import CardGrid from './components/CardGrid.jsx';
import GameModal from './components/GameModal.jsx';
import { fetchPokemonDeck } from './api/pokemonApi.js';
import { shuffleCards } from './utils/shuffle.js';
import './styles/App.css';

const DIFFICULTIES = [
  { id: 'easy', label: 'Easy', count: 8 },
  { id: 'classic', label: 'Classic', count: 12 },
  { id: 'master', label: 'Master', count: 16 },
];

const BEST_SCORE_STORAGE_KEY = 'pokerecall-best-score';

function readInitialBestScore() {
  if (typeof window === 'undefined') return 0;
  try {
    const raw = window.localStorage.getItem(BEST_SCORE_STORAGE_KEY);
    const parsed = Number.parseInt(raw, 10);
    return Number.isFinite(parsed) && parsed > 0 ? parsed : 0;
  } catch {
    return 0;
  }
}

function saveBestScore(value) {
  if (typeof window === 'undefined') return;
  try {
    window.localStorage.setItem(BEST_SCORE_STORAGE_KEY, String(value));
  } catch {
    // Ignore storage errors in private/restricted browsers
  }
}

function App() {
  const [difficulty, setDifficulty] = useState('classic');
  const [deckSeed, setDeckSeed] = useState(0);
  const [cards, setCards] = useState([]);
  const [clickedIds, setClickedIds] = useState([]);
  const [bestScore, setBestScore] = useState(readInitialBestScore);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [gameStatus, setGameStatus] = useState('playing');
  const [repeatCard, setRepeatCard] = useState(null);
  const [newRecordThisRound, setNewRecordThisRound] = useState(false);
  const [isShuffling, setIsShuffling] = useState(false);

  const activeConfig =
    DIFFICULTIES.find((level) => level.id === difficulty) || DIFFICULTIES[1];
  const cardCount = activeConfig.count;
  const score = clickedIds.length;

  useEffect(() => {
    const controller = new AbortController();
    let cancelled = false;

    async function loadAndShuffleDeck() {
      setIsLoading(true);
      setError(null);
      setClickedIds([]);
      setGameStatus('playing');
      setRepeatCard(null);
      setNewRecordThisRound(false);

      try {
        const fetchedCards = await fetchPokemonDeck(
          cardCount,
          controller.signal
        );
        if (!cancelled) {
          // Invoke shuffle on mount and whenever a fresh deck loads
          setCards(shuffleCards(fetchedCards));
        }
      } catch (err) {
        if (!cancelled && err.name !== 'AbortError') {
          setError(
            err.message ||
              'Failed to fetch Pokémon cards. Please check your connection.'
          );
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false);
        }
      }
    }

    loadAndShuffleDeck();

    return () => {
      cancelled = true;
      controller.abort();
    };
  }, [cardCount, deckSeed]);

  useEffect(() => {
    if (!isShuffling) return undefined;
    const timer = window.setTimeout(() => setIsShuffling(false), 190);
    return () => window.clearTimeout(timer);
  }, [isShuffling]);

  function triggerBoardShuffle() {
    setCards((prevCards) => shuffleCards(prevCards));
    setIsShuffling(true);
  }

  function handleCardSelect(card) {
    if (gameStatus !== 'playing' || isLoading) return;

    // Shuffle cards into a random order anytime a user clicks one
    triggerBoardShuffle();

    if (clickedIds.includes(card.id)) {
      setRepeatCard(card);
      setGameStatus('lost');
      return;
    }

    const nextClicked = [...clickedIds, card.id];
    const nextScore = nextClicked.length;
    setClickedIds(nextClicked);

    if (nextScore > bestScore) {
      setBestScore(nextScore);
      saveBestScore(nextScore);
      setNewRecordThisRound(true);
    }

    if (nextScore === cards.length) {
      setGameStatus('won');
    }
  }

  function handleReplaySameDeck() {
    setClickedIds([]);
    setGameStatus('playing');
    setRepeatCard(null);
    setNewRecordThisRound(false);
    triggerBoardShuffle();
  }

  function handleDealNewDeck() {
    setDeckSeed((prev) => prev + 1);
  }

  function handleSelectDifficulty(nextDifficulty) {
    if (nextDifficulty === difficulty) return;
    setDifficulty(nextDifficulty);
  }

  const activeIndex = DIFFICULTIES.findIndex((d) => d.id === difficulty);
  const nextDifficulty =
    activeIndex >= 0 && activeIndex < DIFFICULTIES.length - 1
      ? DIFFICULTIES[activeIndex + 1]
      : null;

  const progressPercent =
    cards.length > 0 ? Math.round((score / cards.length) * 100) : 0;

  return (
    <div className="app-shell">
      <Header
        score={score}
        bestScore={bestScore}
        newRecordThisRound={newRecordThisRound}
        difficulties={DIFFICULTIES}
        activeDifficulty={difficulty}
        onSelectDifficulty={handleSelectDifficulty}
        onNewDeck={handleDealNewDeck}
        isLoading={isLoading}
      />

      <main className="game-main">
        <div className="rules-bar">
          <p className="rules-text">
            Click each Pokémon <strong>only once</strong> to build your streak —
            the deck reshuffles after every pick.
          </p>
          <div className="progress-group" aria-label="Round progress">
            <div className="progress-track">
              <div
                className={`progress-fill ${
                  gameStatus === 'won' ? 'progress-fill--complete' : ''
                }`}
                style={{ width: `${progressPercent}%` }}
              />
            </div>
            <span className="progress-label">
              {score} / {cards.length || cardCount}
            </span>
          </div>
        </div>

        <CardGrid
          cards={cards}
          isLoading={isLoading}
          error={error}
          skeletonCount={cardCount}
          isShuffling={isShuffling}
          disabled={gameStatus !== 'playing'}
          onCardSelect={handleCardSelect}
          onRetry={handleDealNewDeck}
        />
      </main>

      <footer className="app-footer">
        <span>Built with React hooks &amp; Vite for The Odin Project.</span>
        <span>
          Pokémon data &amp; artwork fetched live from{' '}
          <a
            href="https://pokeapi.co/"
            target="_blank"
            rel="noopener noreferrer"
          >
            PokéAPI
          </a>
          .
        </span>
      </footer>

      <GameModal
        status={gameStatus}
        score={score}
        totalCards={cards.length || cardCount}
        bestScore={bestScore}
        newRecordThisRound={newRecordThisRound}
        repeatCard={repeatCard}
        nextDifficultyLabel={
          nextDifficulty
            ? `${nextDifficulty.label} (${nextDifficulty.count})`
            : null
        }
        onReplaySameDeck={handleReplaySameDeck}
        onDealNewDeck={handleDealNewDeck}
        onStepUpDifficulty={() => {
          if (nextDifficulty) setDifficulty(nextDifficulty.id);
        }}
      />
    </div>
  );
}

export default App;
