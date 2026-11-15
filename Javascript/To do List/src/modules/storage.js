/**
 * Storage Module
 * Manages Web Storage API (localStorage) persistence and hydration of Todo and Project objects.
 */
import { Project } from "./project.js";
import { Todo } from "./todo.js";
import { getTodayDateString, getDateOffsetString } from "./dateUtils.js";

const PROJECTS_KEY = "taskflow_projects_v1";
const TODOS_KEY = "taskflow_todos_v1";
const FILTER_KEY = "taskflow_active_filter_v1";

/**
 * Checks if localStorage is available in the current browser.
 */
function isStorageAvailable() {
  try {
    const testKey = "__test_storage__";
    window.localStorage.setItem(testKey, testKey);
    window.localStorage.removeItem(testKey);
    return true;
  } catch (e) {
    console.warn("localStorage is not available:", e);
    return false;
  }
}

/**
 * Creates seed/default data for a brand new user session.
 */
export function getInitialSeedData() {
  const defaultProjects = [
    new Project({
      id: "default-inbox",
      name: "Inbox",
      color: "#6366f1", // Indigo
      isDefault: true,
    }),
    new Project({
      id: "proj-work",
      name: "Work & Career",
      color: "#3b82f6", // Blue
      isDefault: false,
    }),
    new Project({
      id: "proj-personal",
      name: "Personal & Home",
      color: "#10b981", // Emerald
      isDefault: false,
    }),
    new Project({
      id: "proj-odin",
      name: "The Odin Project",
      color: "#f59e0b", // Amber
      isDefault: false,
    }),
  ];

  const defaultTodos = [
    new Todo({
      id: "todo-sample-1",
      title: "Master JavaScript Modules and Webpack",
      description: "Separate business logic from DOM code and bundle using Webpack 5.",
      dueDate: getTodayDateString(),
      priority: "high",
      projectId: "proj-odin",
      completed: false,
      notes: "Remember: Keep DOM manipulation strictly in domManager, business state in appLogic, and models in todo.js & project.js.",
      checklist: [
        { id: "sub-1-1", title: "Configure webpack.config.js with html-webpack-plugin", completed: true },
        { id: "sub-1-2", title: "Integrate date-fns for dynamic relative dates", completed: true },
        { id: "sub-1-3", title: "Implement localStorage serialization and hydration", completed: false },
        { id: "sub-1-4", title: "Test all CRUD operations across project views", completed: false },
      ],
    }),
    new Todo({
      id: "todo-sample-2",
      title: "Submit Odin Project Todo List assignment",
      description: "Verify all assignment criteria, responsive layout, and clean git history.",
      dueDate: getDateOffsetString(1),
      priority: "high",
      projectId: "proj-odin",
      completed: false,
      notes: "Link live demo on GitHub Pages and push repo.",
      checklist: [
        { id: "sub-2-1", title: "Audit responsive design on mobile and desktop", completed: false },
        { id: "sub-2-2", title: "Review localStorage method re-hydration", completed: false },
      ],
    }),
    new Todo({
      id: "todo-sample-3",
      title: "Quarterly review preparation",
      description: "Compile engineering wins, metrics, and goals for Q1.",
      dueDate: getDateOffsetString(3),
      priority: "medium",
      projectId: "proj-work",
      completed: false,
      notes: "Gather data from sprint retrospectives and pull request metrics.",
      checklist: [],
    }),
    new Todo({
      id: "todo-sample-4",
      title: "Weekend farmers market & meal prep",
      description: "Pick up fresh produce and plan meals for the upcoming week.",
      dueDate: getDateOffsetString(5),
      priority: "low",
      projectId: "proj-personal",
      completed: false,
      notes: "Items needed: avocados, sourdough bread, organic olive oil, espresso beans.",
      checklist: [
        { id: "sub-4-1", title: "Sourdough bread & espresso beans", completed: true },
        { id: "sub-4-2", title: "Avocados and seasonal fruits", completed: false },
        { id: "sub-4-3", title: "Prepare overnight oats for Monday", completed: false },
      ],
    }),
    new Todo({
      id: "todo-sample-5",
      title: "Complete initial repo setup and npm install",
      description: "Initialize npm package and install webpack, loaders, and date-fns.",
      dueDate: getTodayDateString(),
      priority: "none",
      projectId: "default-inbox",
      completed: true,
      notes: "Configured cleanly with zero audit vulnerabilities.",
      checklist: [],
    }),
  ];

  return { projects: defaultProjects, todos: defaultTodos };
}

/**
 * Saves projects array to localStorage as JSON.
 */
export function saveProjects(projects) {
  if (!isStorageAvailable()) return;
  try {
    const serialized = JSON.stringify(projects.map((p) => p.toJSON()));
    window.localStorage.setItem(PROJECTS_KEY, serialized);
  } catch (err) {
    console.error("Failed to save projects to localStorage:", err);
  }
}

/**
 * Loads projects array from localStorage and re-hydrates Project instances.
 * Returns null if no saved data exists.
 */
export function loadProjects() {
  if (!isStorageAvailable()) return null;
  try {
    const raw = window.localStorage.getItem(PROJECTS_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed) || parsed.length === 0) return null;
    return parsed.map((item) => Project.fromJSON(item));
  } catch (err) {
    console.error("Failed to load projects from localStorage:", err);
    return null;
  }
}

/**
 * Saves todos array to localStorage as JSON.
 */
export function saveTodos(todos) {
  if (!isStorageAvailable()) return;
  try {
    const serialized = JSON.stringify(todos.map((t) => t.toJSON()));
    window.localStorage.setItem(TODOS_KEY, serialized);
  } catch (err) {
    console.error("Failed to save todos to localStorage:", err);
  }
}

/**
 * Loads todos array from localStorage and re-hydrates Todo instances with methods.
 * Returns null if no saved data exists.
 */
export function loadTodos() {
  if (!isStorageAvailable()) return null;
  try {
    const raw = window.localStorage.getItem(TODOS_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return null;
    return parsed.map((item) => Todo.fromJSON(item));
  } catch (err) {
    console.error("Failed to load todos from localStorage:", err);
    return null;
  }
}

/**
 * Saves active filter state so user returns to where they were.
 */
export function saveActiveFilter(filter) {
  if (!isStorageAvailable()) return;
  try {
    window.localStorage.setItem(FILTER_KEY, JSON.stringify(filter));
  } catch (e) {
    // Ignore filter save errors
  }
}

/**
 * Loads active filter state.
 */
export function loadActiveFilter() {
  if (!isStorageAvailable()) return null;
  try {
    const raw = window.localStorage.getItem(FILTER_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch (e) {
    return null;
  }
}

/**
 * Clears saved data and resets to initial seed.
 */
export function resetStorage() {
  if (isStorageAvailable()) {
    window.localStorage.removeItem(PROJECTS_KEY);
    window.localStorage.removeItem(TODOS_KEY);
    window.localStorage.removeItem(FILTER_KEY);
  }
}
