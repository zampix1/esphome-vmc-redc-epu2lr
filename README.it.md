# ESPHome VMC RED C / LET-C / EVCO EPU2LR

Pacchetti ESPHome non ufficiali e configurazioni di esempio per unita VMC basate sulla famiglia EVCO `EPU2LR` / `c-pro 3 kilo`.

Lingua:

- Italiano: questa pagina
- English: [README.md](README.md)

## Scopo del progetto

Questo repository gestisce attualmente due varianti Modbus distinte:

- **RED C r9 / EPJ-Graph**
- **VMC Italia LET-C**

Condividono la stessa famiglia hardware EVCO e una logica macchina simile, ma la parte alta della mappa registri Modbus **non e identica**. Non trattarle come intercambiabili.

## Varianti supportate

| Variante | Pacchetto | Device import | Stato |
|---|---|---|---|
| RED C r9 / EPJ-Graph | `packages/vmc_redc_r9_epjgraph.yaml` | `devices/vmc-gateway-esp32s3-redc-r9.yaml` | Validata sul campo |
| LET-C | `packages/vmc_let_c.yaml` | `devices/vmc-gateway-esp32s3-let-c.yaml` | Derivata da manuale |
| Percorso legacy | `packages/vmc_redc_epu2lr.yaml` | `devices/vmc-gateway-esp32s3.yaml` | Solo compatibilita |

## Famiglie VMC coperte

| Famiglia | Modelli citati nella documentazione | Classe di portata |
|---|---|---|
| RED C | `15-30`, `15-30 Vertical`, `25-50`, `25-50 Vertical` | 150/300 m3/h e 250/500 m3/h |
| LET-C | `15-30`, `15-30 V`, `25-50`, `25-50 V` | 150/300 m3/h e 250/500 m3/h |

Assunzioni hardware EVCO usate nel progetto:

- controllore: famiglia `c-pro 3 kilo` / modello confermato `EPU2LR`
- USB OTG per upload/download parametri
- bus CAN per terminale remoto
- RS-485 Modbus RTU slave per integrazione esterna
- 6 AI / 5 DI / 3 AO / 7 DO sulla base hardware di riferimento

## Struttura del repository

- `packages/` - pacchetti ESPHome riusabili
- `devices/` - nodi di esempio importabili
- `home-assistant/` - dashboard YAML di esempio
- `tools/` - script di supporto
- `docs/` - note tecniche, documentazione bilingue, policy fonti

## Avvio rapido

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

### Scheletro comune del nodo

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

Poi importa il pacchetto della variante corretta.

## Documentazione

Documentazione nel repo:

- [Indice docs ITA](docs/it/README.md)
- [Docs index ENG](docs/en/README.md)
- [Varianti](docs/VARIANTS.md)
- [Logica operativa RED C](docs/VMC_LOGICA_OPERATIVA.md)
- [Analisi hardware EVCO](docs/EVCO_EPU2LR_ANALISI.md)

GitHub Wiki:

- Wiki home (ENG): <https://github.com/zampix1/esphome-vmc-redc-epu2lr/wiki>
- Wiki home (ITA): <https://github.com/zampix1/esphome-vmc-redc-epu2lr/wiki/Home-IT>

## Community

- Discussions: <https://github.com/zampix1/esphome-vmc-redc-epu2lr/discussions>
- Issues: per bug riproducibili e mapping mancanti

## CI

GitHub Actions valida e compila entrambe le varianti di esempio a ogni push su `main`, sulle pull request e su esecuzione manuale.

## Policy fonti e media

Il repository distribuisce **codice originale e note originali**, ma **non** copia dentro al repo PDF vendor, scansioni di manuali o foto prodotto di terzi.

Motivi:

- i manuali EVCO vietano esplicitamente riproduzione e divulgazione senza autorizzazione
- il sito e i media VMC Italia restano contenuti di terzi
- un repository pubblico non dovrebbe incorporare binari o immagini di terzi senza licenza esplicita

Cosa fa invece il repo:

- link alle fonti ufficiali
- sintesi tecnica scritta in modo originale
- note di validazione sul campo e mapping registri

Vedi:

- [Policy fonti ITA](docs/it/politica-fonti.md)
- [Source policy ENG](docs/en/source-policy.md)

## Home Assistant

Se vuoi la dashboard:

1. Copia `home-assistant/vmc-dashboard.yaml` oppure `home-assistant/vmc-dashboard-redc-r9.yaml` nella cartella dashboard di HA.
2. Aggiungi la dashboard in `configuration.yaml`.
3. Installa `button-card` se vuoi usare le card custom presenti nella dashboard.

## Licenza

Codice del repository e documentazione originale: MIT.

Manuali, datasheet, screenshot e immagini vendor di terzi **non** vengono relicenziati da questo progetto.
