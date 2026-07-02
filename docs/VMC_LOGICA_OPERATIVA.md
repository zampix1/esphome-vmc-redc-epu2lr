# VMC RED C r9 EPJ-Graph - Logica operativa completa

Fonte analizzata: manuale applicativo RED C r9 / EPJ-Graph usato durante la validazione sul campo.

Questa nota sintetizza la logica funzionale della macchina, non la parte meccanica di installazione. Gli indirizzi Modbus sono indicati in **base 0**, coerenti con Home Assistant/ESPHome.

## 0. Conferme dalla rilettura del PDF

Rilettura fatta sul manuale applicativo RED C r9 / EPJ-Graph, incluse le schermate e le figure del controllo EPJ-Graph.

Conferme operative importanti:

- I setpoint rapidi `St-I`, `ur-I`, `St-E`, `ur-E` sono effettivamente setpoint utente, modificabili dal menu rapido e dalla pagina `6.a Set point`.
- Se le fasce orarie sono attive, sul controllo EPJ-Graph i setpoint rapidi e le funzioni non sono modificabili: i valori vengono mostrati come `--` oppure compare l'avviso relativo alle fasce orarie attive.
- Il menu rapido setpoint del controllo remoto include anche la pagina/calcolo del punto di rugiada; e' un indizio chiaro che il costruttore si aspetta un uso "guidato" dei setpoint di umidita, soprattutto in estate.
- Il parametro `Set minima umidita ambiente impostabile` (`n-ur`, Modbus base0 `105`) e' un vincolo reale della macchina, non solo descrittivo: il manuale dice esplicitamente che **non e' possibile impostare setpoint di umidita inferiori a questo valore**.
- Il valore minimo umidita e' nella pagina installatore `6.a Set point`, mentre i setpoint utente stanno nella prima pagina: valori `ur-I`/`ur-E` inferiori al minimo installatore vengono quindi respinti o riportati al limite ammesso.
- Il cambio stagione automatico usa una logica mista calendario + temperatura esterna/rinnovo + tempo di permanenza sopra/sotto soglia; non e' un semplice toggle temperatura.
- La funzione deumidifica con compressore puo' essere limitata per stagione e non puo' convivere liberamente con tutte le combinazioni di integrazione; il manuale segnala esplicitamente che la deumidifica con compressore in inverno non e' attivabile se e' gia' attiva l'integrazione nella stessa stagione.
- Le schermate illustrative del manuale confermano che il display/EPJ-Graph non e' un semplice pannello passivo: espone vincoli, stati di standby, fasce orarie, allarmi e rete CAN in modo coerente con la logica interna della scheda.

## 1. Modello mentale della macchina

La RED C e' una VMC bilanciata con recuperatore ad alta efficienza, batteria ad acqua, circuito frigorifero e logiche di:

- ventilazione con recupero;
- sola ricircolazione interna;
- deumidifica;
- integrazione termica estiva/invernale;
- bypass per free-cooling/free-heating;
- antigelo recuperatore;
- protezione batteria/circuito frigorifero;
- gestione filtri;
- comandi locali, remoti, automatici, fasce orarie e Modbus.

I componenti principali letti/comandati dalla logica sono:

- ventilatore immissione;
- ventilatore espulsione/ripresa;
- serranda ricircolo;
- serranda bypass recuperatore;
- compressore;
- valvola on/off scambiatore a piastre;
- valvola modulante H2O, sulle versioni Plus;
- richiesta pompa/contatto configurabile;
- sonde temperatura: immissione, rinnovo/esterna, ripresa, H2O ingresso, condensatore, evaporatore, display remoto, CAN;
- sonde umidita: display remoto, CAN.

## 2. Sorgenti di comando

La macchina puo' essere comandata da piu' sorgenti:

- display integrato;
- controllo remoto EPJ-Graph;
- ingressi digitali configurabili;
- fasce orarie, se attive;
- logica automatica interna;
- Modbus RS485 slave.

Le fasce orarie, quando abilitate, prendono il controllo di velocita, funzioni e setpoint della fascia corrente. In quel caso display/EPJ non permettono la modifica rapida di velocita, funzioni e setpoint, salvo la gestione stagione dove prevista.

Le velocita forzate da ingresso remoto impediscono la normale modifica della velocita dal display; e' possibile spegnere l'unita salvo diversa configurazione della priorita `Vel/OFF`.

## 3. Modi di attivazione delle funzioni

Ogni funzione principale ha una modalita di gestione.

Ventilazione:

- `OFF`: sempre disattivata;
- `ON`: sempre attiva;
- `REMOTO`: attiva quando l'ingresso configurato e' chiuso.

Deumidifica:

- `OFF`: sempre disattivata;
- `ON`: sempre attiva;
- `REMOTO`: attiva da ingresso digitale;
- `AUTO/REMOTO`: attiva da logica automatica o da ingresso remoto;
- `AUTO`: attiva solo da logica automatica.

Integrazione:

- `OFF`: sempre disattivata;
- `ON`: sempre attiva;
- `REMOTO`: attiva da ingresso digitale;
- `AUTO/REMOTO`: attiva da logica automatica o da ingresso remoto;
- `AUTO`: attiva solo da logica automatica.

Solo ricircolo:

- `OFF`: sempre disattivato;
- `ON`: sempre attivo;
- `REMOTO`: attivo da ingresso digitale.

Estate/Inverno:

- `MANUALE`: stagione impostata manualmente;
- `AUTO`: stagione stabilita da calendario e/o temperatura esterna;
- `REMOTO`: stagione da ingresso digitale, aperto = inverno, chiuso = estate.

## 4. Stati funzionali principali

La macchina distingue lo stato di velocita impostata dallo stato funzionale attivo.

Velocita:

- `0`: Off;
- `1`: Velocita 1;
- `2`: Velocita 2;
- `3`: Velocita 3;
- `4`: Velocita automatica 1;
- `5`: Velocita automatica 2;
- `6-10`: velocita 1/2/3/auto1/auto2 in standby;
- `11-16`: Off o velocita 1/2/3/auto1/auto2 forzate da remoto;
- `17`: manutenzione.

Modalita attiva:

- `0`: Off;
- `1`: Ventilazione;
- `2`: Deumidifica;
- `3`: Integrazione;
- `4`: Deumidifica + Integrazione;
- `5`: Ricircolo;
- `6`: Ventilazione + Deumidifica;
- `7`: Ventilazione + Integrazione;
- `8`: Ventilazione + Deumidifica + Integrazione;
- `9`: Ventilazione + Ricircolo;
- `10`: Manutenzione;
- `11`: Stand-by;
- `12`: Deumidifica STBY;
- `13`: Integrazione STBY;
- `14`: Deumidifica + Integrazione STBY;
- `15`: Ventilazione + Deumidifica STBY;
- `16`: Ventilazione + Integrazione STBY;
- `17`: Ventilazione + Deumidifica + Integrazione STBY.

Stand-by significa: velocita diversa da Off, ma nessuna funzione realmente attiva o funzione in attesa/blocco temporaneo.

## 5. Matrice di funzionamento aria e componenti

### 5.1 Ventilazione

Richieste:

- Ventilazione ON;
- Deumidifica OFF;
- Integrazione OFF;
- Ricircolo OFF.

Effetto:

- entrambi i ventilatori attivi;
- ricambio aria esterna/interna bilanciato;
- recuperatore attivo;
- nessuna deumidifica e nessuna integrazione, tranne eventuale bypass free-cooling/free-heating.

Portate nominali:

- RED C 15/30: immissione 150 m3/h, espulsione 150 m3/h, ricircolo 0;
- RED C 25/50: immissione 250 m3/h, espulsione 250 m3/h, ricircolo 0.

Componenti:

- serranda ricircolo chiusa;
- bypass aperto/chiuso secondo convenienza;
- compressore spento;
- valvola scambiatore chiusa;
- valvola acqua 0%;
- richiesta pompa non attiva.

### 5.2 Solo ricircolo

Richieste:

- Ventilazione OFF;
- Deumidifica OFF;
- Integrazione OFF;
- Ricircolo ON.

Effetto:

- solo ventilatore di immissione;
- aria interna fatta circolare senza rinnovo;
- nessun trattamento termico/deumidifica.

Portate nominali:

- RED C 15/30: immissione 300 m3/h, tutto ricircolo, espulsione 0;
- RED C 25/50: immissione 500 m3/h, tutto ricircolo, espulsione 0.

Componenti:

- serranda ricircolo aperta;
- bypass chiuso;
- compressore spento;
- valvola scambiatore chiusa;
- valvola acqua 0%;
- richiesta pompa non attiva.

### 5.3 Deumidifica e/o integrazione con ventilazione

Richieste:

- Ventilazione ON;
- almeno una tra Deumidifica e Integrazione ON;
- Ricircolo puo' essere ON o OFF.

Effetto:

- rinnovo aria attivo;
- ricircolo parziale per aumentare aria trattata;
- trattamento termico/deumidifica secondo richiesta.

Portate nominali:

- RED C 15/30: immissione 300 m3/h, di cui ricircolo 150 m3/h, espulsione 150 m3/h;
- RED C 25/50: immissione 500 m3/h, di cui ricircolo 250 m3/h, espulsione 250 m3/h.

Componenti:

- serranda ricircolo aperta;
- bypass aperto/chiuso secondo convenienza;
- richiesta pompa attiva;
- valvola modulante H2O aperta in modulazione 0-100%;
- compressore acceso solo se la richiesta include deumidifica;
- compressore non immediato: parte dopo il ritardo/monitoraggio;
- valvola scambiatore on/off aperta in deumidifica quando la valvola modulante e' al 100%;
- in sola integrazione il compressore resta spento e la valvola scambiatore resta chiusa.

### 5.4 Deumidifica e/o integrazione senza ventilazione

Richieste:

- Ventilazione OFF;
- almeno una tra Deumidifica e Integrazione ON;
- Ricircolo puo' essere ON o OFF.

Effetto:

- nessun rinnovo aria;
- aria interna trattata in ricircolo pieno;
- utile per deumidifica/integrazione senza ricambio.

Portate nominali:

- RED C 15/30: immissione 300 m3/h, tutto ricircolo, espulsione 0;
- RED C 25/50: immissione 500 m3/h, tutto ricircolo, espulsione 0.

Componenti:

- serranda ricircolo aperta;
- bypass chiuso;
- richiesta pompa attiva;
- valvola modulante H2O aperta in modulazione 0-100%;
- compressore acceso solo in deumidifica;
- valvola scambiatore aperta in deumidifica con valvola modulante al 100%;
- in sola integrazione compressore spento e valvola scambiatore chiusa.

## 6. Deumidifica

La deumidifica puo' essere manuale, remota, automatica o mista.

Elementi principali:

- usa il compressore solo se la configurazione lo consente nella stagione corrente;
- puo' essere abilitata estate/inverno, solo inverno o solo estate;
- puo' usare anche la ventilazione automatica in base all'umidita;
- richiede acqua fredda: con acqua calda la deumidifica perde efficacia e puo' mandare in blocco la macchina;
- se la temperatura H2O supera la soglia massima per acqua fredda, la deumidifica con compressore viene bloccata, ma la richiesta pompa resta attiva;
- se acqua fredda manca a lungo, viene registrato l'evento "mancanza acqua fredda" senza bloccare funzioni.

Parametri chiave:

- set umidita inverno/estate;
- differenziale umidita per attivazione automatica;
- set minima umidita impostabile;
- selezione sonda umidita: display, CAN, display+CAN;
- max temperatura H2O fredda per abilitazione compressore/deumidifica estiva;
- max apertura valvola H2O;
- valvola standard/invertita;
- temperatura rinnovo sopra cui cambia/maggiora la gestione ricircolo/deumidifica;
- banda PI e tempo integrale valvola;
- ritardo avvio compressore;
- ritardo valvola scambiatore.

## 7. Integrazione

L'integrazione e' trattamento sensibile dell'aria in immissione.

Puo' essere:

- estiva, raffrescamento;
- invernale, riscaldamento;
- abilitata in entrambe le stagioni, solo inverno o solo estate.

Elementi principali:

- in sola integrazione non usa il compressore;
- usa la batteria ad acqua e la valvola modulante;
- attiva la richiesta pompa;
- in estate e' bloccata se l'acqua e' troppo calda;
- in inverno usa un set di temperatura immissione per riscaldamento;
- in estate usa un set di temperatura immissione per raffrescamento;
- puo' attivare ricircolo/velocita ricircolo in inverno solo sopra una temperatura minima di immissione, per evitare aumento velocita con aria fredda.

Parametri chiave:

- modalita integrazione;
- tipo integrazione: sempre/inverno/estate;
- set riscaldamento;
- set raffreddamento;
- temperatura minima immissione per attivazione ricircolo in inverno;
- ritardo OFF pompa;
- max temperatura H2O fredda per integrazione estiva;
- max apertura valvola;
- valvola standard/invertita;
- banda PI e tempo integrale valvola.

## 8. Velocita ventilatori

Le velocita impostabili sono:

- Off;
- Vel 1;
- Vel 2;
- Vel 3;
- Vauto 1;
- Vauto 2.

Vauto 1 e Vauto 2 regolano la velocita entro min/max dedicati in base a temperatura e umidita. Tipicamente possono essere usate come profili "notte" e "giorno".

Parametri:

- set V1;
- set V2;
- set V3;
- set aumento velocita immissione con ricircolo attivo;
- min/max Vauto1;
- min/max Vauto2;
- pressurizzazione/depressurizzazione;
- differenziale Vauto in base alla temperatura;
- differenziale Vauto in base all'umidita con compressore;
- differenziale Vauto in base all'umidita con ventilazione;
- massima velocita impostabile per ventilazione;
- ritardo spegnimento alimentazione ventilatori.

La pressurizzazione agisce come rapporto fra ventilatore immissione ed espulsione. A 100% il sistema e' bilanciato; sotto 100% riduce l'immissione rispetto all'espulsione; sopra 100% aumenta l'immissione, saturando eventualmente a 100% e riducendo l'altro lato.

## 9. Estate/Inverno

La stagione influenza:

- setpoint temperatura/umidita usati;
- abilitazione compressore in deumidifica;
- integrazione riscaldamento/raffrescamento;
- logica free-cooling/free-heating;
- uscite digitali configurabili estate/inverno.

Cambio manuale:

- l'utente imposta inverno/estate.

Cambio remoto:

- ingresso digitale aperto = inverno;
- ingresso digitale chiuso = estate.

Cambio automatico:

- nel periodo Start Inverno - End Inverno, stagione forzata a inverno;
- nel periodo Start Estate - End Estate, stagione forzata a estate;
- nei periodi non assegnati decide la temperatura rinnovo/esterna;
- sotto soglia inverno per tempo impostato passa a inverno;
- sopra soglia estate per tempo impostato passa a estate;
- nella fascia intermedia mantiene lo stato precedente e puo' permettere intervento manuale.

Parametri:

- start/end inverno giorno/mese;
- start/end estate giorno/mese;
- soglia temperatura rinnovo per inverno;
- soglia temperatura rinnovo per estate;
- tempo permanenza sopra/sotto soglia, default 480 minuti.

## 10. Bypass, free-cooling e free-heating

Con ventilazione attiva, la macchina confronta temperatura ripresa/interna e rinnovo/esterna.

Il bypass apre quando conviene usare direttamente l'aria esterna senza recuperatore:

- free-cooling: aria esterna utile a raffrescare;
- free-heating: aria esterna utile a riscaldare.

Configurazioni:

- bypass disabilitato;
- solo free-cooling;
- solo free-heating;
- free-cooling + free-heating.

Parametri:

- temperatura minima rinnovo per free-cooling, per evitare immissione troppo fredda;
- differenziale gestione bypass.

In sola ricircolazione e in deumidifica/integrazione senza ventilazione, il bypass resta chiuso.

## 11. Antigelo recuperatore

La protezione antigelo del recuperatore usa la temperatura sul lato espulsione/rinnovo secondo i parametri interni.

Step indicati dal manuale:

- set antigelo 1: riduzione velocita ventilatore immissione del 30%;
- set antigelo 2: riduzione velocita ventilatore immissione del 70%;
- differenziale antigelo per uscita/isteresi.

Se presente resistenza antigelo configurata su uscita digitale, puo' essere attivata. Il display distingue:

- antigelo con riduzione velocita;
- antigelo con resistenza;
- post-ventilazione.

## 12. Allarmi ed effetti

La macchina registra storico eventi/allarmi con numero evento e timestamp.

Eventi/allarmi:

1. reset allarmi;
2. reset ore filtri;
3. alta pressione refrigerante;
4. bassa pressione refrigerante;
5. mancanza freon;
6. alta temperatura acqua;
7. bassa temperatura circuito idraulico/batteria;
8. NTC condensatore;
9. NTC evaporatore;
10. NTC ripresa;
11. NTC immissione;
12. NTC rinnovo;
13. NTC H2O ingresso;
14. sonda temperatura display;
15. sonda umidita display;
16. sonda temperatura CAN;
17. sonda umidita CAN;
18. blocco da allarme filtri;
19. allarme filtri;
20. mancanza acqua fredda, solo segnalazione/storico.

Allarmi 3-5:

- sono quelli del circuito frigorifero;
- disattivano immediatamente il compressore;
- fermano quindi la funzione di deumidifica;
- possono essere autoresettati dopo il tempo configurato, se autoreset attivo;
- altrimenti richiedono reset manuale.

Allarme 6:

- temperatura acqua troppo alta durante deumidifica e/o integrazione estiva;
- blocca deumidifica e integrazione fino a reset.

Allarme 7:

- acqua/batteria troppo fredda;
- rischio congelamento circuito idraulico.

Allarmi 8-17:

- guasti/corti sonde;
- reset possibile dopo verifica/sostituzione.

Filtri:

- allarme filtri dopo ore impostate, default 4500 h;
- blocco unita se allarme filtri ignorato per ore impostate, default 240 h;
- reset filtri azzera contaore filtri.

## 13. Ingressi digitali

La scheda ha 5 ingressi digitali configurabili come contatti puliti. Non devono ricevere tensione.

Funzioni configurabili:

- deumidifica;
- ventilazione;
- integrazione;
- ricircolo;
- estate/inverno;
- OFF remoto;
- velocita 1 remota;
- velocita 2 remota;
- velocita 3 remota;
- velocita auto1 remota;
- velocita auto2 remota;
- abilita deumidifica/integrazione.

Default:

- IN1 = deumidifica;
- IN2 = ventilazione;
- IN3 = integrazione;
- IN4 = ricircolo;
- IN5 = estate/inverno.

Esiste una priorita configurabile tra OFF remoto e velocita remota:

- OFF prioritario;
- velocita remota prioritaria.

## 14. Uscite digitali configurabili

Uscite 6 e 7 configurabili.

Funzioni possibili:

- richiesta pompa;
- allarme;
- ventilatori ON;
- inverno;
- estate;
- resistenza antigelo.

Default:

- OUT6 = richiesta pompa;
- OUT7 = allarme.

Le uscite sono normalmente in tensione 230 V, ma possono diventare contatti puliti rimuovendo il ponticello previsto.

## 15. Fasce orarie

Disponibili con EPJ-Graph.

Per ogni giorno:

- fino a 5 fasce;
- l'inizio fascia determina il periodo fino alla fascia successiva;
- `23:59` disabilita una fascia non usata.

Ogni fascia puo' impostare:

- velocita: Off, V1, V2, V3, Vauto1, Vauto2;
- ventilazione: Off, On, Remoto;
- deumidifica: Off, On, Remoto, Auto/Remoto, Auto;
- integrazione: Off, On, Remoto, Auto/Remoto, Auto;
- set temperatura inverno;
- set umidita inverno;
- set temperatura estate;
- set umidita estate;
- solo ricircolo: Off, On, Remoto.

Sono previste anche fasce speciali con periodo data/ora di inizio e fine.

## 16. Manutenzione/manuale

La modalita manutenzione e' protetta da password installatore.

Permette di forzare indipendentemente:

- valvola acqua;
- ventilatore espulsione;
- ventilatore immissione;
- compressore;
- alimentazione ventilatori;
- bypass;
- serranda ricircolo;
- valvola scambiatore;
- uscita 6;
- uscita 7.

Nota critica: non lasciare il compressore forzato per piu' di 2 minuti senza circolazione di aria e acqua.

## 17. Registri Modbus operativi principali

### Comandi/stati base

| Base 0 | Nome | Scala | Uso |
|---:|---|---:|---|
| 0 | Selezione velocita | enum | 0 Off, 1 V1, 2 V2, 3 V3, 4 Vauto1, 5 Vauto2 |
| 1 | Velocita attiva | enum | stato reale, include standby/remoto/manutenzione |
| 2 | Gestione ventilazione | enum | 0 Off, 1 On, 2 Remoto |
| 3 | Gestione deumidifica | enum | 0 Off, 1 On, 2 Remoto, 3 Auto/Remoto, 4 Auto |
| 4 | Gestione integrazione | enum | 0 Off, 1 On, 2 Remoto, 3 Auto/Remoto, 4 Auto |
| 5 | Gestione solo ricircolo | enum | 0 Off, 1 On, 2 Remoto |
| 6 | Modalita attiva | enum | stato funzionale 0-17 |
| 7 | Gestione estate/inverno | enum | 0 Manuale, 1 Auto, 2 Remoto |
| 8 | Estate/Inverno | enum | 0 Inverno, 1 Estate, valido se gestione manuale |
| 9 | Fasce orarie | bool | 0 Off, 1 On |
| 10 | Allarme attivo | bool | 1 = presente allarme |
| 11 | Reset allarmi | pulse | scrivere 1, poi torna a 0 |
| 12 | Codice evento | enum | evento/allarme corrente o storico caricato |
| 13-14 | Numero evento | u32 low/high | progressivo evento |
| 15-16 | Ora evento | u32 low/high | secondi dal 01/01/2000 |
| 17 | Vedi ultimo evento | pulse | scrivere 1 |
| 18 | Vedi evento precedente | pulse | scrivere 1 |
| 19 | Vedi evento successivo | pulse | scrivere 1 |
| 20-21 | Contaore filtri | u32 low/high | ore |
| 22-23 | Contaore totali | u32 low/high | ore |
| 24 | Reset filtri | pulse | scrivere 1, poi torna a 0 |

### Sensori e uscite

| Base 0 | Nome | Scala | Note |
|---:|---|---:|---|
| 25 | Temp immissione | x0.1 | signed |
| 26 | Temp rinnovo | x0.1 | signed |
| 27 | Temp ripresa | x0.1 | signed |
| 28 | Temp H2O ingresso | x0.1 | signed |
| 29 | Temp condensatore | x0.1 | signed |
| 30 | Temp evaporatore | x0.1 | signed |
| 31 | Temp display | x0.1 | signed |
| 32 | UR display | x0.1 | signed, filtrare 0-100% |
| 33 | Temp CAN | x0.1 | signed |
| 34 | UR CAN | x0.1 | signed |
| 35 | AO valvola H2O | x0.01 | percentuale |
| 36 | AO vent espulsione | x0.01 | percentuale |
| 37 | AO vent immissione | x0.01 | percentuale |
| 38 | DO compressore | bool | stato uscita |
| 39 | DO ventilatori | bool | alimentazione ventilatori |
| 40 | DO bypass | bool | bypass aperto |
| 41 | DO ricircolo | bool | serranda ricircolo |
| 42 | DO valvola scambiatore | bool | on/off |
| 43 | DO6 configurabile | bool | default pompa |
| 44 | DO7 configurabile | bool | default allarme |
| 45-49 | IN1-IN5 configurabili | bool | ingressi digitali |
| 50 | Software type | raw | tipo software |
| 51 | Software version | x0.01 | versione |

### Setpoint, stagione, ventilazione

| Base 0 | Nome | Scala/enum | Default indicativo |
|---:|---|---|---:|
| 99 | Set inverno temperatura | x0.1 | 20.0 |
| 100 | Set inverno umidita | x0.1 | 50.0 |
| 101 | Set estate temperatura | x0.1 | 24.0 |
| 102 | Set estate umidita | x0.1 | 55.0 |
| 103 | Delta temperatura | x0.1 | 1.0 |
| 104 | Delta umidita | x0.1 | 2.0 |
| 105 | Set minima umidita | x0.1 | 50.0 |
| 106 | Selezione sonda temperatura | enum | display/ripresa/CAN/display+CAN |
| 107 | Selezione sonda umidita | enum | display/CAN/display+CAN |
| 108-115 | Date auto stagione | giorno/mese | start/end inverno/estate |
| 116 | Soglia passaggio inverno | x0.1 | 16.0 |
| 117 | Soglia passaggio estate | x0.1 | 24.0 |
| 118 | Tempo passaggio stagione | min | 480 |
| 119-121 | Set V1/V2/V3 | x0.01 | 40/60/78 circa |
| 122 | Aumento immissione con ricircolo | x0.01 | 22-30 |
| 123-126 | Min/max Vauto1/Vauto2 | x0.01 | profili auto |
| 127 | Pressurizzazione | x0.01 | 100 |
| 128 | Delta temp ventilazione auto | x0.1 | 2.0 |
| 129 | Delta UR Vauto compressore | x0.1 | 4.0 |
| 130 | Delta UR Vauto ventilazione | x0.1 | 15.0 |
| 131-133 | Basso rendimento PI | varie | soglia/banda/tempo |
| 134 | Ritardo OFF ventilatori | s | 300 |
| 135 | Max velocita ventilazione | x0.01 | 78 |
| 136 | Delta blocco condensa | x0.1 | 2.0 |

### Deumidifica, integrazione, I/O, bypass, allarmi, rete

Nota sul manuale RED C r9: la tabella originale riporta sia `Indirizzo Base 0` sia `Indirizzo Base 1`.
Negli estratti testuali/OCR spesso rimangono:

- l'indirizzo esadecimale `0x....`, che coincide con il `Base 0`
- il valore decimale della colonna `Base 1`

Esempio:

- `0x0097 152 Configurazione In1` significa:
  - `Base 0 = 151` (perche `0x0097 = 151`)
  - `Base 1 = 152`

Il progetto ESPHome usa indirizzamento `Base 0`.

| Base 0 | Nome | Scala/enum | Uso |
|---:|---|---|---|
| 137 | Deumidifica ventilazione | bool | abilita Vauto da umidita |
| 138 | Deumidifica compressore | enum | sempre/inverno/estate |
| 139 | Max apertura valvola H2O | x0.01 | limite valvola |
| 140 | Temp rinnovo max | x0.1 | logica ricircolo/deumidifica |
| 141 | Inverti valvola H2O | bool | standard/invertita |
| 142-143 | PI valvola H2O | varie | banda/tempo |
| 144 | Ritardo compressore | s | default 60 |
| 145 | Ritardo valvola scambiatore | s | default 180 |
| 146 | Tipo integrazione | enum | sempre/inverno/estate |
| 147 | Set riscaldamento | x0.1 | immissione inverno |
| 148 | Set raffreddamento | x0.1 | immissione estate |
| 149 | Tmin immissione ricircolo inverno | x0.1 | soglia |
| 150 | Ritardo OFF pompa integrazione | s | default 60 |
| 151-155 | Config IN1-IN5 | enum | funzioni ingressi |
| 156-157 | Config OUT6-OUT7 | enum | pompa/allarme/vent/inv/est/antigelo |
| 158 | Priorita Vel/OFF | enum | OFF prioritario o velocita prioritaria |
| 159 | Funzione bypass | enum | off/freecool/freeheat/entrambi |
| 160 | Set min free-cooling | x0.1 | temperatura rinnovo minima |
| 161 | Delta bypass | x0.1 | isteresi/differenziale |
| 162-164 | Antigelo recuperatore | x0.1 | set1/set2/delta |
| 165 | Ore allarme filtri | h | 9999 disabilita |
| 166 | Ore blocco filtri | h | 255 disabilita |
| 167 | Set antigelo batteria | x0.1 | allarme bassa temperatura |
| 168 | Autoreset allarmi | bool | allarmi frigo |
| 169 | Tempo autoreset | h | default 2 |
| 170 | Max temp H2O fredda | x0.1 | abilita deumidifica/integrazione estate |
| 171 | Ritardo mancanza acqua fredda | s | evento storico |
| 172 | Max temp H2O blocco | x0.1 | allarme acqua calda |
| 173 | Max condensatore | x0.1 | alta pressione |
| 174 | Min evaporatore | x0.1 | bassa pressione |
| 175 | Tempo min evaporatore | s | bassa pressione |
| 176 | Delta condensatore/evaporatore | x0.1 | mancanza freon |
| 177 | Tempo delta cond/evap | s | mancanza freon |
| 178 | Ritardo allarme compressore | s | allarmi frigo |
| 179-182 | Password/time-out | varie | livelli utente/installatore |
| 183 | Modbus indirizzo | raw | 1-247 |
| 184 | Modbus baudrate | enum | 4 = 19200 |
| 185 | Modbus parita | enum | 0 none |
| 186 | Modbus stop bit | enum | 1 = 2 stop |
| 187 | Password accesso parametri Modbus | signed | accesso parametri |

## 18. Conseguenze per ESPHome/Home Assistant

Da esporre subito:

- `select.vmc_speed`: registro 0;
- `select.vmc_ventilation_mode`: registro 2;
- `select.vmc_dehumidification_mode`: registro 3;
- `select.vmc_integration_mode`: registro 4;
- `select.vmc_recirculation_mode`: registro 5;
- `select/number` estate-inverno: registri 7 e 8;
- `switch` o `button` reset allarmi: registro 11;
- `switch` o `button` reset filtri: registro 24;
- sensori stato: 1, 6, 10, 12, 20-24, 25-44.

Correzioni rispetto al vecchio backup:

- reset allarmi: usare registro 11, non 9;
- reset filtri: registro 24;
- sensori temperatura/umidita: usare `S_WORD` con moltiplicatore 0.1;
- uscite DO 38-44 sono R/O e nel manuale stanno nella stessa area input/status: se con `holding` danno problemi, leggerle come `read`;
- percentuali AO 35-37: `U_WORD * 0.01`;
- umidita display va filtrata 0-100%;
- la logica Home Assistant basata su `modbus.write_register` va sostituita da entita ESPHome native o lambda che scrivono registri.

Da aggiungere in seconda fase:

- setpoint ambiente inverno/estate come `number`;
- cambio stagione manuale/auto/remoto;
- funzione bypass;
- parametri filtri e autoreset;
- allarme corrente decodificato in testo;
- storico eventi usando registri 12-19;
- ingressi/uscite digitali 43-49 per debug;
- eventuale controllo fasce orarie solo se si decide di replicarlo o lasciarlo alla macchina.
