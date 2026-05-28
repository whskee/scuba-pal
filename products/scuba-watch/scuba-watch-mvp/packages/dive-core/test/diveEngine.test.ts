import { describe, expect, it } from "vitest";
import {
  DiveEngine,
  DiveState,
  calculateAscentRateMetersPerMinute,
  fastAscentMistake,
  recreationalDive,
  shallowTrainingDive,
  type DiveSample
} from "../src";

function sample(second: number, depthMeters: number): DiveSample {
  return {
    timestampMs: second * 1000,
    depthMeters,
    temperatureC: 24
  };
}

describe("DiveEngine", () => {
  it("detects dive start after depth is held below the surface threshold", () => {
    const engine = new DiveEngine();

    for (let second = 0; second <= 9; second += 1) {
      engine.processSample(sample(second, 1.3));
    }

    expect(engine.getMetrics().state).toBe(DiveState.SURFACE);

    engine.processSample(sample(10, 1.3));

    expect(engine.getMetrics().state).not.toBe(DiveState.SURFACE);
    expect(engine.getMetrics().diveTimeSeconds).toBe(10);
  });

  it("detects dive end after surfacing is held for 60 seconds", () => {
    const engine = new DiveEngine();
    let completed = false;

    for (const profileSample of shallowTrainingDive().samples) {
      const result = engine.processSample(profileSample);
      completed = Boolean(result.completedLog);
    }

    expect(completed).toBe(true);
    expect(engine.getMetrics().state).toBe(DiveState.SURFACED);
  });

  it("updates max depth continuously", () => {
    const engine = new DiveEngine();

    [0, 2, 4, 12, 9].forEach((depth, index) => {
      engine.processSample(sample(index * 10, depth));
    });

    expect(engine.getMetrics().maxDepthMeters).toBe(12);
  });

  it("calculates ascent rate from recent samples", () => {
    const rate = calculateAscentRateMetersPerMinute([
      sample(0, 18),
      sample(20, 15)
    ]);

    expect(rate).toBeCloseTo(9, 2);
  });

  it("flags a fast ascent warning", () => {
    const engine = new DiveEngine();
    const statuses = fastAscentMistake().samples.map(
      (profileSample) => engine.processSample(profileSample).metrics.ascentStatus
    );

    expect(statuses).toContain("FAST");
  });

  it("requires a safety stop after max depth exceeds 10 m", () => {
    const engine = new DiveEngine();

    for (const profileSample of recreationalDive().samples.slice(0, 180)) {
      engine.processSample(profileSample);
    }

    expect(engine.getMetrics().safetyStopRequired).toBe(true);
  });

  it("only decreases the safety stop countdown in the 3-6 m zone", () => {
    const engine = new DiveEngine();
    for (let second = 0; second <= 20; second += 1) {
      engine.processSample(sample(second, 12));
    }

    const before = engine.getMetrics().safetyStopSecondsRemaining;
    engine.processSample(sample(21, 7));
    expect(engine.getMetrics().safetyStopSecondsRemaining).toBe(before);

    engine.processSample(sample(22, 5));
    expect(engine.getMetrics().safetyStopSecondsRemaining).toBe(before - 1);
  });

  it("does not require a safety stop for a shallow training dive", () => {
    const engine = new DiveEngine();

    for (const profileSample of shallowTrainingDive().samples) {
      engine.processSample(profileSample);
    }

    expect(engine.getMetrics().safetyStopRequired).toBe(false);
  });
});
