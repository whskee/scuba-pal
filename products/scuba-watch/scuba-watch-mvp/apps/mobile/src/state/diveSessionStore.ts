import {
  DiveEngine,
  DiveState,
  getFakeDiveProfile,
  type DiveLog,
  type DiveMetrics,
  type DiveSample,
  type FakeDiveProfile,
  type FakeDiveProfileName
} from "@scuba-watch/dive-core";
import { create } from "zustand";

export interface DiveSummary {
  log: DiveLog;
  profileName: FakeDiveProfileName;
  ascentWarningOccurred: boolean;
  safetyStopCompleted: boolean;
}

interface DiveSessionState {
  engine?: DiveEngine;
  profile?: FakeDiveProfile;
  sampleIndex: number;
  visibleSamples: DiveSample[];
  metrics?: DiveMetrics;
  running: boolean;
  summary?: DiveSummary;
  ascentWarningOccurred: boolean;
  startProfile: (profileName: FakeDiveProfileName) => void;
  pause: () => void;
  resume: () => void;
  tick: () => void;
  endSimulation: () => void;
  clearSummary: () => void;
}

const initialMetrics: DiveMetrics = {
  currentDepthMeters: 0,
  maxDepthMeters: 0,
  diveTimeSeconds: 0,
  temperatureC: 26,
  ascentRateMetersPerMinute: 0,
  ascentStatus: "OK",
  safetyStopRequired: false,
  safetyStopSecondsRemaining: 0,
  state: DiveState.SURFACE
};

function buildSummary(params: {
  log: DiveLog;
  profileName: FakeDiveProfileName;
  ascentWarningOccurred: boolean;
  finalMetrics: DiveMetrics;
}): DiveSummary {
  return {
    log: params.log,
    profileName: params.profileName,
    ascentWarningOccurred: params.ascentWarningOccurred,
    safetyStopCompleted:
      !params.finalMetrics.safetyStopRequired ||
      params.finalMetrics.safetyStopSecondsRemaining === 0
  };
}

export const useDiveSessionStore = create<DiveSessionState>((set, get) => ({
  sampleIndex: 0,
  visibleSamples: [],
  metrics: initialMetrics,
  running: false,
  ascentWarningOccurred: false,

  startProfile: (profileName) => {
    const baseProfile = getFakeDiveProfile(profileName);
    const sessionStartedAt = Date.now();
    const profile: FakeDiveProfile = {
      ...baseProfile,
      samples: baseProfile.samples.map((sample) => ({
        ...sample,
        timestampMs: sessionStartedAt + sample.timestampMs
      }))
    };
    const engine = new DiveEngine();

    set({
      engine,
      profile,
      sampleIndex: 0,
      visibleSamples: [],
      metrics: initialMetrics,
      running: true,
      summary: undefined,
      ascentWarningOccurred: false
    });
  },

  pause: () => set({ running: false }),
  resume: () => {
    const { profile, summary } = get();
    if (profile && !summary) {
      set({ running: true });
    }
  },

  tick: () => {
    const {
      engine,
      profile,
      sampleIndex,
      visibleSamples,
      summary,
      ascentWarningOccurred
    } = get();

    if (!engine || !profile || summary) {
      return;
    }

    const sample = profile.samples[sampleIndex];
    if (!sample) {
      const finishedLog = engine.finish();
      const finalMetrics = engine.getMetrics();
      if (finishedLog) {
        set({
          running: false,
          summary: buildSummary({
            log: finishedLog,
            profileName: profile.name,
            ascentWarningOccurred,
            finalMetrics
          })
        });
      }
      return;
    }

    const result = engine.processSample(sample);
    const nextSamples = [...visibleSamples.slice(-119), sample];
    const hadFastAscent = ascentWarningOccurred || result.metrics.ascentStatus === "FAST";

    if (result.completedLog) {
      set({
        sampleIndex: sampleIndex + 1,
        visibleSamples: nextSamples,
        metrics: result.metrics,
        running: false,
        summary: buildSummary({
          log: result.completedLog,
          profileName: profile.name,
          ascentWarningOccurred: hadFastAscent,
          finalMetrics: result.metrics
        })
      });
      return;
    }

    set({
      sampleIndex: sampleIndex + 1,
      visibleSamples: nextSamples,
      metrics: result.metrics,
      ascentWarningOccurred: hadFastAscent
    });
  },

  endSimulation: () => {
    const { engine, profile, metrics, ascentWarningOccurred } = get();
    if (!engine || !profile) {
      return;
    }

    const log = engine.finish();
    const finalMetrics = metrics ?? engine.getMetrics();

    if (log) {
      set({
        running: false,
        summary: buildSummary({
          log,
          profileName: profile.name,
          ascentWarningOccurred:
            ascentWarningOccurred || finalMetrics.ascentStatus === "FAST",
          finalMetrics
        })
      });
    }
  },

  clearSummary: () => set({ summary: undefined })
}));
