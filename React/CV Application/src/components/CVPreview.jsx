import '../styles/CVPreview.css';
import { formatDateRange, parseResponsibilities } from '../utils/formatters';

function CVPreview({ general, education, experience, hasUnsavedEdits }) {
  const hasContactItems = Boolean(
    general.email || general.phone || general.location
  );

  return (
    <div className="preview-wrapper">
      <div className="preview-header no-print">
        <span className="preview-label">Submitted CV Preview</span>
        {hasUnsavedEdits ? (
          <span className="preview-unsaved-pill">
            Unsaved edits — click Submit to update
          </span>
        ) : (
          <span className="preview-synced-pill">Up to date</span>
        )}
      </div>

      <article className="cv-sheet" aria-label="Curriculum Vitae Document">
        <header className="cv-doc-header">
          <h2
            className={`cv-doc-name ${
              general.name ? '' : 'cv-doc-name--placeholder'
            }`}
          >
            {general.name || 'Your Full Name'}
          </h2>

          {general.role && <p className="cv-doc-role">{general.role}</p>}

          {hasContactItems ? (
            <ul className="cv-contact-list">
              {general.email && (
                <li className="cv-contact-item">
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
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                    <polyline points="22,6 12,13 2,6" />
                  </svg>
                  <span>{general.email}</span>
                </li>
              )}

              {general.phone && (
                <li className="cv-contact-item">
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
                    <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
                  </svg>
                  <span>{general.phone}</span>
                </li>
              )}

              {general.location && (
                <li className="cv-contact-item">
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
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                    <circle cx="12" cy="10" r="3" />
                  </svg>
                  <span>{general.location}</span>
                </li>
              )}
            </ul>
          ) : (
            <p className="cv-empty-note" style={{ marginTop: '0.65rem' }}>
              Submit General Information to display your contact details.
            </p>
          )}
        </header>

        <section className="cv-section" aria-labelledby="cv-experience-title">
          <h3 id="cv-experience-title" className="cv-section-heading">
            Practical Experience
          </h3>

          {experience.length > 0 ? (
            <div className="cv-entry-list">
              {experience.map((entry) => {
                const bullets = parseResponsibilities(entry.responsibilities);
                const dateRange = formatDateRange(
                  entry.dateFrom,
                  entry.dateUntil
                );

                return (
                  <div key={entry.id} className="cv-entry">
                    <div className="cv-entry-top">
                      <h4 className="cv-entry-primary">{entry.company}</h4>
                      {dateRange && (
                        <span className="cv-entry-date">{dateRange}</span>
                      )}
                    </div>
                    {entry.position && (
                      <p className="cv-entry-secondary">{entry.position}</p>
                    )}
                    {bullets.length > 1 ? (
                      <ul className="cv-responsibilities-list">
                        {bullets.map((line, idx) => (
                          <li key={`${entry.id}-cv-bullet-${idx}`}>{line}</li>
                        ))}
                      </ul>
                    ) : bullets.length === 1 ? (
                      <p className="cv-responsibilities-text">{bullets[0]}</p>
                    ) : null}
                  </div>
                );
              })}
            </div>
          ) : (
            <p className="cv-empty-note">
              No practical experience submitted yet.
            </p>
          )}
        </section>

        <section className="cv-section" aria-labelledby="cv-education-title">
          <h3 id="cv-education-title" className="cv-section-heading">
            Education
          </h3>

          {education.length > 0 ? (
            <div className="cv-entry-list">
              {education.map((entry) => (
                <div key={entry.id} className="cv-entry">
                  <div className="cv-entry-top">
                    <h4 className="cv-entry-primary">{entry.school}</h4>
                    {entry.dateOfStudy && (
                      <span className="cv-entry-date">{entry.dateOfStudy}</span>
                    )}
                  </div>
                  {entry.titleOfStudy && (
                    <p className="cv-entry-secondary">{entry.titleOfStudy}</p>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="cv-empty-note">
              No educational experience submitted yet.
            </p>
          )}
        </section>
      </article>
    </div>
  );
}

export default CVPreview;
