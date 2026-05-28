import {
  SAFETY_STOP_MAX_DEPTH_METERS,
  SAFETY_STOP_MIN_DEPTH_METERS,
  SAFETY_STOP_REQUIRED_DEPTH_METERS,
  SAFETY_STOP_SECONDS
} from "./constants";

export function isSafetyStopRequired(maxDepthMeters: number): boolean {
  return maxDepthMeters > SAFETY_STOP_REQUIRED_DEPTH_METERS;
}

export function isInSafetyStopZone(depthMeters: number): boolean {
  return (
    depthMeters >= SAFETY_STOP_MIN_DEPTH_METERS &&
    depthMeters <= SAFETY_STOP_MAX_DEPTH_METERS
  );
}

export function updateSafetyStopSecondsRemaining(params: {
  currentRemainingSeconds: number;
  depthMeters: number;
  elapsedSeconds: number;
  required: boolean;
}): number {
  const { currentRemainingSeconds, depthMeters, elapsedSeconds, required } =
    params;

  if (!required) {
    return currentRemainingSeconds;
  }

  if (!isInSafetyStopZone(depthMeters)) {
    return currentRemainingSeconds;
  }

  return Math.max(0, currentRemainingSeconds - elapsedSeconds);
}

export const INITIAL_SAFETY_STOP_SECONDS = SAFETY_STOP_SECONDS;
