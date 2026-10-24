# Assisted Evaporator Thaw

Last updated: 2026-10-25.

Italian: [Scongelamento assistito evaporatore](../it/scongelamento-assistito-evaporatore.md).

## Field status and availability

The reference RED C r9 / EPJ-Graph installation, equipped with an EVCO EPU2LR controller, used a Home Assistant assisted-thaw supervisor successfully throughout the 2026 summer season. The operator confirmed this result on 2026-10-25.

This is evidence of successful seasonal use on one installation, not manufacturer certification or a controlled comparison of dehumidification performance.

| Item | Status |
|---|---|
| Installation-specific evaporator recovery cycle | Field-tested during the full 2026 summer season |
| Summer-only automatic and manual start interlocks | Verified separately in winter mode on 2026-10-25 |
| RED C sizes and layouts other than the reference installation | Not independently validated by this report |
| LET-C assisted-thaw operation | Not field-tested |
| Reusable Home Assistant package or blueprint | Not yet distributed in this repository |

The public ESPHome packages expose the readings and controls used by the supervisor. They do not contain this Home Assistant cycle. Importing or updating a package does not automatically enable assisted thaw.

## Purpose and operating sequence

The supervisor responds to sustained low evaporator temperature during dehumidification. It requests a pause in dehumidification and lets indoor air warm the evaporator. It is not a reverse-cycle or hot-gas defrost command.

The field sequence is:

1. Save the current speed, ventilation, dehumidification, integration and recirculation selections.
2. Set dehumidification and integration to OFF through the normal operating-mode controls.
3. Enable indoor-air recirculation at speed 1, with outside-air ventilation disabled for the recovery interval.
4. Wait for compressor-off feedback and monitor evaporator recovery.
5. After the recovery wait, restore the saved selections. This restoration behavior belongs to the field implementation; the failure cases below still need hardening before a reusable release.

The supervisor does not write directly to the compressor output, use maintenance-mode forcing, or bypass native alarms. A recirculation selection alone is not proof of actual airflow: physical damper status, fan commands and compressor feedback must also be checked.

## Field thresholds

These are the installation-specific settings used by the field implementation, not manufacturer-rated limits for every supported unit.

| Parameter | Field setting |
|---|---|
| Automatic request | Evaporator at or below -7 deg C for 10 minutes, with dehumidification requested |
| Recovery criterion | Evaporator at or above +5 deg C for 3 minutes |
| Compressor-off feedback wait | Up to 3 minutes |
| Evaporator recovery wait | Up to 20 minutes; this is not the total cycle duration |
| Minimum interval between cycle starts | 1 hour |
| Other automatic-start checks | Explicit enable switch, gateway online, no active alarm, no cycle already running |

The original timed waits could continue on timeout and proceed to restoration. Successful seasonal use does not establish that this fallback is safe during sensor loss, failed compressor shutdown or persistent icing. A reusable release must address those cases explicitly rather than treating the timeout as successful recovery.

## Seasonal safeguards added on 2026-10-25

These safeguards were added and tested after the summer field period:

- The Home Assistant supervisor accepts new automatic and manual starts only when the actual VMC season is explicitly `Estate` (summer). Winter, unknown and unavailable season states block a start.
- The automatic enable helper starts OFF when Home Assistant starts. A winter season change or an attempt to re-enable it outside summer turns it OFF again.
- Returning to summer does not enable the helper automatically.
- A season change during a cycle interrupts the recovery wait and prevents restoration of saved summer selections. A notification requests a check of the resulting operating modes.
- The manual dashboard button is hidden outside summer; the script also checks the season independently of the dashboard.
- The dashboard shows the automatic-enable state, evaporator temperature and read-only last-cycle timestamp. A running-cycle row appears only during execution.

Eight focused configuration tests passed. Live winter-mode checks confirmed that re-enabling the helper was rejected and that a manual script invocation left the operating selections and last-cycle timestamp unchanged. These checks validate the winter interlocks, not a new full-season run of the updated supervisor.

The summer-only rule is a policy for this supervisor and its current heating configuration. It is not a claim that the manufacturer's controller cannot support winter dehumidification with an appropriate configuration and hydraulic supply.

## Native protection remains active

Assisted evaporator thaw is separate from the controller's heat-recovery-exchanger frost protection and hydronic-coil frost protection. Those protections may be needed in winter even while the refrigeration compressor is off. Disabling the Home Assistant cycle must not disable or alter them.

A temporary fan pause does not establish that assisted thaw ran. Correlate the cycle timestamp and script execution history with temperatures and fan commands before attributing a machine behavior to this supervisor.

## Requirements before a reusable release

- Select entities through blueprint inputs or equivalent configuration; do not depend on one installation's entity IDs, heat pump or power meter.
- Keep the function opt-in and make thresholds, persistence periods and retry limits configurable.
- Keep dehumidification disabled and report a fault if compressor-off feedback is not confirmed, the evaporator reading is invalid, or recovery times out below the safe threshold.
- Do not overwrite operating modes changed by the user while the cycle is running; define interruption and restart behavior explicitly.
- Test successful recovery, timeout, missing sensors, lost gateway connectivity, alarms, Home Assistant restart, season changes and manual overrides.
- Retain the model-specific validation distinction in [Variants](../VARIANTS.md). A shared EVCO controller does not establish identical firmware behavior or register mappings.

The field report supports publishing the successful summer experience. It does not make the still-unreleased reusable implementation available or validated by implication.
