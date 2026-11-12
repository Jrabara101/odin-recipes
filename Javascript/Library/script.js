// ==================== DATA LAYER ====================

const myLibrary = [];

/**
 * Represents a book in the library collection.
 * @param {string} title
 * @param {string} author
 * @param {number|string} pages
 * @param {boolean} read
 * @param {string} [genre=""]
 */
function Book(title, author, pages, read, genre = "") {
  if (!new.target) {
    return new Book(title, author, pages, read, genre);
  }

  this.id =
    typeof crypto !== "undefined" && typeof crypto.randomUUID === "function"
      ? crypto.randomUUID()
      : `book-${Date.now()}-${Math.random().toString(16).slice(2)}`;
  this.title = title;
  this.author = author;
  this.pages = Number(pages);
  this.read = Boolean(read);
  this.genre = String(genre ?? "").trim();
}

/**
 * Toggles the read status of a Book instance.
 */
Book.prototype.toggleRead = function () {
  this.read = !this.read;
};

/**
 * Creates a new Book instance and stores it in myLibrary.
 * @param {string} title
 * @param {string} author
 * @param {number|string} pages
 * @param {boolean} read
 * @param {string} [genre=""]
 * @returns {Book}
 */
function addBookToLibrary(title, author, pages, read, genre = "") {
  const newBook = new Book(title, author, pages, read, genre);
  myLibrary.push(newBook);
  return newBook;
}

/**
 * Removes a book from myLibrary by its unique ID.
 * @param {string} bookId
 */
function removeBookFromLibrary(bookId) {
  const index = myLibrary.findIndex((book) => book.id === bookId);
  if (index !== -1) {
    myLibrary.splice(index, 1);
  }
}

/**
 * Finds a book by ID and toggles its read status via Book.prototype.toggleRead.
 * @param {string} bookId
 */
function toggleBookReadStatus(bookId) {
  const book = myLibrary.find((entry) => entry.id === bookId);
  if (book) {
    book.toggleRead();
  }
}

// ==================== DISPLAY & UI STATE ====================

const SVG_NS = "http://www.w3.org/2000/svg";

let activeFilter = "all";

const libraryGrid = document.getElementById("library-grid");
const statTotal = document.getElementById("stat-total");
const statRead = document.getElementById("stat-read");
const statUnread = document.getElementById("stat-unread");
const statPagesRead = document.getElementById("stat-pages-read");
const filterButtons = document.querySelectorAll(".filter-btn");

const newBookBtn = document.getElementById("new-book-btn");
const bookDialog = document.getElementById("book-dialog");
const bookForm = document.getElementById("book-form");
const closeDialogBtn = document.getElementById("close-dialog-btn");
const cancelDialogBtn = document.getElementById("cancel-dialog-btn");

const titleInput = document.getElementById("book-title");
const authorInput = document.getElementById("book-author");
const pagesInput = document.getElementById("book-pages");
const genreInput = document.getElementById("book-genre");
const readInput = document.getElementById("book-read");

const errorTitle = document.getElementById("error-title");
const errorAuthor = document.getElementById("error-author");
const errorPages = document.getElementById("error-pages");

/**
 * Builds an inline SVG element from static path/shape definitions.
 * @param {Array<{tag: string, attrs: Record<string, string>}>} shapes
 * @returns {SVGSVGElement}
 */
function createSvgIcon(shapes) {
  const svg = document.createElementNS(SVG_NS, "svg");
  svg.setAttribute("viewBox", "0 0 24 24");
  svg.setAttribute("fill", "none");
  svg.setAttribute("stroke", "currentColor");
  svg.setAttribute("stroke-width", "1.9");
  svg.setAttribute("stroke-linecap", "round");
  svg.setAttribute("stroke-linejoin", "round");
  svg.setAttribute("aria-hidden", "true");

  shapes.forEach(({ tag, attrs }) => {
    const node = document.createElementNS(SVG_NS, tag);
    Object.entries(attrs).forEach(([key, value]) => {
      node.setAttribute(key, value);
    });
    svg.appendChild(node);
  });

  return svg;
}

const ICONS = {
  pages: () =>
    createSvgIcon([
      { tag: "path", attrs: { d: "M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20" } },
    ]),
  check: () =>
    createSvgIcon([{ tag: "polyline", attrs: { points: "20 6 9 17 4 12" } }]),
  undo: () =>
    createSvgIcon([
      { tag: "path", attrs: { d: "M3 7v6h6" } },
      { tag: "path", attrs: { d: "M21 17a9 9 0 0 0-9-9 9 9 0 0 0-6 2.3L3 13" } },
    ]),
  trash: () =>
    createSvgIcon([
      { tag: "polyline", attrs: { points: "3 6 5 6 21 6" } },
      { tag: "path", attrs: { d: "M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" } },
    ]),
  bookEmpty: () =>
    createSvgIcon([
      { tag: "path", attrs: { d: "M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" } },
      { tag: "path", attrs: { d: "M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" } },
    ]),
};

/**
 * Returns the subset of myLibrary matching the active filter.
 * @returns {Book[]}
 */
function getFilteredBooks() {
  if (activeFilter === "read") {
    return myLibrary.filter((book) => book.read);
  }
  if (activeFilter === "unread") {
    return myLibrary.filter((book) => !book.read);
  }
  return myLibrary;
}

/**
 * Updates the summary statistics bar from myLibrary.
 */
function updateStats() {
  const totalCount = myLibrary.length;
  const readCount = myLibrary.filter((book) => book.read).length;
  const unreadCount = totalCount - readCount;
  const pagesReadCount = myLibrary.reduce(
    (sum, book) => (book.read ? sum + book.pages : sum),
    0
  );

  statTotal.textContent = String(totalCount);
  statRead.textContent = String(readCount);
  statUnread.textContent = String(unreadCount);
  statPagesRead.textContent = pagesReadCount.toLocaleString();
}

/**
 * Creates a DOM card element linked to a Book instance via data-id.
 * @param {Book} book
 * @returns {HTMLElement}
 */
function createBookCard(book) {
  const card = document.createElement("article");
  card.className = book.read ? "book-card is-read" : "book-card";
  card.dataset.id = book.id;

  // Card top metadata row (optional genre + read status badge)
  const cardTop = document.createElement("div");
  cardTop.className = "card-top";

  if (book.genre) {
    const genreTag = document.createElement("span");
    genreTag.className = "genre-tag";
    genreTag.textContent = book.genre;
    cardTop.appendChild(genreTag);
  }

  const statusBadge = document.createElement("span");
  statusBadge.className = book.read ? "status-badge is-read" : "status-badge is-unread";
  statusBadge.textContent = book.read ? "Read" : "Unread";
  cardTop.appendChild(statusBadge);

  // Title and Author
  const titleEl = document.createElement("h2");
  titleEl.className = "book-title";
  titleEl.textContent = book.title;

  const authorEl = document.createElement("p");
  authorEl.className = "book-author";
  authorEl.textContent = `by ${book.author}`;

  // Page count
  const metaEl = document.createElement("p");
  metaEl.className = "book-meta";
  metaEl.appendChild(ICONS.pages());
  const pagesLabel = book.pages === 1 ? "1 page" : `${book.pages.toLocaleString()} pages`;
  metaEl.appendChild(document.createTextNode(pagesLabel));

  // Action buttons
  const actionsEl = document.createElement("div");
  actionsEl.className = "card-actions";

  const toggleBtn = document.createElement("button");
  toggleBtn.type = "button";
  toggleBtn.className = "card-btn btn-toggle-read";
  toggleBtn.dataset.action = "toggle-read";
  toggleBtn.appendChild(book.read ? ICONS.undo() : ICONS.check());
  toggleBtn.appendChild(
    document.createTextNode(book.read ? "Mark Unread" : "Mark Read")
  );

  const removeBtn = document.createElement("button");
  removeBtn.type = "button";
  removeBtn.className = "card-btn btn-remove";
  removeBtn.dataset.action = "remove";
  removeBtn.setAttribute("aria-label", `Remove ${book.title}`);
  removeBtn.appendChild(ICONS.trash());
  removeBtn.appendChild(document.createTextNode("Remove"));

  actionsEl.append(toggleBtn, removeBtn);
  card.append(cardTop, titleEl, authorEl, metaEl, actionsEl);

  return card;
}

/**
 * Creates a contextual empty-state panel when no cards are visible.
 * @returns {HTMLElement}
 */
function createEmptyState() {
  const wrapper = document.createElement("div");
  wrapper.className = "empty-state";

  const iconBox = document.createElement("div");
  iconBox.className = "empty-icon";
  iconBox.appendChild(ICONS.bookEmpty());

  const heading = document.createElement("h2");
  heading.className = "empty-title";

  const description = document.createElement("p");
  description.className = "empty-description";

  const actionBtn = document.createElement("button");
  actionBtn.type = "button";
  actionBtn.className = "btn btn-primary";

  if (myLibrary.length === 0) {
    heading.textContent = "Your shelf is empty";
    description.textContent =
      "Add your first book to start keeping track of titles, page counts, and what you have read.";
    actionBtn.textContent = "Add Your First Book";
    actionBtn.dataset.action = "open-dialog";
  } else {
    heading.textContent =
      activeFilter === "read" ? "No finished books yet" : "All caught up!";
    description.textContent =
      activeFilter === "read"
        ? "Mark a book as read once you finish it to see it listed here."
        : "Every book in your library is marked as read.";
    actionBtn.textContent = "Show All Books";
    actionBtn.dataset.action = "reset-filter";
  }

  wrapper.append(iconBox, heading, description, actionBtn);
  return wrapper;
}

/**
 * Loops through myLibrary and renders book cards to the page.
 */
function displayBooks() {
  libraryGrid.textContent = "";
  updateStats();

  const booksToShow = getFilteredBooks();
  if (booksToShow.length === 0) {
    libraryGrid.appendChild(createEmptyState());
    return;
  }

  const fragment = document.createDocumentFragment();
  booksToShow.forEach((book) => {
    fragment.appendChild(createBookCard(book));
  });
  libraryGrid.appendChild(fragment);
}

// ==================== DIALOG & FORM HANDLING ====================

function clearFieldErrors() {
  [
    [titleInput, errorTitle],
    [authorInput, errorAuthor],
    [pagesInput, errorPages],
  ].forEach(([input, errorEl]) => {
    input.classList.remove("is-invalid");
    errorEl.textContent = "";
  });
}

function setFieldError(input, errorEl, message) {
  input.classList.add("is-invalid");
  errorEl.textContent = message;
}

function validateForm() {
  clearFieldErrors();
  let firstInvalid = null;

  const title = titleInput.value.trim();
  const author = authorInput.value.trim();
  const pagesRaw = pagesInput.value.trim();
  const pages = Number(pagesRaw);

  if (!title) {
    setFieldError(titleInput, errorTitle, "Please enter a book title.");
    firstInvalid = firstInvalid || titleInput;
  }

  if (!author) {
    setFieldError(authorInput, errorAuthor, "Please enter the author's name.");
    firstInvalid = firstInvalid || authorInput;
  }

  if (!pagesRaw || !Number.isInteger(pages) || pages < 1 || pages > 50000) {
    setFieldError(pagesInput, errorPages, "Enter a whole number between 1 and 50,000.");
    firstInvalid = firstInvalid || pagesInput;
  }

  if (firstInvalid) {
    firstInvalid.focus();
    return false;
  }

  return true;
}

function openBookDialog() {
  clearFieldErrors();
  bookForm.reset();
  bookDialog.showModal();
  titleInput.focus();
}

function closeBookDialog() {
  bookDialog.close();
  bookForm.reset();
  clearFieldErrors();
}

function setActiveFilter(filterValue) {
  activeFilter = filterValue;
  filterButtons.forEach((btn) => {
    const isSelected = btn.dataset.filter === filterValue;
    btn.classList.toggle("is-active", isSelected);
    btn.setAttribute("aria-pressed", String(isSelected));
  });
  displayBooks();
}

// ==================== EVENT LISTENERS ====================

newBookBtn.addEventListener("click", openBookDialog);
closeDialogBtn.addEventListener("click", closeBookDialog);
cancelDialogBtn.addEventListener("click", closeBookDialog);

// Close modal when clicking on the backdrop outside the dialog card
bookDialog.addEventListener("click", (event) => {
  if (event.target !== bookDialog || event.detail === 0) {
    return;
  }
  const rect = bookDialog.getBoundingClientRect();
  const clickedInDialog =
    event.clientX >= rect.left &&
    event.clientX <= rect.right &&
    event.clientY >= rect.top &&
    event.clientY <= rect.bottom;
  if (!clickedInDialog) {
    closeBookDialog();
  }
});

// Clear individual field errors as the user types
[
  [titleInput, errorTitle],
  [authorInput, errorAuthor],
  [pagesInput, errorPages],
].forEach(([input, errorEl]) => {
  input.addEventListener("input", () => {
    if (input.classList.contains("is-invalid")) {
      input.classList.remove("is-invalid");
      errorEl.textContent = "";
    }
  });
});

bookForm.addEventListener("submit", (event) => {
  event.preventDefault();
  if (!validateForm()) {
    return;
  }

  addBookToLibrary(
    titleInput.value.trim(),
    authorInput.value.trim(),
    Number(pagesInput.value),
    readInput.checked,
    genreInput.value.trim()
  );

  // If the user adds an unread book while viewing "read" (or vice versa), switch to "all" so they see it immediately
  if (
    (activeFilter === "read" && !readInput.checked) ||
    (activeFilter === "unread" && readInput.checked)
  ) {
    setActiveFilter("all");
  } else {
    displayBooks();
  }

  closeBookDialog();
});

filterButtons.forEach((btn) => {
  btn.addEventListener("click", () => {
    setActiveFilter(btn.dataset.filter);
  });
});

libraryGrid.addEventListener("click", (event) => {
  const actionTarget = event.target.closest("[data-action]");
  if (!actionTarget) {
    return;
  }

  const action = actionTarget.dataset.action;

  if (action === "open-dialog") {
    openBookDialog();
    return;
  }

  if (action === "reset-filter") {
    setActiveFilter("all");
    return;
  }

  const card = actionTarget.closest(".book-card");
  if (!card) {
    return;
  }

  const bookId = card.dataset.id;

  if (action === "toggle-read") {
    toggleBookReadStatus(bookId);
    displayBooks();
  } else if (action === "remove") {
    removeBookFromLibrary(bookId);
    displayBooks();
  }
});

// ==================== INITIAL SEED DATA ====================

addBookToLibrary("The Hobbit", "J.R.R. Tolkien", 310, true, "Fantasy");
addBookToLibrary("Dune", "Frank Herbert", 688, false, "Science Fiction");
addBookToLibrary("1984", "George Orwell", 328, true, "Dystopian");
addBookToLibrary("Project Hail Mary", "Andy Weir", 496, false, "Sci-Fi");
addBookToLibrary("The Design of Everyday Things", "Don Norman", 368, true, "Design");

displayBooks();
