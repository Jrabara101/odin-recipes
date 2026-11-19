import Gameboard from "./Gameboard";

class Player {
  constructor(name = "Player", type = "human") {
    this.name = name;
    this.type = type;
    this.gameboard = new Gameboard();

    // AI state for computer player
    this.potentialTargets = [];
    this.currentShipHits = [];
  }

  attack(enemyGameboard, x, y) {
    const result = enemyGameboard.receiveAttack(x, y);
    if (this.type === "computer" && (result.result === "hit" || result.result === "miss")) {
      if (result.result === "hit") {
        this.registerHit(x, y, result.isSunk, enemyGameboard);
      }
    }
    return result;
  }

  registerHit(x, y, isSunk, enemyGameboard = null) {
    if (isSunk) {
      // Current ship is sunk, reset current ship hits and clear invalid targets
      this.currentShipHits = [];
      this.potentialTargets = this.potentialTargets.filter(([tx, ty]) => {
        return enemyGameboard ? !enemyGameboard.hasBeenAttacked(tx, ty) : true;
      });
      return;
    }

    this.currentShipHits.push([x, y]);

    const size = enemyGameboard ? enemyGameboard.size : 10;
    const deltas = [
      [0, -1], // North
      [0, 1],  // South
      [-1, 0], // West
      [1, 0],  // East
    ];

    if (this.currentShipHits.length >= 2) {
      // Determine orientation if we have 2 or more hits on the current ship
      const [firstX, firstY] = this.currentShipHits[0];
      const isHorizontal = this.currentShipHits.every(([, hy]) => hy === firstY);
      const isVertical = this.currentShipHits.every(([hx]) => hx === firstX);

      // Prioritize along line
      const lineDeltas = isHorizontal
        ? [[-1, 0], [1, 0]]
        : isVertical
        ? [[0, -1], [0, 1]]
        : deltas;

      // Add adjacent points from all recorded hits along line
      for (const [hx, hy] of this.currentShipHits) {
        for (const [dx, dy] of lineDeltas) {
          const nx = hx + dx;
          const ny = hy + dy;
          if (nx >= 0 && nx < size && ny >= 0 && ny < size) {
            if (!enemyGameboard || !enemyGameboard.hasBeenAttacked(nx, ny)) {
              if (!this.potentialTargets.some(([tx, ty]) => tx === nx && ty === ny)) {
                this.potentialTargets.unshift([nx, ny]); // prioritize line endpoints
              }
            }
          }
        }
      }
    } else {
      // Single hit: add all cardinal neighbors
      for (const [dx, dy] of deltas) {
        const nx = x + dx;
        const ny = y + dy;
        if (nx >= 0 && nx < size && ny >= 0 && ny < size) {
          if (!enemyGameboard || !enemyGameboard.hasBeenAttacked(nx, ny)) {
            if (!this.potentialTargets.some(([tx, ty]) => tx === nx && ty === ny)) {
              this.potentialTargets.push([nx, ny]);
            }
          }
        }
      }
    }
  }

  computerAttack(enemyGameboard) {
    const size = enemyGameboard.size;
    let target = null;

    // 1. Try smart target queue
    while (this.potentialTargets.length > 0) {
      const [cx, cy] = this.potentialTargets.shift();
      if (!enemyGameboard.hasBeenAttacked(cx, cy)) {
        target = [cx, cy];
        break;
      }
    }

    // 2. If no target in queue, hunt mode
    if (!target) {
      const parityCells = [];
      const allAvailableCells = [];

      for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
          if (!enemyGameboard.hasBeenAttacked(x, y)) {
            allAvailableCells.push([x, y]);
            if ((x + y) % 2 === 0) {
              parityCells.push([x, y]);
            }
          }
        }
      }

      if (parityCells.length > 0) {
        const randomIndex = Math.floor(Math.random() * parityCells.length);
        target = parityCells[randomIndex];
      } else if (allAvailableCells.length > 0) {
        const randomIndex = Math.floor(Math.random() * allAvailableCells.length);
        target = allAvailableCells[randomIndex];
      }
    }

    if (!target) {
      return { result: "nomoves" };
    }

    const [tx, ty] = target;
    const attackResult = this.attack(enemyGameboard, tx, ty);
    return {
      x: tx,
      y: ty,
      ...attackResult,
    };
  }

  resetAI() {
    this.potentialTargets = [];
    this.currentShipHits = [];
  }
}

export default Player;
