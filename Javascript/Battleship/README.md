# Battleship — The Odin Project

A feature-complete, modern browser implementation of the classic naval strategy game **Battleship**, built with Vanilla JavaScript, Test-Driven Development (TDD) using Jest & Babel, and bundled with Webpack.

---

## 🚀 Features

### Core Mechanics & TDD Architecture
- **Strict Separation of Concerns**: Pure domain models (`Ship`, `Gameboard`, `Player`, `GameController`) are completely decoupled from DOM manipulation and rendering (`DomController`, `audio.js`).
- **Comprehensive Unit Testing**: 48+ test cases covering ships, board bounds, collisions, hit detection, fleet sinking, AI turns, and pass-and-play turn switching with **~95% code coverage**.
- **Standard Battleship Fleet**:
  - Carrier (5 cells)
  - Battleship (4 cells)
  - Destroyer (3 cells)
  - Submarine (3 cells)
  - Patrol Boat (2 cells)

### Extra Credit & Advanced Features
1. **Interactive Ship Placement & Drag-and-Drop**:
   - Drag ships directly from the dry dock onto the 10x10 tactical deployment grid.
   - Live hover highlights (green for valid placement, red for invalid/collision/out-of-bounds).
   - Click-to-place fallback support (click a ship in the dock, then click on the grid).
   - Axis rotation via the **Rotate** button or pressing <kbd>R</kbd>.
   - Instant **Randomize Fleet** and **Reset Grid** capabilities.
2. **2-Player Mode with Pass Device Protocol**:
   - Play against a friend locally in **2-Player (Pass & Play)** mode.
   - Includes a secure full-screen **"Pass Device" intermission modal** ensuring players cannot peek at each other's ship positions.
3. **Smart Computer AI (Hunt & Target)**:
   - **Hunt Mode**: Uses a checkerboard parity heuristic to locate ships in half the moves of pure random guessing.
   - **Target Mode**: Upon scoring a hit, dynamically queues adjacent cardinal coordinates (North, South, East, West). Once multiple hits are scored, it aligns along the ship's axis to systematically sink the vessel before returning to hunt mode.
4. **Procedural Web Audio Sound Effects**:
   - Pure Web Audio API synthesized sound effects without external asset dependencies:
     - Radar/Sonar pings
     - Cannon / missile launches
     - Direct hit explosion bursts
     - Ocean splash misses
     - Naval klaxon / ship sunk horns
     - Triumphant victory fanfare
   - Toggleable sound button (Mute / Unmute).
5. **Modern Radar Tactical UI**:
   - Cyberpunk naval command theme with glowing radar sweeps, real-time combat intelligence feed, live fleet status chips, and responsive design across desktop, tablet, and mobile.

---

## 🛠️ Project Structure

```
Battleship/
├── dist/                     # Webpack production build output
│   ├── index.html
│   └── bundle.js
├── src/
│   ├── index.js              # Application entrypoint
│   ├── template.html         # HTML template
│   ├── style.css             # Cyberpunk/naval operations styling
│   ├── models/
│   │   ├── Ship.js           # Ship factory/class with length, hits, isSunk()
│   │   ├── Gameboard.js      # 10x10 grid, placement, collision checks, receiveAttack()
│   │   └── Player.js         # Human & Smart AI (Hunt & Target) Player
│   ├── controllers/
│   │   └── GameController.js # Game state, turn alternation, win conditions
│   ├── views/
│   │   ├── DomController.js  # Grid rendering, drag-and-drop, modals, combat log
│   │   └── audio.js          # Procedural Web Audio API sound generator
│   └── tests/
│       ├── Ship.test.js
│       ├── Gameboard.test.js
│       ├── Player.test.js
│       └── GameController.test.js
├── babel.config.json         # Babel preset configuration for Jest ESM support
├── webpack.config.js         # Webpack build and development server config
├── package.json
└── README.md
```

---

## 🧪 Running the Tests

To run the full Jest test suite:

```bash
npm test
```

To run Jest with test coverage reporting:

```bash
npm run test:coverage
```

To run Jest in watch mode during development:

```bash
npm run test:watch
```

---

## 💻 Running the Application

### Development Server
Starts the Webpack development server with hot module replacement:

```bash
npm start
```

### Production Build
Generates the optimized static distribution files in `dist/`:

```bash
npm run build
```

---

## 🎮 How to Play

1. **Select Mode**: Choose between **1-Player (vs Smart AI)** or **2-Player (Pass & Play)** in the top navigation bar.
2. **Deploy Your Fleet**:
   - Drag vessels from the dry dock onto your grid, or click a ship to select it and click on the grid.
   - Press <kbd>R</kbd> or click **Rotate** to toggle Horizontal/Vertical orientation.
   - Or click **Randomize Fleet** for quick deployment.
   - Click **Confirm & Start Battle**.
3. **Engage in Naval Combat**:
   - Click on coordinates within the hostile **Hostile Waters (Radar)** grid to launch strikes.
   - Red explosion markers denote direct hits; blue/white pegs denote misses.
   - In 2-Player mode, pass the screen when prompted to maintain tactical secrecy.
   - Sink all 5 enemy vessels to claim victory!
