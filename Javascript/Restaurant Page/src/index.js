import "./style.css";
import loadHome from "./home.js";
import loadMenu from "./menu.js";
import loadAbout from "./about.js";
import loadContact from "./contact.js";

console.log("Restaurant Page application initialized successfully!");

function clearContent() {
  const content = document.getElementById("content");
  if (content) {
    content.innerHTML = "";
  }
}

function setActiveButton(tabName) {
  const buttons = document.querySelectorAll(".nav-btn");
  buttons.forEach((btn) => {
    if (btn.getAttribute("data-tab") === tabName) {
      btn.classList.add("active");
    } else {
      btn.classList.remove("active");
    }
  });
}

function switchTab(tabName) {
  clearContent();
  setActiveButton(tabName);

  switch (tabName) {
    case "home":
      loadHome();
      break;
    case "menu":
      loadMenu();
      break;
    case "about":
      loadAbout();
      break;
    case "contact":
      loadContact();
      break;
    default:
      loadHome();
  }

  // Scroll smoothly to top of content
  window.scrollTo({ top: 0, behavior: "smooth" });
}

let isInitialized = false;

function setupNavigation() {
  if (isInitialized) return;
  isInitialized = true;

  const navButtons = document.querySelectorAll(".nav-btn");
  navButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const tab = btn.getAttribute("data-tab");
      if (tab) {
        switchTab(tab);
      }
    });
  });

  // Delegate clicks on any in-content buttons with data-target (e.g. hero CTA buttons)
  const content = document.getElementById("content");
  if (content) {
    content.addEventListener("click", (e) => {
      const targetBtn = e.target.closest("[data-target]");
      if (targetBtn) {
        const targetTab = targetBtn.getAttribute("data-target");
        if (targetTab) {
          switchTab(targetTab);
        }
      }
    });
  }
}

function init() {
  setupNavigation();
  switchTab("home");
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init);
} else {
  init();
}
