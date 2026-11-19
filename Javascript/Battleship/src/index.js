import "./style.css";
import GameController from "./controllers/GameController";
import DomController from "./views/DomController";

document.addEventListener("DOMContentLoaded", () => {
  const gameController = new GameController("pvc");
  new DomController(gameController);
});
