# Scuba Watch MVP

Scuba Watch MVP is a software-first prototype of a minimal scuba watch and dive logger. It simulates deterministic dive profiles with fake sensor data, renders a premium watch-style mobile UI, calculates simple dive logging metrics, and saves completed logs locally on the device.

This project is not a decompression computer. It does not calculate decompression obligations, no-decompression limits, tissue loading, gas planning, oxygen exposure, emergency ascent guidance, or any other life-support decision.

## What Is Included

- Shared TypeScript dive engine in `packages/dive-core`
- Expo React Native app in `apps/mobile`
- Deterministic fake profiles for shallow, recreational, and fast-ascent dives
- Local dive-log persistence with AsyncStorage
- Live simulated watch UI with depth, max depth, dive time, temperature, ascent status, safety stop, state, and chart
- Saved dive summaries and log detail views
- Vitest unit tests for core dive behavior
- Architecture, hardware roadmap, and safety documentation

## Install

```sh
npm install
```

## Run The App

```sh
npm run start
```

Then open the Expo app in a simulator, emulator, physical device, or browser target from the Expo CLI.

Useful shortcuts:

```sh
npm run ios
npm run android
npm run web
```

## Run Tests

```sh
npm test
```

## Architecture Overview

The monorepo is split into a reusable dive engine and a mobile UI:

- `packages/dive-core` owns domain types, fake profiles, depth metrics, ascent-rate calculation, safety-stop countdown behavior, and the state machine.
- `apps/mobile` owns the Expo UI, simulation playback, navigation, and AsyncStorage persistence.
- `docs` captures product boundaries and the intended path toward hardware.

The core engine is sample-driven. A fake profile, and later a real pressure sensor pipeline, both feed `DiveSample` objects into the same `DiveEngine.processSample()` method.

## Safety Boundary

This prototype is for simulation and dive logging only. It is not certified, must not be used for real dive safety decisions, and must never replace a certified dive computer, proper dive planning, or training.

See [docs/safety.md](docs/safety.md) for the full safety statement.

## Next Hardware Steps

The next hardware-facing milestone is a sensor-ingestion adapter that can accept pressure and temperature samples from a real device while preserving the current engine API. See [docs/hardware-roadmap.md](docs/hardware-roadmap.md).
