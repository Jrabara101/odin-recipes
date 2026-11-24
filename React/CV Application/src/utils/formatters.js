export function parseResponsibilities(text) {
  if (!text) return [];
  return text
    .split(/\r?\n/)
    .map((line) => line.replace(/^\s*[-•*]\s*/, '').trim())
    .filter(Boolean);
}

export function formatDateRange(dateFrom, dateUntil) {
  const from = (dateFrom || '').trim();
  const until = (dateUntil || '').trim();
  if (from && until) return `${from} – ${until}`;
  if (from) return `${from} – Present`;
  if (until) return until;
  return '';
}
