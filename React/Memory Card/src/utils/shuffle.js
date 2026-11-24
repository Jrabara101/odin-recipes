/**
 * Returns a new array shuffled using the Fisher-Yates algorithm.
 * When shuffling 2+ items, retries once if the result matches the input order
 * so a player click always visibly rearranges the board.
 */
export function shuffleCards(items) {
  if (!Array.isArray(items) || items.length <= 1) {
    return Array.isArray(items) ? [...items] : [];
  }

  const performShuffle = (source) => {
    const copy = [...source];
    for (let i = copy.length - 1; i > 0; i -= 1) {
      const j = Math.floor(Math.random() * (i + 1));
      [copy[i], copy[j]] = [copy[j], copy[i]];
    }
    return copy;
  };

  let shuffled = performShuffle(items);
  const unchanged = shuffled.every((item, index) => item === items[index]);
  if (unchanged) {
    shuffled = performShuffle(items);
  }
  return shuffled;
}

export function formatPokemonName(rawName) {
  if (!rawName) return '';
  return rawName
    .split('-')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

export function formatPokedexNumber(id) {
  return `#${String(id).padStart(3, '0')}`;
}
