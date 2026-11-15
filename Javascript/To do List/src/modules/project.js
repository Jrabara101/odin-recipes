/**
 * Project Model Class
 * Represents a project bucket that groups related todos.
 */
export class Project {
  constructor({
    id = `proj-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
    name = "New Project",
    color = "#4f46e5",
    isDefault = false,
    createdAt = new Date().toISOString(),
  } = {}) {
    this.id = id;
    this.name = name.trim();
    this.color = color;
    this.isDefault = isDefault;
    this.createdAt = createdAt;
  }

  update({ name, color }) {
    if (name !== undefined && name.trim()) {
      this.name = name.trim();
    }
    if (color !== undefined) {
      this.color = color;
    }
  }

  toJSON() {
    return {
      id: this.id,
      name: this.name,
      color: this.color,
      isDefault: this.isDefault,
      createdAt: this.createdAt,
    };
  }

  static fromJSON(data) {
    return new Project(data);
  }
}
