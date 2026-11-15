/**
 * TaskFlow Application Entry Point
 * Orchestrates logic initialization and DOM bootstrapping.
 */
import "./styles/main.css";
import { appLogic } from "./modules/appLogic.js";
import { domManager } from "./modules/domManager.js";

document.addEventListener("DOMContentLoaded", () => {
  // 1. Initialize data layer & state from localStorage
  appLogic.init();

  // 2. Initialize DOM view and event listeners
  domManager.init();

  console.log("TaskFlow loaded successfully.");
});
