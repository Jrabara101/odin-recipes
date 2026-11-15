/**
 * Application Logic Controller
 * Central state store and business logic orchestrator.
 * Keeps data logic strictly separated from DOM rendering.
 */
import { Todo } from "./todo.js";
import { Project } from "./project.js";
import * as storage from "./storage.js";
import { isDueDateToday, isDueDateThisWeek, isDueDateOverdue } from "./dateUtils.js";

class AppLogic {
  constructor() {
    this.projects = [];
    this.todos = [];
    this.activeFilter = { type: "all" }; // 'all' | 'today' | 'week' | 'priority' | 'inbox' | 'completed' | 'project'
    this.searchQuery = "";
    this.sortBy = "dueDate"; // 'dueDate' | 'priority' | 'title'
    this.sortOrder = "asc";
  }

  /**
   * Initializes state from localStorage or loads seed data.
   */
  init() {
    let savedProjects = storage.loadProjects();
    let savedTodos = storage.loadTodos();

    if (!savedProjects || savedProjects.length === 0) {
      const seed = storage.getInitialSeedData();
      this.projects = seed.projects;
      this.todos = seed.todos;
      this.persist();
    } else {
      this.projects = savedProjects;
      this.todos = savedTodos || [];
    }

    const savedFilter = storage.loadActiveFilter();
    if (savedFilter) {
      // Validate that if it's a project filter, the project still exists
      if (savedFilter.type === "project") {
        const exists = this.projects.some((p) => p.id === savedFilter.projectId);
        this.activeFilter = exists ? savedFilter : { type: "all" };
      } else {
        this.activeFilter = savedFilter;
      }
    }
  }

  /**
   * Persists both projects and todos to localStorage.
   */
  persist() {
    storage.saveProjects(this.projects);
    storage.saveTodos(this.todos);
    storage.saveActiveFilter(this.activeFilter);
  }

  // ==========================================
  // PROJECT OPERATIONS
  // ==========================================

  getAllProjects() {
    return [...this.projects];
  }

  getDefaultProject() {
    return this.projects.find((p) => p.isDefault) || this.projects[0];
  }

  getProject(id) {
    return this.projects.find((p) => p.id === id) || null;
  }

  createProject(name, color = "#4f46e5") {
    const trimmed = (name || "").trim();
    if (!trimmed) throw new Error("Project name cannot be empty.");

    const newProject = new Project({
      name: trimmed,
      color,
      isDefault: false,
    });

    this.projects.push(newProject);
    this.persist();
    return newProject;
  }

  updateProject(id, { name, color }) {
    const project = this.getProject(id);
    if (!project) return null;
    project.update({ name, color });
    this.persist();
    return project;
  }

  deleteProject(id) {
    const project = this.getProject(id);
    if (!project || project.isDefault) {
      return false; // Cannot delete non-existent or default project
    }

    const defaultProj = this.getDefaultProject();
    // Reassign any todos under this project to the default Inbox so no tasks are lost
    this.todos.forEach((todo) => {
      if (todo.projectId === id) {
        todo.projectId = defaultProj.id;
      }
    });

    this.projects = this.projects.filter((p) => p.id !== id);

    // If active view was this project, redirect to 'all'
    if (this.activeFilter.type === "project" && this.activeFilter.projectId === id) {
      this.activeFilter = { type: "all" };
    }

    this.persist();
    return true;
  }

  // ==========================================
  // TODO OPERATIONS
  // ==========================================

  getAllTodos() {
    return [...this.todos];
  }

  getTodo(id) {
    return this.todos.find((t) => t.id === id) || null;
  }

  createTodo({
    title,
    description = "",
    dueDate = "",
    priority = "medium",
    projectId,
    notes = "",
    checklist = [],
  }) {
    const trimmedTitle = (title || "").trim();
    if (!trimmedTitle) {
      throw new Error("Task title cannot be empty.");
    }

    // Default to active project if valid, or default project
    let targetProjectId = projectId;
    if (!targetProjectId || !this.getProject(targetProjectId)) {
      if (this.activeFilter.type === "project" && this.getProject(this.activeFilter.projectId)) {
        targetProjectId = this.activeFilter.projectId;
      } else {
        targetProjectId = this.getDefaultProject().id;
      }
    }

    const newTodo = new Todo({
      title: trimmedTitle,
      description: (description || "").trim(),
      dueDate: dueDate || "",
      priority: ["high", "medium", "low", "none"].includes(priority) ? priority : "medium",
      projectId: targetProjectId,
      completed: false,
      notes: (notes || "").trim(),
      checklist: Array.isArray(checklist) ? checklist : [],
    });

    this.todos.unshift(newTodo); // Add to beginning
    this.persist();
    return newTodo;
  }

  updateTodo(id, updatedFields) {
    const todo = this.getTodo(id);
    if (!todo) return null;
    todo.update(updatedFields);
    this.persist();
    return todo;
  }

  deleteTodo(id) {
    const initialLen = this.todos.length;
    this.todos = this.todos.filter((t) => t.id !== id);
    const deleted = this.todos.length < initialLen;
    if (deleted) {
      this.persist();
    }
    return deleted;
  }

  toggleTodoComplete(id) {
    const todo = this.getTodo(id);
    if (!todo) return null;
    const newState = todo.toggleComplete();
    this.persist();
    return newState;
  }

  addChecklistItem(todoId, text) {
    const todo = this.getTodo(todoId);
    if (!todo) return null;
    const item = todo.addChecklistItem(text);
    if (item) this.persist();
    return item;
  }

  toggleChecklistItem(todoId, itemId) {
    const todo = this.getTodo(todoId);
    if (!todo) return null;
    const state = todo.toggleChecklistItem(itemId);
    this.persist();
    return state;
  }

  deleteChecklistItem(todoId, itemId) {
    const todo = this.getTodo(todoId);
    if (!todo) return false;
    const removed = todo.deleteChecklistItem(itemId);
    if (removed) this.persist();
    return removed;
  }

  // ==========================================
  // VIEW, FILTER & SORT LOGIC
  // ==========================================

  setActiveFilter(filter) {
    this.activeFilter = filter;
    this.persist();
  }

  getActiveFilter() {
    return { ...this.activeFilter };
  }

  setSearchQuery(query) {
    this.searchQuery = (query || "").trim().toLowerCase();
  }

  getSearchQuery() {
    return this.searchQuery;
  }

  setSorting(sortBy, sortOrder = "asc") {
    this.sortBy = sortBy;
    this.sortOrder = sortOrder;
  }

  getFilteredTodos() {
    const defaultProj = this.getDefaultProject();
    let result = [...this.todos];

    // Filter by view type
    switch (this.activeFilter.type) {
      case "inbox":
        result = result.filter(
          (t) => t.projectId === defaultProj.id && !t.completed
        );
        break;
      case "today":
        result = result.filter(
          (t) => isDueDateToday(t.dueDate) && !t.completed
        );
        break;
      case "week":
        result = result.filter(
          (t) => isDueDateThisWeek(t.dueDate) && !t.completed
        );
        break;
      case "priority":
        result = result.filter(
          (t) => t.priority === "high" && !t.completed
        );
        break;
      case "completed":
        result = result.filter((t) => t.completed);
        break;
      case "project":
        result = result.filter(
          (t) => t.projectId === this.activeFilter.projectId
        );
        break;
      case "all":
      default:
        // By default 'all' shows all non-completed tasks (or both if desired, but standard is active tasks)
        result = result.filter((t) => !t.completed);
        break;
    }

    // Filter by search query if present
    if (this.searchQuery) {
      result = result.filter((t) => {
        const inTitle = t.title.toLowerCase().includes(this.searchQuery);
        const inDesc = t.description.toLowerCase().includes(this.searchQuery);
        const inNotes = t.notes.toLowerCase().includes(this.searchQuery);
        const inChecklist = t.checklist.some((c) =>
          c.title.toLowerCase().includes(this.searchQuery)
        );
        return inTitle || inDesc || inNotes || inChecklist;
      });
    }

    // Sort results
    const priorityWeights = { high: 3, medium: 2, low: 1, none: 0 };

    result.sort((a, b) => {
      // Completed items always sink to bottom unless in completed view
      if (this.activeFilter.type !== "completed" && a.completed !== b.completed) {
        return a.completed ? 1 : -1;
      }

      if (this.sortBy === "priority") {
        const weightA = priorityWeights[a.priority] || 0;
        const weightB = priorityWeights[b.priority] || 0;
        return this.sortOrder === "asc" ? weightB - weightA : weightA - weightB;
      }

      if (this.sortBy === "title") {
        const cmp = a.title.localeCompare(b.title);
        return this.sortOrder === "asc" ? cmp : -cmp;
      }

      // Default: Due Date
      if (!a.dueDate && !b.dueDate) return 0;
      if (!a.dueDate) return 1; // Undated tasks go last
      if (!b.dueDate) return -1;
      const cmp = a.dueDate.localeCompare(b.dueDate);
      return this.sortOrder === "asc" ? cmp : -cmp;
    });

    return result;
  }

  // ==========================================
  // BADGE COUNTS
  // ==========================================

  getCounts() {
    const defaultProj = this.getDefaultProject();
    const counts = {
      all: 0,
      today: 0,
      week: 0,
      priority: 0,
      inbox: 0,
      completed: 0,
      projects: {},
    };

    this.projects.forEach((p) => {
      counts.projects[p.id] = 0;
    });

    this.todos.forEach((todo) => {
      if (todo.completed) {
        counts.completed++;
        return;
      }

      // Active tasks
      counts.all++;

      if (todo.projectId === defaultProj.id) {
        counts.inbox++;
      }

      if (isDueDateToday(todo.dueDate)) {
        counts.today++;
      }

      if (isDueDateThisWeek(todo.dueDate)) {
        counts.week++;
      }

      if (todo.priority === "high") {
        counts.priority++;
      }

      if (counts.projects[todo.projectId] !== undefined) {
        counts.projects[todo.projectId]++;
      }
    });

    return counts;
  }

  resetAllData() {
    storage.resetStorage();
    const seed = storage.getInitialSeedData();
    this.projects = seed.projects;
    this.todos = seed.todos;
    this.activeFilter = { type: "all" };
    this.searchQuery = "";
    this.persist();
  }
}

export const appLogic = new AppLogic();
