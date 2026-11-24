# CV Application

A React CV / résumé builder built for [The Odin Project — CV Application](https://www.theodinproject.com/lessons/react-new-cv-application).

## Features

- **General Information**: Edit and submit full name, optional professional title, email, phone number, and optional location.
- **Educational Experience**: Add, edit, remove, and submit multiple educational entries (school name, title of study, date of study).
- **Practical Experience**: Add, edit, remove, and submit multiple roles (company name, position title, date from/until, and main responsibilities formatted into bullet points).
- **Per-Section & Whole-CV Controls**: Submit any section to replace its form inputs with semantic HTML elements, click Edit to restore the inputs pre-populated with previously submitted values, or use **Submit All / Edit All**, **Load Example**, **Clear**, and **Print / PDF**.
- **Print-Ready Preview**: Editorial A4-proportioned CV sheet with dedicated `@media print` styling.

## Project Structure

```text
src/
├── components/
│   ├── CVPreview.jsx
│   ├── Education.jsx
│   ├── Experience.jsx
│   ├── GeneralInfo.jsx
│   └── Header.jsx
├── data/
│   └── initialData.js
├── styles/
│   ├── App.css
│   ├── CVPreview.css
│   ├── Header.css
│   ├── SectionCard.css
│   └── global.css
├── utils/
│   └── formatters.js
├── App.jsx
└── main.jsx
```

## Development

```bash
npm install
npm run dev
npm run lint
npm run build
```
