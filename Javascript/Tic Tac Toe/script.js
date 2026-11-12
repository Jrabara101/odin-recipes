/**
 * Gameboard singleton module (IIFE).
 * Owns the 3x3 board array (indices 0..8) and enforces valid mark placement.
 */
const Gameboard = (() => {
  const board = Array(9).fill("");

  const getBoard = () => [...board];

  const getCell = (index) => {
    if (!Number.isInteger(index) || index < 0 || index >= board.length) {
      return null;
    }
    return board[index];
  };

  const placeMarker = (index, marker) => {
    if (!Number.isInteger(index) || index < 0 || index >= board.length) {
      return false;
    }
    if (board[index] !== "") {
      return false;
    }
    board[index] = marker;
    return true;
  };

  const isFull = () => board.every((cell) => cell !== "");

  const reset = () => {
    board.fill("");
  };

  const printBoard = () => {
    const format = (cell, idx) => (cell === "" ? String(idx) : cell);
    const rows = [0, 3, 6].map(
      (start) =>
        ` ${format(board[start], start)} | ${format(board[start + 1], start + 1)} | ${format(board[start + 2], start + 2)} `
    );
    console.log(rows.join("\n---+---+---\n"));
  };

  return {
    getBoard,
    getCell,
    placeMarker,
    isFull,
    reset,
    printBoard,
  };
})();

/**
 * GameController singleton module (IIFE).
 * Creates players via an internal factory and controls turns, win/tie checks, and scores.
 */
const GameController = (() => {
  const WINNING_LINES = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  function createPlayer(defaultName, marker) {
    let name = defaultName;
    let score = 0;

    return {
      getName: () => name,
      setName: (nextName) => {
        const cleaned = String(nextName ?? "").trim();
        name = cleaned || defaultName;
      },
      getMarker: () => marker,
      getScore: () => score,
      incrementScore: () => {
        score += 1;
      },
      resetScore: () => {
        score = 0;
      },
    };
  }

  const players = [createPlayer("Player 1", "X"), createPlayer("Player 2", "O")];

  let activePlayerIndex = 0;
  let status = "playing"; // "playing" | "won" | "tie"
  let winner = null;
  let winningLine = null;
  let ties = 0;

  const getActivePlayer = () => players[activePlayerIndex];

  const checkWinner = (board) => {
    for (const line of WINNING_LINES) {
      const [a, b, c] = line;
      if (board[a] !== "" && board[a] === board[b] && board[a] === board[c]) {
        return line;
      }
    }
    return null;
  };

  const getState = () => ({
    board: Gameboard.getBoard(),
    activePlayer: {
      name: getActivePlayer().getName(),
      marker: getActivePlayer().getMarker(),
    },
    players: players.map((player) => ({
      name: player.getName(),
      marker: player.getMarker(),
      score: player.getScore(),
    })),
    status,
    winner: winner
      ? {
          name: winner.getName(),
          marker: winner.getMarker(),
        }
      : null,
    winningLine: winningLine ? [...winningLine] : null,
    ties,
  });

  const playRound = (index) => {
    if (status !== "playing") {
      return { valid: false, reason: "game-over", state: getState() };
    }

    const currentPlayer = getActivePlayer();
    const placed = Gameboard.placeMarker(index, currentPlayer.getMarker());
    if (!placed) {
      return { valid: false, reason: "invalid-cell", state: getState() };
    }

    const matchedLine = checkWinner(Gameboard.getBoard());
    if (matchedLine) {
      status = "won";
      winner = currentPlayer;
      winningLine = matchedLine;
      currentPlayer.incrementScore();
      return { valid: true, outcome: "won", state: getState() };
    }

    if (Gameboard.isFull()) {
      status = "tie";
      ties += 1;
      return { valid: true, outcome: "tie", state: getState() };
    }

    activePlayerIndex = 1 - activePlayerIndex;
    return { valid: true, outcome: "continue", state: getState() };
  };

  const setPlayerNames = (playerOneName, playerTwoName) => {
    players[0].setName(playerOneName);
    players[1].setName(playerTwoName);
  };

  const restartRound = () => {
    Gameboard.reset();
    activePlayerIndex = 0;
    status = "playing";
    winner = null;
    winningLine = null;
    return getState();
  };

  const resetMatch = () => {
    players.forEach((player) => player.resetScore());
    ties = 0;
    return restartRound();
  };

  return {
    playRound,
    setPlayerNames,
    restartRound,
    resetMatch,
    getState,
  };
})();

/**
 * DisplayController singleton module (IIFE).
 * Synchronizes the DOM with GameController state and routes user interactions.
 */
const DisplayController = (() => {
  const SVG_NS = "http://www.w3.org/2000/svg";

  const boardEl = document.getElementById("gameboard");
  const cells = Array.from(document.querySelectorAll(".cell"));
  const statusBanner = document.getElementById("status-banner");

  const playerForm = document.getElementById("player-form");
  const playerXInput = document.getElementById("player-x-name");
  const playerOInput = document.getElementById("player-o-name");
  const resetScoresBtn = document.getElementById("reset-scores-btn");

  const scoreCardX = document.getElementById("score-card-x");
  const scoreCardO = document.getElementById("score-card-o");
  const scoreLabelX = document.getElementById("score-label-x");
  const scoreLabelO = document.getElementById("score-label-o");
  const scoreValueX = document.getElementById("score-value-x");
  const scoreValueO = document.getElementById("score-value-o");
  const scoreValueTies = document.getElementById("score-value-ties");

  function createMarkerSvg(marker) {
    const svg = document.createElementNS(SVG_NS, "svg");
    svg.setAttribute("viewBox", "0 0 24 24");
    svg.setAttribute("fill", "none");
    svg.setAttribute("stroke", "currentColor");
    svg.setAttribute("stroke-width", "2.75");
    svg.setAttribute("stroke-linecap", "round");
    svg.setAttribute("aria-hidden", "true");
    svg.setAttribute("class", "mark-svg");

    if (marker === "X") {
      const line1 = document.createElementNS(SVG_NS, "line");
      line1.setAttribute("x1", "5");
      line1.setAttribute("y1", "5");
      line1.setAttribute("x2", "19");
      line1.setAttribute("y2", "19");

      const line2 = document.createElementNS(SVG_NS, "line");
      line2.setAttribute("x1", "19");
      line2.setAttribute("y1", "5");
      line2.setAttribute("x2", "5");
      line2.setAttribute("y2", "19");

      svg.append(line1, line2);
    } else {
      const circle = document.createElementNS(SVG_NS, "circle");
      circle.setAttribute("cx", "12");
      circle.setAttribute("cy", "12");
      circle.setAttribute("r", "7.5");
      svg.appendChild(circle);
    }

    return svg;
  }

  function renderBoard(state) {
    const winSet = new Set(state.winningLine || []);
    const isGameOver = state.status !== "playing";

    cells.forEach((cell) => {
      const index = Number(cell.dataset.index);
      const value = state.board[index];
      const row = Math.floor(index / 3) + 1;
      const col = (index % 3) + 1;

      if (cell.dataset.mark !== value) {
        cell.textContent = "";
        cell.dataset.mark = value;
        if (value) {
          cell.appendChild(createMarkerSvg(value));
        }
      }

      cell.classList.toggle("is-x", value === "X");
      cell.classList.toggle("is-o", value === "O");
      cell.classList.toggle("is-winning", winSet.has(index));
      cell.classList.toggle("is-dimmed", state.status === "won" && !winSet.has(index));

      const isDisabled = value !== "" || isGameOver;
      cell.setAttribute("aria-disabled", String(isDisabled));
      cell.setAttribute(
        "aria-label",
        `Row ${row}, Column ${col}: ${value || "empty"}`
      );
    });
  }

  function renderScoreboardAndStatus(state) {
    const [playerX, playerO] = state.players;

    scoreLabelX.textContent = `${playerX.name} (X)`;
    scoreLabelO.textContent = `${playerO.name} (O)`;
    scoreValueX.textContent = String(playerX.score);
    scoreValueO.textContent = String(playerO.score);
    scoreValueTies.textContent = String(state.ties);

    const isPlaying = state.status === "playing";
    scoreCardX.classList.toggle("is-turn", isPlaying && state.activePlayer.marker === "X");
    scoreCardO.classList.toggle("is-turn", isPlaying && state.activePlayer.marker === "O");

    statusBanner.classList.remove("is-x-turn", "is-o-turn", "is-win", "is-tie");

    if (state.status === "won") {
      statusBanner.classList.add("is-win");
      statusBanner.textContent = `${state.winner.name} (${state.winner.marker}) wins!`;
    } else if (state.status === "tie") {
      statusBanner.classList.add("is-tie");
      statusBanner.textContent = "It's a tie! Neither player got three in a row.";
    } else {
      statusBanner.classList.add(
        state.activePlayer.marker === "X" ? "is-x-turn" : "is-o-turn"
      );
      statusBanner.textContent = `${state.activePlayer.name}'s turn (${state.activePlayer.marker})`;
    }
  }

  function render() {
    const state = GameController.getState();
    renderBoard(state);
    renderScoreboardAndStatus(state);
  }

  function handleBoardClick(event) {
    const cell = event.target.closest(".cell");
    if (!cell || cell.getAttribute("aria-disabled") === "true") {
      return;
    }

    const index = Number(cell.dataset.index);
    const result = GameController.playRound(index);
    if (result.valid) {
      render();
    }
  }

  function syncPlayerNames() {
    GameController.setPlayerNames(playerXInput.value, playerOInput.value);
  }

  function handleFormSubmit(event) {
    event.preventDefault();
    syncPlayerNames();
    GameController.restartRound();
    render();
  }

  function handleNameInput() {
    syncPlayerNames();
    renderScoreboardAndStatus(GameController.getState());
  }

  function handleResetScores() {
    syncPlayerNames();
    GameController.resetMatch();
    render();
  }

  function init() {
    if (!boardEl || !playerForm) {
      return;
    }

    boardEl.addEventListener("click", handleBoardClick);
    playerForm.addEventListener("submit", handleFormSubmit);
    playerXInput.addEventListener("input", handleNameInput);
    playerOInput.addEventListener("input", handleNameInput);
    resetScoresBtn.addEventListener("click", handleResetScores);

    syncPlayerNames();
    render();
  }

  init();

  return { render };
})();

