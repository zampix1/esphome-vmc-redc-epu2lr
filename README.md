# ESPHome VMC RED C / LET-C / EVCO EPU2LR

Unofficial ESPHome packages and example configurations for VMC units based on the EVCO `EPU2LR` / `c-pro 3 kilo` family.

This repository now contains **two explicit Modbus variants**:

- **RED C r9 / EPJ-Graph**
- **LET-C**

They share a lot of logic, but **the upper Modbus register map is not identical**. Do not assume one package fits both.

## Variants

| Variant | Package | Status | Notes |
|---|---|---|---|
| RED C r9 / EPJ-Graph | `packages/vmc_redc_r9_epjgraph.yaml` | Field-tested | Built from your working gateway and cross-checked against the RED C r9 manual. |
| LET-C | `packages/vmc_let_c.yaml` | Document-derived | Mapped against the LET-C manual. Not field-tested on a real LET-C unit. |
| Legacy compatibility path | `packages/vmc_redc_epu2lr.yaml` | Compatibility | Preserved for older import URLs; use the explicit RED C r9 package for new setups. |

## What is included

- `packages/vmc_redc_r9_epjgraph.yaml`  
  Canonical RED C r9 / EPJ-Graph package.
- `packages/vmc_let_c.yaml`  
  LET-C package with its own upper register map.
- `packages/vmc_redc_epu2lr.yaml`  
  Backward-compatible package path kept for existing imports.
- `devices/vmc-gateway-esp32s3-redc-r9.yaml`  
  Full importable example for RED C r9 / EPJ-Graph.
- `devices/vmc-gateway-esp32s3-let-c.yaml`  
  Full importable example for LET-C.
- `devices/vmc-gateway-esp32s3.yaml`  
  Legacy RED C example path retained for compatibility.
- `home-assistant/vmc-dashboard.yaml`  
  Dashboard originally built around the RED C r9 variant.
- `home-assistant/vmc-dashboard-redc-r9.yaml`  
  Explicitly named copy of the same dashboard.
- `tools/Export-VmcParameters.ps1`  
  PowerShell export tool for Home Assistant entity snapshots.
- `docs/`  
  Notes about the RED C application logic, EVCO hardware family and addressing caveats.

## Hardware assumptions

The example gateway is built around an ESP32-S3 RS485 board with:

- `GPIO17` = RS485 TX
- `GPIO18` = RS485 RX
- `GPIO21` = RS485 DE/RE

Adjust substitutions if your board differs.

## Quick start

### RED C r9 / EPJ-Graph

Full example:

```yaml
packages:
  vmc: github://zampix1/esphome-vmc-redc-epu2lr/packages/vmc_redc_r9_epjgraph.yaml@main
```

Importable device:

`devices/vmc-gateway-esp32s3-redc-r9.yaml`

### LET-C

Full example:

```yaml
packages:
  vmc: github://zampix1/esphome-vmc-redc-epu2lr/packages/vmc_let_c.yaml@main
```

Importable device:

`devices/vmc-gateway-esp32s3-let-c.yaml`

## Common custom node skeleton

```yaml
substitutions:
  name: vmc-gateway
  friendly_name: VMC Gateway
  board: esp32-s3-devkitc-1
  modbus_tx_pin: GPIO17
  modbus_rx_pin: GPIO18
  modbus_flow_control_pin: GPIO21

esphome:
  name: ${name}
  friendly_name: ${friendly_name}

esp32:
  board: ${board}
  framework:
    type: arduino

logger:
api:
ota:
  - platform: esphome

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

captive_portal:

web_server:
  port: 80
  version: 3

packages:
  vmc: github://zampix1/esphome-vmc-redc-epu2lr/packages/vmc_redc_r9_epjgraph.yaml@main
```

Swap the package path for `vmc_let_c.yaml` if you are targeting LET-C.

## Notes

- Protected installer parameters are written with authenticated back-to-back Modbus writes.
- Invalid CAN temperature/humidity sensors are hidden internally.
- Temperature and percentage sensors include sanity filters to avoid sentinel spikes.
- Register addresses in this project are **Base 0**.
- In the RED C and LET-C PDFs, OCR/text extraction often shows the hexadecimal address (`Base 0`) together with the decimal `Base 1` column. Read the hexadecimal address if you want the value used by these packages.
- The included dashboard was built around the RED C r9 variant. It should mostly work on LET-C for common entities, but it is not yet curated specifically for LET-C-only parameters.
- This is not an official EVCO, VMC Italia or RED C project.

## Home Assistant

If you want the dashboard:

1. Copy `home-assistant/vmc-dashboard.yaml` or `home-assistant/vmc-dashboard-redc-r9.yaml` into your HA dashboards folder.
2. Add the dashboard entry to `configuration.yaml`.
3. Ensure `button-card` is installed if you want the custom button cards used by the dashboard.

## License

MIT
