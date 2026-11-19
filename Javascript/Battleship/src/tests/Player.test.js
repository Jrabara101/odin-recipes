import Player from "../models/Player";
import Gameboard from "../models/Gameboard";
import Ship from "../models/Ship";

describe("Player Factory / Class", () => {
  let player1;
  let player2;
  let computer;

  beforeEach(() => {
    player1 = new Player("Alice", "human");
    player2 = new Player("Bob", "human");
    computer = new Player("Computer", "computer");
  });

  test("initializes with name, type, and an instance of Gameboard", () => {
    expect(player1.name).toBe("Alice");
    expect(player1.type).toBe("human");
    expect(player1.gameboard).toBeInstanceOf(Gameboard);

    expect(computer.name).toBe("Computer");
    expect(computer.type).toBe("computer");
    expect(computer.gameboard).toBeInstanceOf(Gameboard);
  });

  test("defaults name to 'Player' and type to 'human' if not provided", () => {
    const defaultPlayer = new Player();
    expect(defaultPlayer.name).toBe("Player");
    expect(defaultPlayer.type).toBe("human");
  });

  describe("Human Player Attacks", () => {
    test("can attack an enemy gameboard at valid coordinates", () => {
      const ship = new Ship(2);
      player2.gameboard.placeShip(ship, 0, 0, false);

      const result = player1.attack(player2.gameboard, 0, 0);
      expect(result.result).toBe("hit");
      expect(player2.gameboard.hasBeenAttacked(0, 0)).toBe(true);
    });

    test("records miss on enemy board when coordinates have no ship", () => {
      const result = player1.attack(player2.gameboard, 5, 5);
      expect(result.result).toBe("miss");
      expect(player2.gameboard.hasBeenAttacked(5, 5)).toBe(true);
    });
  });

  describe("Computer Player Random & Smart Attacks", () => {
    test("computerAttack makes a legal move against enemy board", () => {
      const move = computer.computerAttack(player1.gameboard);
      expect(move).toHaveProperty("x");
      expect(move).toHaveProperty("y");
      expect(move.x).toBeGreaterThanOrEqual(0);
      expect(move.x).toBeLessThan(player1.gameboard.size);
      expect(move.y).toBeGreaterThanOrEqual(0);
      expect(move.y).toBeLessThan(player1.gameboard.size);
      expect(player1.gameboard.hasBeenAttacked(move.x, move.y)).toBe(true);
    });

    test("computer does not attack the same coordinate twice", () => {
      const attackedCoordinates = new Set();
      // Attack 50 times
      for (let i = 0; i < 50; i++) {
        const move = computer.computerAttack(player1.gameboard);
        const key = `${move.x},${move.y}`;
        expect(attackedCoordinates.has(key)).toBe(false);
        attackedCoordinates.add(key);
      }
      expect(attackedCoordinates.size).toBe(50);
    });

    test("computer targets adjacent slots after scoring a hit (Smart AI)", () => {
      // Place a ship of length 3 at (4, 4), (5, 4), (6, 4)
      const ship = new Ship(3, "Destroyer");
      player1.gameboard.placeShip(ship, 4, 4, false);

      // Force computer to attack (4, 4) first to simulate initial hit
      const initialHit = computer.attack(player1.gameboard, 4, 4);
      expect(initialHit.result).toBe("hit");
      computer.registerHit(4, 4, false); // Notify AI of hit

      // Next computerAttack should choose one of the adjacent coordinates:
      // (3, 4), (5, 4), (4, 3), (4, 5)
      const nextMove = computer.computerAttack(player1.gameboard);
      const isAdjacent =
        (Math.abs(nextMove.x - 4) === 1 && nextMove.y === 4) ||
        (Math.abs(nextMove.y - 4) === 1 && nextMove.x === 4);
      expect(isAdjacent).toBe(true);
    });

    test("computer can play through an entire game without stalling or invalid moves", () => {
      player1.gameboard.autoPlaceFleet();
      let turns = 0;
      const maxTurns = 100;

      while (!player1.gameboard.allShipsSunk() && turns < maxTurns) {
        computer.computerAttack(player1.gameboard);
        turns++;
      }

      expect(player1.gameboard.allShipsSunk()).toBe(true);
      expect(turns).toBeLessThanOrEqual(100);
    });
  });
});
