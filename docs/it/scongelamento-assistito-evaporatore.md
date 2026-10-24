# Scongelamento Assistito Evaporatore

Ultimo aggiornamento: 2026-10-25.

English: [Assisted evaporator thaw](../en/assisted-evaporator-thaw.md).

## Riscontro sul campo e disponibilita

L'installazione RED C r9 / EPJ-Graph di riferimento, dotata di controllore EVCO EPU2LR, ha utilizzato con esito positivo un supervisore Home Assistant per lo scongelamento assistito durante l'intera stagione estiva 2026. La conferma d'uso e stata raccolta il 2026-10-25.

Il risultato documenta l'impiego stagionale riuscito su un'installazione, non una certificazione del costruttore o una prova comparativa della resa di deumidificazione.

| Elemento | Stato |
|---|---|
| Ciclo di recupero evaporatore specifico dell'installazione | Collaudato sul campo durante l'intera stagione estiva 2026 |
| Blocchi stagionali per avvio automatico e manuale | Verificati separatamente in modalita Inverno il 2026-10-25 |
| Taglie e configurazioni RED C diverse dall'installazione di riferimento | Non validate indipendentemente da questo riscontro |
| Scongelamento assistito su LET-C | Non collaudato sul campo |
| Package o blueprint Home Assistant riutilizzabile | Non ancora distribuito nel repository |

I pacchetti ESPHome pubblici espongono le letture e i comandi usati dal supervisore, ma non contengono questo ciclo Home Assistant. Importare o aggiornare un pacchetto non abilita automaticamente lo scongelamento assistito.

## Scopo e sequenza operativa

Il supervisore interviene in presenza di temperatura evaporatore persistentemente bassa durante la deumidificazione. Richiede una pausa della deumidificazione e utilizza l'aria interna per riscaldare l'evaporatore. Non e un comando di sbrinamento a inversione di ciclo o a gas caldo.

La sequenza usata sul campo e:

1. Memorizzazione delle selezioni di velocita, ventilazione, deumidificazione, integrazione e ricircolo.
2. Impostazione di deumidificazione e integrazione su OFF tramite i normali comandi di funzionamento.
3. Attivazione del ricircolo interno a velocita 1, con ventilazione di rinnovo disattivata durante il recupero.
4. Attesa del riscontro compressore spento e monitoraggio del recupero dell'evaporatore.
5. Ripristino delle selezioni memorizzate al termine dell'attesa. Questo comportamento appartiene all'implementazione usata sul campo; i casi di errore descritti sotto richiedono ancora un trattamento piu rigoroso prima della distribuzione riutilizzabile.

Il supervisore non scrive direttamente sull'uscita compressore, non usa forzature di manutenzione e non aggira gli allarmi nativi. La sola selezione del ricircolo non dimostra la presenza di portata d'aria: vanno verificati anche stato fisico della serranda, comandi dei ventilatori e riscontro compressore.

## Soglie usate sul campo

Queste impostazioni si riferiscono all'installazione di riferimento e non sono limiti nominali del costruttore per tutte le unita supportate.

| Parametro | Impostazione sul campo |
|---|---|
| Richiesta automatica | Evaporatore a -7 deg C o meno per 10 minuti, con deumidificazione richiesta |
| Criterio di recupero | Evaporatore a +5 deg C o piu per 3 minuti |
| Attesa riscontro compressore spento | Fino a 3 minuti |
| Attesa recupero evaporatore | Fino a 20 minuti; non e la durata totale del ciclo |
| Intervallo minimo tra avvii | 1 ora |
| Altri vincoli per l'avvio automatico | Abilitazione esplicita, gateway online, nessun allarme attivo, nessun ciclo gia in corso |

Le attese dell'implementazione originale potevano proseguire al timeout e arrivare al ripristino dei comandi. L'esito stagionale positivo non dimostra che questo comportamento sia sicuro in caso di perdita della sonda, mancato arresto del compressore o ghiaccio persistente. La versione riutilizzabile deve gestire esplicitamente questi casi, senza interpretare il timeout come recupero riuscito.

## Vincoli stagionali aggiunti il 2026-10-25

Questi vincoli sono stati aggiunti e verificati dopo la stagione estiva:

- Il supervisore Home Assistant accetta nuovi avvii automatici e manuali soltanto quando la stagione effettiva VMC e esplicitamente `Estate`. Inverno, stagione sconosciuta e stagione non disponibile bloccano l'avvio.
- L'abilitazione automatica parte da OFF all'avvio di Home Assistant. Il passaggio a Inverno o un tentativo di riabilitazione fuori Estate la riportano su OFF.
- Il ritorno a Estate non riattiva automaticamente l'abilitazione.
- Un cambio stagione durante il ciclo interrompe l'attesa di recupero e impedisce il ripristino delle selezioni estive memorizzate. Una notifica richiede di verificare i modi di funzionamento risultanti.
- Il pulsante manuale della dashboard e nascosto fuori Estate; lo script controlla la stagione anche indipendentemente dalla dashboard.
- La card mostra abilitazione automatica, temperatura evaporatore e data dell'ultimo ciclo in sola lettura. La riga del ciclo in corso compare soltanto durante l'esecuzione.

Sono passati otto test mirati sulla configurazione. Le prove operative in Inverno hanno verificato il rifiuto della riabilitazione automatica e l'avvio manuale bloccato, senza modificare le selezioni operative o la data dell'ultimo ciclo. Queste prove verificano i blocchi invernali, non una nuova stagione completa con il supervisore aggiornato.

La regola solo Estate e una scelta di questo supervisore per l'attuale assetto di riscaldamento. Non significa che il controllore del costruttore non possa gestire deumidificazione invernale con configurazione e alimentazione idraulica appropriate.

## Protezioni native sempre operative

Lo scongelamento assistito dell'evaporatore e distinto dall'antigelo del recuperatore e dall'antigelo della batteria idronica gestiti dal controllore. Queste protezioni possono servire in inverno anche con compressore frigorifero spento. Disabilitare il ciclo Home Assistant non deve disabilitarle o modificarle.

Una pausa temporanea dei ventilatori non dimostra l'esecuzione dello scongelamento assistito. Prima di attribuire un comportamento della macchina al supervisore occorre correlare data del ciclo e storico dello script con temperature e comandi ventilatori.

## Requisiti prima della distribuzione riutilizzabile

- Selezione delle entita tramite input del blueprint o configurazione equivalente, senza dipendere dagli identificativi, dalla pompa di calore o dal wattmetro di un singolo impianto.
- Funzione facoltativa con abilitazione esplicita e soglie, tempi di permanenza e intervalli di riprova configurabili.
- Deumidificazione mantenuta disattivata e segnalazione di errore se manca il riscontro compressore spento, la lettura evaporatore non e valida o il recupero scade senza raggiungere la soglia di sicurezza.
- Nessuna sovrascrittura dei modi modificati dall'utente durante il ciclo; comportamento esplicito in caso di interruzione o riavvio.
- Test di recupero riuscito, timeout, sonde mancanti, perdita del gateway, allarmi, riavvio Home Assistant, cambio stagione e intervento manuale.
- Mantenimento dei livelli di validazione distinti indicati in [Varianti](../VARIANTS.md). Il controllore EVCO condiviso non garantisce firmware o mappe registri identici.

Il riscontro sul campo giustifica la pubblicazione dell'esperienza estiva positiva, ma non implica che la versione riutilizzabile ancora da distribuire sia gia disponibile o validata.
