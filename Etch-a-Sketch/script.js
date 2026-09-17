const DEFAULT_SIZE = 16;
const MAX_SIZE = 100;

const container = document.querySelector("#container");
const resizeButton = document.querySelector("#resize");
const clearButton = document.querySelector("#clear");

// Builds a size x size grid of rows, each holding `size` squares.
// Flexbox splits the fixed 960px container evenly, so the total
// drawing area stays the same no matter how many squares there are.
function createGrid(size) {
  container.replaceChildren();

  for (let i = 0; i < size; i++) {
    const row = document.createElement("div");
    row.classList.add("row");

    for (let j = 0; j < size; j++) {
      const square = document.createElement("div");
      square.classList.add("square");
      square.addEventListener("mouseenter", paintSquare);
      row.appendChild(square);
    }

    container.appendChild(row);
  }
}

function randomColor() {
  const r = Math.floor(Math.random() * 256);
  const g = Math.floor(Math.random() * 256);
  const b = Math.floor(Math.random() * 256);
  return `rgb(${r}, ${g}, ${b})`;
}

// Each square picks a random color the first time it is touched, then
// darkens by 10% of full opacity on every pass. Ten passes reach 1.
function paintSquare(event) {
  const square = event.target;
  const opacity = Number(square.style.opacity) || 0;

  if (opacity === 0) {
    square.style.backgroundColor = randomColor();
  }

  if (opacity < 1) {
    square.style.opacity = Math.min(opacity + 0.1, 1);
  }
}

function clearGrid() {
  const squares = container.querySelectorAll(".square");
  squares.forEach((square) => {
    square.style.opacity = 0;
    square.style.backgroundColor = "";
  });
}

resizeButton.addEventListener("click", () => {
  const input = prompt(
    `How many squares per side? (1-${MAX_SIZE})`,
    DEFAULT_SIZE
  );

  // The user cancelled the prompt.
  if (input === null) return;

  const size = Number(input);

  if (!Number.isInteger(size) || size < 1 || size > MAX_SIZE) {
    alert(`Please enter a whole number between 1 and ${MAX_SIZE}.`);
    return;
  }

  createGrid(size);
});

clearButton.addEventListener("click", clearGrid);

createGrid(DEFAULT_SIZE);
