# ESPHome VMC RED C / LET-C / EVCO EPU2LR

Unofficial ESPHome packages and example configurations for VMC units based on the EVCO `EPU2LR` / `c-pro 3 kilo` family.

Language:

- English: this page
- Italian: [README.it.md](README.it.md)

## Project scope

This repository currently targets two explicit Modbus variants:

- **RED C r9 / EPJ-Graph**
- **VMC Italia LET-C**

They share the same EVCO hardware family and a similar operating model, but the upper Modbus register map is **not identical**. Do not assume one package fits both.

## Supported variants

| Variant | Package | Device import | Status |
|---|---|---|---|
| RED C r9 / EPJ-Graph | `packages/vmc_redc_r9_epjgraph.yaml` | `devices/vmc-gateway-esp32s3-redc-r9.yaml` | Field-tested |
| LET-C | `packages/vmc_let_c.yaml` | `devices/vmc-gateway-esp32s3-let-c.yaml` | Document-derived |
| Legacy compatibility path | `packages/vmc_redc_epu2lr.yaml` | `devices/vmc-gateway-esp32s3.yaml` | Compatibility only |

## VMC families covered

| Family | Models covered in docs | Airflow reference |
|---|---|---|
| RED C | `15-30`, `15-30 Vertical`, `25-50`, `25-50 Vertical` | 150/300 m3/h and 250/500 m3/h classes |
| LET-C | `15-30`, `15-30 V`, `25-50`, `25-50 V` | 150/300 m3/h and 250/500 m3/h classes |

The EVCO platform assumptions used by this project are:

- controller family: `c-pro 3 kilo` / model family `EPU2LR`
- USB OTG for upload/download of parameters
- CAN bus for the remote terminal
- RS-485 Modbus RTU slave for external integration
- 6 AI / 5 DI / 3 AO / 7 DO on the base hardware family

## Repository layout

- `packages/` - reusable ESPHome packages
- `devices/` - importable example nodes
- `home-assistant/` - dashboard YAML examples
- `tools/` - helper scripts
- `docs/` - technical notes, bilingual documentation, source policy

## Quick start

### RED C r9 / EPJ-Graph

```yaml
packages:
  vmc: github://zampix1/esphome-vmc-redc-epu2lr/packages/vmc_redc_r9_epjgraph.yaml@main
```

### LET-C

```yaml
packages:
  vmc: github://zampix1/esphome-vmc-redc-epu2lr/packages/vmc_let_c.yaml@main
```

### Common node skeleton

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
```

Import the package that matches the target variant.

### Required ESPHome secrets

The importable device examples use a secret for the fallback access point password. Add it to your ESPHome `secrets.yaml`:

```yaml
wifi_ssid: "your-wifi"
wifi_password: "your-password"
vmc_fallback_ap_password: "change-this-long-password"
```

## Built-in diagnostics

The packages expose operational diagnostics intended to make field troubleshooting faster:

- effective dehumidification, based on active mode plus compressor state
- standby/consent indicators for requested functions that are not actually running
- display dew point estimate
- evaporator margin against a conservative low-temperature threshold
- a short operational diagnostic text sensor

## Documentation

Repo docs:

- [Italian docs index](docs/it/README.md)
- [English docs index](docs/en/README.md)
- [External reference media](docs/en/external-reference-media.md)
- [Variants](docs/VARIANTS.md)
- [RED C operating logic](docs/VMC_LOGICA_OPERATIVA.md)
- [EVCO hardware analysis](docs/EVCO_EPU2LR_ANALISI.md)

GitHub Wiki:

- Wiki home (EN): <https://github.com/zampix1/esphome-vmc-redc-epu2lr/wiki>
- Wiki home (IT): <https://github.com/zampix1/esphome-vmc-redc-epu2lr/wiki/Home-IT>

## Community

- Discussions: <https://github.com/zampix1/esphome-vmc-redc-epu2lr/discussions>
- Issues: use issues for reproducible bugs and missing mappings

## External reference media

Official VMC Italia product images hosted on the vendor site:

- LET-C 15-30: <https://www.vmcitalia.it/wp-content/uploads/2026/03/letc_1530.jpg>
- LET-C 15-30 V: <https://www.vmcitalia.it/wp-content/uploads/2026/03/letc_1530_vert.jpg>
- LET-C 25-50: <https://www.vmcitalia.it/wp-content/uploads/2026/03/letc_2550.jpg>
- LET-C 25-50 V: <https://www.vmcitalia.it/wp-content/uploads/2026/03/letc_2550_vert.jpg>

Representative external images:

![LET-C 25-50](https://www.vmcitalia.it/wp-content/uploads/2026/03/letc_2550.jpg)
![LET-C 25-50 V](https://www.vmcitalia.it/wp-content/uploads/2026/03/letc_2550_vert.jpg)

Official product and control PDFs:

- LET-C product page: <https://www.vmcitalia.it/prodotto/deumidificatori-con-vmc-let-c/>
- LET-C 15-30 product PDF: <https://www.vmcitalia.it/wp-content/uploads/2022/04/VMC_LET-C_15-30_H.pdf>
- LET-C 15-30 V product PDF: <https://www.vmcitalia.it/wp-content/uploads/2026/03/VMC_LET-C_15-30_V.pdf>
- LET-C 25-50 product PDF: <https://www.vmcitalia.it/wp-content/uploads/2026/03/VMC_LET-C_25-50_H.pdf>
- LET-C 25-50 V product PDF: <https://www.vmcitalia.it/wp-content/uploads/2026/03/VMC_LET-C_25-50_V.pdf>
- LET-C control guide: <https://www.vmcitalia.it/wp-content/uploads/2026/03/Tipologie-di-controllo-unita_LET-C.pdf>

## CI

GitHub Actions validates and compiles both example variants on every push to `main`, on pull requests, and on manual workflow dispatch.

## Source and media policy

This repository distributes **original code and original documentation notes** under MIT, but it does **not** mirror vendor PDFs, scanned manuals or vendor product photos.

Why:

- EVCO manuals explicitly forbid reproduction/disclosure without authorization.
- VMC Italia site and media remain third-party content.
- Public repositories should not vendor third-party binaries or images unless the license is explicit.

What this repo does instead:

- links to official product pages and manuals
- summarizes technical data in original wording
- keeps field notes and reverse-mapped register information

See:

- [English source policy](docs/en/source-policy.md)
- [Italian source policy](docs/it/politica-fonti.md)

## Home Assistant

Example dashboard setup:

1. Copy `home-assistant/vmc-dashboard.yaml` or `home-assistant/vmc-dashboard-redc-r9.yaml` into the Home Assistant dashboards folder.
2. Add the dashboard entry to `configuration.yaml`.
3. Install `button-card` when using the custom button cards included in the dashboard.

## License

Repository code and original documentation: MIT.

Third-party manuals, datasheets, screenshots and vendor images are **not** relicensed by this project.
