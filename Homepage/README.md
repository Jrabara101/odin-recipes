# The Odin Project — Project: Homepage (Personal Portfolio)

A responsive homepage and personal portfolio website designed and implemented as the capstone project for **The Odin Project: Advanced HTML and CSS** course.

- **Course:** The Odin Project — Advanced HTML and CSS
- **Assignment:** [Project: Homepage](https://www.theodinproject.com/lessons/advanced-html-and-css-homepage)
- **Viewport Support:** Fully responsive across all devices from **320px to 1920px+** width.

---

## 🎨 Design & Layout Overview

The project matches the provided design brief across all three specified viewports (**Desktop**, **Tablet**, and **Mobile**):

| Viewport | Target Width | Layout Strategy |
|:---|:---|:---|
| **Desktop** | `1081px` – `1920px+` | Overlapping hero card with portrait, 3-column project grid, 2-column contact footer |
| **Tablet** | `768px` – `1080px` | Floated hero portrait with wrapped "About me" text, top-right header name, 2-column project grid |
| **Mobile** | `320px` – `767px` | Stacked single-column layout, centered typography, full-width photo header & footer |

---

## 📁 File Structure

```text
Homepage/
├── index.html                     # Semantic HTML5 document structure
├── style.css                      # Modern CSS (Custom Properties, Grid, Flexbox, Media Queries)
├── README.md                      # Project documentation and specifications
└── assets/
    ├── design/                    # High-resolution design reference specifications
    │   ├── portfolio-desktop.png  # Desktop layout (1440px / 2880px retina)
    │   ├── portfolio-tablet.png   # Tablet layout (1024px / 2048px retina)
    │   └── portfolio-mobile.png   # Mobile layout (375px / 750px retina)
    ├── icons/                     # Vector SVG icons (Devicon & Material Design Icons)
    │   ├── email.svg              # MDI email envelope icon
    │   ├── github.svg             # Devicon GitHub octocat
    │   ├── linkedin.svg           # Devicon LinkedIn icon
    │   ├── open-in-new.svg        # MDI external link icon
    │   ├── phone.svg              # MDI phone icon
    │   └── twitter.svg            # Twitter / X brand icon
    └── images/                    # High-resolution photo assets
        ├── hero-portrait-clean.jpg # Ashley Williams portrait (clean background)
        └── contact-portrait.jpg    # Ashley Williams smiling with laptop & phone
```

---

## 🌟 Key Features & Implementation Highlights

### 1. Advanced Responsive Layouts
- **CSS Grid & Flexbox:** Dynamic grid tracks adapt automatically from 1 column (mobile) to 2 columns (tablet) to 3 columns (desktop).
- **Angled Clip-Path Hero Banner:** The vibrant cyan (`#0891b2`) hero background is created with modern `clip-path: polygon(...)`, providing sharp, scalable geometric angles without relying on raster images.
- **Adaptive Text & Typography:** Google Fonts (`Playfair Display` serif for editorial headings, and `Roboto` sans-serif for clean body readability).
- **Tablet Text Wrap:** Uses intelligent float and negative margins to allow "About me" content to wrap around the portrait naturally on tablet screens, exactly matching the Odin reference.

### 2. Micro-Interactions & Hover Effects
- **Project Card Elevation:** Smooth `transform: translateY(-5px)` and box-shadow elevation transitions on hover.
- **Icon Actions:** Interactive hover scaling on GitHub repository and Live Preview links.
- **Accessible Links:** `aria-label` attributes and SVG `aria-hidden` attributes for full screen-reader compliance.

### 3. Palette & Design Specs
- **Primary Accent:** `#0891b2` (Cyan 600)
- **Dark Text:** `#1e293b` (Slate 800)
- **Muted Text:** `#64748b` (Slate 500)
- **Project 1:** `#9e1c1c` (Crimson)
- **Project 2:** `#7c75ca` (Periwinkle / Indigo)
- **Project 3:** `#5e8f4d` (Leaf Green)
- **Project 4:** `#c363b4` (Orchid / Magenta)
- **Project 5:** `#d88f39` (Amber / Golden Orange)
- **Project 6:** `#4ba2d2` (Ocean Blue)

---

## 🚀 How to View Locally

Simply open `index.html` in any modern web browser:

```bash
# In Windows PowerShell:
Start-Process "Homepage/index.html"
```

Or serve with Python's built-in HTTP server:

```bash
cd Homepage
python -m http.server 8000
# Open http://localhost:8000 in your browser
```
