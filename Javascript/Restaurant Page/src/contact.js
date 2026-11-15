export default function loadContact() {
  const content = document.getElementById("content");
  if (!content) return;

  const contactContainer = document.createElement("div");
  contactContainer.classList.add("contact-container");

  // Contact Header
  const contactHeader = document.createElement("div");
  contactHeader.classList.add("section-header");

  const contactTag = document.createElement("span");
  contactTag.classList.add("section-tagline");
  contactTag.textContent = "Contattaci &bull; Table Booking & Inquiries";

  const contactTitle = document.createElement("h2");
  contactTitle.classList.add("section-title");
  contactTitle.textContent = "Reserve Your Experience";

  const contactDesc = document.createElement("p");
  contactDesc.classList.add("section-desc");
  contactDesc.textContent =
    "Whether planning an intimate candlelit dinner or a celebration with loved ones, we look forward to welcoming you into our dining room.";

  contactHeader.append(contactTag, contactTitle, contactDesc);

  // Main Split Layout
  const layout = document.createElement("div");
  layout.classList.add("contact-layout");

  // Left Side: Contact Information Cards
  const infoPanel = document.createElement("div");
  infoPanel.classList.add("contact-info-panel");

  const infoCards = [
    {
      icon: "📍",
      title: "Our Address",
      text: "Via dei Bardi, 42<br>50125 Firenze FI, Italy<br><em>Steps from Ponte Vecchio along the Arno River</em>",
    },
    {
      icon: "📞",
      title: "Direct Telephone",
      text: "Main Line: +39 055 234 8891<br>Mobile / WhatsApp: +39 349 812 7700<br><em>Lines open Tuesday – Sunday from 10:00 AM</em>",
    },
    {
      icon: "✉️",
      title: "Electronic Inquiries",
      text: "Reservations: prenotazioni@osteriarustica.com<br>Private Events & Wine Tastings: events@osteriarustica.com",
    },
    {
      icon: "🍷",
      title: "Private Dining & Events",
      text: "Our 16th-century wine cellar room accommodates up to 24 guests for bespoke multi-course menus and wine pairings.",
    },
  ];

  infoCards.forEach((c) => {
    const card = document.createElement("div");
    card.classList.add("contact-card");

    const iconDiv = document.createElement("div");
    iconDiv.classList.add("contact-icon");
    iconDiv.textContent = c.icon;

    const cardContent = document.createElement("div");
    cardContent.classList.add("contact-card-content");

    const titleH4 = document.createElement("h4");
    titleH4.textContent = c.title;

    const descP = document.createElement("p");
    descP.innerHTML = c.text;

    cardContent.append(titleH4, descP);
    card.append(iconDiv, cardContent);
    infoPanel.appendChild(card);
  });

  // Right Side: Reservation Form Panel
  const formPanel = document.createElement("div");
  formPanel.classList.add("reservation-panel");

  const formH3 = document.createElement("h3");
  formH3.textContent = "Book a Table Online";

  const formSubtitle = document.createElement("p");
  formSubtitle.textContent =
    "For parties larger than 8 guests, please reach out directly via telephone or email.";

  const form = document.createElement("form");
  form.classList.add("reservation-form");

  // Form Rows
  // Row 1: Name & Email
  const row1 = document.createElement("div");
  row1.classList.add("form-row");

  const nameGroup = document.createElement("div");
  nameGroup.classList.add("form-group");
  const nameLabel = document.createElement("label");
  nameLabel.setAttribute("for", "res-name");
  nameLabel.textContent = "Full Name *";
  const nameInput = document.createElement("input");
  nameInput.type = "text";
  nameInput.id = "res-name";
  nameInput.required = true;
  nameInput.placeholder = "e.g. Leonardo Bianchi";
  nameGroup.append(nameLabel, nameInput);

  const emailGroup = document.createElement("div");
  emailGroup.classList.add("form-group");
  const emailLabel = document.createElement("label");
  emailLabel.setAttribute("for", "res-email");
  emailLabel.textContent = "Email Address *";
  const emailInput = document.createElement("input");
  emailInput.type = "email";
  emailInput.id = "res-email";
  emailInput.required = true;
  emailInput.placeholder = "leonardo@example.com";
  emailGroup.append(emailLabel, emailInput);

  row1.append(nameGroup, emailGroup);

  // Row 2: Phone & Guests
  const row2 = document.createElement("div");
  row2.classList.add("form-row");

  const phoneGroup = document.createElement("div");
  phoneGroup.classList.add("form-group");
  const phoneLabel = document.createElement("label");
  phoneLabel.setAttribute("for", "res-phone");
  phoneLabel.textContent = "Phone Number *";
  const phoneInput = document.createElement("input");
  phoneInput.type = "tel";
  phoneInput.id = "res-phone";
  phoneInput.required = true;
  phoneInput.placeholder = "+39 ...";
  phoneGroup.append(phoneLabel, phoneInput);

  const guestsGroup = document.createElement("div");
  guestsGroup.classList.add("form-group");
  const guestsLabel = document.createElement("label");
  guestsLabel.setAttribute("for", "res-guests");
  guestsLabel.textContent = "Number of Guests *";
  const guestsSelect = document.createElement("select");
  guestsSelect.id = "res-guests";
  [
    "1 Guest (Solo Dining)",
    "2 Guests (Table for Two)",
    "3 Guests",
    "4 Guests",
    "5 Guests",
    "6 Guests",
    "7-8 Guests",
  ].forEach((text, i) => {
    const opt = document.createElement("option");
    opt.value = i + 1;
    opt.textContent = text;
    if (i === 1) opt.selected = true;
    guestsSelect.appendChild(opt);
  });
  guestsGroup.append(guestsLabel, guestsSelect);

  row2.append(phoneGroup, guestsGroup);

  // Row 3: Date & Time
  const row3 = document.createElement("div");
  row3.classList.add("form-row");

  const dateGroup = document.createElement("div");
  dateGroup.classList.add("form-group");
  const dateLabel = document.createElement("label");
  dateLabel.setAttribute("for", "res-date");
  dateLabel.textContent = "Preferred Date *";
  const dateInput = document.createElement("input");
  dateInput.type = "date";
  dateInput.id = "res-date";
  dateInput.required = true;
  // default to tomorrow
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  dateInput.value = tomorrow.toISOString().split("T")[0];
  dateGroup.append(dateLabel, dateInput);

  const timeGroup = document.createElement("div");
  timeGroup.classList.add("form-group");
  const timeLabel = document.createElement("label");
  timeLabel.setAttribute("for", "res-time");
  timeLabel.textContent = "Seating Time *";
  const timeSelect = document.createElement("select");
  timeSelect.id = "res-time";
  [
    "12:30 PM (Pranzo / Lunch)",
    "1:15 PM (Pranzo / Lunch)",
    "2:00 PM (Pranzo / Lunch)",
    "6:30 PM (Early Dinner)",
    "7:30 PM (Dinner First Seating)",
    "8:30 PM (Dinner Prime Seating)",
    "9:30 PM (Late Dinner)",
  ].forEach((t) => {
    const opt = document.createElement("option");
    opt.value = t;
    opt.textContent = t;
    if (t.includes("8:30")) opt.selected = true;
    timeSelect.appendChild(opt);
  });
  timeGroup.append(timeLabel, timeSelect);

  row3.append(dateGroup, timeGroup);

  // Row 4: Seating Area
  const seatingGroup = document.createElement("div");
  seatingGroup.classList.add("form-group");
  const seatingLabel = document.createElement("label");
  seatingLabel.setAttribute("for", "res-seating");
  seatingLabel.textContent = "Seating Area Preference";
  const seatingSelect = document.createElement("select");
  seatingSelect.id = "res-seating";
  [
    "Vaulted Dining Hall (Candlelit stone room)",
    "Garden Pergola Terrace (Weather permitting)",
    "Chef's Counter (View of the pasta kitchen)",
    "First Available Table",
  ].forEach((area) => {
    const opt = document.createElement("option");
    opt.value = area;
    opt.textContent = area;
    seatingSelect.appendChild(opt);
  });
  seatingGroup.append(seatingLabel, seatingSelect);

  // Row 5: Notes / Dietary
  const notesGroup = document.createElement("div");
  notesGroup.classList.add("form-group");
  const notesLabel = document.createElement("label");
  notesLabel.setAttribute("for", "res-notes");
  notesLabel.textContent = "Special Requests or Dietary Requirements";
  const notesArea = document.createElement("textarea");
  notesArea.id = "res-notes";
  notesArea.rows = 3;
  notesArea.placeholder =
    "Please let us know of any allergies, vegetarian/vegan preferences, or special anniversaries...";
  notesGroup.append(notesLabel, notesArea);

  // Submit Button
  const submitBtn = document.createElement("button");
  submitBtn.type = "submit";
  submitBtn.classList.add("form-submit-btn");
  submitBtn.textContent = "Confirm Reservation Request";

  // Alert Box for feedback
  const alertBox = document.createElement("div");
  alertBox.classList.add("form-alert");

  form.append(row1, row2, row3, seatingGroup, notesGroup, submitBtn, alertBox);

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const guestName = nameInput.value.trim() || "Guest";
    const selectedDate = dateInput.value;
    const selectedTime = timeSelect.value;
    const partySize = guestsSelect.value;

    alertBox.className = "form-alert success";
    alertBox.innerHTML = `
      <strong>Grazie mille, ${guestName}!</strong><br>
      Your reservation request for <strong>${partySize} guest(s)</strong> on <strong>${selectedDate}</strong> at <strong>${selectedTime}</strong> has been received. Our maître d' will review and send a confirmation to <em>${emailInput.value}</em> shortly.
    `;

    form.reset();
    dateInput.value = tomorrow.toISOString().split("T")[0];
    timeSelect.value = "8:30 PM (Dinner Prime Seating)";
    guestsSelect.value = "2";
  });

  formPanel.append(formH3, formSubtitle, form);
  layout.append(infoPanel, formPanel);

  contactContainer.append(contactHeader, layout);
  content.appendChild(contactContainer);
}
