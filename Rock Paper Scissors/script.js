console.log("Hello World");

// Step 2: randomly return "rock", "paper" or "scissors"
function getComputerChoice() {
  const randomNumber = Math.random();

  if (randomNumber < 1 / 3) {
    return "rock";
  } else if (randomNumber < 2 / 3) {
    return "paper";
  } else {
    return "scissors";
  }
}

// Step 3: ask the human for a choice and return it
function getHumanChoice() {
  const choice = prompt("Rock, paper or scissors?");
  return choice.toLowerCase();
}

// Step 6: the whole game lives in here
function playGame() {
  // Step 4: score variables
  let humanScore = 0;
  let computerScore = 0;

  // Step 5: play one round
  function playRound(humanChoice, computerChoice) {
    humanChoice = humanChoice.toLowerCase();

    if (humanChoice === computerChoice) {
      console.log(`It's a tie! You both chose ${humanChoice}`);
    } else if (
      (humanChoice === "rock" && computerChoice === "scissors") ||
      (humanChoice === "paper" && computerChoice === "rock") ||
      (humanChoice === "scissors" && computerChoice === "paper")
    ) {
      humanScore++;
      console.log(`You win! ${humanChoice} beats ${computerChoice}`);
    } else {
      computerScore++;
      console.log(`You lose! ${computerChoice} beats ${humanChoice}`);
    }

    console.log(`Score - You: ${humanScore}, Computer: ${computerScore}`);
  }

  // Play 5 rounds
  for (let round = 1; round <= 5; round++) {
    console.log(`--- Round ${round} ---`);
    const humanSelection = getHumanChoice();
    const computerSelection = getComputerChoice();
    playRound(humanSelection, computerSelection);
  }

  // Declare the overall winner
  console.log("--- Final result ---");
  if (humanScore > computerScore) {
    console.log(`You won the game! ${humanScore} to ${computerScore}`);
  } else if (computerScore > humanScore) {
    console.log(`You lost the game! ${computerScore} to ${humanScore}`);
  } else {
    console.log(`The game is a tie! ${humanScore} to ${computerScore}`);
  }
}

playGame();
