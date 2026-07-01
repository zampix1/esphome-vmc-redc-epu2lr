# Source Policy

## Short version

This repository publishes original code and original documentation notes.

It does **not** redistribute third-party manuals, datasheets, vendor screenshots or vendor product photos.

## Why this rule exists

Two separate issues matter:

1. **Licensing**
   - EVCO manuals explicitly reserve rights and forbid reproduction/disclosure without authorization.
   - VMC Italia product pages and media are third-party content.

2. **Repository hygiene**
   - Vendor PDFs and copied media create legal ambiguity.
   - Official links age better than mirrored binaries when the repo is meant to stay public.

## What contributors should do instead

- link to the official product page or manual
- summarize the relevant data in original wording
- document what was field-validated versus what was only inferred from documentation

## Official sources currently used by this project

VMC Italia:

- LET-C product page: <https://www.vmcitalia.it/prodotto/deumidificatori-con-vmc-let-c/>
- LET-C 15-30 product PDF: <https://www.vmcitalia.it/wp-content/uploads/2022/04/VMC_LET-C_15-30_H.pdf>
- LET-C 25-50 product PDF: <https://www.vmcitalia.it/wp-content/uploads/2022/04/VMC_LET-C_25-50_H.pdf>
- LET-C control/operating guide: <https://www.vmcitalia.it/wp-content/uploads/2022/04/Tipologie-di-controllo-unita_LET-C.pdf>

EVCO:

- `c-pro 3 kilo` hardware manual, Italian: <https://www.evco.it/assets/doc/114CP3UKI114.pdf>
- `c-pro 3 kilo` hardware manual, English: <https://www.evco.it/assets/doc/114CP3UKE114.pdf>
- `c-pro 3 kilo` datasheet: <https://www.evco.it/assets/doc/104CP3K0A103.pdf>
- EPJ-Graph user terminal, datasheet: <https://www.evco.it/assets/doc/104PJGRAPHI103.pdf>
- EPJ-Graph user terminal, manual: <https://www.evco.it/assets/doc/114PJGRAPHI104.pdf>

## RED C application material

The RED C r9 application manual was used during development and field validation, but it is not mirrored in this public repository.

## Media policy

Accepted in the public repo:

- original diagrams
- original screenshots produced from your own HA/ESPHome environment
- original photos you own
- third-party assets only when the redistribution terms are explicit

Not accepted by default:

- copied vendor PDFs
- copied vendor product photos
- scanned manual pages
