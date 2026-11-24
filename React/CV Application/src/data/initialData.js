let idCounter = 1;

function nextId(prefix) {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return `${prefix}-${crypto.randomUUID()}`;
  }
  idCounter += 1;
  return `${prefix}-${Date.now()}-${idCounter}`;
}

export function createEmptyEducation() {
  return {
    id: nextId('edu'),
    school: '',
    titleOfStudy: '',
    dateOfStudy: '',
  };
}

export function createEmptyExperience() {
  return {
    id: nextId('exp'),
    company: '',
    position: '',
    responsibilities: '',
    dateFrom: '',
    dateUntil: '',
  };
}

export const EXAMPLE_CV = {
  general: {
    name: 'Elena Vance',
    role: 'Frontend Software Engineer',
    email: 'elena.vance@example.com',
    phone: '+1 (415) 555-0194',
    location: 'San Francisco, CA',
  },
  education: [
    {
      id: 'edu-example-1',
      school: 'University of Washington',
      titleOfStudy: 'B.S. in Computer Science',
      dateOfStudy: 'Sep 2018 – Jun 2022',
    },
    {
      id: 'edu-example-2',
      school: 'The Odin Project',
      titleOfStudy: 'Full Stack JavaScript Curriculum',
      dateOfStudy: '2022 – 2023',
    },
  ],
  experience: [
    {
      id: 'exp-example-1',
      company: 'Northstar Digital Studio',
      position: 'Frontend Engineer',
      dateFrom: 'Jul 2023',
      dateUntil: 'Present',
      responsibilities:
        'Architected modular React component libraries used across 4 client-facing web applications.\nImproved Core Web Vitals and cut initial bundle size by 34% through code splitting and CSS optimization.\nPartnered with product designers to deliver WCAG AA accessible form workflows and responsive layouts.',
    },
    {
      id: 'exp-example-2',
      company: 'Cascade Web Labs',
      position: 'Junior Web Developer',
      dateFrom: 'Jul 2022',
      dateUntil: 'Jun 2023',
      responsibilities:
        'Built interactive client dashboards using modern JavaScript, REST APIs, and semantic HTML/CSS.\nAuthored unit and integration tests, raising test coverage on core billing modules from 52% to 88%.',
    },
  ],
};

export const EMPTY_CV = {
  general: {
    name: '',
    role: '',
    email: '',
    phone: '',
    location: '',
  },
  education: [],
  experience: [],
};

export function cloneCVData(data) {
  return {
    general: { ...data.general },
    education: data.education.map((item) => ({ ...item })),
    experience: data.experience.map((item) => ({ ...item })),
  };
}
