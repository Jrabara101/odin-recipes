# L'Osteria Rustica — Restaurant Page

An authentic, artisanal Italian trattoria website built with vanilla JavaScript, modular ES6 design, and Webpack for [The Odin Project](https://www.theodinproject.com/lessons/javascript-restaurant-page).

## ✨ Features

- **100% Dynamic DOM Rendering:** The website contents inside `#content` are generated entirely using JavaScript modules and DOM manipulation.
- **Tabbed Browsing:**
  - **Home:** Hero banner with call-to-actions, artisanal highlights, operating hours, and location atmosphere.
  - **Menu:** Categorized Italian dining menu (Antipasti, Primi, Secondi, Pizze, Dolci) with prices, descriptions, and dietary badges (Chef's Pick, Vegetarian, Popular).
  - **About:** The story of the restaurant, kitchen philosophy, culinary statistics, and bios for the head chef, pastry chef, and sommelier.
  - **Contact:** Restaurant contact details, hours, and an interactive online reservation booking form with immediate feedback.
- **Modern Webpack 5 Pipeline:** Bundles CSS, modern JavaScript, and HTML templates with hot reloading and asset optimization.
- **Responsive & Elegant Design:** Custom typography, warm Italian palette (tuscan gold, terracotta, rich charcoal), and responsive grid layouts for desktop, tablet, and mobile.

## 🛠️ Tech Stack

- Vanilla JavaScript (ES6 Modules)
- Webpack 5 + Webpack CLI
- Webpack Dev Server
- HTML Webpack Plugin
- CSS3 & CSS Custom Properties

## 🚀 Getting Started

### Prerequisites

Ensure you have [Node.js](https://nodejs.org/) installed on your machine.

### Installation

1. Navigate to the project directory:
   ```bash
   cd "Javascript/Restaurant Page"
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

### Development Server

Start the development server with live reloading:
```bash
npm start
```
Open `http://localhost:8080` (or the terminal port provided) in your browser.

### Production Build

Compile and bundle the project into the `dist/` directory:
```bash
npm run build
```

## 🌐 GitHub Pages Deployment Guide

To deploy the bundled output from `dist/` to GitHub Pages:

```bash
# 1. Ensure all changes are committed on main
git add .
git commit -m "feat: complete Restaurant Page project"

# 2. Build the production bundle
npm run build

# 3. Create or switch to gh-pages branch
git branch gh-pages
git checkout gh-pages && git merge main --no-edit

# 4. Commit and push the dist directory as subtree (or deploy dist)
git add "Javascript/Restaurant Page/dist" -f && git commit -m "Deployment commit"
git subtree push --prefix "Javascript/Restaurant Page/dist" origin gh-pages
git checkout main
```
