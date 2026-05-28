import {
  DIVE_END_DEPTH_METERS,
  DIVE_END_HOLD_SECONDS,
  DIVE_START_DEPTH_METERS,
  DIVE_START_HOLD_SECONDS
} from "./constants";
import { isInSafetyStopZone } from "./safetyStop";
import { DiveState, type DiveSample } from "./types";

export interface DiveStateMachineInput {
  sample: DiveSample;
  previousSample?: DiveSample;
  diveStarted: boolean;
  diveEnded: boolean;
  safetyStopRequired: boolean;
  safetyStopSecondsRemaining: number;
}

export interface DiveStateMachineMemory {
  startCandidateSinceMs?: number;
  surfaceCandidateSinceMs?: number;
}

export function updateStartDetection(
  memory: DiveStateMachineMemory,
  sample: DiveSample
): { started: boolean; startTimestampMs?: number } {
  if (sample.depthMeters > DIVE_START_DEPTH_METERS) {
    memory.startCandidateSinceMs ??= sample.timestampMs;

    const heldSeconds =
      (sample.timestampMs - memory.startCandidateSinceMs) / 1000;

    if (heldSeconds >= DIVE_START_HOLD_SECONDS) {
      return {
        started: true,
        startTimestampMs: memory.startCandidateSinceMs
      };
    }
  } else {
    memory.startCandidateSinceMs = undefined;
  }

  return { started: false };
}

export function updateEndDetection(
  memory: DiveStateMachineMemory,
  sample: DiveSample,
  diveStarted: boolean
): { ended: boolean; endTimestampMs?: number } {
  if (!diveStarted) {
    return { ended: false };
  }

  if (sample.depthMeters < DIVE_END_DEPTH_METERS) {
    memory.surfaceCandidateSinceMs ??= sample.timestampMs;
    const heldSeconds =
      (sample.timestampMs - memory.surfaceCandidateSinceMs) / 1000;

    if (heldSeconds >= DIVE_END_HOLD_SECONDS) {
      return {
        ended: true,
        endTimestampMs: sample.timestampMs
      };
    }
  } else {
    memory.surfaceCandidateSinceMs = undefined;
  }

  return { ended: false };
}

export function resolveDiveState(input: DiveStateMachineInput): DiveState {
  const {
    sample,
    previousSample,
    diveStarted,
    diveEnded,
    safetyStopRequired,
    safetyStopSecondsRemaining
  } = input;

  if (diveEnded) {
    return DiveState.SURFACED;
  }

  if (!diveStarted) {
    return DiveState.SURFACE;
  }

  if (
    safetyStopRequired &&
    safetyStopSecondsRemaining > 0 &&
    isInSafetyStopZone(sample.depthMeters)
  ) {
    return DiveState.SAFETY_STOP;
  }

  if (!previousSample) {
    return DiveState.BOTTOM;
  }

  const depthDelta = sample.depthMeters - previousSample.depthMeters;

  if (depthDelta > 0.05) {
    return DiveState.DESCENDING;
  }

  if (depthDelta < -0.05) {
    return DiveState.ASCENDING;
  }

  return DiveState.BOTTOM;
}
