/**
 * DOM Manager Module
 * Manages all user interface interactions, DOM creation, modal controllers, and event listeners.
 * Strictly separates UI presentation from application logic.
 */
import { appLogic } from "./appLogic.js";
import { formatDueDate, isDueDateToday, isDueDateOverdue, getTodayDateString } from "./dateUtils.js";

class DOMManager {
  constructor() {
    // Cache DOM Elements
    this.app = document.getElementById("app");
    this.sidebar = document.getElementById("sidebar");
    this.sidebarToggleBtn = document.getElementById("sidebar-toggle-btn");
    this.sidebarBackdrop = document.getElementById("sidebar-backdrop");
    
    // Header & Search
    this.globalSearchInput = document.getElementById("global-search-input");
    this.clearSearchBtn = document.getElementById("clear-search-btn");
    this.headerAddTaskBtn = document.getElementById("header-add-task-btn");
    this.resetDataBtn = document.getElementById("reset-data-btn");

    // Views & Sidebar Lists
    this.systemViewsList = document.getElementById("system-views-list");
    this.projectsList = document.getElementById("projects-list");
    this.addProjectBtn = document.getElementById("add-project-btn");

    // Main Content
    this.currentViewTitle = document.getElementById("current-view-title");
    this.currentViewBadge = document.getElementById("current-view-badge");
    this.currentViewDescription = document.getElementById("current-view-description");
    this.sortSelect = document.getElementById("sort-select");
    this.inlineAddTaskBtn = document.getElementById("inline-add-task-btn");
    this.taskList = document.getElementById("task-list");
    this.emptyState = document.getElementById("empty-state");
    this.emptyTitle = document.getElementById("empty-title");
    this.emptySubtitle = document.getElementById("empty-subtitle");
    this.emptyAddBtn = document.getElementById("empty-add-btn");

    // Task Modal
    this.taskModal = document.getElementById("task-modal");
    this.taskForm = document.getElementById("task-form");
    this.taskModalTitle = document.getElementById("task-modal-title");
    this.taskIdInput = document.getElementById("task-id-input");
    this.taskTitleInput = document.getElementById("task-title-input");
    this.taskDescInput = document.getElementById("task-desc-input");
    this.taskDueDateInput = document.getElementById("task-due-date-input");
    this.taskPriorityInput = document.getElementById("task-priority-input");
    this.taskProjectInput = document.getElementById("task-project-input");
    this.taskNotesInput = document.getElementById("task-notes-input");
    this.modalChecklistItems = document.getElementById("modal-checklist-items");
    this.newSubtaskInput = document.getElementById("new-subtask-input");
    this.addSubtaskBtn = document.getElementById("add-subtask-btn");
    this.deleteTaskModalBtn = document.getElementById("delete-task-modal-btn");

    // Project Modal
    this.projectModal = document.getElementById("project-modal");
    this.projectForm = document.getElementById("project-form");
    this.projectModalTitle = document.getElementById("project-modal-title");
    this.projectIdInput = document.getElementById("project-id-input");
    this.projectNameInput = document.getElementById("project-name-input");
    this.colorPalette = document.getElementById("color-palette");

    // Confirm Modal
    this.confirmModal = document.getElementById("confirm-modal");
    this.confirmModalTitle = document.getElementById("confirm-modal-title");
    this.confirmModalMessage = document.getElementById("confirm-modal-message");
    this.confirmActionBtn = document.getElementById("confirm-action-btn");
    this.onConfirmCallback = null;

    // Toast Container
    this.toastContainer = document.getElementById("toast-container");

    // Internal state for temporary modal checklist items when creating/editing
    this.currentModalChecklist = [];
  }

  /**
   * Initializes all event listeners and renders initial UI.
   */
  init() {
    this.bindEvents();
    this.render();
  }

  // ==========================================
  // EVENT BINDINGS
  // ==========================================

  bindEvents() {
    // Mobile Sidebar Toggle
    this.sidebarToggleBtn?.addEventListener("click", () => this.toggleMobileSidebar());
    this.sidebarBackdrop?.addEventListener("click", () => this.closeMobileSidebar());

    // Navigation Views Clicks
    this.systemViewsList?.addEventListener("click", (e) => {
      const btn = e.target.closest(".nav-item");
      if (!btn) return;
      const view = btn.dataset.view;
      if (view) {
        appLogic.setActiveFilter({ type: view });
        this.closeMobileSidebar();
        this.render();
      }
    });

    // Add Task Button triggers
    this.headerAddTaskBtn?.addEventListener("click", () => this.openTaskModal());
    this.inlineAddTaskBtn?.addEventListener("click", () => this.openTaskModal());
    this.emptyAddBtn?.addEventListener("click", () => this.openTaskModal());

    // Add Project Button
    this.addProjectBtn?.addEventListener("click", () => this.openProjectModal());

    // Reset Data
    this.resetDataBtn?.addEventListener("click", () => {
      this.openConfirmModal({
        title: "Reset Application Data?",
        message: "This will restore sample projects and tasks, erasing any custom modifications.",
        actionText: "Reset All",
        onConfirm: () => {
          appLogic.resetAllData();
          this.showToast("Restored initial demo data.", "success");
          this.render();
        },
      });
    });

    // Global Search
    this.globalSearchInput?.addEventListener("input", (e) => {
      const val = e.target.value;
      appLogic.setSearchQuery(val);
      if (val) {
        this.clearSearchBtn?.classList.remove("hidden");
      } else {
        this.clearSearchBtn?.classList.add("hidden");
      }
      this.renderTaskList();
      this.renderViewHeader();
    });

    this.clearSearchBtn?.addEventListener("click", () => {
      if (this.globalSearchInput) this.globalSearchInput.value = "";
      this.clearSearchBtn?.classList.add("hidden");
      appLogic.setSearchQuery("");
      this.renderTaskList();
      this.renderViewHeader();
    });

    // Sort Dropdown
    this.sortSelect?.addEventListener("change", (e) => {
      const [sortBy, sortOrder] = e.target.value.split("-");
      appLogic.setSorting(sortBy, sortOrder);
      this.renderTaskList();
    });

    // Task Form Submission
    this.taskForm?.addEventListener("submit", (e) => {
      e.preventDefault();
      this.handleTaskFormSubmit();
    });

    // Subtask Checklist in Modal
    this.addSubtaskBtn?.addEventListener("click", () => this.handleAddModalSubtask());
    this.newSubtaskInput?.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        this.handleAddModalSubtask();
      }
    });

    // Delete Task inside Modal
    this.deleteTaskModalBtn?.addEventListener("click", () => {
      const taskId = this.taskIdInput.value;
      if (!taskId) return;
      this.openConfirmModal({
        title: "Delete Task?",
        message: "Are you sure you want to permanently delete this task?",
        actionText: "Delete",
        onConfirm: () => {
          appLogic.deleteTodo(taskId);
          this.closeModal(this.taskModal);
          this.showToast("Task deleted.", "info");
          this.render();
        },
      });
    });

    // Project Form Submission
    this.projectForm?.addEventListener("submit", (e) => {
      e.preventDefault();
      this.handleProjectFormSubmit();
    });

    // Confirm Modal Action
    this.confirmActionBtn?.addEventListener("click", () => {
      if (typeof this.onConfirmCallback === "function") {
        this.onConfirmCallback();
      }
      this.closeModal(this.confirmModal);
    });

    // Generic Modal Close Buttons
    document.querySelectorAll("[data-close-modal]").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        const dialog = e.target.closest("dialog");
        if (dialog) this.closeModal(dialog);
      });
    });

    // Close modal on backdrop click
    [this.taskModal, this.projectModal, this.confirmModal].forEach((modal) => {
      modal?.addEventListener("click", (e) => {
        if (e.target === modal) {
          this.closeModal(modal);
        }
      });
    });
  }

  // ==========================================
  // MOBILE SIDEBAR DRAWER
  // ==========================================

  toggleMobileSidebar() {
    this.sidebar?.classList.toggle("open");
    this.sidebarBackdrop?.classList.toggle("active");
  }

  closeMobileSidebar() {
    this.sidebar?.classList.remove("open");
    this.sidebarBackdrop?.classList.remove("active");
  }

  // ==========================================
  // MASTER RENDER
  // ==========================================

  render() {
    this.renderSidebar();
    this.renderViewHeader();
    this.renderTaskList();
  }

  // ==========================================
  // SIDEBAR RENDERING
  // ==========================================

  renderSidebar() {
    const counts = appLogic.getCounts();
    const activeFilter = appLogic.getActiveFilter();

    // Update system counts
    const countAllEl = document.getElementById("count-all");
    const countTodayEl = document.getElementById("count-today");
    const countWeekEl = document.getElementById("count-week");
    const countPriorityEl = document.getElementById("count-priority");
    const countCompletedEl = document.getElementById("count-completed");

    if (countAllEl) countAllEl.textContent = counts.all;
    if (countTodayEl) countTodayEl.textContent = counts.today;
    if (countWeekEl) countWeekEl.textContent = counts.week;
    if (countPriorityEl) countPriorityEl.textContent = counts.priority;
    if (countCompletedEl) countCompletedEl.textContent = counts.completed;

    // Update active highlight on system views
    const viewButtons = this.systemViewsList?.querySelectorAll(".nav-item") || [];
    viewButtons.forEach((btn) => {
      if (activeFilter.type === btn.dataset.view) {
        btn.classList.add("active");
      } else {
        btn.classList.remove("active");
      }
    });

    // Render Projects list
    if (!this.projectsList) return;
    this.projectsList.innerHTML = "";

    const projects = appLogic.getAllProjects();
    projects.forEach((proj) => {
      const li = document.createElement("li");
      li.className = "project-nav-item";

      const btn = document.createElement("button");
      btn.className = `nav-item ${
        activeFilter.type === "project" && activeFilter.projectId === proj.id ? "active" : ""
      }`;
      btn.dataset.projectId = proj.id;

      // Color indicator dot
      const dot = document.createElement("span");
      dot.className = "project-dot";
      dot.style.backgroundColor = proj.color || "#4f46e5";

      // Label
      const label = document.createElement("span");
      label.className = "nav-label";
      label.textContent = proj.name;

      // Count badge
      const count = document.createElement("span");
      count.className = "nav-count project-count";
      count.textContent = counts.projects[proj.id] || 0;

      btn.appendChild(dot);
      btn.appendChild(label);
      btn.appendChild(count);

      // Action buttons (edit, delete) for custom projects
      if (!proj.isDefault) {
        const actionsContainer = document.createElement("div");
        actionsContainer.className = "project-actions";

        // Edit button
        const editBtn = document.createElement("button");
        editBtn.className = "project-action-btn";
        editBtn.title = "Edit Project";
        editBtn.setAttribute("aria-label", `Edit ${proj.name}`);
        editBtn.innerHTML = `
          <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
          </svg>
        `;
        editBtn.addEventListener("click", (e) => {
          e.stopPropagation();
          this.openProjectModal(proj);
        });

        // Delete button
        const delBtn = document.createElement("button");
        delBtn.className = "project-action-btn delete-btn";
        delBtn.title = "Delete Project";
        delBtn.setAttribute("aria-label", `Delete ${proj.name}`);
        delBtn.innerHTML = `
          <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="3 6 5 6 21 6"></polyline>
            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
          </svg>
        `;
        delBtn.addEventListener("click", (e) => {
          e.stopPropagation();
          this.openConfirmModal({
            title: `Delete "${proj.name}"?`,
            message: "Tasks within this project will be safely moved to your Inbox.",
            actionText: "Delete Project",
            onConfirm: () => {
              appLogic.deleteProject(proj.id);
              this.showToast(`Project "${proj.name}" deleted.`, "info");
              this.render();
            },
          });
        });

        actionsContainer.appendChild(editBtn);
        actionsContainer.appendChild(delBtn);
        btn.appendChild(actionsContainer);
      }

      // Project selection click
      btn.addEventListener("click", () => {
        appLogic.setActiveFilter({ type: "project", projectId: proj.id });
        this.closeMobileSidebar();
        this.render();
      });

      li.appendChild(btn);
      this.projectsList.appendChild(li);
    });
  }

  // ==========================================
  // VIEW HEADER RENDERING
  // ==========================================

  renderViewHeader() {
    const activeFilter = appLogic.getActiveFilter();
    const searchQuery = appLogic.getSearchQuery();
    const filteredTodos = appLogic.getFilteredTodos();

    let title = "All Tasks";
    let desc = "All pending tasks across all your projects.";

    if (searchQuery) {
      title = `Search: "${searchQuery}"`;
      desc = `Matching tasks found across titles, notes, and subtasks.`;
    } else {
      switch (activeFilter.type) {
        case "today":
          title = "Today";
          desc = "Tasks due today to tackle right now.";
          break;
        case "week":
          title = "Next 7 Days";
          desc = "Upcoming tasks scheduled over the next seven days.";
          break;
        case "priority":
          title = "High Priority";
          desc = "Urgent and high priority tasks requiring your focus.";
          break;
        case "completed":
          title = "Completed";
          desc = "Tasks you've successfully accomplished.";
          break;
        case "project": {
          const proj = appLogic.getProject(activeFilter.projectId);
          if (proj) {
            title = proj.name;
            desc = proj.isDefault
              ? "Default bucket for tasks without a specific project."
              : `All tasks categorized under ${proj.name}.`;
          }
          break;
        }
        case "all":
        default:
          title = "All Tasks";
          desc = "All pending tasks across all your projects.";
          break;
      }
    }

    if (this.currentViewTitle) this.currentViewTitle.textContent = title;
    if (this.currentViewBadge) {
      const count = filteredTodos.length;
      this.currentViewBadge.textContent = `${count} ${count === 1 ? "task" : "tasks"}`;
    }
    if (this.currentViewDescription) this.currentViewDescription.textContent = desc;
  }

  // ==========================================
  // TASK LIST RENDERING
  // ==========================================

  renderTaskList() {
    if (!this.taskList) return;
    this.taskList.innerHTML = "";

    const todos = appLogic.getFilteredTodos();

    if (todos.length === 0) {
      this.showEmptyState();
      return;
    }

    this.hideEmptyState();

    todos.forEach((todo) => {
      const itemEl = this.createTaskCard(todo);
      this.taskList.appendChild(itemEl);
    });
  }

  createTaskCard(todo) {
    const card = document.createElement("article");
    card.className = `task-item priority-${todo.priority} ${todo.completed ? "completed" : ""}`;
    card.dataset.id = todo.id;

    // Checkbox
    const checkContainer = document.createElement("div");
    checkContainer.className = "task-checkbox-container";
    checkContainer.title = todo.completed ? "Mark incomplete" : "Mark complete";
    checkContainer.innerHTML = `
      <div class="custom-checkbox">
        <svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="20 6 9 17 4 12"></polyline>
        </svg>
      </div>
    `;

    checkContainer.addEventListener("click", (e) => {
      e.stopPropagation();
      const isComplete = appLogic.toggleTodoComplete(todo.id);
      this.showToast(isComplete ? "Task completed!" : "Task marked active.", "info");
      this.render();
    });

    // Content Body
    const content = document.createElement("div");
    content.className = "task-content";
    content.title = "Click to view and edit details";

    // Title Row
    const titleRow = document.createElement("div");
    titleRow.className = "task-header-row";

    const titleEl = document.createElement("h3");
    titleEl.className = "task-title";
    titleEl.textContent = todo.title;
    titleRow.appendChild(titleEl);
    content.appendChild(titleRow);

    // Optional Description
    if (todo.description) {
      const descEl = document.createElement("p");
      descEl.className = "task-description";
      descEl.textContent = todo.description;
      content.appendChild(descEl);
    }

    // Metadata Row
    const metaRow = document.createElement("div");
    metaRow.className = "task-meta-row";

    // Project Badge
    const project = appLogic.getProject(todo.projectId);
    if (project) {
      const projBadge = document.createElement("span");
      projBadge.className = "meta-badge project-badge";
      projBadge.innerHTML = `
        <span class="project-dot" style="background-color: ${project.color}; width: 8px; height: 8px;"></span>
        <span>${project.name}</span>
      `;
      metaRow.appendChild(projBadge);
    }

    // Due Date Badge
    if (todo.dueDate) {
      const isTodayDate = isDueDateToday(todo.dueDate);
      const isOverdue = !todo.completed && isDueDateOverdue(todo.dueDate);

      const dateBadge = document.createElement("span");
      dateBadge.className = `meta-badge date-badge ${isTodayDate ? "today" : ""} ${isOverdue ? "overdue" : ""}`;
      dateBadge.innerHTML = `
        <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
          <line x1="16" y1="2" x2="16" y2="6"></line>
          <line x1="8" y1="2" x2="8" y2="6"></line>
          <line x1="3" y1="10" x2="21" y2="10"></line>
        </svg>
        <span>${formatDueDate(todo.dueDate)}</span>
      `;
      metaRow.appendChild(dateBadge);
    }

    // Checklist Progress Badge
    if (todo.checklist && todo.checklist.length > 0) {
      const { total, completed } = todo.getChecklistProgress();
      const checkBadge = document.createElement("span");
      checkBadge.className = "meta-badge checklist-badge";
      checkBadge.innerHTML = `
        <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M9 11l3 3L22 4"></path>
          <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path>
        </svg>
        <span>${completed}/${total}</span>
      `;
      metaRow.appendChild(checkBadge);
    }

    // Notes Icon Badge
    if (todo.notes) {
      const notesBadge = document.createElement("span");
      notesBadge.className = "meta-badge notes-badge";
      notesBadge.title = "Has detailed notes";
      notesBadge.innerHTML = `
        <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
          <polyline points="14 2 14 8 20 8"></polyline>
          <line x1="16" y1="13" x2="8" y2="13"></line>
          <line x1="16" y1="17" x2="8" y2="17"></line>
        </svg>
      `;
      metaRow.appendChild(notesBadge);
    }

    content.appendChild(metaRow);

    // Clicking content opens task details
    content.addEventListener("click", () => {
      this.openTaskModal(todo);
    });

    // Actions (Edit, Delete)
    const actions = document.createElement("div");
    actions.className = "task-actions";

    const editBtn = document.createElement("button");
    editBtn.className = "icon-btn small";
    editBtn.title = "Edit Task";
    editBtn.innerHTML = `
      <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
      </svg>
    `;
    editBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      this.openTaskModal(todo);
    });

    const deleteBtn = document.createElement("button");
    deleteBtn.className = "icon-btn small";
    deleteBtn.title = "Delete Task";
    deleteBtn.innerHTML = `
      <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="3 6 5 6 21 6"></polyline>
        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
      </svg>
    `;
    deleteBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      this.openConfirmModal({
        title: "Delete Task?",
        message: `Are you sure you want to delete "${todo.title}"?`,
        actionText: "Delete",
        onConfirm: () => {
          appLogic.deleteTodo(todo.id);
          this.showToast("Task deleted.", "info");
          this.render();
        },
      });
    });

    actions.appendChild(editBtn);
    actions.appendChild(deleteBtn);

    card.appendChild(checkContainer);
    card.appendChild(content);
    card.appendChild(actions);

    return card;
  }

  showEmptyState() {
    if (!this.emptyState) return;
    this.emptyState.classList.remove("hidden");

    const searchQuery = appLogic.getSearchQuery();
    const activeFilter = appLogic.getActiveFilter();

    if (searchQuery) {
      if (this.emptyTitle) this.emptyTitle.textContent = "No matching tasks found";
      if (this.emptySubtitle) this.emptySubtitle.textContent = `No tasks matched your query "${searchQuery}".`;
    } else if (activeFilter.type === "completed") {
      if (this.emptyTitle) this.emptyTitle.textContent = "No completed tasks yet";
      if (this.emptySubtitle) this.emptySubtitle.textContent = "When you complete tasks, they will appear here.";
    } else if (activeFilter.type === "today") {
      if (this.emptyTitle) this.emptyTitle.textContent = "No tasks due today";
      if (this.emptySubtitle) this.emptySubtitle.textContent = "You're all clear for today! Enjoy your day or add a task.";
    } else {
      if (this.emptyTitle) this.emptyTitle.textContent = "All tasks completed!";
      if (this.emptySubtitle) this.emptySubtitle.textContent = "Stay organized and productive. Add a new task to get started.";
    }
  }

  hideEmptyState() {
    if (this.emptyState) {
      this.emptyState.classList.add("hidden");
    }
  }

  // ==========================================
  // TASK MODAL CONTROLLER
  // ==========================================

  populateProjectDropdown(selectedProjectId) {
    if (!this.taskProjectInput) return;
    this.taskProjectInput.innerHTML = "";
    const projects = appLogic.getAllProjects();
    projects.forEach((proj) => {
      const opt = document.createElement("option");
      opt.value = proj.id;
      opt.textContent = `${proj.isDefault ? "📥 " : "📁 "} ${proj.name}`;
      if (proj.id === selectedProjectId) {
        opt.selected = true;
      }
      this.taskProjectInput.appendChild(opt);
    });
  }

  openTaskModal(todo = null) {
    if (!this.taskModal) return;

    this.currentModalChecklist = [];

    const activeFilter = appLogic.getActiveFilter();
    let defaultProjectId = appLogic.getDefaultProject().id;
    if (activeFilter.type === "project" && appLogic.getProject(activeFilter.projectId)) {
      defaultProjectId = activeFilter.projectId;
    }

    if (todo) {
      // Edit existing task
      this.taskModalTitle.textContent = "Edit Task";
      this.taskIdInput.value = todo.id;
      this.taskTitleInput.value = todo.title;
      this.taskDescInput.value = todo.description || "";
      this.taskDueDateInput.value = todo.dueDate || "";
      this.taskPriorityInput.value = todo.priority || "medium";
      this.populateProjectDropdown(todo.projectId || defaultProjectId);
      this.taskNotesInput.value = todo.notes || "";
      this.currentModalChecklist = (todo.checklist || []).map((item) => ({ ...item }));
      this.deleteTaskModalBtn?.classList.remove("hidden");
    } else {
      // Add new task
      this.taskModalTitle.textContent = "New Task";
      this.taskIdInput.value = "";
      this.taskTitleInput.value = "";
      this.taskDescInput.value = "";
      this.taskDueDateInput.value = activeFilter.type === "today" ? getTodayDateString() : "";
      this.taskPriorityInput.value = activeFilter.type === "priority" ? "high" : "medium";
      this.populateProjectDropdown(defaultProjectId);
      this.taskNotesInput.value = "";
      this.currentModalChecklist = [];
      this.deleteTaskModalBtn?.classList.add("hidden");
    }

    this.renderModalChecklist();
    if (this.newSubtaskInput) this.newSubtaskInput.value = "";

    this.openModal(this.taskModal);
    setTimeout(() => this.taskTitleInput?.focus(), 50);
  }

  renderModalChecklist() {
    if (!this.modalChecklistItems) return;
    this.modalChecklistItems.innerHTML = "";

    this.currentModalChecklist.forEach((item, index) => {
      const row = document.createElement("div");
      row.className = `modal-check-item ${item.completed ? "completed" : ""}`;

      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.checked = item.completed;
      checkbox.addEventListener("change", () => {
        item.completed = checkbox.checked;
        this.renderModalChecklist();
      });

      const span = document.createElement("span");
      span.textContent = item.title;

      const delBtn = document.createElement("button");
      delBtn.type = "button";
      delBtn.className = "delete-check-item-btn";
      delBtn.title = "Delete step";
      delBtn.textContent = "✕";
      delBtn.addEventListener("click", () => {
        this.currentModalChecklist.splice(index, 1);
        this.renderModalChecklist();
      });

      row.appendChild(checkbox);
      row.appendChild(span);
      row.appendChild(delBtn);

      this.modalChecklistItems.appendChild(row);
    });
  }

  handleAddModalSubtask() {
    const text = this.newSubtaskInput?.value?.trim();
    if (!text) return;
    this.currentModalChecklist.push({
      id: `check-${Date.now()}-${Math.random().toString(36).substring(2, 6)}`,
      title: text,
      completed: false,
    });
    if (this.newSubtaskInput) this.newSubtaskInput.value = "";
    this.renderModalChecklist();
  }

  handleTaskFormSubmit() {
    const id = this.taskIdInput.value;
    const title = this.taskTitleInput.value.trim();
    const description = this.taskDescInput.value.trim();
    const dueDate = this.taskDueDateInput.value;
    const priority = this.taskPriorityInput.value;
    const projectId = this.taskProjectInput.value;
    const notes = this.taskNotesInput.value.trim();
    const checklist = this.currentModalChecklist;

    if (!title) return;

    if (id) {
      // Update
      appLogic.updateTodo(id, {
        title,
        description,
        dueDate,
        priority,
        projectId,
        notes,
        checklist,
      });
      this.showToast("Task updated.", "success");
    } else {
      // Create
      appLogic.createTodo({
        title,
        description,
        dueDate,
        priority,
        projectId,
        notes,
        checklist,
      });
      this.showToast("New task created!", "success");
    }

    this.closeModal(this.taskModal);
    this.render();
  }

  // ==========================================
  // PROJECT MODAL CONTROLLER
  // ==========================================

  openProjectModal(project = null) {
    if (!this.projectModal) return;

    if (project) {
      this.projectModalTitle.textContent = "Edit Project";
      this.projectIdInput.value = project.id;
      this.projectNameInput.value = project.name;
      const radio = this.colorPalette?.querySelector(`input[value="${project.color}"]`);
      if (radio) radio.checked = true;
    } else {
      this.projectModalTitle.textContent = "New Project";
      this.projectIdInput.value = "";
      this.projectNameInput.value = "";
      const defaultRadio = this.colorPalette?.querySelector(`input[value="#6366f1"]`);
      if (defaultRadio) defaultRadio.checked = true;
    }

    this.openModal(this.projectModal);
    setTimeout(() => this.projectNameInput?.focus(), 50);
  }

  handleProjectFormSubmit() {
    const id = this.projectIdInput.value;
    const name = this.projectNameInput.value.trim();
    const selectedColorRadio = this.colorPalette?.querySelector("input[name='project-color']:checked");
    const color = selectedColorRadio ? selectedColorRadio.value : "#6366f1";

    if (!name) return;

    if (id) {
      appLogic.updateProject(id, { name, color });
      this.showToast(`Project updated to "${name}".`, "success");
    } else {
      const created = appLogic.createProject(name, color);
      appLogic.setActiveFilter({ type: "project", projectId: created.id });
      this.showToast(`Project "${name}" created!`, "success");
    }

    this.closeModal(this.projectModal);
    this.render();
  }

  // ==========================================
  // CONFIRM MODAL CONTROLLER
  // ==========================================

  openConfirmModal({ title, message, actionText = "Delete", onConfirm }) {
    if (!this.confirmModal) return;
    this.confirmModalTitle.textContent = title;
    this.confirmModalMessage.textContent = message;
    this.confirmActionBtn.textContent = actionText;
    this.onConfirmCallback = onConfirm;
    this.openModal(this.confirmModal);
  }

  // ==========================================
  // GENERIC MODAL CONTROLS & TOASTS
  // ==========================================

  openModal(modal) {
    if (modal && typeof modal.showModal === "function") {
      modal.showModal();
    }
  }

  closeModal(modal) {
    if (modal && typeof modal.close === "function") {
      modal.close();
    }
  }

  showToast(message, type = "info") {
    if (!this.toastContainer) return;
    const toast = document.createElement("div");
    toast.className = `toast ${type === "danger" ? "toast-danger" : type === "success" ? "toast-success" : ""}`;

    const iconSvg = type === "success"
      ? `<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>`
      : `<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>`;

    toast.innerHTML = `${iconSvg}<span>${message}</span>`;
    this.toastContainer.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = "0";
      toast.style.transform = "translateY(10px) scale(0.95)";
      setTimeout(() => toast.remove(), 250);
    }, 2800);
  }
}

export const domManager = new DOMManager();
