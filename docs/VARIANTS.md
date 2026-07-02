# Variants

This repository contains two different Modbus mappings that belong to the same EVCO / RED C family but are **not register-identical**.

## RED C r9 / EPJ-Graph

- Package: `packages/vmc_redc_r9_epjgraph.yaml`
- Device import: `devices/vmc-gateway-esp32s3-redc-r9.yaml`
- Source basis:
  - field validation on the installed gateway
  - RED C r9 EPJ-Graph manual

This is the most trusted variant in the repository because it was field-tested and cross-checked against the manual.

## LET-C

- Package: `packages/vmc_let_c.yaml`
- Device import: `devices/vmc-gateway-esp32s3-let-c.yaml`
- Source basis:
  - LET-C control manual
  - Modbus table extracted from the PDF

This variant is mapped documentally but has not been validated on a real LET-C unit yet.

## Addressing rule used in the repo

All ESPHome register addresses in this repository use **Base 0** addressing.

When reading the manuals:

- the hexadecimal address `0x....` is the reliable `Base 0` reference
- the decimal column printed next to it is often `Base 1`

Example:

- `0x0097 152 Configurazione In1`
  - `0x0097 = 151` decimal -> `Base 0 = 151`
  - `152` -> `Base 1 = 152`

## Recommendation

- **RED C r9 / EPJ-Graph** is the preferred mapping for units that match the family already field-tested in this project.
- **LET-C** applies to units whose documentation matches the LET-C manual, especially in the upper register range.
