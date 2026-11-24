import { useState } from 'react';
import Header from './components/Header.jsx';
import GeneralInfo from './components/GeneralInfo.jsx';
import Education from './components/Education.jsx';
import Experience from './components/Experience.jsx';
import CVPreview from './components/CVPreview.jsx';
import {
  EXAMPLE_CV,
  EMPTY_CV,
  cloneCVData,
  createEmptyEducation,
  createEmptyExperience,
} from './data/initialData.js';
import './styles/App.css';

function trimGeneral(general) {
  return {
    name: general.name.trim(),
    role: general.role.trim(),
    email: general.email.trim(),
    phone: general.phone.trim(),
    location: general.location.trim(),
  };
}

function sanitizeEducationList(list) {
  return list
    .map((item) => ({
      id: item.id,
      school: item.school.trim(),
      titleOfStudy: item.titleOfStudy.trim(),
      dateOfStudy: item.dateOfStudy.trim(),
    }))
    .filter((item) => item.school || item.titleOfStudy || item.dateOfStudy);
}

function sanitizeExperienceList(list) {
  return list
    .map((item) => ({
      id: item.id,
      company: item.company.trim(),
      position: item.position.trim(),
      responsibilities: item.responsibilities.trim(),
      dateFrom: item.dateFrom.trim(),
      dateUntil: item.dateUntil.trim(),
    }))
    .filter(
      (item) =>
        item.company ||
        item.position ||
        item.responsibilities ||
        item.dateFrom ||
        item.dateUntil
    );
}

function App() {
  const [submitted, setSubmitted] = useState(() => cloneCVData(EXAMPLE_CV));
  const [draft, setDraft] = useState(() => cloneCVData(EXAMPLE_CV));
  const [isEditing, setIsEditing] = useState({
    general: true,
    education: false,
    experience: false,
  });

  // General Info handlers
  function handleGeneralChange(field, value) {
    setDraft((prev) => ({
      ...prev,
      general: { ...prev.general, [field]: value },
    }));
  }

  function handleGeneralSubmit() {
    const cleaned = trimGeneral(draft.general);
    setSubmitted((prev) => ({ ...prev, general: cleaned }));
    setDraft((prev) => ({ ...prev, general: cleaned }));
    setIsEditing((prev) => ({ ...prev, general: false }));
  }

  function handleGeneralEdit() {
    setDraft((prev) => ({ ...prev, general: { ...submitted.general } }));
    setIsEditing((prev) => ({ ...prev, general: true }));
  }

  function handleGeneralCancel() {
    setDraft((prev) => ({ ...prev, general: { ...submitted.general } }));
    setIsEditing((prev) => ({ ...prev, general: false }));
  }

  // Education handlers
  function handleEducationChange(id, field, value) {
    setDraft((prev) => ({
      ...prev,
      education: prev.education.map((item) =>
        item.id === id ? { ...item, [field]: value } : item
      ),
    }));
  }

  function handleAddEducation() {
    setDraft((prev) => ({
      ...prev,
      education: [...prev.education, createEmptyEducation()],
    }));
  }

  function handleRemoveEducation(id) {
    setDraft((prev) => ({
      ...prev,
      education: prev.education.filter((item) => item.id !== id),
    }));
  }

  function handleEducationSubmit() {
    const cleaned = sanitizeEducationList(draft.education);
    setSubmitted((prev) => ({ ...prev, education: cleaned }));
    setDraft((prev) => ({ ...prev, education: cleaned }));
    setIsEditing((prev) => ({ ...prev, education: false }));
  }

  function handleEducationEdit() {
    setDraft((prev) => ({
      ...prev,
      education:
        submitted.education.length > 0
          ? submitted.education.map((item) => ({ ...item }))
          : [createEmptyEducation()],
    }));
    setIsEditing((prev) => ({ ...prev, education: true }));
  }

  function handleEducationCancel() {
    setDraft((prev) => ({
      ...prev,
      education: submitted.education.map((item) => ({ ...item })),
    }));
    setIsEditing((prev) => ({ ...prev, education: false }));
  }

  // Practical Experience handlers
  function handleExperienceChange(id, field, value) {
    setDraft((prev) => ({
      ...prev,
      experience: prev.experience.map((item) =>
        item.id === id ? { ...item, [field]: value } : item
      ),
    }));
  }

  function handleAddExperience() {
    setDraft((prev) => ({
      ...prev,
      experience: [...prev.experience, createEmptyExperience()],
    }));
  }

  function handleRemoveExperience(id) {
    setDraft((prev) => ({
      ...prev,
      experience: prev.experience.filter((item) => item.id !== id),
    }));
  }

  function handleExperienceSubmit() {
    const cleaned = sanitizeExperienceList(draft.experience);
    setSubmitted((prev) => ({ ...prev, experience: cleaned }));
    setDraft((prev) => ({ ...prev, experience: cleaned }));
    setIsEditing((prev) => ({ ...prev, experience: false }));
  }

  function handleExperienceEdit() {
    setDraft((prev) => ({
      ...prev,
      experience:
        submitted.experience.length > 0
          ? submitted.experience.map((item) => ({ ...item }))
          : [createEmptyExperience()],
    }));
    setIsEditing((prev) => ({ ...prev, experience: true }));
  }

  function handleExperienceCancel() {
    setDraft((prev) => ({
      ...prev,
      experience: submitted.experience.map((item) => ({ ...item })),
    }));
    setIsEditing((prev) => ({ ...prev, experience: false }));
  }

  // Whole-CV toolbar handlers
  function handleSubmitAll() {
    const nextGeneral = isEditing.general
      ? trimGeneral(draft.general)
      : submitted.general;
    const nextEducation = isEditing.education
      ? sanitizeEducationList(draft.education)
      : submitted.education;
    const nextExperience = isEditing.experience
      ? sanitizeExperienceList(draft.experience)
      : submitted.experience;

    const nextSubmitted = {
      general: nextGeneral,
      education: nextEducation,
      experience: nextExperience,
    };

    setSubmitted(nextSubmitted);
    setDraft(cloneCVData(nextSubmitted));
    setIsEditing({ general: false, education: false, experience: false });
  }

  function handleEditAll() {
    setDraft({
      general: { ...submitted.general },
      education:
        submitted.education.length > 0
          ? submitted.education.map((item) => ({ ...item }))
          : [createEmptyEducation()],
      experience:
        submitted.experience.length > 0
          ? submitted.experience.map((item) => ({ ...item }))
          : [createEmptyExperience()],
    });
    setIsEditing({ general: true, education: true, experience: true });
  }

  function handleLoadExample() {
    const example = cloneCVData(EXAMPLE_CV);
    setSubmitted(example);
    setDraft(cloneCVData(example));
    setIsEditing({ general: false, education: false, experience: false });
  }

  function handleClear() {
    setSubmitted(cloneCVData(EMPTY_CV));
    setDraft({
      general: { ...EMPTY_CV.general },
      education: [createEmptyEducation()],
      experience: [createEmptyExperience()],
    });
    setIsEditing({ general: true, education: true, experience: true });
  }

  function handlePrint() {
    window.print();
  }

  const submittedCount =
    Number(!isEditing.general) +
    Number(!isEditing.education) +
    Number(!isEditing.experience);
  const allSubmitted = submittedCount === 3;

  const hasUnsavedEdits =
    (isEditing.general &&
      JSON.stringify(trimGeneral(draft.general)) !==
        JSON.stringify(submitted.general)) ||
    (isEditing.education &&
      JSON.stringify(sanitizeEducationList(draft.education)) !==
        JSON.stringify(submitted.education)) ||
    (isEditing.experience &&
      JSON.stringify(sanitizeExperienceList(draft.experience)) !==
        JSON.stringify(submitted.experience));

  return (
    <div className="app-shell">
      <Header
        allSubmitted={allSubmitted}
        submittedCount={submittedCount}
        totalSections={3}
        onSubmitAll={handleSubmitAll}
        onEditAll={handleEditAll}
        onLoadExample={handleLoadExample}
        onClear={handleClear}
        onPrint={handlePrint}
      />

      <main className="workspace">
        <div className="editor-column no-print">
          <p className="editor-intro">
            Fill in each section and click <strong>Submit</strong> to display
            the saved values in HTML and update your CV preview. Click{' '}
            <strong>Edit</strong> anytime to modify and resubmit.
          </p>

          <GeneralInfo
            draft={draft.general}
            submitted={submitted.general}
            isEditing={isEditing.general}
            onChange={handleGeneralChange}
            onSubmit={handleGeneralSubmit}
            onEdit={handleGeneralEdit}
            onCancel={handleGeneralCancel}
          />

          <Education
            draftList={draft.education}
            submittedList={submitted.education}
            isEditing={isEditing.education}
            onChangeItem={handleEducationChange}
            onAddItem={handleAddEducation}
            onRemoveItem={handleRemoveEducation}
            onSubmit={handleEducationSubmit}
            onEdit={handleEducationEdit}
            onCancel={handleEducationCancel}
          />

          <Experience
            draftList={draft.experience}
            submittedList={submitted.experience}
            isEditing={isEditing.experience}
            onChangeItem={handleExperienceChange}
            onAddItem={handleAddExperience}
            onRemoveItem={handleRemoveExperience}
            onSubmit={handleExperienceSubmit}
            onEdit={handleExperienceEdit}
            onCancel={handleExperienceCancel}
          />
        </div>

        <aside className="preview-column" aria-label="CV Preview">
          <CVPreview
            general={submitted.general}
            education={submitted.education}
            experience={submitted.experience}
            hasUnsavedEdits={hasUnsavedEdits}
          />
        </aside>
      </main>
    </div>
  );
}

export default App;
