# EVCO EPU2LR - Analisi dei manuali hardware

Manuali analizzati:

- `104CP3K0A103` datasheet EVCO
- `114CP3UKE114` EVCO hardware manual (English)
- `114CP3UKI114` EVCO hardware manual (Italian)

Per il repository pubblico, i PDF originali non vengono replicati. Vedi i link ufficiali in [docs/it/politica-fonti.md](it/politica-fonti.md) e [docs/en/source-policy.md](en/source-policy.md).

## 1. Che cosa sono questi tre documenti

`104CP3K0A103` e' una scheda sintetica di famiglia. Serve a capire la piattaforma `c-pro 3 micro / c-pro 3 kilo`, non l'applicazione VMC.

`114CP3UKE114` e `114CP3UKI114` sono lo stesso manuale hardware completo, rispettivamente in inglese e italiano. Sono i documenti importanti per:

- alimentazione
- pinout/morsetti
- USB
- CAN
- RS-485
- I/O analogici e digitali
- terminazioni bus
- limiti elettrici

Non descrivono la logica funzionale RED C. Quella resta definita dal manuale applicativo RED C e dal firmware OEM caricato sul controllore.

## 2. Cosa i manuali EVCO confermano con certezza

Per la famiglia `c-pro 3 kilo`, i manuali confermano:

- formato 4 moduli DIN
- porta USB OTG per programmazione/debug
- upload/download parametri tramite periferica USB
- una porta CAN non optoisolata
- una porta RS-485 non optoisolata con protocollo Modbus slave
- nei modelli `kilo+`, una seconda RS-485 per Modbus master
- 6 ingressi analogici base
- 5 ingressi digitali base
- 3 uscite analogiche base
- 7 uscite digitali base a relè

Nel datasheet `104CP3K0A103` la piattaforma e' descritta cosi', in sostanza:

- RTC
- 6 AI
- 5 DI optoisolati
- 3 AO
- 7 DO
- USB OTG
- CAN
- RS-485 Modbus slave

Questa dotazione e' coerente con le unita VMC coperte dal progetto.

## 3. Implicazioni per EPU2LR

Il codice articolo `EPU2LR` non compare in chiaro nel testo estratto dei PDF, ma dato che il modello e' stato confermato sul campo e dato l'hardware osservato, il quadro coerente e' questo:

- il controllore appartiene alla famiglia `c-pro 3 kilo`
- usa CAN per il terminale remoto EPJ-Graph
- espone Modbus RTU slave su RS-485
- supporta backup/restore parametri via USB

La VMC validata via ESPHome si comporta in modo coerente con questa piattaforma:

- pannello remoto su CAN
- macchina principale su RS-485 Modbus slave
- indirizzo Modbus configurabile lato controllore
- parametri e rete modificabili da menu installatore

## 4. Alimentazione e collegamenti rilevanti

Dal manuale hardware `114CP3UKI114`:

- `c-pro 3 kilo` si alimenta a `24 VAC` oppure `20...30 VDC`
- alimentazione protetta con fusibile `2 A-T 250 V`
- RS-485 max `1000 m`, doppino twistato
- CAN max:
  - `1000 m` a `20 kbaud`
  - `500 m` a `50 kbaud`
  - `250 m` a `125 kbaud`

Per il cablaggio:

- sulle versioni `kilo` ci sono morsettiere a molla estraibili per alimentazione, I/O, CAN e RS-485
- le uscite digitali 1...7 sono relè SPST da `3 A res. @ 250 VAC`
- `NO6`, `NO7` e `CO6/7` corrispondono bene alla coppia di uscite configurabili che nel firmware RED C vedi come `OUT6` e `OUT7`

## 5. CAN e terminale EPJ-Graph

I manuali EVCO confermano che:

- il terminale remoto EPJ-Graph comunica su CAN
- la rete CAN ha terminazione inseribile via micro-switch
- lo stato CAN e il baud rate si possono vedere/configurare da menu

Questo spiega la struttura tipica dell'unita:

- controllore EPU2LR dentro la VMC
- EPJ-Graph a muro come terminale remoto

Questa parte e' importante perche' separa nettamente:

- la logica macchina vera, che gira sul controllore
- il display, che non e' il "cervello", ma un terminale intelligente su CAN

## 6. RS-485 Modbus e relazione con ESPHome

I manuali EVCO confermano:

- una RS-485 slave Modbus sulla famiglia `kilo`
- terminazione RS-485 inseribile da micro-switch
- configurazione di:
  - indirizzo nodo
  - baud rate
  - parita'
  - bit di stop

La baseline validata sul campo e' coerente con questa configurazione:

- `19200`
- `N`
- `2 stop bit`
- `address 1`

Il gateway ESPHome usa quindi un'interfaccia prevista dall'hardware EVCO.

## 7. USB backup/restore parametri

I manuali hardware EVCO confermano in modo esplicito che tramite USB e' possibile:

- copiare i parametri dal controllore a una periferica USB
- copiare i parametri da USB al controllore

Questa conferma abilita due livelli complementari di backup:

- backup nativo EVCO via USB
- snapshot operativo via Modbus/ESPHome/Home Assistant

Le due cose sono complementari, non alternative.

## 8. Cosa i manuali EVCO non bastano a spiegare

I manuali EVCO hardware non descrivono:

- la semantica dei registri RED C
- perche' `Set min UR` limita `ur-I` e `ur-E`
- le priorita' tra fasce orarie, stagioni, ingressi remoti e automatico
- la logica deumidifica/integrazione/bypass

Queste cose appartengono al firmware applicativo RED C e sono documentate nel manuale RED C, non nel manuale EVCO hardware.

Sintesi:

- EVCO descrive **l'hardware**
- RED C descrive **cosa il firmware applicativo fa con quell'hardware**

## 9. Leve utili per il progetto

Da questi manuali, le leve concrete ancora utili per il progetto sono:

- USB backup/restore parametri del controllore
- controllo accurato delle terminazioni CAN / RS-485
- verifica del baud CAN in caso di problemi sul terminale EPJ-Graph
- eventuale esposizione in HA dei parametri di rete e dei parametri installatore piu' rilevanti

## 10. Conclusione tecnica

Architettura tecnica di riferimento:

- **controller macchina**: EVCO `c-pro 3 kilo`, modello validato sul campo `EPU2LR`
- **terminale utente remoto**: EPJ-Graph su CAN
- **bus integrazione esterna**: RS-485 Modbus slave
- **backup nativo**: USB
- **logica funzionale VMC**: firmware OEM RED C, non genericamente EVCO

Il punto tecnico principale e' separare le responsabilita del sistema:

- dall'hardware EVCO
- dal firmware applicativo RED C
- dalla configurazione installata lato setpoint, fasce orarie, password e sensori
