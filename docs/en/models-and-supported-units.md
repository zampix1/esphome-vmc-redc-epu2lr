# Models and Supported Units

## What this repository targets

This project covers two related but distinct VMC application families built around the EVCO `EPU2LR` / `c-pro 3 kilo` platform:

- RED C r9 with EPJ-Graph remote terminal
- VMC Italia LET-C

## EVCO controller platform

Hardware assumptions confirmed for the `c-pro 3 kilo` / `EPU2LR` family:

- 4-DIN programmable controller
- USB OTG for programming and parameter transfer
- CAN bus for the remote terminal
- RS-485 Modbus RTU slave for external integration
- base I/O family with 6 analog inputs, 5 digital inputs, 3 analog outputs and 7 digital outputs
- supply: `24 VAC` or `20...30 VDC`

These points are important because the repository is not only a register map dump; it assumes the actual EVCO transport topology used by these machines.

## RED C family

Technical data consolidated from the RED C application manual reviewed during field validation:

| Model family | Ventilation mode | Integration/dehumidification + ventilation | Recirculation-only treatment |
|---|---:|---:|---:|
| RED C 15-30 / 15-30 Vertical | 150 m3/h | 300 m3/h | 300 m3/h |
| RED C 25-50 / 25-50 Vertical | 250 m3/h | 500 m3/h | 500 m3/h |

Additional notes:

- RED C 15-30 uses the 150/300 class.
- RED C 25-50 uses the 250/500 class.
- The RED C package in this repository is the most trusted one because it was field-tested and cross-checked against the application manual.

## LET-C family

Technical data exposed on the official VMC Italia product page:

| Model | Duct layout | Ventilation mode | Integration mode |
|---|---|---:|---:|
| LET-C 15-30 | Opposed duct connections | 150 m3/h | 300 m3/h |
| LET-C 15-30 V | Single-side duct connections | 150 m3/h | 300 m3/h |
| LET-C 25-50 | Opposed duct connections | 250 m3/h | 500 m3/h |
| LET-C 25-50 V | Single-side duct connections | 250 m3/h | 500 m3/h |

Additional notes:

- LET-C is presented by VMC Italia as an all-in-one unit for controlled mechanical ventilation, dehumidification and small hot/cold integration.
- The document-derived Modbus package in this repository matches the LET-C documentation but is not yet field-tested on a real LET-C unit.

## Field status in this repo

| Variant | Validation level |
|---|---|
| RED C r9 / EPJ-Graph | Field-tested and document cross-checked |
| LET-C | Document-derived only |

## Modbus baseline used in this project

Validated field baseline on the RED C installation used during development:

- Modbus RTU
- `19200`
- parity `N`
- `2` stop bits
- address `1`

All addresses in the ESPHome packages use **Base 0** addressing.
