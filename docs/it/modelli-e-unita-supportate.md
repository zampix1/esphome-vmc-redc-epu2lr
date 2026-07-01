# Modelli e unita supportate

## Cosa copre questo repository

Il progetto copre due famiglie applicative VMC correlate ma distinte, entrambe costruite attorno alla piattaforma EVCO `EPU2LR` / `c-pro 3 kilo`:

- RED C r9 con terminale remoto EPJ-Graph
- VMC Italia LET-C

## Piattaforma controllore EVCO

Assunzioni hardware confermate per la famiglia `c-pro 3 kilo` / `EPU2LR`:

- controllore programmabile 4 moduli DIN
- USB OTG per programmazione e trasferimento parametri
- bus CAN per il terminale remoto
- RS-485 Modbus RTU slave per integrazione esterna
- famiglia I/O base con 6 ingressi analogici, 5 ingressi digitali, 3 uscite analogiche e 7 uscite digitali
- alimentazione: `24 VAC` oppure `20...30 VDC`

Questo e importante perche il repository non si limita a un dump di registri: assume la topologia di trasporto EVCO realmente usata da queste macchine.

## Famiglia RED C

Dati tecnici consolidati dal manuale applicativo RED C usato durante la validazione sul campo:

| Famiglia modello | Modalita ventilazione | Deumidifica/integrazione + ventilazione | Trattamento in solo ricircolo |
|---|---:|---:|---:|
| RED C 15-30 / 15-30 Vertical | 150 m3/h | 300 m3/h | 300 m3/h |
| RED C 25-50 / 25-50 Vertical | 250 m3/h | 500 m3/h | 500 m3/h |

Note:

- RED C 15-30 appartiene alla classe 150/300.
- RED C 25-50 appartiene alla classe 250/500.
- Il pacchetto RED C in questo repository e la variante piu affidabile perche e stata verificata sia sul campo sia contro manuale.

## Famiglia LET-C

Dati tecnici esposti nella pagina prodotto ufficiale VMC Italia:

| Modello | Layout tubazioni | Modalita ventilazione | Modalita integrazione |
|---|---|---:|---:|
| LET-C 15-30 | Attacchi contrapposti | 150 m3/h | 300 m3/h |
| LET-C 15-30 V | Attacchi su un solo lato | 150 m3/h | 300 m3/h |
| LET-C 25-50 | Attacchi contrapposti | 250 m3/h | 500 m3/h |
| LET-C 25-50 V | Attacchi su un solo lato | 250 m3/h | 500 m3/h |

Note:

- LET-C viene presentata da VMC Italia come unita all-in-one per ventilazione meccanica controllata, deumidificazione e piccola integrazione in caldo/freddo.
- Il pacchetto LET-C di questo repository e allineato alla documentazione, ma non e ancora validato sul campo su una LET-C reale.

## Stato di validazione nel repo

| Variante | Livello di validazione |
|---|---|
| RED C r9 / EPJ-Graph | Validata sul campo e ricontrollata su manuale |
| LET-C | Solo derivazione documentale |

## Baseline Modbus usata nel progetto

Baseline validata sull'installazione RED C usata durante lo sviluppo:

- Modbus RTU
- `19200`
- parita `N`
- `2` stop bit
- indirizzo `1`

Tutti gli indirizzi usati nei pacchetti ESPHome sono in **Base 0**.
