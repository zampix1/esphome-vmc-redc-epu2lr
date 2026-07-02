# Contributing

Thanks for contributing.

## Scope

This repository is for:

- ESPHome packages
- example device configs
- Home Assistant dashboard examples
- original technical notes derived from field validation and public documentation

## Before changing mappings

Every mapping change must state the affected variant:

- `RED C r9 / EPJ-Graph`
- `LET-C`

Registers should not be moved between variants unless the change is justified by:

- field validation, or
- an official source that clearly matches the target unit

All register addresses in this repo are **Base 0**.

## Sources and media

Third-party manuals, datasheets, screenshots or vendor product photos should not be added to this repository unless one of the following is available:

- explicit written permission, or
- a license that clearly allows redistribution

Preferred approach:

- link to the official source
- summarize the relevant data in original wording
- record what was validated on real hardware and what is only document-derived

## Discussions vs issues

- Use **Discussions** for questions, setup help, comparisons between variants and field notes.
- Use **Issues** for reproducible bugs, broken mappings and concrete enhancement requests.
