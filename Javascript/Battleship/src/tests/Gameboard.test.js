import Gameboard from "../models/Gameboard";
import Ship from "../models/Ship";

describe("Gameboard Factory / Class", () => {
  let board;

  beforeEach(() => {
    board = new Gameboard();
  });

  test("initializes with a default 10x10 size and empty state", () => {
    expect(board.size).toBe(10);
    expect(board.ships.length).toBe(0);
    expect(board.missedAttacks).toEqual([]);
    expect(board.successfulHits).toEqual([]);
  });

  describe("Ship Placement", () => {
    test("places a ship horizontally within bounds", () => {
      const ship = new Ship(3, "Destroyer");
      const result = board.placeShip(ship, 2, 3, false);
      expect(result).toBe(true);
      expect(board.getShipAt(2, 3)).toBe(ship);
      expect(board.getShipAt(3, 3)).toBe(ship);
      expect(board.getShipAt(4, 3)).toBe(ship);
      expect(board.getShipAt(5, 3)).toBeNull();
    });

    test("places a ship vertically within bounds", () => {
      const ship = new Ship(3, "Submarine");
      const result = board.placeShip(ship, 0, 0, true);
      expect(result).toBe(true);
      expect(board.getShipAt(0, 0)).toBe(ship);
      expect(board.getShipAt(0, 1)).toBe(ship);
      expect(board.getShipAt(0, 2)).toBe(ship);
      expect(board.getShipAt(0, 3)).toBeNull();
    });

    test("rejects horizontal placement that exceeds board width", () => {
      const ship = new Ship(4);
      expect(board.placeShip(ship, 7, 0, false)).toBe(false);
      expect(board.ships.length).toBe(0);
    });

    test("rejects vertical placement that exceeds board height", () => {
      const ship = new Ship(4);
      expect(board.placeShip(ship, 0, 7, true)).toBe(false);
      expect(board.ships.length).toBe(0);
    });

    test("rejects placement with negative coordinates", () => {
      const ship = new Ship(3);
      expect(board.placeShip(ship, -1, 2, false)).toBe(false);
      expect(board.placeShip(ship, 2, -1, false)).toBe(false);
    });

    test("prevents overlapping ships", () => {
      const ship1 = new Ship(3);
      const ship2 = new Ship(3);
      board.placeShip(ship1, 2, 2, false); // occupies (2,2), (3,2), (4,2)
      // Trying to cross at (3,2)
      const result = board.placeShip(ship2, 3, 1, true); // occupies (3,1), (3,2), (3,3)
      expect(result).toBe(false);
      expect(board.ships.length).toBe(1);
    });

    test("canPlaceShip correctly identifies valid and invalid spots", () => {
      const ship = new Ship(3);
      board.placeShip(ship, 0, 0, false);
      const newShip = new Ship(2);
      expect(board.canPlaceShip(newShip, 0, 0, false)).toBe(false);
      expect(board.canPlaceShip(newShip, 5, 5, false)).toBe(true);
      expect(board.canPlaceShip(newShip, 9, 9, false)).toBe(false); // exceeds width
    });
  });

  describe("receiveAttack()", () => {
    test("records a missed attack when no ship is present", () => {
      const response = board.receiveAttack(5, 5);
      expect(response.result).toBe("miss");
      expect(response.x).toBe(5);
      expect(response.y).toBe(5);
      expect(board.missedAttacks).toContainEqual([5, 5]);
      expect(board.hasBeenAttacked(5, 5)).toBe(true);
    });

    test("hits the correct ship when coordinates match", () => {
      const ship = new Ship(3, "Cruiser");
      board.placeShip(ship, 2, 2, false);

      const response = board.receiveAttack(3, 2);
      expect(response.result).toBe("hit");
      expect(response.ship).toBe(ship);
      expect(response.isSunk).toBe(false);
      expect(ship.hits).toBe(1);
      expect(board.successfulHits).toContainEqual([3, 2]);
      expect(board.hasBeenAttacked(3, 2)).toBe(true);
    });

    test("registers ship sinking when all ship cells are hit", () => {
      const ship = new Ship(2, "Patrol");
      board.placeShip(ship, 0, 0, false);

      const hit1 = board.receiveAttack(0, 0);
      expect(hit1.result).toBe("hit");
      expect(hit1.isSunk).toBe(false);
      expect(ship.isSunk()).toBe(false);

      const hit2 = board.receiveAttack(1, 0);
      expect(hit2.result).toBe("hit");
      expect(hit2.isSunk).toBe(true);
      expect(ship.isSunk()).toBe(true);
    });

    test("rejects attack out of board boundaries", () => {
      const response = board.receiveAttack(10, 10);
      expect(response.result).toBe("invalid");
    });

    test("detects duplicate attacks on the same coordinate", () => {
      board.receiveAttack(1, 1);
      const duplicateResponse = board.receiveAttack(1, 1);
      expect(duplicateResponse.result).toBe("duplicate");
    });
  });

  describe("allShipsSunk()", () => {
    test("returns false when no ships have been placed", () => {
      expect(board.allShipsSunk()).toBe(false);
    });

    test("returns false when some ships are still afloat", () => {
      const ship1 = new Ship(2);
      const ship2 = new Ship(1);
      board.placeShip(ship1, 0, 0, false);
      board.placeShip(ship2, 5, 5, false);

      board.receiveAttack(5, 5); // ship2 is sunk
      expect(board.allShipsSunk()).toBe(false);
    });

    test("returns true when all placed ships have been sunk", () => {
      const ship1 = new Ship(2);
      const ship2 = new Ship(1);
      board.placeShip(ship1, 0, 0, false);
      board.placeShip(ship2, 5, 5, false);

      board.receiveAttack(0, 0);
      board.receiveAttack(1, 0);
      board.receiveAttack(5, 5);

      expect(board.allShipsSunk()).toBe(true);
    });
  });

  describe("Fleet Auto-Placement & Reset", () => {
    test("autoPlaceFleet places standard 5 ships without errors or collisions", () => {
      board.autoPlaceFleet();
      expect(board.ships.length).toBe(5);
      expect(board.allShipsSunk()).toBe(false);

      // Verify no coordinates overlap
      const coordinateSet = new Set();
      board.ships.forEach(({ coordinates }) => {
        coordinates.forEach(([x, y]) => {
          const key = `${x},${y}`;
          expect(coordinateSet.has(key)).toBe(false);
          coordinateSet.add(key);
        });
      });
      // 5 + 4 + 3 + 3 + 2 = 17 total cells
      expect(coordinateSet.size).toBe(17);
    });

    test("reset() clears all ships, hits, and misses", () => {
      board.autoPlaceFleet();
      board.receiveAttack(0, 0);
      board.reset();

      expect(board.ships.length).toBe(0);
      expect(board.missedAttacks.length).toBe(0);
      expect(board.successfulHits.length).toBe(0);
    });
  });
});
