import Player from "../models/Player";
import Ship from "../models/Ship";
import { DEFAULT_FLEET } from "../models/Gameboard";

class GameController {
  constructor(mode = "pvc", player1Name = "Player 1", player2Name = "Player 2") {
    this.mode = mode; // 'pvc' or 'pvp'
    this.fleetSpec = DEFAULT_FLEET;
    this.player1 = new Player(player1Name, "human");
    this.player2 =
      mode === "pvc"
        ? new Player("Computer", "computer")
        : new Player(player2Name, "human");

    this.currentPlayerIndex = 0;
    this.phase = "setup"; // 'setup' | 'playing' | 'gameover'
    this.winner = null;
    this.turnCount = 1;
    this.logs = [];
  }

  getCurrentPlayer() {
    return this.currentPlayerIndex === 0 ? this.player1 : this.player2;
  }

  getWaitingPlayer() {
    return this.currentPlayerIndex === 0 ? this.player2 : this.player1;
  }

  isPlayerReady(player) {
    return player.gameboard.ships.length === this.fleetSpec.length;
  }

  randomizeBoard(player) {
    player.gameboard.autoPlaceFleet(this.fleetSpec);
    return true;
  }

  resetBoard(player) {
    player.gameboard.reset();
  }

  startGame() {
    if (this.mode === "pvc") {
      if (!this.isPlayerReady(this.player1)) {
        return false;
      }
      if (!this.isPlayerReady(this.player2)) {
        this.player2.gameboard.autoPlaceFleet(this.fleetSpec);
      }
    } else {
      // PvP mode requires both human players to have placed their fleets
      if (!this.isPlayerReady(this.player1) || !this.isPlayerReady(this.player2)) {
        return false;
      }
    }

    this.phase = "playing";
    this.currentPlayerIndex = 0;
    this.winner = null;
    this.turnCount = 1;
    this.logs = [];
    this.addLog("Battle started! All stations, man your battle stations!");
    return true;
  }

  addLog(message) {
    this.logs.unshift({
      time: new Date().toLocaleTimeString(),
      turn: this.turnCount,
      message,
    });
  }

  playTurn(x, y) {
    if (this.phase !== "playing") {
      return { success: false, reason: "not_playing" };
    }

    const current = this.getCurrentPlayer();
    const waiting = this.getWaitingPlayer();

    // Human player attacks waiting enemy gameboard
    const attackResult = current.attack(waiting.gameboard, x, y);

    if (attackResult.result === "duplicate" || attackResult.result === "invalid") {
      return { success: false, reason: attackResult.result, x, y };
    }

    let logMsg = `${current.name} fired at [${String.fromCharCode(65 + x)}${y + 1}] - ${attackResult.result.toUpperCase()}!`;
    if (attackResult.result === "hit" && attackResult.isSunk) {
      logMsg += ` ${waiting.name}'s ${attackResult.ship.name} was SUNK!`;
    }
    this.addLog(logMsg);

    // Check if waiting player is defeated
    if (waiting.gameboard.allShipsSunk()) {
      this.phase = "gameover";
      this.winner = current;
      this.addLog(`VICTORY! ${current.name} has destroyed the enemy fleet!`);
      return {
        success: true,
        attackResult,
        gameOver: true,
        winner: current,
      };
    }

    // In PvC mode, computer responds immediately
    if (this.mode === "pvc" && waiting.type === "computer") {
      const computerTurn = waiting.computerAttack(this.player1.gameboard);
      let compLogMsg = `Computer counter-attacked at [${String.fromCharCode(65 + computerTurn.x)}${computerTurn.y + 1}] - ${computerTurn.result.toUpperCase()}!`;
      if (computerTurn.result === "hit" && computerTurn.isSunk) {
        compLogMsg += ` Player 1's ${computerTurn.ship.name} was SUNK!`;
      }
      this.addLog(compLogMsg);

      if (this.player1.gameboard.allShipsSunk()) {
        this.phase = "gameover";
        this.winner = waiting;
        this.addLog(`DEFEAT! The computer has destroyed your fleet!`);
        return {
          success: true,
          attackResult,
          computerTurn,
          gameOver: true,
          winner: waiting,
        };
      }

      this.turnCount++;
      return {
        success: true,
        attackResult,
        computerTurn,
        gameOver: false,
      };
    }

    // In PvP mode, pass device to other human player
    this.currentPlayerIndex = this.currentPlayerIndex === 0 ? 1 : 0;
    this.turnCount++;
    return {
      success: true,
      attackResult,
      gameOver: false,
      passDevice: true,
      nextPlayer: this.getCurrentPlayer(),
    };
  }

  restartGame(mode = this.mode) {
    this.mode = mode;
    this.player1 = new Player("Player 1", "human");
    this.player2 =
      mode === "pvc"
        ? new Player("Computer", "computer")
        : new Player("Player 2", "human");

    this.currentPlayerIndex = 0;
    this.phase = "setup";
    this.winner = null;
    this.turnCount = 1;
    this.logs = [];
  }
}

export default GameController;
