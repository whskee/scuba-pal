import { calculateAscentRateMetersPerMinute, getAscentStatus } from "./ascentRate";
import { calculateAverageDepth, calculateMaxDepth, calculateMinTemperature } from "./depth";
import {
  DiveStateMachineMemory,
  resolveDiveState,
  updateEndDetection,
  updateStartDetection
} from "./diveStateMachine";
import {
  INITIAL_SAFETY_STOP_SECONDS,
  isSafetyStopRequired,
  updateSafetyStopSecondsRemaining
} from "./safetyStop";
import { DiveState, type DiveLog, type DiveMetrics, type DiveSample } from "./types";

export interface DiveEngineResult {
  metrics: DiveMetrics;
  completedLog?: DiveLog;
}

export class DiveEngine {
  private readonly allSamples: DiveSample[] = [];
  private readonly activeSamples: DiveSample[] = [];
  private readonly memory: DiveStateMachineMemory = {};
  private diveStarted = false;
  private diveEnded = false;
  private startedAt?: number;
  private endedAt?: number;
  private maxDepthMeters = 0;
  private safetyStopSecondsRemaining = INITIAL_SAFETY_STOP_SECONDS;
  private completedLog?: DiveLog;

  processSample(sample: DiveSample): DiveEngineResult {
    if (this.diveEnded) {
      return { metrics: this.buildMetrics(sample), completedLog: this.completedLog };
    }

    const previousSample = this.allSamples[this.allSamples.length - 1];
    this.allSamples.push(sample);
    this.maxDepthMeters = Math.max(this.maxDepthMeters, sample.depthMeters);

    if (!this.diveStarted) {
      const startDetection = updateStartDetection(this.memory, sample);

      if (startDetection.started && startDetection.startTimestampMs !== undefined) {
        this.diveStarted = true;
        this.startedAt = startDetection.startTimestampMs;

        for (const historicalSample of this.allSamples) {
          if (historicalSample.timestampMs >= this.startedAt) {
            this.activeSamples.push(historicalSample);
            this.maxDepthMeters = Math.max(
              this.maxDepthMeters,
              historicalSample.depthMeters
            );
          }
        }
      }
    } else {
      this.activeSamples.push(sample);
    }

    const elapsedSeconds =
      previousSample && this.diveStarted
        ? Math.max(0, (sample.timestampMs - previousSample.timestampMs) / 1000)
        : 0;

    const safetyStopRequired = isSafetyStopRequired(this.maxDepthMeters);
    this.safetyStopSecondsRemaining = updateSafetyStopSecondsRemaining({
      currentRemainingSeconds: this.safetyStopSecondsRemaining,
      depthMeters: sample.depthMeters,
      elapsedSeconds,
      required: this.diveStarted && safetyStopRequired
    });

    if (this.diveStarted) {
      const endDetection = updateEndDetection(this.memory, sample, true);
      if (endDetection.ended && endDetection.endTimestampMs !== undefined) {
        this.diveEnded = true;
        this.endedAt = endDetection.endTimestampMs;
        this.completedLog = this.createDiveLog();
      }
    }

    return {
      metrics: this.buildMetrics(sample),
      completedLog: this.completedLog
    };
  }

  finish(endTimestampMs?: number): DiveLog | undefined {
    if (!this.diveStarted || this.activeSamples.length === 0) {
      return undefined;
    }

    this.diveEnded = true;
    this.endedAt =
      endTimestampMs ??
      this.activeSamples[this.activeSamples.length - 1]?.timestampMs ??
      this.startedAt;
    this.completedLog = this.createDiveLog();
    return this.completedLog;
  }

  getMetrics(): DiveMetrics {
    const latest = this.allSamples[this.allSamples.length - 1] ?? {
      timestampMs: 0,
      depthMeters: 0,
      temperatureC: 24
    };

    return this.buildMetrics(latest);
  }

  private buildMetrics(sample: DiveSample): DiveMetrics {
    const samplesForRate =
      this.activeSamples.length > 0 ? this.activeSamples : this.allSamples;
    const ascentRateMetersPerMinute =
      calculateAscentRateMetersPerMinute(samplesForRate);
    const safetyStopRequired =
      this.diveStarted && isSafetyStopRequired(this.maxDepthMeters);
    const previousActiveSample =
      this.activeSamples.length >= 2
        ? this.activeSamples[this.activeSamples.length - 2]
        : undefined;

    return {
      currentDepthMeters: sample.depthMeters,
      maxDepthMeters: this.maxDepthMeters,
      diveTimeSeconds:
        this.diveStarted && this.startedAt !== undefined
          ? Math.max(0, Math.floor((sample.timestampMs - this.startedAt) / 1000))
          : 0,
      temperatureC: sample.temperatureC,
      ascentRateMetersPerMinute,
      ascentStatus: getAscentStatus(ascentRateMetersPerMinute),
      safetyStopRequired,
      safetyStopSecondsRemaining: safetyStopRequired
        ? Math.ceil(this.safetyStopSecondsRemaining)
        : 0,
      state: resolveDiveState({
        sample,
        previousSample: previousActiveSample,
        diveStarted: this.diveStarted,
        diveEnded: this.diveEnded,
        safetyStopRequired,
        safetyStopSecondsRemaining: this.safetyStopSecondsRemaining
      })
    };
  }

  private createDiveLog(): DiveLog {
    const samples = [...this.activeSamples];
    const startedAt = this.startedAt ?? samples[0]?.timestampMs ?? 0;
    const endedAt = this.endedAt ?? samples[samples.length - 1]?.timestampMs ?? startedAt;

    return {
      id: `dive-${startedAt}-${endedAt}`,
      startedAt,
      endedAt,
      maxDepthMeters: calculateMaxDepth(samples),
      durationSeconds: Math.max(0, Math.round((endedAt - startedAt) / 1000)),
      averageDepthMeters: calculateAverageDepth(samples),
      minTemperatureC: calculateMinTemperature(samples),
      samples
    };
  }
}

export function createDiveEngine(): DiveEngine {
  return new DiveEngine();
}
