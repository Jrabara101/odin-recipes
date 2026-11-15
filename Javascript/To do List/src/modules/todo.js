/**
 * Todo Model Class
 * Represents an individual task item with properties and state manipulation methods.
 */
export class Todo {
  constructor({
    id = `todo-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
    title = "",
    description = "",
    dueDate = "",
    priority = "medium",
    projectId = "default-inbox",
    completed = false,
    notes = "",
    checklist = [],
    createdAt = new Date().toISOString(),
  } = {}) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.dueDate = dueDate;
    this.priority = priority; // 'high' | 'medium' | 'low' | 'none'
    this.projectId = projectId;
    this.completed = completed;
    this.notes = notes;
    this.checklist = checklist; // Array of { id, title, completed }
    this.createdAt = createdAt;
  }

  toggleComplete() {
    this.completed = !this.completed;
    return this.completed;
  }

  update({
    title,
    description,
    dueDate,
    priority,
    projectId,
    notes,
    checklist,
  }) {
    if (title !== undefined) this.title = title.trim();
    if (description !== undefined) this.description = description.trim();
    if (dueDate !== undefined) this.dueDate = dueDate;
    if (priority !== undefined) this.priority = priority;
    if (projectId !== undefined) this.projectId = projectId;
    if (notes !== undefined) this.notes = notes.trim();
    if (checklist !== undefined && Array.isArray(checklist)) {
      this.checklist = checklist;
    }
  }

  addChecklistItem(title) {
    if (!title || !title.trim()) return null;
    const newItem = {
      id: `check-${Date.now()}-${Math.random().toString(36).substring(2, 6)}`,
      title: title.trim(),
      completed: false,
    };
    this.checklist.push(newItem);
    return newItem;
  }

  toggleChecklistItem(itemId) {
    const item = this.checklist.find((i) => i.id === itemId);
    if (item) {
      item.completed = !item.completed;
      return item.completed;
    }
    return null;
  }

  deleteChecklistItem(itemId) {
    const initialLen = this.checklist.length;
    this.checklist = this.checklist.filter((i) => i.id !== itemId);
    return this.checklist.length < initialLen;
  }

  getChecklistProgress() {
    const total = this.checklist.length;
    if (total === 0) return { total: 0, completed: 0, percentage: 0 };
    const completed = this.checklist.filter((i) => i.completed).length;
    const percentage = Math.round((completed / total) * 100);
    return { total, completed, percentage };
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      description: this.description,
      dueDate: this.dueDate,
      priority: this.priority,
      projectId: this.projectId,
      completed: this.completed,
      notes: this.notes,
      checklist: this.checklist,
      createdAt: this.createdAt,
    };
  }

  static fromJSON(data) {
    return new Todo(data);
  }
}
