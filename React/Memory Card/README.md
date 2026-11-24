# PokéRecall — Memory Card Game

A React Memory Card game built for [The Odin Project — Memory Card](https://www.theodinproject.com/lessons/react-new-memory-card).

## Features

- **Live External API Integration**: Fetches Pokémon official artwork, Pokédex numbers, elemental types, and Base Stat Totals (BST) from [PokéAPI](https://pokeapi.co/) using `useEffect` with `AbortController` cleanup.
- **Scoreboard & Persistence**: Tracks **Current Score** and **Best Score** (persisted in `localStorage`) along with a live round progress meter.
- **Random Shuffle on Mount & Every Click**: Uses a Fisher-Yates shuffle utility invoked both when cards mount/load and after every card selection.
- **Difficulty Tiers & Replay Controls**: Play **Easy (8 cards)**, **Classic (12 cards)**, or **Master (16 cards)**, deal a fresh random deck anytime, and review round outcomes in the Victory / Game Over modal.

## Project Structure

```text
src/
├── api/
│   └── pokemonApi.js
├── components/
│   ├── Card.jsx
│   ├── CardGrid.jsx
│   ├── GameModal.jsx
│   └── Header.jsx
├── styles/
│   ├── App.css
│   ├── Card.css
│   ├── CardGrid.css
│   ├── GameModal.css
│   ├── Header.css
│   └── global.css
├── utils/
│   └── shuffle.js
├── App.jsx
└── main.jsx
```

## Development

```bash
npm install
npm run dev
npm run lint
npm run build
```
