import {
  ASCENT_RATE_FAST_METERS_PER_MINUTE,
  ASCENT_RATE_SLOW_METERS_PER_MINUTE,
  ASCENT_RATE_WINDOW_SECONDS
} from "./constants";
import type { AscentStatus, DiveSample } from "./types";

export function calculateAscentRateMetersPerMinute(
  samples: DiveSample[],
  windowSeconds = ASCENT_RATE_WINDOW_SECONDS
): number {
  if (samples.length < 2) {
    return 0;
  }

  const newest = samples[samples.length - 1];
  const cutoffMs = newest.timestampMs - windowSeconds * 1000;
  const oldestInWindow =
    samples.find((sample) => sample.timestampMs >= cutoffMs) ?? samples[0];

  const elapsedMinutes =
    (newest.timestampMs - oldestInWindow.timestampMs) / 1000 / 60;

  if (elapsedMinutes <= 0) {
    return 0;
  }

  // Positive ascent rate means the diver is getting shallower.
  const rate = (oldestInWindow.depthMeters - newest.depthMeters) / elapsedMinutes;
  return Math.max(0, rate);
}

export function getAscentStatus(
  ascentRateMetersPerMinute: number
): AscentStatus {
  if (ascentRateMetersPerMinute > ASCENT_RATE_FAST_METERS_PER_MINUTE) {
    return "FAST";
  }

  if (ascentRateMetersPerMinute >= ASCENT_RATE_SLOW_METERS_PER_MINUTE) {
    return "SLOW";
  }

  return "OK";
}
