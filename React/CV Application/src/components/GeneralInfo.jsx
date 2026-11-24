import '../styles/SectionCard.css';

function GeneralInfo({
  draft,
  submitted,
  isEditing,
  onChange,
  onSubmit,
  onEdit,
  onCancel,
}) {
  const hasSubmittedData = Boolean(
    submitted.name ||
      submitted.email ||
      submitted.phone ||
      submitted.role ||
      submitted.location
  );

  function handleFormSubmit(event) {
    event.preventDefault();
    onSubmit();
  }

  return (
    <section className="section-card" aria-labelledby="general-info-heading">
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
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
              <circle cx="12" cy="7" r="4" />
            </svg>
          </span>
          <div>
            <h2 id="general-info-heading" className="section-title">
              General Information
            </h2>
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
            <div className="form-grid">
              <div className="field field--full">
                <label htmlFor="general-name" className="field-label">
                  Full Name
                </label>
                <input
                  id="general-name"
                  name="name"
                  type="text"
                  className="field-input"
                  placeholder="e.g. Elena Vance"
                  value={draft.name}
                  onChange={(e) => onChange('name', e.target.value)}
                  required
                />
              </div>

              <div className="field field--full">
                <label htmlFor="general-role" className="field-label">
                  Professional Title
                  <span className="field-optional">(optional)</span>
                </label>
                <input
                  id="general-role"
                  name="role"
                  type="text"
                  className="field-input"
                  placeholder="e.g. Frontend Software Engineer"
                  value={draft.role}
                  onChange={(e) => onChange('role', e.target.value)}
                />
              </div>

              <div className="field">
                <label htmlFor="general-email" className="field-label">
                  Email Address
                </label>
                <input
                  id="general-email"
                  name="email"
                  type="email"
                  className="field-input"
                  placeholder="name@example.com"
                  value={draft.email}
                  onChange={(e) => onChange('email', e.target.value)}
                  required
                />
              </div>

              <div className="field">
                <label htmlFor="general-phone" className="field-label">
                  Phone Number
                </label>
                <input
                  id="general-phone"
                  name="phone"
                  type="tel"
                  className="field-input"
                  placeholder="+1 (415) 555-0194"
                  value={draft.phone}
                  onChange={(e) => onChange('phone', e.target.value)}
                  required
                />
              </div>

              <div className="field field--full">
                <label htmlFor="general-location" className="field-label">
                  Location
                  <span className="field-optional">(optional)</span>
                </label>
                <input
                  id="general-location"
                  name="location"
                  type="text"
                  className="field-input"
                  placeholder="e.g. San Francisco, CA"
                  value={draft.location}
                  onChange={(e) => onChange('location', e.target.value)}
                />
              </div>
            </div>

            <div className="section-actions section-actions--end">
              <div className="action-group">
                {hasSubmittedData && (
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
            {hasSubmittedData ? (
              <dl className="submitted-dl">
                <div className="submitted-field submitted-field--full">
                  <dt>Full Name</dt>
                  <dd className="submitted-name-value">
                    {submitted.name || '—'}
                  </dd>
                </div>

                {submitted.role && (
                  <div className="submitted-field submitted-field--full">
                    <dt>Professional Title</dt>
                    <dd>{submitted.role}</dd>
                  </div>
                )}

                <div className="submitted-field">
                  <dt>Email</dt>
                  <dd>{submitted.email || '—'}</dd>
                </div>

                <div className="submitted-field">
                  <dt>Phone</dt>
                  <dd>{submitted.phone || '—'}</dd>
                </div>

                {submitted.location && (
                  <div className="submitted-field submitted-field--full">
                    <dt>Location</dt>
                    <dd>{submitted.location}</dd>
                  </div>
                )}
              </dl>
            ) : (
              <p className="submitted-empty">
                No general information submitted yet.
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

export default GeneralInfo;
