import { clampDepth } from "./depth";
import type { DiveSample, FakeDiveProfile, FakeDiveProfileName } from "./types";

type Segment = {
  fromSecond: number;
  toSecond: number;
  fromDepth: number;
  toDepth: number;
};

const ONE_SECOND_MS = 1000;

function interpolate(segment: Segment, second: number): number {
  if (segment.toSecond === segment.fromSecond) {
    return segment.toDepth;
  }

  const progress =
    (second - segment.fromSecond) / (segment.toSecond - segment.fromSecond);
  return segment.fromDepth + (segment.toDepth - segment.fromDepth) * progress;
}

function depthAt(segments: Segment[], second: number): number {
  const segment = segments.find(
    (candidate) =>
      second >= candidate.fromSecond && second <= candidate.toSecond
  );

  if (!segment) {
    return 0;
  }

  return clampDepth(interpolate(segment, second));
}

function temperatureForDepth(depthMeters: number, second: number): number {
  const gentleSensorNoise = ((second % 11) - 5) * 0.015;
  return Number((26 - depthMeters * 0.16 + gentleSensorNoise).toFixed(1));
}

function buildProfile(
  name: FakeDiveProfileName,
  label: string,
  description: string,
  totalSeconds: number,
  segments: Segment[]
): FakeDiveProfile {
  const samples: DiveSample[] = [];

  for (let second = 0; second <= totalSeconds; second += 1) {
    const depthMeters = depthAt(segments, second);
    samples.push({
      timestampMs: second * ONE_SECOND_MS,
      depthMeters,
      temperatureC: temperatureForDepth(depthMeters, second),
      pressureBar: Number((1 + depthMeters / 10).toFixed(3))
    });
  }

  return { name, label, description, samples };
}

export function shallowTrainingDive(): FakeDiveProfile {
  return buildProfile(
    "shallowTrainingDive",
    "Shallow Training Dive",
    "A calm 8 m profile without a required safety stop.",
    480,
    [
      { fromSecond: 0, toSecond: 10, fromDepth: 0, toDepth: 0 },
      { fromSecond: 10, toSecond: 70, fromDepth: 0, toDepth: 8 },
      { fromSecond: 70, toSecond: 300, fromDepth: 8, toDepth: 8 },
      { fromSecond: 300, toSecond: 420, fromDepth: 8, toDepth: 0 },
      { fromSecond: 420, toSecond: 480, fromDepth: 0, toDepth: 0 }
    ]
  );
}

export function recreationalDive(): FakeDiveProfile {
  return buildProfile(
    "recreationalDive",
    "Recreational Dive",
    "An 18 m profile with a completed safety stop.",
    1020,
    [
      { fromSecond: 0, toSecond: 10, fromDepth: 0, toDepth: 0 },
      { fromSecond: 10, toSecond: 130, fromDepth: 0, toDepth: 18 },
      { fromSecond: 130, toSecond: 600, fromDepth: 18, toDepth: 18 },
      { fromSecond: 600, toSecond: 720, fromDepth: 18, toDepth: 5 },
      { fromSecond: 720, toSecond: 900, fromDepth: 5, toDepth: 5 },
      { fromSecond: 900, toSecond: 960, fromDepth: 5, toDepth: 0 },
      { fromSecond: 960, toSecond: 1020, fromDepth: 0, toDepth: 0 }
    ]
  );
}

export function fastAscentMistake(): FakeDiveProfile {
  return buildProfile(
    "fastAscentMistake",
    "Fast Ascent Mistake",
    "A 22 m profile with a deliberately fast ascent warning.",
    570,
    [
      { fromSecond: 0, toSecond: 10, fromDepth: 0, toDepth: 0 },
      { fromSecond: 10, toSecond: 130, fromDepth: 0, toDepth: 22 },
      { fromSecond: 130, toSecond: 420, fromDepth: 22, toDepth: 22 },
      { fromSecond: 420, toSecond: 500, fromDepth: 22, toDepth: 0 },
      { fromSecond: 500, toSecond: 570, fromDepth: 0, toDepth: 0 }
    ]
  );
}

export function getFakeDiveProfiles(): FakeDiveProfile[] {
  return [shallowTrainingDive(), recreationalDive(), fastAscentMistake()];
}

export function getFakeDiveProfile(name: FakeDiveProfileName): FakeDiveProfile {
  const profile = getFakeDiveProfiles().find((candidate) => candidate.name === name);

  if (!profile) {
    throw new Error(`Unknown fake dive profile: ${name}`);
  }

  return profile;
}
