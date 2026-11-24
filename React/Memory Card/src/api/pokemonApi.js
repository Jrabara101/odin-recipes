import {
  formatPokedexNumber,
  formatPokemonName,
  shuffleCards,
} from '../utils/shuffle.js';

const POKEAPI_BASE = 'https://pokeapi.co/api/v2/pokemon';

// Curated pool of 48 iconic, visually distinct Pokémon across generations
const POKEMON_POOL_IDS = [
  1, 4, 7, 25, 39, 52, 54, 59, 65, 94, 104, 129, 130, 131, 133, 134, 135, 136,
  143, 144, 145, 146, 149, 150, 151, 152, 155, 158, 175, 196, 197, 212, 248,
  249, 250, 252, 255, 258, 282, 302, 330, 359, 373, 376, 384, 393, 445, 448,
];

function selectRandomIds(count) {
  const shuffledPool = shuffleCards(POKEMON_POOL_IDS);
  return shuffledPool.slice(0, Math.min(count, shuffledPool.length));
}

async function fetchSinglePokemon(id, signal) {
  const response = await fetch(`${POKEAPI_BASE}/${id}`, { signal });
  if (!response.ok) {
    throw new Error(`PokéAPI responded with status ${response.status}`);
  }
  const data = await response.json();

  const image =
    data.sprites?.other?.['official-artwork']?.front_default ||
    data.sprites?.other?.home?.front_default ||
    data.sprites?.front_default;

  const types = (data.types || []).map((entry) => entry.type.name);
  const baseStatTotal = (data.stats || []).reduce(
    (sum, stat) => sum + (stat.base_stat || 0),
    0
  );

  return {
    id: data.id,
    pokedexNumber: formatPokedexNumber(data.id),
    name: formatPokemonName(data.name),
    image,
    types,
    primaryType: types[0] || 'normal',
    baseStatTotal,
  };
}

export async function fetchPokemonDeck(count, signal) {
  const ids = selectRandomIds(count);
  const cards = await Promise.all(
    ids.map((id) => fetchSinglePokemon(id, signal))
  );
  return cards;
}
