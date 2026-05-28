export function formatMeters(value: number): string {
  return `${value.toFixed(1)} m`;
}

export function formatTemperature(value: number): string {
  return `${value.toFixed(1)} C`;
}

export function formatDuration(totalSeconds: number): string {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, "0")}`;
}
