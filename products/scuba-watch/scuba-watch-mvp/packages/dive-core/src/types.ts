export type AscentStatus = "OK" | "SLOW" | "FAST";

export interface DiveSample {
  timestampMs: number;
  depthMeters: number;
  temperatureC: number;
  pressureBar?: number;
}

export enum DiveState {
  SURFACE = "SURFACE",
  DESCENDING = "DESCENDING",
  BOTTOM = "BOTTOM",
  ASCENDING = "ASCENDING",
  SAFETY_STOP = "SAFETY_STOP",
  SURFACED = "SURFACED"
}

export interface DiveMetrics {
  currentDepthMeters: number;
  maxDepthMeters: number;
  diveTimeSeconds: number;
  temperatureC: number;
  ascentRateMetersPerMinute: number;
  ascentStatus: AscentStatus;
  safetyStopRequired: boolean;
  safetyStopSecondsRemaining: number;
  state: DiveState;
}

export interface DiveLog {
  id: string;
  startedAt: number;
  endedAt: number;
  maxDepthMeters: number;
  durationSeconds: number;
  averageDepthMeters: number;
  minTemperatureC: number;
  samples: DiveSample[];
}

export type FakeDiveProfileName =
  | "shallowTrainingDive"
  | "recreationalDive"
  | "fastAscentMistake";

export interface FakeDiveProfile {
  name: FakeDiveProfileName;
  label: string;
  description: string;
  samples: DiveSample[];
}
