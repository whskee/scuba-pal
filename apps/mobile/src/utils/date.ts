const timezoneSuffixPattern = /(z|[+-]\d{2}:?\d{2})$/i;
const dateOnlyPattern = /^\d{4}-\d{2}-\d{2}$/;

export function normalizeApiDateString(value?: string | null): string {
  if (!value) return new Date().toISOString();
  if (dateOnlyPattern.test(value)) return `${value}T00:00:00Z`;
  return timezoneSuffixPattern.test(value) ? value : `${value}Z`;
}

export function parseApiDate(value?: string | null): Date {
  const date = new Date(normalizeApiDateString(value));
  return Number.isNaN(date.getTime()) ? new Date() : date;
}

export function localDateKey(value?: string | null): string {
  const date = parseApiDate(value);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export function formatMessageTime(value?: string | null): string {
  const date = parseApiDate(value);
  return `${String(date.getHours()).padStart(2, "0")}:${String(date.getMinutes()).padStart(2, "0")}`;
}

export function formatDateHeader(value?: string | null): string {
  const date = parseApiDate(value);
  const today = new Date();
  const yesterday = new Date();
  yesterday.setDate(today.getDate() - 1);

  const key = localDateKey(value);
  if (key === localDateKey(today.toISOString())) return "Today";
  if (key === localDateKey(yesterday.toISOString())) return "Yesterday";

  const includeYear = date.getFullYear() !== today.getFullYear();
  return date.toLocaleDateString(undefined, {
    weekday: "short",
    month: "short",
    day: "numeric",
    year: includeYear ? "numeric" : undefined
  });
}

export function formatConversationTime(value?: string | null): string {
  const key = localDateKey(value);
  const todayKey = localDateKey(new Date().toISOString());
  return key === todayKey ? formatMessageTime(value) : formatDateHeader(value);
}

export function formatRelativeTime(value?: string | null): string {
  const date = parseApiDate(value);
  const diffMs = Date.now() - date.getTime();
  if (diffMs < 60_000) return "just now";

  const minutes = Math.floor(diffMs / 60_000);
  if (minutes < 60) return `${minutes}m ago`;

  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;

  const days = Math.floor(hours / 24);
  if (days === 1) return `Yesterday at ${formatMessageTime(value)}`;
  if (days < 7) return `${days}d ago`;

  return `${date.toLocaleDateString(undefined, { month: "short", day: "numeric", year: date.getFullYear() === new Date().getFullYear() ? undefined : "numeric" })} at ${formatMessageTime(value)}`;
}

export const shortDateTime = (value: string) => parseApiDate(value).toLocaleString();
