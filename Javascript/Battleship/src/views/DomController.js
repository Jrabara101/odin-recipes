import sound from "./audio";
import Ship from "../models/Ship";

class DomController {
  constructor(gameController) {
    this.gc = gameController;

    // Setup state
    this.isVertical = false;
    this.selectedShipIndex = null;
    this.currentPlacingPlayer = this.gc.player1;
    this.placedShipIndices = new Set();
    this.isTransitioning = false;

    // Cache DOM Elements
    this.dom = {
      appContainer: document.querySelector(".app-container"),
      modeSelect: document.getElementById("mode-select"),
      soundBtn: document.getElementById("sound-btn"),
      rulesBtn: document.getElementById("rules-btn"),
      restartBtn: document.getElementById("restart-btn"),
      statusBanner: document.getElementById("status-banner"),
      statusMessage: document.getElementById("status-message"),
      statusIcon: document.getElementById("status-icon"),

      // Setup screen
      setupScreen: document.getElementById("setup-screen"),
      setupPlayerTitle: document.getElementById("setup-player-title"),
      setupGrid: document.getElementById("setup-grid"),
      shipDock: document.getElementById("ship-dock"),
      rotateBtn: document.getElementById("rotate-btn"),
      orientationLabel: document.getElementById("orientation-label"),
      randomizeBtn: document.getElementById("randomize-btn"),
      resetPlacementBtn: document.getElementById("reset-placement-btn"),
      startGameBtn: document.getElementById("start-game-btn"),

      // Battle screen
      battleScreen: document.getElementById("battle-screen"),
      friendlyTitle: document.getElementById("friendly-title"),
      hostileTitle: document.getElementById("hostile-title"),
      friendlyGrid: document.getElementById("friendly-grid"),
      hostileGrid: document.getElementById("hostile-grid"),
      friendlyFleetStatus: document.getElementById("friendly-fleet-status"),
      hostileFleetStatus: document.getElementById("hostile-fleet-status"),
      turnCounter: document.getElementById("turn-counter"),
      combatLog: document.getElementById("combat-log"),

      // Modals
      passDeviceModal: document.getElementById("pass-device-modal"),
      nextPlayerName: document.getElementById("next-player-name"),
      passReadyBtn: document.getElementById("pass-ready-btn"),

      gameOverModal: document.getElementById("game-over-modal"),
      gameOverIcon: document.getElementById("game-over-icon"),
      gameOverTitle: document.getElementById("game-over-title"),
      gameOverMessage: document.getElementById("game-over-message"),
      statTurns: document.getElementById("stat-turns"),
      statAccuracy: document.getElementById("stat-accuracy"),
      statSurvived: document.getElementById("stat-survived"),
      playAgainBtn: document.getElementById("play-again-btn"),

      rulesModal: document.getElementById("rules-modal"),
      closeRulesBtn: document.getElementById("close-rules-btn"),
      acknowledgeRulesBtn: document.getElementById("acknowledge-rules-btn"),
    };

    this.initEventListeners();
    this.initSetupScreen();
  }

  initEventListeners() {
    // Top Bar Controls
    this.dom.soundBtn.addEventListener("click", () => this.toggleSound());
    this.dom.rulesBtn.addEventListener("click", () => this.showRulesModal(true));
    this.dom.closeRulesBtn.addEventListener("click", () => this.showRulesModal(false));
    this.dom.acknowledgeRulesBtn.addEventListener("click", () => this.showRulesModal(false));
    this.dom.restartBtn.addEventListener("click", () => this.handleRestart());
    this.dom.modeSelect.addEventListener("change", (e) => this.handleModeChange(e.target.value));

    // Setup Actions
    this.dom.rotateBtn.addEventListener("click", () => this.toggleOrientation());
    window.addEventListener("keydown", (e) => {
      if ((e.key === "r" || e.key === "R") && this.gc.phase === "setup") {
        this.toggleOrientation();
      }
    });

    this.dom.randomizeBtn.addEventListener("click", () => this.handleRandomizePlacement());
    this.dom.resetPlacementBtn.addEventListener("click", () => this.handleResetPlacement());
    this.dom.startGameBtn.addEventListener("click", () => this.handleStartGame());

    // Modals
    this.dom.passReadyBtn.addEventListener("click", () => this.handlePassDeviceReady());
    this.dom.playAgainBtn.addEventListener("click", () => this.handleRestart());
  }

  toggleSound() {
    const isMuted = sound.toggleMute();
    this.dom.soundBtn.querySelector(".btn-icon").textContent = isMuted ? "🔇" : "🔊";
    this.dom.soundBtn.querySelector(".btn-text").textContent = isMuted ? "Sound: OFF" : "Sound: ON";
  }

  showRulesModal(show) {
    if (show) {
      sound.playSonar();
      this.dom.rulesModal.classList.remove("hidden");
    } else {
      this.dom.rulesModal.classList.add("hidden");
    }
  }

  setStatus(message, icon = "⚓") {
    this.dom.statusMessage.textContent = message;
    this.dom.statusIcon.textContent = icon;
  }

  handleModeChange(newMode) {
    this.gc.restartGame(newMode);
    this.initSetupScreen();
  }

  handleRestart() {
    this.dom.gameOverModal.classList.add("hidden");
    this.gc.restartGame(this.dom.modeSelect.value);
    this.initSetupScreen();
  }

  toggleOrientation() {
    this.isVertical = !this.isVertical;
    this.dom.orientationLabel.textContent = this.isVertical ? "Vertical" : "Horizontal";
    sound.playSonar();
  }

  /* ------------------- SETUP PHASE ------------------- */
  initSetupScreen() {
    this.currentPlacingPlayer = this.gc.player1;
    this.placedShipIndices.clear();
    this.selectedShipIndex = null;
    this.isVertical = false;
    this.dom.orientationLabel.textContent = "Horizontal";

    this.dom.battleScreen.classList.add("hidden");
    this.dom.setupScreen.classList.remove("hidden");
    this.dom.setupPlayerTitle.textContent = `${this.currentPlacingPlayer.name}: Place Your Fleet`;

    this.setStatus(
      `${this.currentPlacingPlayer.name}, drag ships or select and click to deploy your fleet.`,
      "⚓"
    );

    this.renderDock();
    this.renderSetupGrid();
    this.updateStartButton();
  }

  renderDock() {
    this.dom.shipDock.innerHTML = "";

    this.gc.fleetSpec.forEach((spec, index) => {
      const shipItem = document.createElement("div");
      shipItem.className = `dock-ship ${this.placedShipIndices.has(index) ? "placed" : ""}`;
      shipItem.dataset.shipIndex = index;
      shipItem.draggable = !this.placedShipIndices.has(index);

      if (this.selectedShipIndex === index) {
        shipItem.classList.add("selected");
      }

      const info = document.createElement("div");
      info.className = "ship-info";

      const name = document.createElement("span");
      name.className = "ship-name";
      name.textContent = spec.name;

      const lenText = document.createElement("span");
      lenText.className = "ship-length-text";
      lenText.textContent = `${spec.length} cells`;

      info.appendChild(name);
      info.appendChild(lenText);

      const previewCells = document.createElement("div");
      previewCells.className = "ship-preview-cells";
      for (let i = 0; i < spec.length; i++) {
        const cell = document.createElement("div");
        cell.className = "preview-cell";
        previewCells.appendChild(cell);
      }

      shipItem.appendChild(info);
      shipItem.appendChild(previewCells);

      // Drag and Drop
      shipItem.addEventListener("dragstart", (e) => {
        if (this.placedShipIndices.has(index)) return;
        shipItem.classList.add("dragging");
        e.dataTransfer.setData("text/plain", index.toString());
        this.selectedShipIndex = index;
        sound.playSonar();
      });

      shipItem.addEventListener("dragend", () => {
        shipItem.classList.remove("dragging");
      });

      // Click to select
      shipItem.addEventListener("click", () => {
        if (this.placedShipIndices.has(index)) return;
        this.selectedShipIndex = this.selectedShipIndex === index ? null : index;
        sound.playSonar();
        this.renderDock();
      });

      this.dom.shipDock.appendChild(shipItem);
    });
  }

  renderSetupGrid() {
    this.dom.setupGrid.innerHTML = "";
    const board = this.currentPlacingPlayer.gameboard;

    for (let y = 0; y < board.size; y++) {
      for (let x = 0; x < board.size; x++) {
        const cell = document.createElement("div");
        cell.className = "grid-cell";
        cell.dataset.x = x;
        cell.dataset.y = y;

        if (board.getShipAt(x, y)) {
          cell.classList.add("ship-cell");
        }

        // Drag events on grid cell
        cell.addEventListener("dragover", (e) => {
          e.preventDefault();
          this.previewPlacement(x, y, true);
        });

        cell.addEventListener("dragleave", () => {
          this.clearPlacementPreview();
        });

        cell.addEventListener("drop", (e) => {
          e.preventDefault();
          this.clearPlacementPreview();
          const shipIndexStr = e.dataTransfer.getData("text/plain");
          const shipIndex = parseInt(shipIndexStr, 10);
          this.attemptPlaceShip(shipIndex, x, y);
        });

        // Click placement
        cell.addEventListener("mouseenter", () => {
          if (this.selectedShipIndex !== null) {
            this.previewPlacement(x, y, true);
          }
        });

        cell.addEventListener("mouseleave", () => {
          if (this.selectedShipIndex !== null) {
            this.clearPlacementPreview();
          }
        });

        cell.addEventListener("click", () => {
          if (this.selectedShipIndex !== null) {
            this.attemptPlaceShip(this.selectedShipIndex, x, y);
          }
        });

        this.dom.setupGrid.appendChild(cell);
      }
    }
  }

  previewPlacement(originX, originY, isValid = true) {
    this.clearPlacementPreview();
    if (this.selectedShipIndex === null) return;

    const spec = this.gc.fleetSpec[this.selectedShipIndex];
    const board = this.currentPlacingPlayer.gameboard;
    const tempShip = new Ship(spec.length, spec.name);
    const valid = board.canPlaceShip(tempShip, originX, originY, this.isVertical);

    for (let i = 0; i < spec.length; i++) {
      const cx = this.isVertical ? originX : originX + i;
      const cy = this.isVertical ? originY + i : originY;

      if (cx >= 0 && cx < board.size && cy >= 0 && cy < board.size) {
        const targetCell = this.dom.setupGrid.querySelector(
          `.grid-cell[data-x="${cx}"][data-y="${cy}"]`
        );
        if (targetCell) {
          targetCell.classList.add(valid ? "placement-valid" : "placement-invalid");
        }
      }
    }
  }

  clearPlacementPreview() {
    const previewCells = this.dom.setupGrid.querySelectorAll(".placement-valid, .placement-invalid");
    previewCells.forEach((c) => c.classList.remove("placement-valid", "placement-invalid"));
  }

  attemptPlaceShip(shipIndex, x, y) {
    if (isNaN(shipIndex) || this.placedShipIndices.has(shipIndex)) return;

    const spec = this.gc.fleetSpec[shipIndex];
    const ship = new Ship(spec.length, spec.name);
    const success = this.currentPlacingPlayer.gameboard.placeShip(ship, x, y, this.isVertical);

    if (success) {
      sound.playHit();
      this.placedShipIndices.add(shipIndex);
      this.selectedShipIndex = null;
      this.renderDock();
      this.renderSetupGrid();
      this.updateStartButton();

      const remaining = this.gc.fleetSpec.length - this.placedShipIndices.size;
      if (remaining > 0) {
        this.setStatus(`Placed ${spec.name}! ${remaining} vessels remaining.`, "✅");
      } else {
        this.setStatus(`All vessels deployed! Confirm fleet to commence battle.`, "🚀");
      }
    } else {
      sound.playMiss();
      this.setStatus(`Cannot place ${spec.name} here. Check boundaries and obstacles.`, "⚠️");
    }
  }

  handleRandomizePlacement() {
    this.currentPlacingPlayer.gameboard.autoPlaceFleet(this.gc.fleetSpec);
    this.placedShipIndices = new Set(this.gc.fleetSpec.map((_, i) => i));
    this.selectedShipIndex = null;
    sound.playCannon();
    this.renderDock();
    this.renderSetupGrid();
    this.updateStartButton();
    this.setStatus(`Fleet randomized and positioned for battle!`, "🎲");
  }

  handleResetPlacement() {
    this.currentPlacingPlayer.gameboard.reset();
    this.placedShipIndices.clear();
    this.selectedShipIndex = null;
    sound.playMiss();
    this.renderDock();
    this.renderSetupGrid();
    this.updateStartButton();
    this.setStatus(`Grid cleared. Reposition your fleet.`, "🔄");
  }

  updateStartButton() {
    const isReady = this.placedShipIndices.size === this.gc.fleetSpec.length;
    this.dom.startGameBtn.disabled = !isReady;
  }

  handleStartGame() {
    if (this.gc.mode === "pvp" && this.currentPlacingPlayer === this.gc.player1) {
      // Player 1 finished placement in PvP, switch to Player 2
      this.currentPlacingPlayer = this.gc.player2;
      this.placedShipIndices.clear();
      this.selectedShipIndex = null;
      this.showPassDeviceModal(this.gc.player2.name, () => {
        this.dom.setupPlayerTitle.textContent = `${this.currentPlacingPlayer.name}: Place Your Fleet`;
        this.setStatus(`${this.currentPlacingPlayer.name}, deploy your fleet.`, "⚓");
        this.renderDock();
        this.renderSetupGrid();
        this.updateStartButton();
      });
      return;
    }

    // Both players (or Player 1 in PvC) are ready
    this.gc.startGame();
    sound.playVictory();
    this.startBattlePhase();
  }

  /* ------------------- BATTLE PHASE ------------------- */
  startBattlePhase() {
    this.dom.setupScreen.classList.add("hidden");
    this.dom.battleScreen.classList.remove("hidden");
    this.renderBattleScreens();
    this.setStatus(
      `Turn ${this.gc.turnCount}: ${this.gc.getCurrentPlayer().name}'s turn. Select target coordinate on radar!`,
      "🎯"
    );
  }

  renderBattleScreens() {
    const current = this.gc.getCurrentPlayer();
    const waiting = this.gc.getWaitingPlayer();

    this.dom.turnCounter.textContent = `TURN: ${this.gc.turnCount}`;
    this.dom.friendlyTitle.textContent = `${current.name.toUpperCase()} (DEFENSE)`;
    this.dom.hostileTitle.textContent = `${waiting.name.toUpperCase()} (RADAR TARGETING)`;

    this.renderGrid(this.dom.friendlyGrid, current.gameboard, false);
    this.renderGrid(this.dom.hostileGrid, waiting.gameboard, true);
    this.renderFleetStatus(this.dom.friendlyFleetStatus, current.gameboard);
    this.renderFleetStatus(this.dom.hostileFleetStatus, waiting.gameboard);
    this.renderCombatLog();
  }

  renderGrid(container, gameboard, isHostile = false) {
    container.innerHTML = "";

    for (let y = 0; y < gameboard.size; y++) {
      for (let x = 0; x < gameboard.size; x++) {
        const cell = document.createElement("div");
        cell.className = "grid-cell";
        cell.dataset.x = x;
        cell.dataset.y = y;

        const hasAttacked = gameboard.hasBeenAttacked(x, y);
        const ship = gameboard.getShipAt(x, y);

        if (!isHostile && ship) {
          cell.classList.add("ship-cell");
        }

        if (hasAttacked) {
          if (ship) {
            cell.classList.add(ship.isSunk() ? "sunk-cell" : "hit-cell");
          } else {
            cell.classList.add("miss-cell");
          }
        }

        if (isHostile) {
          cell.addEventListener("click", () => {
            this.handlePlayerAttack(x, y);
          });
        }

        container.appendChild(cell);
      }
    }
  }

  renderFleetStatus(container, gameboard) {
    container.innerHTML = "";
    this.gc.fleetSpec.forEach((spec) => {
      // Find ship on board matching name
      const shipEntry = gameboard.ships.find((s) => s.ship.name === spec.name);
      const isSunk = shipEntry ? shipEntry.ship.isSunk() : false;

      const chip = document.createElement("div");
      chip.className = `fleet-chip ${isSunk ? "sunk" : ""}`;
      chip.textContent = `${spec.name} (${spec.length})`;
      container.appendChild(chip);
    });
  }

  renderCombatLog() {
    this.dom.combatLog.innerHTML = "";
    if (this.gc.logs.length === 0) {
      this.dom.combatLog.innerHTML = `<div class="log-entry">Waiting for battle actions...</div>`;
      return;
    }

    this.gc.logs.slice(0, 15).forEach((entry) => {
      const logDiv = document.createElement("div");
      logDiv.className = "log-entry";
      logDiv.textContent = `[${entry.time}] ${entry.message}`;
      this.dom.combatLog.appendChild(logDiv);
    });
  }

  handlePlayerAttack(x, y) {
    if (this.isTransitioning || this.gc.phase !== "playing") return;

    const waiting = this.gc.getWaitingPlayer();
    if (waiting.gameboard.hasBeenAttacked(x, y)) {
      this.setStatus("Coordinates already targeted, Commander! Pick a new sector.", "⚠️");
      sound.playMiss();
      return;
    }

    this.isTransitioning = true;
    sound.playCannon();

    // Small delay to simulate missile flight and enhance game feel
    setTimeout(() => {
      const result = this.gc.playTurn(x, y);

      if (!result.success) {
        this.isTransitioning = false;
        return;
      }

      // Audio feedback for attack
      if (result.attackResult.result === "hit") {
        if (result.attackResult.isSunk) {
          sound.playSunk();
        } else {
          sound.playHit();
        }
      } else {
        sound.playMiss();
      }

      this.renderBattleScreens();

      // Check Victory
      if (result.gameOver) {
        sound.playVictory();
        this.showGameOverModal(result.winner);
        this.isTransitioning = false;
        return;
      }

      // PvP Turn Pass Modal
      if (result.passDevice) {
        this.showPassDeviceModal(result.nextPlayer.name, () => {
          this.renderBattleScreens();
          this.setStatus(
            `Turn ${this.gc.turnCount}: ${this.gc.getCurrentPlayer().name}'s turn. Target the radar grid!`,
            "🎯"
          );
          this.isTransitioning = false;
        });
        return;
      }

      // In PvC mode, computer just counter-attacked
      if (result.computerTurn) {
        setTimeout(() => {
          if (result.computerTurn.result === "hit") {
            if (result.computerTurn.isSunk) {
              sound.playSunk();
            } else {
              sound.playHit();
            }
          }
          this.renderBattleScreens();

          if (result.gameOver) {
            sound.playSunk();
            this.showGameOverModal(result.winner);
          } else {
            this.setStatus(
              `Turn ${this.gc.turnCount}: Your turn, Commander. Select target coordinate.`,
              "🎯"
            );
          }
          this.isTransitioning = false;
        }, 300);
      } else {
        this.isTransitioning = false;
      }
    }, 200);
  }

  showPassDeviceModal(nextPlayerName, onReady) {
    this.dom.nextPlayerName.textContent = nextPlayerName;
    this.dom.passDeviceModal.classList.remove("hidden");
    this.pendingPassCallback = onReady;
  }

  handlePassDeviceReady() {
    this.dom.passDeviceModal.classList.add("hidden");
    sound.playSonar();
    if (this.pendingPassCallback) {
      const cb = this.pendingPassCallback;
      this.pendingPassCallback = null;
      cb();
    }
  }

  showGameOverModal(winner) {
    const isHumanWin = winner.type === "human";
    this.dom.gameOverIcon.textContent = isHumanWin ? "🏆" : "💥";
    this.dom.gameOverTitle.textContent = isHumanWin
      ? `${winner.name.toUpperCase()} VICTORIOUS!`
      : "FLEET DESTROYED!";
    this.dom.gameOverMessage.textContent = isHumanWin
      ? `Command mastery demonstrated. All enemy warships sunk in ${this.gc.turnCount} turns.`
      : `Hostile forces successfully sank your entire fleet. Review tactical plans and retry.`;

    // Calculate stats
    this.dom.statTurns.textContent = this.gc.turnCount;

    const totalAttacksMade = this.gc.getWaitingPlayer().gameboard.allAttacks.size;
    const hitsMade = this.gc.getWaitingPlayer().gameboard.successfulHits.length;
    const accuracy = totalAttacksMade > 0 ? Math.round((hitsMade / totalAttacksMade) * 100) : 0;
    this.dom.statAccuracy.textContent = `${accuracy}%`;

    const survivedShips = winner.gameboard.ships.filter((s) => !s.ship.isSunk()).length;
    this.dom.statSurvived.textContent = `${survivedShips} / ${this.gc.fleetSpec.length}`;

    this.dom.gameOverModal.classList.remove("hidden");
  }
}

export default DomController;
