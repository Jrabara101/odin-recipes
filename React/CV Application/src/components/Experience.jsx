import '../styles/SectionCard.css';
import { formatDateRange, parseResponsibilities } from '../utils/formatters';

function Experience({
  draftList,
  submittedList,
  isEditing,
  onChangeItem,
  onAddItem,
  onRemoveItem,
  onSubmit,
  onEdit,
  onCancel,
}) {
  const displayCount = isEditing ? draftList.length : submittedList.length;

  function handleFormSubmit(event) {
    event.preventDefault();
    onSubmit();
  }

  return (
    <section className="section-card" aria-labelledby="experience-heading">
      <div className="section-card-header">
        <div className="section-heading-group">
          <span className="section-icon" aria-hidden="true">
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <rect x="2" y="7" width="20" height="14" rx="2" ry="2" />
              <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16" />
            </svg>
          </span>
          <div>
            <h2 id="experience-heading" className="section-title">
              Practical Experience
            </h2>
            <p className="section-count">
              {displayCount} {displayCount === 1 ? 'role' : 'roles'}
            </p>
          </div>
        </div>
        <span
          className={`status-badge ${
            isEditing ? 'status-badge--editing' : 'status-badge--submitted'
          }`}
        >
          {isEditing ? 'Editing' : 'Submitted'}
        </span>
      </div>

      <div className="section-body">
        {isEditing ? (
          <form onSubmit={handleFormSubmit}>
            {draftList.length > 0 ? (
              <div className="entries-editor-stack">
                {draftList.map((entry, index) => (
                  <div key={entry.id} className="entry-editor-card">
                    <div className="entry-editor-top">
                      <span className="entry-editor-label">
                        Experience #{index + 1}
                      </span>
                      <button
                        type="button"
                        className="btn--remove"
                        onClick={() => onRemoveItem(entry.id)}
                      >
                        Remove
                      </button>
                    </div>

                    <div className="form-grid">
                      <div className="field">
                        <label
                          htmlFor={`exp-company-${entry.id}`}
                          className="field-label"
                        >
                          Company Name
                        </label>
                        <input
                          id={`exp-company-${entry.id}`}
                          type="text"
                          className="field-input"
                          placeholder="e.g. Northstar Digital Studio"
                          value={entry.company}
                          onChange={(e) =>
                            onChangeItem(entry.id, 'company', e.target.value)
                          }
                          required
                        />
                      </div>

                      <div className="field">
                        <label
                          htmlFor={`exp-position-${entry.id}`}
                          className="field-label"
                        >
                          Position Title
                        </label>
                        <input
                          id={`exp-position-${entry.id}`}
                          type="text"
                          className="field-input"
                          placeholder="e.g. Frontend Engineer"
                          value={entry.position}
                          onChange={(e) =>
                            onChangeItem(entry.id, 'position', e.target.value)
                          }
                          required
                        />
                      </div>

                      <div className="field">
                        <label
                          htmlFor={`exp-from-${entry.id}`}
                          className="field-label"
                        >
                          Date From
                        </label>
                        <input
                          id={`exp-from-${entry.id}`}
                          type="text"
                          className="field-input"
                          placeholder="e.g. Jul 2023"
                          value={entry.dateFrom}
                          onChange={(e) =>
                            onChangeItem(entry.id, 'dateFrom', e.target.value)
                          }
                          required
                        />
                      </div>

                      <div className="field">
                        <label
                          htmlFor={`exp-until-${entry.id}`}
                          className="field-label"
                        >
                          Date Until
                        </label>
                        <input
                          id={`exp-until-${entry.id}`}
                          type="text"
                          className="field-input"
                          placeholder="e.g. Present"
                          value={entry.dateUntil}
                          onChange={(e) =>
                            onChangeItem(entry.id, 'dateUntil', e.target.value)
                          }
                          required
                        />
                      </div>

                      <div className="field field--full">
                        <label
                          htmlFor={`exp-resp-${entry.id}`}
                          className="field-label"
                        >
                          Main Responsibilities
                        </label>
                        <textarea
                          id={`exp-resp-${entry.id}`}
                          className="field-textarea"
                          placeholder="Describe your key responsibilities and achievements..."
                          value={entry.responsibilities}
                          onChange={(e) =>
                            onChangeItem(
                              entry.id,
                              'responsibilities',
                              e.target.value
                            )
                          }
                          required
                        />
                        <span className="field-hint">
                          Put each responsibility on a new line to display as
                          bullet points.
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="empty-editor-banner">
                No practical experience entries yet. Add one below or submit to
                leave this section empty.
              </p>
            )}

            <div className="section-actions">
              <button
                type="button"
                className="btn btn--dashed"
                onClick={onAddItem}
              >
                + Add Experience
              </button>

              <div className="action-group">
                {submittedList.length > 0 && (
                  <button
                    type="button"
                    className="btn btn--secondary"
                    onClick={onCancel}
                  >
                    Cancel
                  </button>
                )}
                <button type="submit" className="btn btn--primary">
                  Submit
                </button>
              </div>
            </div>
          </form>
        ) : (
          <div>
            {submittedList.length > 0 ? (
              <ul className="submitted-entries">
                {submittedList.map((entry) => {
                  const bullets = parseResponsibilities(entry.responsibilities);
                  const dateRange = formatDateRange(
                    entry.dateFrom,
                    entry.dateUntil
                  );

                  return (
                    <li key={entry.id} className="submitted-entry">
                      <div className="submitted-entry-header">
                        <h3 className="submitted-entry-title">
                          {entry.company}
                        </h3>
                        {dateRange && (
                          <span className="submitted-entry-date">
                            {dateRange}
                          </span>
                        )}
                      </div>
                      {entry.position && (
                        <p className="submitted-entry-subtitle">
                          {entry.position}
                        </p>
                      )}
                      {bullets.length > 0 && (
                        <ul className="submitted-entry-bullets">
                          {bullets.map((line, idx) => (
                            <li key={`${entry.id}-bullet-${idx}`}>{line}</li>
                          ))}
                        </ul>
                      )}
                    </li>
                  );
                })}
              </ul>
            ) : (
              <p className="submitted-empty">
                No practical experience added yet.
              </p>
            )}

            <div className="section-actions section-actions--end">
              <button
                type="button"
                className="btn btn--secondary"
                onClick={onEdit}
              >
                Edit
              </button>
            </div>
          </div>
        )}
      </div>
    </section>
  );
}

export default Experience;
