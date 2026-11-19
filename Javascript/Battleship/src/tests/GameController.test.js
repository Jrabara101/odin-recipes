import GameController from "../controllers/GameController";
import Ship from "../models/Ship";

describe("GameController", () => {
  let controller;

  beforeEach(() => {
    controller = new GameController("pvc");
  });

  test("initializes with setup phase and player1 as active", () => {
    expect(controller.mode).toBe("pvc");
    expect(controller.phase).toBe("setup");
    expect(controller.player1.name).toBe("Player 1");
    expect(controller.player2.name).toBe("Computer");
    expect(controller.player2.type).toBe("computer");
    expect(controller.getCurrentPlayer()).toBe(controller.player1);
  });

  test("initializes correctly in pvp mode", () => {
    const pvpController = new GameController("pvp");
    expect(pvpController.mode).toBe("pvp");
    expect(pvpController.player2.type).toBe("human");
    expect(pvpController.player2.name).toBe("Player 2");
  });

  test("randomizeBoard populates all ships on a player's board", () => {
    controller.randomizeBoard(controller.player1);
    expect(controller.player1.gameboard.ships.length).toBe(5);
    expect(controller.isPlayerReady(controller.player1)).toBe(true);
  });

  test("startGame transitions from setup to playing when fleet is ready", () => {
    controller.randomizeBoard(controller.player1);
    const started = controller.startGame();
    expect(started).toBe(true);
    expect(controller.phase).toBe("playing");
    // In pvc mode, computer fleet should also be auto-placed
    expect(controller.player2.gameboard.ships.length).toBe(5);
  });

  test("startGame fails if player fleet is not ready", () => {
    const started = controller.startGame();
    expect(started).toBe(false);
    expect(controller.phase).toBe("setup");
  });

  describe("Gameplay Turns & Win Condition", () => {
    beforeEach(() => {
      // Set up small custom fleets for deterministic game test
      controller.player1.gameboard.placeShip(new Ship(2, "Patrol Boat"), 0, 0, false);
      controller.player2.gameboard.placeShip(new Ship(2, "Patrol Boat"), 0, 0, false);
      controller.phase = "playing";
    });

    test("human player attack registers on enemy board", () => {
      const turnResult = controller.playTurn(0, 0);
      expect(turnResult.success).toBe(true);
      expect(turnResult.attackResult.result).toBe("hit");
      expect(controller.player2.gameboard.hasBeenAttacked(0, 0)).toBe(true);
    });

    test("duplicate attack returns success=false and does not waste turn", () => {
      controller.playTurn(0, 0);
      const duplicateTurn = controller.playTurn(0, 0);
      expect(duplicateTurn.success).toBe(false);
      expect(duplicateTurn.reason).toBe("duplicate");
    });

    test("detects victory when all enemy ships are sunk", () => {
      // First hit
      controller.playTurn(0, 0);
      expect(controller.phase).toBe("playing");

      // Sinking hit
      const finalTurn = controller.playTurn(1, 0);
      expect(finalTurn.success).toBe(true);
      expect(controller.phase).toBe("gameover");
      expect(controller.winner).toBe(controller.player1);
    });

    test("computer turn fires back in pvc mode after human turn", () => {
      const turnResult = controller.playTurn(5, 5); // miss on enemy
      expect(turnResult.success).toBe(true);
      expect(turnResult.computerTurn).toBeDefined();
      expect(turnResult.computerTurn.x).toBeGreaterThanOrEqual(0);
      expect(controller.player1.gameboard.allAttacks.size).toBe(1);
    });

    test("handles computer victory when player 1 fleet is sunk", () => {
      // Simulate player1's only ship being hit by computer
      // To test deterministic computer win:
      controller.player2.computerAttack = jest.fn().mockImplementation(() => {
        controller.player1.gameboard.receiveAttack(0, 0);
        controller.player1.gameboard.receiveAttack(1, 0); // sinks player 1's ship
        return {
          x: 1,
          y: 0,
          result: "hit",
          isSunk: true,
          ship: { name: "Patrol Boat" },
        };
      });

      const turnResult = controller.playTurn(5, 5);
      expect(turnResult.gameOver).toBe(true);
      expect(turnResult.winner).toBe(controller.player2);
      expect(controller.phase).toBe("gameover");
    });
  });

  describe("PvP 2-Player Pass and Play Mode", () => {
    let pvpController;

    beforeEach(() => {
      pvpController = new GameController("pvp");
      pvpController.player1.gameboard.placeShip(new Ship(2, "Patrol"), 0, 0, false);
      pvpController.player2.gameboard.placeShip(new Ship(2, "Patrol"), 3, 3, false);
      pvpController.phase = "playing";
    });

    test("switches turns between Player 1 and Player 2 with passDevice signal", () => {
      expect(pvpController.getCurrentPlayer().name).toBe("Player 1");
      const turn1 = pvpController.playTurn(0, 0); // Miss on Bob
      expect(turn1.success).toBe(true);
      expect(turn1.passDevice).toBe(true);
      expect(turn1.nextPlayer.name).toBe("Player 2");
      expect(pvpController.getCurrentPlayer().name).toBe("Player 2");

      const turn2 = pvpController.playTurn(5, 5); // Miss on Alice
      expect(turn2.success).toBe(true);
      expect(turn2.passDevice).toBe(true);
      expect(turn2.nextPlayer.name).toBe("Player 1");
      expect(pvpController.getCurrentPlayer().name).toBe("Player 1");
    });

    test("resetBoard clears the player board", () => {
      pvpController.resetBoard(pvpController.player1);
      expect(pvpController.player1.gameboard.ships.length).toBe(0);
    });

    test("restartGame resets game state and players", () => {
      pvpController.restartGame("pvc");
      expect(pvpController.mode).toBe("pvc");
      expect(pvpController.phase).toBe("setup");
      expect(pvpController.player2.type).toBe("computer");
      expect(pvpController.turnCount).toBe(1);
    });
  });
});
