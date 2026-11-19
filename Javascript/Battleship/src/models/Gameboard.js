import Ship from "./Ship";

const DEFAULT_FLEET = [
  { name: "Carrier", length: 5 },
  { name: "Battleship", length: 4 },
  { name: "Destroyer", length: 3 },
  { name: "Submarine", length: 3 },
  { name: "Patrol Boat", length: 2 },
];

class Gameboard {
  constructor(size = 10) {
    this.size = size;
    this.ships = [];
    this.missedAttacks = [];
    this.successfulHits = [];
    this.allAttacks = new Set();
    this.grid = this._createEmptyGrid();
  }

  _createEmptyGrid() {
    return Array.from({ length: this.size }, () =>
      Array.from({ length: this.size }, () => null)
    );
  }

  canPlaceShip(ship, x, y, isVertical = false) {
    if (!ship || typeof ship.length !== "number") return false;
    if (x < 0 || x >= this.size || y < 0 || y >= this.size) return false;

    if (!isVertical && x + ship.length > this.size) return false;
    if (isVertical && y + ship.length > this.size) return false;

    for (let i = 0; i < ship.length; i++) {
      const cx = isVertical ? x : x + i;
      const cy = isVertical ? y + i : y;
      if (this.grid[cy][cx] !== null) {
        return false;
      }
    }

    return true;
  }

  placeShip(ship, x, y, isVertical = false) {
    if (!this.canPlaceShip(ship, x, y, isVertical)) {
      return false;
    }

    const coordinates = [];
    for (let i = 0; i < ship.length; i++) {
      const cx = isVertical ? x : x + i;
      const cy = isVertical ? y + i : y;
      this.grid[cy][cx] = ship;
      coordinates.push([cx, cy]);
    }

    this.ships.push({ ship, coordinates, isVertical });
    return true;
  }

  getShipAt(x, y) {
    if (x < 0 || x >= this.size || y < 0 || y >= this.size) return null;
    return this.grid[y][x];
  }

  hasBeenAttacked(x, y) {
    return this.allAttacks.has(`${x},${y}`);
  }

  receiveAttack(x, y) {
    if (x < 0 || x >= this.size || y < 0 || y >= this.size) {
      return { result: "invalid", x, y };
    }

    const key = `${x},${y}`;
    if (this.allAttacks.has(key)) {
      return { result: "duplicate", x, y };
    }

    this.allAttacks.add(key);
    const targetShip = this.grid[y][x];

    if (targetShip) {
      targetShip.hit();
      this.successfulHits.push([x, y]);
      return {
        result: "hit",
        ship: targetShip,
        isSunk: targetShip.isSunk(),
        x,
        y,
      };
    }

    this.missedAttacks.push([x, y]);
    return {
      result: "miss",
      x,
      y,
    };
  }

  allShipsSunk() {
    if (this.ships.length === 0) return false;
    return this.ships.every(({ ship }) => ship.isSunk());
  }

  autoPlaceFleet(fleetConfig = DEFAULT_FLEET) {
    this.reset();
    for (const spec of fleetConfig) {
      let placed = false;
      let attempts = 0;
      const maxAttempts = 1000;

      while (!placed && attempts < maxAttempts) {
        attempts++;
        const isVertical = Math.random() < 0.5;
        const x = Math.floor(Math.random() * this.size);
        const y = Math.floor(Math.random() * this.size);
        const ship = new Ship(spec.length, spec.name);

        if (this.canPlaceShip(ship, x, y, isVertical)) {
          this.placeShip(ship, x, y, isVertical);
          placed = true;
        }
      }

      if (!placed) {
        throw new Error(`Failed to place ship ${spec.name} after ${maxAttempts} attempts`);
      }
    }
  }

  reset() {
    this.ships = [];
    this.missedAttacks = [];
    this.successfulHits = [];
    this.allAttacks.clear();
    this.grid = this._createEmptyGrid();
  }
}

export default Gameboard;
export { DEFAULT_FLEET };
