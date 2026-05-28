import type { DiveSample } from "./types";

export function clampDepth(depthMeters: number): number {
  return Math.max(0, Number(depthMeters.toFixed(2)));
}

export function calculateMaxDepth(samples: DiveSample[]): number {
  return samples.reduce((max, sample) => Math.max(max, sample.depthMeters), 0);
}

export function calculateAverageDepth(samples: DiveSample[]): number {
  if (samples.length === 0) {
    return 0;
  }

  const total = samples.reduce((sum, sample) => sum + sample.depthMeters, 0);
  return total / samples.length;
}

export function calculateMinTemperature(samples: DiveSample[]): number {
  if (samples.length === 0) {
    return 0;
  }

  return samples.reduce(
    (min, sample) => Math.min(min, sample.temperatureC),
    samples[0]?.temperatureC ?? 0
  );
}
