// --- math operators ---

function add(a, b) {
  return a + b;
}

function subtract(a, b) {
  return a - b;
}

function multiply(a, b) {
  return a * b;
}

function divide(a, b) {
  if (b === 0) return null; // caller shows the snarky message
  return a / b;
}

function operate(operator, a, b) {
  switch (operator) {
    case "+":
      return add(a, b);
    case "−":
      return subtract(a, b);
    case "×":
      return multiply(a, b);
    case "÷":
      return divide(a, b);
    default:
      return null;
  }
}

// --- state ---
// firstNumber holds the left operand once an operator is picked.
// currentInput is always what the display shows as a number string.
// typing tells us whether currentInput is being keyed in (true) or is a
// finished result (false) — that's what makes "5 + 3 = then press 7"
// start over instead of appending.

let firstNumber = null;
let operator = null;
let currentInput = "0";
let typing = false;
let justErrored = false;

const currentDisplay = document.querySelector("#current");
const expressionDisplay = document.querySelector("#expression");

function roundResult(value) {
  // Keep it to 10 significant digits so long decimals don't overflow,
  // then drop any trailing zeros the rounding introduced.
  return parseFloat(value.toPrecision(10));
}

function updateDisplay() {
  currentDisplay.textContent = currentInput;

  if (operator !== null) {
    expressionDisplay.textContent = `${firstNumber} ${operator}`;
  } else {
    expressionDisplay.textContent = "";
  }
}

function showError(message) {
  currentInput = message;
  firstNumber = null;
  operator = null;
  typing = false;
  justErrored = true;
  currentDisplay.textContent = message;
  expressionDisplay.textContent = "";
}

function clearAll() {
  firstNumber = null;
  operator = null;
  currentInput = "0";
  typing = false;
  justErrored = false;
  updateDisplay();
}

function appendDigit(digit) {
  if (justErrored) clearAll();

  if (!typing) {
    // Starting a fresh number: after a result, after an operator, or at boot.
    currentInput = digit;
    typing = true;
  } else if (currentInput === "0") {
    currentInput = digit; // no leading zeros
  } else {
    currentInput += digit;
  }

  updateDisplay();
}

function appendDecimal() {
  if (justErrored) clearAll();

  if (!typing) {
    currentInput = "0.";
    typing = true;
  } else if (!currentInput.includes(".")) {
    currentInput += ".";
  }

  updateDisplay();
}

function backspace() {
  if (justErrored) {
    clearAll();
    return;
  }
  if (!typing) return; // don't chew up a result

  currentInput = currentInput.slice(0, -1);
  if (currentInput === "" || currentInput === "-") currentInput = "0";
  updateDisplay();
}

function setOperator(nextOperator) {
  if (justErrored) clearAll();

  // Consecutive operators just swap the pending one — no evaluation.
  if (operator !== null && !typing) {
    operator = nextOperator;
    updateDisplay();
    return;
  }

  if (operator === null) {
    firstNumber = parseFloat(currentInput);
  } else {
    // We have a full pair, so fold it down before taking the new operator.
    const result = operate(operator, firstNumber, parseFloat(currentInput));
    if (result === null) {
      showError("Nice try — can't divide by zero");
      return;
    }
    firstNumber = roundResult(result);
    currentInput = String(firstNumber);
  }

  operator = nextOperator;
  typing = false;
  updateDisplay();
}

function equals() {
  if (justErrored) clearAll();

  // Nothing to do without both an operator and a second number.
  if (operator === null || !typing) return;

  const result = operate(operator, firstNumber, parseFloat(currentInput));
  if (result === null) {
    showError("Nice try — can't divide by zero");
    return;
  }

  currentInput = String(roundResult(result));
  firstNumber = null;
  operator = null;
  typing = false;
  updateDisplay();
}

// --- wiring ---

document.querySelectorAll(".key").forEach((key) => {
  key.addEventListener("click", () => {
    const { digit, operator: op, action } = key.dataset;

    if (digit !== undefined) appendDigit(digit);
    else if (op !== undefined) setOperator(op);
    else if (action === "decimal") appendDecimal();
    else if (action === "clear") clearAll();
    else if (action === "backspace") backspace();
    else if (action === "equals") equals();
  });
});

// Keyboard support. Map the typed characters onto the same handlers, and
// flash the matching button so the click and the key look alike.
const keyboardMap = {
  "/": "÷",
  "*": "×",
  "-": "−",
  "+": "+",
};

document.addEventListener("keydown", (event) => {
  const { key } = event;
  let button = null;

  if (key >= "0" && key <= "9") {
    appendDigit(key);
    button = document.querySelector(`[data-digit="${key}"]`);
  } else if (key === "." || key === ",") {
    appendDecimal();
    button = document.querySelector('[data-action="decimal"]');
  } else if (key in keyboardMap) {
    setOperator(keyboardMap[key]);
    button = document.querySelector(`[data-operator="${keyboardMap[key]}"]`);
  } else if (key === "Enter" || key === "=") {
    event.preventDefault(); // Enter would re-click the last focused button
    equals();
    button = document.querySelector('[data-action="equals"]');
  } else if (key === "Backspace") {
    backspace();
    button = document.querySelector('[data-action="backspace"]');
  } else if (key === "Escape") {
    clearAll();
    button = document.querySelector('[data-action="clear"]');
  }

  if (button) {
    button.classList.add("pressed");
    setTimeout(() => button.classList.remove("pressed"), 100);
  }
});

updateDisplay();
