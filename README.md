# ESPHome VMC RED C / EVCO EPU2LR

Unofficial ESPHome package and example configuration for VMC units based on:

- EVCO `EPU2LR` / `c-pro 3 kilo`
- EPJ-Graph wall panel
- Modbus RTU `19200 / N / 2`, slave address `1`

This repository packages the work into a reusable GitHub-hosted ESPHome package, so it can be imported from ESPHome directly and reused by others.

## What is included

- `packages/vmc_redc_epu2lr.yaml`  
  Main ESPHome package with Modbus controller, sensors, selects, buttons and authenticated writes for protected parameters.
- `devices/vmc-gateway-esp32s3.yaml`  
  Example full configuration for an ESP32-S3 RS485 gateway.
- `home-assistant/vmc-dashboard.yaml`  
  Lovelace dashboard for Home Assistant.
- `tools/Export-VmcParameters.ps1`  
  PowerShell export tool for Home Assistant entity snapshots.
- `docs/`  
  Notes about the RED C application logic and EVCO hardware family.

## Hardware assumptions

The default example is built around an ESP32-S3 RS485 board with:

- `GPIO17` = RS485 TX
- `GPIO18` = RS485 RX
- `GPIO21` = RS485 DE/RE

Adjust these substitutions if your board differs.

## Quick start

### Option 1: import the full example

Use the example device YAML:

```yaml
packages:
  vmc: github://zampix1/esphome-vmc-redc-epu2lr/packages/vmc_redc_epu2lr.yaml@main
```

Or start from:

`devices/vmc-gateway-esp32s3.yaml`

### Option 2: include the package in your own ESPHome node

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
  vmc: github://zampix1/esphome-vmc-redc-epu2lr/packages/vmc_redc_epu2lr.yaml@main
```

## Notes

- The package intentionally uses authenticated back-to-back Modbus writes for protected installer parameters.
- Invalid CAN temperature/humidity sensors are hidden internally.
- Temperature and percentage sensors include sanity filters to avoid sentinel spikes.
- Register addresses in this project are `Base 0`. In the RED C PDF, OCR/text extraction often shows the hexadecimal address (`Base 0`) together with the decimal `Base 1` column, which can look like an off-by-one error if read too quickly.
- This is not an official EVCO or RED C project.

## Home Assistant

If you want the dashboard:

1. Copy `home-assistant/vmc-dashboard.yaml` into your HA dashboards folder.
2. Add the dashboard entry to `configuration.yaml`.
3. Ensure `button-card` is installed if you want the custom button cards used by the dashboard.

## License

MIT
