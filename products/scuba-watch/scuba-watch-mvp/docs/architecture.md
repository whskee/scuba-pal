# Architecture

Scuba Watch MVP is organized as a software-first monorepo so the dive logic can be tested independently from the mobile UI and reused later by embedded-facing code.

## Packages

### `packages/dive-core`

The dive core is pure TypeScript and has no React Native or backend dependency. It contains:

- `types.ts` for shared sample, metric, state, and log types
- `ascentRate.ts` for rolling-window ascent-rate calculation
- `safetyStop.ts` for safety-stop requirement and countdown behavior
- `diveStateMachine.ts` for surface, descent, bottom, ascent, safety stop, and surfaced state transitions
- `fakeProfiles.ts` for deterministic simulation profiles
- `diveEngine.ts` for the sample-driven engine facade

The key runtime API is:

```ts
const engine = new DiveEngine();
const result = engine.processSample(sample);
```

That shape is intentional. Fake data, replayed logs, BLE packets, or MCU-originated samples can all enter the same engine path.

### `apps/mobile`

The Expo app owns:

- profile selection
- simulation playback
- watch-style live UI
- local app state with Zustand
- saved dive-log persistence with AsyncStorage
- summary and log detail screens

The app offsets deterministic fake profile timestamps to the current wall-clock time when a simulation starts. The core profiles remain deterministic for tests.

## Data Flow

1. User selects a fake profile.
2. The mobile app creates a new `DiveEngine`.
3. A timer feeds one deterministic `DiveSample` into the engine per simulation tick.
4. The engine returns live `DiveMetrics`.
5. The UI renders depth, time, max depth, temperature, ascent status, safety stop, and state.
6. When the engine completes a dive, the app shows a summary.
7. The user saves the completed log into AsyncStorage.

## Safety Boundary In Architecture

No decompression model exists in the codebase. The engine only calculates display and logging metrics requested for MVP-0:

- depth
- max depth
- dive time
- temperature
- ascent rate status
- simple safety-stop countdown
- simple dive state
- saved dive summary

There is no NDL, tissue loading, gas mix, CNS oxygen, decompression ceiling, gas consumption, or emergency ascent algorithm.

## Future Integration Points

- Replace fake profile playback with a sensor adapter that emits `DiveSample`.
- Add a hardware transport module for BLE sync.
- Add a firmware-side sample protocol and checksum.
- Add import/export of signed dive logs.
- Add test fixtures from hardware bench recordings.
