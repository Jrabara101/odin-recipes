import '../styles/Header.css';

function Header({
  allSubmitted,
  submittedCount,
  totalSections,
  onSubmitAll,
  onEditAll,
  onLoadExample,
  onClear,
  onPrint,
}) {
  return (
    <header className="app-header no-print">
      <div className="app-header-inner">
        <div className="brand-group">
          <div className="brand-mark" aria-hidden="true">
            CV
          </div>
          <div className="brand-text">
            <h1 className="brand-title">CV Application</h1>
            <p className="brand-subtitle">Editorial Résumé Builder</p>
          </div>
          <span
            className={`progress-chip ${
              allSubmitted ? 'progress-chip--complete' : ''
            }`}
          >
            {submittedCount}/{totalSections} submitted
          </span>
        </div>

        <div className="header-actions">
          {allSubmitted ? (
            <button
              type="button"
              className="toolbar-btn toolbar-btn--primary"
              onClick={onEditAll}
            >
              Edit All
            </button>
          ) : (
            <button
              type="button"
              className="toolbar-btn toolbar-btn--primary"
              onClick={onSubmitAll}
            >
              Submit All
            </button>
          )}
          <button type="button" className="toolbar-btn" onClick={onLoadExample}>
            Load Example
          </button>
          <button
            type="button"
            className="toolbar-btn toolbar-btn--danger"
            onClick={onClear}
          >
            Clear
          </button>
          <button type="button" className="toolbar-btn" onClick={onPrint}>
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              aria-hidden="true"
            >
              <polyline points="6 9 6 2 18 2 18 9" />
              <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2" />
              <rect x="6" y="14" width="12" height="8" />
            </svg>
            Print / PDF
          </button>
        </div>
      </div>
    </header>
  );
}

export default Header;
