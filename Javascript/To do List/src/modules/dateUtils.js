/**
 * Date Utility Module
 * Wraps date-fns functions to handle due date calculations, relative labels, and formatting.
 */
import {
  parseISO,
  format,
  isToday,
  isTomorrow,
  startOfDay,
  addDays,
  isBefore,
  isValid,
} from "date-fns";

/**
 * Parses a YYYY-MM-DD string safely into a Date object at start of day.
 */
export function parseDueDate(dateString) {
  if (!dateString) return null;
  const parsed = parseISO(dateString);
  return isValid(parsed) ? parsed : null;
}

/**
 * Checks if a date string falls on today.
 */
export function isDueDateToday(dateString) {
  const date = parseDueDate(dateString);
  if (!date) return false;
  return isToday(date);
}

/**
 * Checks if a date string is in the past (before start of today).
 */
export function isDueDateOverdue(dateString) {
  const date = parseDueDate(dateString);
  if (!date) return false;
  const todayStart = startOfDay(new Date());
  return isBefore(date, todayStart);
}

/**
 * Checks if a date string falls within the next 7 days (including today).
 */
export function isDueDateThisWeek(dateString) {
  const date = parseDueDate(dateString);
  if (!date) return false;
  const todayStart = startOfDay(new Date());
  const endOfWeekSpan = addDays(todayStart, 8); // next 7 days window
  return !isBefore(date, todayStart) && isBefore(date, endOfWeekSpan);
}

/**
 * Formats a due date into a human-friendly string.
 * Examples: "Today", "Tomorrow", "Overdue (Nov 12)", "Nov 20", "Jan 5, 2027"
 */
export function formatDueDate(dateString) {
  const date = parseDueDate(dateString);
  if (!date) return "No due date";

  if (isToday(date)) {
    return "Today";
  }

  if (isTomorrow(date)) {
    return "Tomorrow";
  }

  const todayStart = startOfDay(new Date());
  if (isBefore(date, todayStart)) {
    return `Overdue (${format(date, "MMM d")})`;
  }

  const currentYear = new Date().getFullYear();
  if (date.getFullYear() === currentYear) {
    return format(date, "MMM d");
  }

  return format(date, "MMM d, yyyy");
}

/**
 * Returns today's date formatted as YYYY-MM-DD for HTML input[type=date].
 */
export function getTodayDateString() {
  return format(new Date(), "yyyy-MM-dd");
}

/**
 * Returns a date string offset by N days formatted as YYYY-MM-DD.
 */
export function getDateOffsetString(days) {
  return format(addDays(new Date(), days), "yyyy-MM-dd");
}
