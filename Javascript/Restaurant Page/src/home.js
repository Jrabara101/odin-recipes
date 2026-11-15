export default function loadHome() {
  const content = document.getElementById("content");
  if (!content) return;

  const homeContainer = document.createElement("div");
  homeContainer.classList.add("home-container");

  // Hero Banner Section
  const heroBanner = document.createElement("section");
  heroBanner.classList.add("hero-banner");

  const heroBadge = document.createElement("div");
  heroBadge.classList.add("hero-badge");
  heroBadge.innerHTML = `<span>✨</span><span>Michelin Selected &bull; Tuscan Heritage</span>`;

  const heroTitle = document.createElement("h2");
  heroTitle.classList.add("hero-title");
  heroTitle.innerHTML = `Where Generational Passion Meets the Art of <span>Authentic Italian Cuisine</span>`;

  const heroSubtitle = document.createElement("p");
  heroSubtitle.classList.add("hero-subtitle");
  heroSubtitle.textContent =
    "Nestled in the historic quarters, L'Osteria Rustica celebrates timeless Italian hospitality, daily hand-rolled pastas, wood-fired hearth delicacies, and sun-ripened organic Tuscan produce.";

  const heroActions = document.createElement("div");
  heroActions.classList.add("hero-actions");

  const menuBtn = document.createElement("button");
  menuBtn.classList.add("btn-primary");
  menuBtn.textContent = "View Our Menu";
  menuBtn.setAttribute("data-target", "menu");

  const reserveBtn = document.createElement("button");
  reserveBtn.classList.add("btn-secondary");
  reserveBtn.textContent = "Reserve a Table";
  reserveBtn.setAttribute("data-target", "contact");

  heroActions.append(menuBtn, reserveBtn);
  heroBanner.append(heroBadge, heroTitle, heroSubtitle, heroActions);

  // Culinary Highlights / Features
  const featuresSection = document.createElement("section");
  featuresSection.classList.add("features-section");

  const featuresHeader = document.createElement("div");
  featuresHeader.classList.add("section-header");
  const featuresTag = document.createElement("span");
  featuresTag.classList.add("section-tagline");
  featuresTag.textContent = "Our Artisan Philosophy";
  const featuresTitle = document.createElement("h3");
  featuresTitle.classList.add("section-title");
  featuresTitle.textContent = "Crafted With Care Every Day";
  const featuresDesc = document.createElement("p");
  featuresDesc.classList.add("section-desc");
  featuresDesc.textContent =
    "We believe dining is an intimate communion of memories, ingredients, and warmth. Every recipe is an ode to our Italian roots.";
  featuresHeader.append(featuresTag, featuresTitle, featuresDesc);

  const featuresGrid = document.createElement("div");
  featuresGrid.classList.add("features-grid");

  const featuresData = [
    {
      icon: "🍝",
      title: "Handmade Pastas",
      desc: "Extruded and rolled fresh each morning with stone-milled semolina and organic free-range egg yolks.",
    },
    {
      icon: "🔥",
      title: "Wood-Fired Hearth",
      desc: "Slow-roasted Florentine cuts and blistered Neapolitan sourdough baked over seasoned olive and oak wood.",
    },
    {
      icon: "🍇",
      title: "Curated Enoteca",
      desc: "An exclusive cellar of over 180 biodynamic and classic appellation wines from Tuscany and Piedmont.",
    },
    {
      icon: "🌿",
      title: "Zero-Kilometer Farm",
      desc: "Heritage heirloom vegetables, cold-pressed olive oils, and aged Pecorino sourced from neighboring family estates.",
    },
  ];

  featuresData.forEach((item) => {
    const card = document.createElement("div");
    card.classList.add("feature-card");

    const iconDiv = document.createElement("div");
    iconDiv.classList.add("feature-icon");
    iconDiv.textContent = item.icon;

    const cardTitle = document.createElement("h4");
    cardTitle.classList.add("feature-title");
    cardTitle.textContent = item.title;

    const cardDesc = document.createElement("p");
    cardDesc.classList.add("feature-desc");
    cardDesc.textContent = item.desc;

    card.append(iconDiv, cardTitle, cardDesc);
    featuresGrid.appendChild(card);
  });

  featuresSection.append(featuresHeader, featuresGrid);

  // Hours & Atmosphere Split
  const splitSection = document.createElement("section");
  splitSection.classList.add("home-info-split");

  // Hours Box
  const hoursBox = document.createElement("div");
  hoursBox.classList.add("info-box");

  const hoursTitle = document.createElement("h4");
  hoursTitle.classList.add("info-box-title");
  hoursTitle.innerHTML = `<span>🕒</span> Hours of Service`;

  const hoursList = document.createElement("ul");
  hoursList.classList.add("hours-list");

  const schedule = [
    { day: "Monday", time: "Closed (Staff Market Day)" },
    { day: "Tuesday – Thursday", time: "12:00 PM – 3:00 PM | 5:30 PM – 10:00 PM" },
    { day: "Friday", time: "12:00 PM – 3:00 PM | 5:30 PM – 11:00 PM" },
    { day: "Saturday", time: "11:30 AM – 11:00 PM (Continuous)" },
    { day: "Sunday", time: "11:30 AM – 9:30 PM (Sunday Roast & Pranzo)" },
  ];

  schedule.forEach((entry) => {
    const row = document.createElement("li");
    row.classList.add("hours-row");

    const daySpan = document.createElement("span");
    daySpan.classList.add("hours-day");
    daySpan.textContent = entry.day;

    const timeSpan = document.createElement("span");
    timeSpan.classList.add("hours-time");
    timeSpan.textContent = entry.time;

    row.append(daySpan, timeSpan);
    hoursList.appendChild(row);
  });

  hoursBox.append(hoursTitle, hoursList);

  // Location / Ambience Box
  const locBox = document.createElement("div");
  locBox.classList.add("info-box");

  const locTitle = document.createElement("h4");
  locTitle.classList.add("info-box-title");
  locTitle.innerHTML = `<span>📍</span> Location & Atmosphere`;

  const locContent = document.createElement("div");
  locContent.classList.add("info-address");
  locContent.innerHTML = `
    <p><strong>Historic Florence District:</strong><br>Via dei Bardi, 42, 50125 Firenze FI, Italy</p>
    <p>Situated a brief stroll from the iconic Ponte Vecchio, overlooking the tranquil waters of the Arno River.</p>
    <p>Our dining room features 16th-century stone archways, candlelit oak tables, and an intimate pergola terrace shaded by fragrant wisteria vines.</p>
  `;

  locBox.append(locTitle, locContent);
  splitSection.append(hoursBox, locBox);

  // Review Quote
  const quoteSection = document.createElement("section");
  quoteSection.classList.add("quote-card");
  quoteSection.innerHTML = `
    “The finest pappardelle al ragù d'anatra in Florence. Every single bite feels like stepping into a sun-drenched Tuscan hillside home. An absolute triumph of warmth and culinary perfection.”
    <span class="quote-author">— Lorenzo De Luca, Guida Gastronomica Fiorentina</span>
  `;

  // Assemble full home view
  homeContainer.append(heroBanner, featuresSection, splitSection, quoteSection);
  content.appendChild(homeContainer);
}
