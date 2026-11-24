import '../styles/SectionCard.css';

function Education({
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
    <section className="section-card" aria-labelledby="education-heading">
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
              <path d="M22 10v6M2 10l10-5 10 5-10 5z" />
              <path d="M6 12v5c3 3 9 3 12 0v-5" />
            </svg>
          </span>
          <div>
            <h2 id="education-heading" className="section-title">
              Educational Experience
            </h2>
            <p className="section-count">
              {displayCount} {displayCount === 1 ? 'entry' : 'entries'}
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
                        Education #{index + 1}
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
                      <div className="field field--full">
                        <label
                          htmlFor={`edu-school-${entry.id}`}
                          className="field-label"
                        >
                          School Name
                        </label>
                        <input
                          id={`edu-school-${entry.id}`}
                          type="text"
                          className="field-input"
                          placeholder="e.g. University of Washington"
                          value={entry.school}
                          onChange={(e) =>
                            onChangeItem(entry.id, 'school', e.target.value)
                          }
                          required
                        />
                      </div>

                      <div className="field">
                        <label
                          htmlFor={`edu-title-${entry.id}`}
                          className="field-label"
                        >
                          Title of Study
                        </label>
                        <input
                          id={`edu-title-${entry.id}`}
                          type="text"
                          className="field-input"
                          placeholder="e.g. B.S. in Computer Science"
                          value={entry.titleOfStudy}
                          onChange={(e) =>
                            onChangeItem(
                              entry.id,
                              'titleOfStudy',
                              e.target.value
                            )
                          }
                          required
                        />
                      </div>

                      <div className="field">
                        <label
                          htmlFor={`edu-date-${entry.id}`}
                          className="field-label"
                        >
                          Date of Study
                        </label>
                        <input
                          id={`edu-date-${entry.id}`}
                          type="text"
                          className="field-input"
                          placeholder="e.g. Sep 2018 – Jun 2022"
                          value={entry.dateOfStudy}
                          onChange={(e) =>
                            onChangeItem(
                              entry.id,
                              'dateOfStudy',
                              e.target.value
                            )
                          }
                          required
                        />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="empty-editor-banner">
                No education entries yet. Add one below or submit to leave this
                section empty.
              </p>
            )}

            <div className="section-actions">
              <button
                type="button"
                className="btn btn--dashed"
                onClick={onAddItem}
              >
                + Add Education
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
                {submittedList.map((entry) => (
                  <li key={entry.id} className="submitted-entry">
                    <div className="submitted-entry-header">
                      <h3 className="submitted-entry-title">{entry.school}</h3>
                      {entry.dateOfStudy && (
                        <span className="submitted-entry-date">
                          {entry.dateOfStudy}
                        </span>
                      )}
                    </div>
                    {entry.titleOfStudy && (
                      <p className="submitted-entry-subtitle">
                        {entry.titleOfStudy}
                      </p>
                    )}
                  </li>
                ))}
              </ul>
            ) : (
              <p className="submitted-empty">
                No educational experience added yet.
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

export default Education;
