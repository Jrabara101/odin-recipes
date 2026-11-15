export default function loadMenu() {
  const content = document.getElementById("content");
  if (!content) return;

  const menuContainer = document.createElement("div");
  menuContainer.classList.add("menu-container");

  // Menu Header
  const menuHeader = document.createElement("div");
  menuHeader.classList.add("section-header");

  const menuTag = document.createElement("span");
  menuTag.classList.add("section-tagline");
  menuTag.textContent = "I Nostri Sapori &bull; Seasonal Carta";

  const menuTitle = document.createElement("h2");
  menuTitle.classList.add("section-title");
  menuTitle.textContent = "Handcrafted Menu";

  const menuDesc = document.createElement("p");
  menuDesc.classList.add("section-desc");
  menuDesc.textContent =
    "Every dish reflects our devotion to time-honored Italian culinary craft, prepared daily using pristine seasonal ingredients from local Tuscan producers.";

  menuHeader.append(menuTag, menuTitle, menuDesc);
  menuContainer.appendChild(menuHeader);

  // Menu Data Structure
  const menuData = [
    {
      category: "Antipasti & Small Plates",
      italian: "Per Cominciare",
      description: "Artisanal starters to awaken the palate, best shared around the table.",
      dishes: [
        {
          name: "Burrata Pugliese con Fichi",
          italian: "Pugliese Burrata with Caramelized Figs",
          price: "€16",
          desc: "Creamy hand-tied burrata, caramelized black mission figs, toasted pine nuts, 18-year aged Modena balsamic, warm grilled sourdough.",
          badges: ["Vegetarian", "Popular"],
        },
        {
          name: "Carpaccio di Chianina",
          italian: "Heritage Chianina Beef Carpaccio",
          price: "€19",
          desc: "Paper-thin raw Tuscan Chianina beef, shaved 28-month Parmigiano-Reggiano, wild baby rocket, crisp capers, cold-pressed green olive oil.",
          badges: ["Chef's Pick"],
        },
        {
          name: "Arancini al Tartufo & Taleggio",
          italian: "Crisp Truffled Rice Croquettes",
          price: "€15",
          desc: "Golden Carnaroli saffron risotto balls filled with molten Taleggio cheese, served with a silky black summer truffle aioli.",
          badges: ["Vegetarian"],
        },
        {
          name: "Polpo Grigliato al Rosmarino",
          italian: "Charred Mediterranean Octopus",
          price: "€21",
          desc: "Slow-tenderized then flame-seared octopus, creamy cannellini bean purée, blistered Datterini tomatoes, lemon herb salsa verde.",
          badges: ["Chef's Pick"],
        },
      ],
    },
    {
      category: "Primi & Hand-Rolled Pastas",
      italian: "La Pasta Fatta in Casa",
      description: "Hand-rolled and extruded daily in our glass kitchen using Italian stone-ground semolina.",
      dishes: [
        {
          name: "Pappardelle al Ragù di Cinghiale",
          italian: "Wild Boar Ribbon Pasta",
          price: "€26",
          desc: "Wide egg ribbons tossed in our signature 12-hour braised Tuscan wild boar ragù, fresh juniper, rosemary, and aged Pecorino di Pienza.",
          badges: ["Chef's Pick", "Popular"],
        },
        {
          name: "Tagliolini al Tartufo Nero",
          italian: "Handcut Tagliolini with Black Truffle",
          price: "€29",
          desc: "Delicate 30-yolk fresh tagliolini swirled in cultured mountain butter, parmigiano cream, and shaved fresh black truffle at table.",
          badges: ["Popular"],
        },
        {
          name: "Ravioli di Zucca e Amaretti",
          italian: "Delicata Squash & Ricotta Ravioli",
          price: "€23",
          desc: "House-made parcels filled with roasted sweet squash and sheep's milk ricotta, served in bubbling hazelnut brown butter and crispy sage.",
          badges: ["Vegetarian"],
        },
        {
          name: "Gnocchi alla Sorrentina",
          italian: "Pillowy Handmade Potato Gnocchi",
          price: "€22",
          desc: "Featherlight potato dumplings baked in San Marzano tomato sugo, molten buffalo mozzarella, sweet basil, and toasted garlic oil.",
          badges: ["Vegetarian"],
        },
      ],
    },
    {
      category: "Secondi & Wood-Fired Hearth",
      italian: "Dalla Griglia & Dal Fuoco",
      description: "Cooked to perfection over sweet olive and oak embers inside our traditional brick hearth.",
      dishes: [
        {
          name: "Bistecca alla Fiorentina (1.2kg)",
          italian: "Classic Florentine T-Bone (For Two)",
          price: "€82",
          desc: "Dry-aged heritage Chianina beef grilled rare over seasoned wood embers, served with flaked Maldon salt, rosemary oil, and roasted Tuscan beans.",
          badges: ["Chef's Pick"],
        },
        {
          name: "Branzino al Cartoccio",
          italian: "Whole Mediterranean Sea Bass",
          price: "€34",
          desc: "Parchment-baked wild sea bass with baby fennel, taggiasca olives, caper berries, white wine, and roasted fingerling potatoes.",
          badges: [],
        },
        {
          name: "Pollo al Mattone",
          italian: "Brick-Pressed Farmhouse Chicken",
          price: "€28",
          desc: "Crispy-skinned pasture-raised half chicken flattened under Tuscan terracotta tiles with fresh garlic, chili, lemon, and salsa al dragoncello.",
          badges: ["Popular"],
        },
      ],
    },
    {
      category: "Pizze Tradizionali",
      italian: "Farina, Acqua, Lievito & Passione",
      description: "48-hour slow fermented sourdough crust, baked in our 850°F volcanic stone oven.",
      dishes: [
        {
          name: "Margherita Verace D.O.P.",
          italian: "Neapolitan Classic",
          price: "€17",
          desc: "San Marzano D.O.P. tomatoes, hand-torn Campania buffalo mozzarella, fresh sweet basil leaves, Sicilian extra virgin olive oil.",
          badges: ["Vegetarian", "Popular"],
        },
        {
          name: "Diavola di Spilinga",
          italian: "Spicy Calabrian Salami & Nduja",
          price: "€20",
          desc: "Crushed tomatoes, smoked provola cheese, spicy Ventricina salami, dollops of spicy Calabrian nduja, hot wildflower honey.",
          badges: ["Popular"],
        },
        {
          name: "Quattro Formaggi & Tartufo",
          italian: "Four Artisan Cheeses with Truffle",
          price: "€22",
          desc: "Fior di latte, Gorgonzola dolce, aged Taleggio, Pecorino Romano, caramelized shallots, wild forest mushrooms, and white truffle essence.",
          badges: ["Vegetarian"],
        },
      ],
    },
    {
      category: "Dolci Artigianali",
      italian: "La Dolce Vita",
      description: "Handcrafted Italian desserts and treats to conclude your feast.",
      dishes: [
        {
          name: "Tiramisù della Nonna",
          italian: "Generational Family Tiramisù",
          price: "€11",
          desc: "Savoiardi ladyfingers soaked in dark espresso and Marsala wine, layered with airy whipped mascarpone and Valrhona cocoa dust.",
          badges: ["Popular"],
        },
        {
          name: "Torta all'Olio d'Oliva e Agrumi",
          italian: "Tuscan Olive Oil & Blood Orange Cake",
          price: "€11",
          desc: "Moist sponge infused with fresh estate olive oil and citrus zest, accompanied by Fior di Latte gelato and candied peel.",
          badges: ["Vegetarian"],
        },
        {
          name: "Panna Cotta alla Vaniglia",
          italian: "Tahitian Vanilla Bean Panna Cotta",
          price: "€10",
          desc: "Silky cooked cream delicately perfumed with organic vanilla beans, topped with a tart raspberry and wild blackberry reduction.",
          badges: ["Vegetarian"],
        },
      ],
    },
  ];

  menuData.forEach((sectionData) => {
    const section = document.createElement("section");
    section.classList.add("menu-category-section");

    const categoryHeader = document.createElement("div");
    categoryHeader.classList.add("category-header");

    const titleH3 = document.createElement("h3");
    titleH3.classList.add("category-title");
    titleH3.innerHTML = `<span>${sectionData.category}</span>`;

    const descSpan = document.createElement("span");
    descSpan.classList.add("category-desc");
    descSpan.textContent = sectionData.italian;

    categoryHeader.append(titleH3, descSpan);

    const dishesGrid = document.createElement("div");
    dishesGrid.classList.add("dishes-grid");

    sectionData.dishes.forEach((dish) => {
      const dishCard = document.createElement("div");
      dishCard.classList.add("dish-card");

      const dishHeader = document.createElement("div");
      dishHeader.classList.add("dish-header");

      const titleGroup = document.createElement("div");
      const dishName = document.createElement("h4");
      dishName.classList.add("dish-name");
      dishName.textContent = dish.name;

      const dishItalian = document.createElement("span");
      dishItalian.classList.add("dish-italian");
      dishItalian.textContent = dish.italian;

      titleGroup.append(dishName, dishItalian);

      const dishPrice = document.createElement("span");
      dishPrice.classList.add("dish-price");
      dishPrice.textContent = dish.price;

      dishHeader.append(titleGroup, dishPrice);

      const dishDesc = document.createElement("p");
      dishDesc.classList.add("dish-desc");
      dishDesc.textContent = dish.desc;

      const badgesContainer = document.createElement("div");
      badgesContainer.classList.add("dish-badges");

      dish.badges.forEach((bText) => {
        const badge = document.createElement("span");
        badge.classList.add("badge");
        if (bText.includes("Chef")) {
          badge.classList.add("badge-chef");
        } else if (bText.includes("Vegetarian")) {
          badge.classList.add("badge-veg");
        } else {
          badge.classList.add("badge-popular");
        }
        badge.textContent = bText;
        badgesContainer.appendChild(badge);
      });

      dishCard.append(dishHeader, dishDesc, badgesContainer);
      dishesGrid.appendChild(dishCard);
    });

    section.append(categoryHeader, dishesGrid);
    menuContainer.appendChild(section);
  });

  content.appendChild(menuContainer);
}
