# Contributing

Thanks for contributing.

## Scope

This repository is for:

- ESPHome packages
- example device configs
- Home Assistant dashboard examples
- original technical notes derived from field validation and public documentation

## Before changing mappings

Always state which variant you are touching:

- `RED C r9 / EPJ-Graph`
- `LET-C`

Do not move registers between them unless you can justify the change with:

- field validation, or
- an official source that clearly matches the target unit

All register addresses in this repo are **Base 0**.

## Sources and media

Do not add third-party manuals, datasheets, screenshots or vendor product photos to this repository unless you have:

- explicit written permission, or
- a license that clearly allows redistribution

Preferred approach:

- link to the official source
- summarize the relevant data in your own words
- record what was validated on real hardware and what is only document-derived

## Discussions vs issues

- Use **Discussions** for questions, setup help, comparisons between variants and field notes.
- Use **Issues** for reproducible bugs, broken mappings and concrete enhancement requests.
