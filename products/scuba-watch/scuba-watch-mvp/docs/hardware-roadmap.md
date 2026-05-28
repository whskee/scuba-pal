# Hardware Roadmap

This MVP keeps the dive logic sample-driven so real hardware can be added without rewriting the app or domain model.

## Pressure And Temperature Sensing

A future prototype can use an MS5837-style pressure sensor or similar waterproof depth sensor. The firmware should convert raw pressure and temperature readings into timestamped samples:

```ts
{
  timestampMs: number,
  depthMeters: number,
  temperatureC: number,
  pressureBar?: number
}
```

Those samples can feed the existing `DiveEngine.processSample()` API.

## MCU Firmware

The first embedded firmware milestone should:

- initialize and calibrate the pressure sensor
- sample pressure and temperature at a stable cadence
- convert pressure to approximate depth
- debounce physical button inputs
- write samples to local flash storage
- expose recent samples over a debug serial link

## BLE Sync

After firmware can record samples, add BLE for post-dive sync:

- advertise a dive-log service
- transfer log metadata first
- transfer samples in chunks
- validate chunk order and checksums
- let the mobile app import logs after the dive

BLE should not be required for in-water safety behavior in a real product.

## Local Flash Storage

The watch hardware should store complete dive samples locally so a phone connection is optional. Storage design should account for:

- interrupted dives
- power loss during writes
- log finalization after surfacing
- fixed-size sample records
- wear leveling or append-only pages

## Waterproof Enclosure Testing

Before any real-water use, the enclosure needs bench and controlled-water testing:

- static pressure tests
- button seal testing
- thermal cycling
- corrosion checks
- condensation checks
- post-test sensor calibration comparison

## Physical Inputs

The MVP UI uses touch controls. Hardware should map to large, gloved-use physical buttons:

- start/select
- back
- up/down or next/previous
- long-press emergency-safe UI escape

Button handling belongs in firmware, but semantic actions should map cleanly to app/watch UI commands.

## Battery Monitoring

Future firmware should sample battery voltage and charging state. The UI can eventually display battery state and low-battery warnings, but this MVP does not make safety decisions from battery state.

## Custom PCB Path

The custom PCB phase should wait until the sensor, storage, BLE, button, battery, and power-management choices are proven on development boards. A sensible sequence is:

1. bench prototype with off-the-shelf MCU and pressure sensor boards
2. sealed prototype with debug access
3. firmware logging and BLE transfer
4. first custom PCB
5. environmental testing
6. industrial design integration
