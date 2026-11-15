# TaskFlow | The Odin Project: Todo List

A modern, high-performance, responsive Todo and Project Management web application built with **Vanilla JavaScript (ES6 Modules)**, **Webpack 5**, **date-fns**, and the **Web Storage API (localStorage)**.

Designed and implemented in accordance with [The Odin Project's JavaScript Todo List curriculum](https://www.theodinproject.com/lessons/javascript-todo-list).

---

## ✨ Features

- **Project Buckets & Categorization**:
  - Default "Inbox" project for uncategorized tasks.
  - Create, customize, edit, and delete custom projects with a custom color palette.
  - Deleting a project automatically and safely reassigns tasks to the default Inbox, preventing accidental data loss.

- **Smart Views & Filters**:
  - **All Tasks**: Overview of active tasks across all projects.
  - **Today**: Real-time filter powered by `date-fns isToday`.
  - **Next 7 Days**: Upcoming tasks scheduled for the next 7 days using `date-fns addDays` and start-of-day comparison.
  - **High Priority**: Urgent tasks requiring immediate attention.
  - **Completed**: Archive of accomplished tasks.
  - **Instant Search**: Real-time search across task titles, descriptions, notes, and checklist items.
  - **Multi-criteria Sorting**: Sort by Due Date (Earliest / Latest), Priority (High to Low / Low to High), or Title (A - Z).

- **Rich Task Objects**:
  - `title`, `description`, `dueDate` (with relative labels like *Today*, *Tomorrow*, *Overdue (Nov 12)*, *Nov 20*), `priority` (High, Medium, Low, None), `projectId`, `completed`, `notes`, and `checklist`.
  - **Interactive Checklist / Subtasks**: Track sub-steps for any task with progress badges (e.g. `2/4`).
  - **Color-coded Priority Indicator**: Clean visual priority stripes (Red = High, Orange = Medium, Blue = Low, Slate = None).
  - **Detail & Edit Modal**: Expand any task to review notes, update metadata, manage subtasks, or delete.

- **Robust LocalStorage Persistence**:
  - Auto-saves every modification (create, update, toggle completion, delete, reorder).
  - **Prototype & Class Re-Hydration**: Restores `Todo` and `Project` instances using `Todo.fromJSON()` and `Project.fromJSON()` upon retrieval, ensuring all class methods (`toggleComplete()`, `addChecklistItem()`, `getChecklistProgress()`, etc.) remain fully functional after serialization.
  - Includes seed data on first launch with demo projects and tasks, plus a one-click "Reset Demo Data" option.

- **Responsive & Accessible Design**:
  - Desktop split-view layout with collapsibility.
  - Mobile slide-out drawer with backdrop blur.
  - Clean SVG iconography without bulky external font libraries.

---

## 🏗️ Architecture & Separation of Concerns

The project strictly separates business/domain logic, storage persistence, and DOM rendering:

```
To do List/
├── dist/                     # Webpack production output
│   ├── bundle.js
│   └── index.html
├── src/
│   ├── modules/
│   │   ├── todo.js           # Todo class: state, updates, checklist management, fromJSON/toJSON
│   │   ├── project.js        # Project class: identity, color styling, fromJSON/toJSON
│   │   ├── dateUtils.js      # date-fns wrapper: relative formatting, overdue and week calculations
│   │   ├── storage.js        # Web Storage manager: serialization, error handling, default seed data
│   │   ├── appLogic.js       # Core business logic: filtering, searching, sorting, CRUD operations
│   │   └── domManager.js     # DOM controller: rendering, event delegation, dialog modals, toast alerts
│   ├── styles/
│   │   ├── variables.css     # Design tokens, color system, priority badges, shadows
│   │   ├── layout.css        # App shell, header, search bar, base reset
│   │   ├── sidebar.css       # Sidebar navigation, counters, project list, mobile drawer
│   │   ├── tasks.css         # Task cards, checkboxes, priority stripes, empty states
│   │   ├── modal.css         # Native <dialog> modal cards, checklist editor, toasts
│   │   └── main.css          # Master stylesheet
│   ├── index.js              # Entry point: bootstrapping appLogic & domManager
│   └── template.html         # HTML template for HtmlWebpackPlugin
├── package.json              # Scripts, devDependencies, and date-fns
├── webpack.config.js         # Webpack 5 bundling configuration
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- Node.js (v18+)
- npm

### Installation & Running Locally

1. Navigate to the project directory:
   ```bash
   cd "c:/Users/Admin/odin-recipes/Javascript/To do List"
   ```

2. Install dependencies (if not already installed):
   ```bash
   npm install
   ```

3. Build for production:
   ```bash
   npm run build
   ```

4. Run the development server with live reload:
   ```bash
   npm start
   ```

5. Watch files during development:
   ```bash
   npm run watch
   ```

---

## 📋 Assignment Requirements Verification

- [x] **Todo objects dynamically created**: Implemented using ES6 `Todo` class with custom factories and `fromJSON` hydration.
- [x] **Properties**: Includes `title`, `description`, `dueDate`, `priority`, `projectId`, `completed`, `notes`, and `checklist`.
- [x] **Projects / Lists**: Default "Inbox" project and user-creatable custom projects with color tagging.
- [x] **Separation of Concerns**: Domain logic in `todo.js`/`project.js`, controller logic in `appLogic.js`, storage in `storage.js`, and DOM rendering in `domManager.js`.
- [x] **UI capabilities**:
  - View all projects.
  - View all todos in each project / smart view.
  - Expand single todo to inspect and edit details.
  - Delete a todo with confirmation.
  - Mark todos complete with instant feedback.
- [x] **date-fns integration**: Uses `date-fns` for relative dates (*Today*, *Tomorrow*, *Overdue*), parsing, and date window queries.
- [x] **localStorage persistence**: Full persistence using Web Storage API with crash-safe JSON parsing and method restoration.
