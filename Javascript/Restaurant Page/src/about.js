export default function loadAbout() {
  const content = document.getElementById("content");
  if (!content) return;

  const aboutContainer = document.createElement("div");
  aboutContainer.classList.add("about-container");

  // About Header
  const aboutHeader = document.createElement("div");
  aboutHeader.classList.add("section-header");

  const aboutTag = document.createElement("span");
  aboutTag.classList.add("section-tagline");
  aboutTag.textContent = "Chi Siamo &bull; Heritage & Passion";

  const aboutTitle = document.createElement("h2");
  aboutTitle.classList.add("section-title");
  aboutTitle.textContent = "The Story Behind L'Osteria";

  const aboutDesc = document.createElement("p");
  aboutDesc.classList.add("section-desc");
  aboutDesc.textContent =
    "A journey born from childhood kitchens, rustic clay ovens, and an unwavering commitment to the timeless soul of authentic Italian cooking.";

  aboutHeader.append(aboutTag, aboutTitle, aboutDesc);

  // Story Section with Narrative and Highlights
  const storySection = document.createElement("section");
  storySection.classList.add("story-section");

  const storyText = document.createElement("div");
  storyText.classList.add("story-text");

  const storyH3 = document.createElement("h3");
  storyH3.textContent = "Generations of Flavor Under Historic Tuscan Arches";

  const storyP1 = document.createElement("p");
  storyP1.textContent =
    "Founded in 2014 by husband-and-wife duo Matteo and Giuliana Moretti, L'Osteria Rustica began as a humble dream along the cobbled banks of the Arno River. Matteo was raised in the sun-drenched hills of Montepulciano, where his grandmother taught him that genuine cooking requires only three virtues: patience, honest ingredients, and unbounded love.";

  const storyP2 = document.createElement("p");
  storyP2.textContent =
    "Today, our kitchen remains true to those fundamental roots. Every single morning begins before dawn: sacks of stone-ground heritage grain arrive from certified organic mills, eggs from free-roaming hens are folded into golden pasta dough, and our hearth is stoked with fragrant oak and olive embers.";

  const storyP3 = document.createElement("p");
  storyP3.textContent =
    "We don't chase fleeting culinary trends. Instead, we elevate rustic comfort: hearty wild boar ragù simmered for half a day, fresh hand-tied mozzarella, and seasonal vegetables picked hours before they grace your plate.";

  storyText.append(storyH3, storyP1, storyP2, storyP3);

  // Stat Highlight Box
  const statBox = document.createElement("div");
  statBox.classList.add("story-highlight-box");

  const stats = [
    { num: "12+", label: "Years bringing warmth and authentic flavor to Florence" },
    { num: "100%", label: "Handmade daily pastas & naturally leavened sourdough" },
    { num: "180+", label: "Boutique biodynamic & regional Italian wines in cellar" },
    { num: "0 km", label: "Seasonal vegetables sourced directly from family farms" },
  ];

  stats.forEach((s) => {
    const item = document.createElement("div");
    item.classList.add("stat-item");

    const numSpan = document.createElement("span");
    numSpan.classList.add("stat-num");
    numSpan.textContent = s.num;

    const labelSpan = document.createElement("span");
    labelSpan.classList.add("stat-label");
    labelSpan.textContent = s.label;

    item.append(numSpan, labelSpan);
    statBox.appendChild(item);
  });

  storySection.append(storyText, statBox);

  // The Culinary Team
  const teamSection = document.createElement("section");
  teamSection.classList.add("team-section");

  const teamHeader = document.createElement("div");
  teamHeader.classList.add("section-header");

  const teamTag = document.createElement("span");
  teamTag.classList.add("section-tagline");
  teamTag.textContent = "The Artisans";

  const teamTitle = document.createElement("h3");
  teamTitle.classList.add("section-title");
  teamTitle.textContent = "Meet Our Kitchen & Cellar Family";

  teamHeader.append(teamTag, teamTitle);

  const teamGrid = document.createElement("div");
  teamGrid.classList.add("team-grid");

  const teamMembers = [
    {
      initials: "MM",
      name: "Matteo Moretti",
      role: "Executive Chef & Co-Founder",
      bio: "Trained under classical Florentine masters with over 20 years dedicated to the preservation of rustic Tuscan hearth cuisine and whole-animal craftsmanship.",
    },
    {
      initials: "GM",
      name: "Giuliana Moretti",
      role: "Master Pastry Chef & Co-Founder",
      bio: "A champion of heritage Italian baking and slow-churned gelato. Giuliana crafts our legendary tiramisù and delicate morning brioches with artistry.",
    },
    {
      initials: "AR",
      name: "Alessandro Ricci",
      role: "Head Sommelier & Enoteca Director",
      bio: "Certified AIS Sommelier with an intimate knowledge of micro-terroirs across Chianti, Montalcino, and Bolgheri. Alessandro guides each table to perfection.",
    },
  ];

  teamMembers.forEach((member) => {
    const card = document.createElement("div");
    card.classList.add("team-card");

    const avatar = document.createElement("div");
    avatar.classList.add("team-avatar");
    avatar.textContent = member.initials;

    const mName = document.createElement("h4");
    mName.classList.add("team-name");
    mName.textContent = member.name;

    const mRole = document.createElement("span");
    mRole.classList.add("team-role");
    mRole.textContent = member.role;

    const mBio = document.createElement("p");
    mBio.classList.add("team-bio");
    mBio.textContent = member.bio;

    card.append(avatar, mName, mRole, mBio);
    teamGrid.appendChild(card);
  });

  teamSection.append(teamHeader, teamGrid);

  aboutContainer.append(aboutHeader, storySection, teamSection);
  content.appendChild(aboutContainer);
}
