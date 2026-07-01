param(
  [string]$HomeAssistantUrl = "http://homeassistant.local:8123",
  [string]$Token = $env:HA_TOKEN,
  [string]$OutputDirectory = ".",
  [string]$CatalogPath = ".\vmc_parametri_catalogo.csv"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Token)) {
  throw "Missing Home Assistant token. Set `$env:HA_TOKEN or pass -Token."
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outDir = Resolve-Path -LiteralPath $OutputDirectory
$csvOut = Join-Path $outDir "vmc-parametri-snapshot-$timestamp.csv"
$jsonOut = Join-Path $outDir "vmc-parametri-snapshot-$timestamp.json"

$headers = @{
  Authorization = "Bearer $Token"
  "Content-Type" = "application/json"
}

$statesUrl = "$($HomeAssistantUrl.TrimEnd('/'))/api/states"
try {
  $states = Invoke-RestMethod -Method Get -Uri $statesUrl -Headers $headers
} catch {
  $message = $_.Exception.Message
  if ($message -match "401") {
    throw "Home Assistant returned 401 Unauthorized. The token is invalid, expired, or you passed the literal placeholder instead of a real long-lived access token."
  }
  throw
}

$catalog = @{}
if (Test-Path -LiteralPath $CatalogPath) {
  Import-Csv -LiteralPath $CatalogPath | ForEach-Object {
    $catalog[$_.key] = $_
  }
}

function Convert-EntityToKey {
  param([string]$EntityId)

  $name = $EntityId -replace '^(sensor|binary_sensor|text_sensor|select|number|button)\.', ''
  $name = $name -replace '^vmc_gateway_vmc_', ''
  $name = $name -replace '^vmc_gateway_', ''
  $name = $name -replace '^vmc_', ''
  $name = $name -replace '_gateway_', ''
  $name = $name -replace '^gateway_vmc_', ''
  $name = $name -replace '^gateway_', ''

  $aliases = @{
    "velocita_attiva_vmc" = "active_speed"
    "modalita_attiva" = "active_mode"
    "current_speed" = "active_speed"
    "modalita_attiva_testo" = "active_mode"
    "evento_testo" = "event_code"
    "codice_evento" = "event_code"
    "numero_evento" = "event_number_low"
    "ora_evento_raw" = "event_time_low"
    "contaore_filtri" = "filter_hours_low"
    "contaore_totali" = "total_hours_low"
    "temperatura_immissione" = "temp_supply"
    "temperatura_rinnovo" = "temp_outdoor"
    "temperatura_ripresa" = "temp_return"
    "temperatura_h2o_in" = "temp_h2o_in"
    "temperatura_condensatore" = "temp_condenser"
    "temperatura_evaporatore" = "temp_evaporator"
    "temperatura_display" = "temp_display"
    "umidita_display" = "humidity_display"
    "umidita_display_filtrata" = "humidity_display"
    "temperatura_can" = "temp_can"
    "umidita_can" = "humidity_can"
    "apertura_valvola_h2o_in" = "ao_h2o_valve"
    "velocita_ventilatore_espulsione" = "ao_exhaust_fan"
    "velocita_ventilatore_immissione" = "ao_supply_fan"
    "stato_accensione_compressore" = "do_compressor"
    "compressore_attivo" = "do_compressor"
    "stato_alimentazione_ventilatori" = "do_fans"
    "alimentazione_ventilatori" = "do_fans"
    "stato_apertura_bypass" = "do_bypass"
    "bypass_aperto" = "do_bypass"
    "stato_apertura_ricircolo" = "do_recirculation"
    "ricircolo_aperto" = "do_recirculation"
    "stato_apertura_valvola_scambiatore" = "do_plate_valve"
    "valvola_scambiatore_aperta" = "do_plate_valve"
    "uscita_6_configurabile" = "do6"
    "uscita_7_configurabile" = "do7"
    "ingresso_1" = "in1"
    "ingresso_2" = "in2"
    "ingresso_3" = "in3"
    "ingresso_4" = "in4"
    "ingresso_5" = "in5"
    "software_type" = "software_type"
    "software_version" = "software_version"
    "speed" = "speed_select"
    "ventilation_mode" = "ventilation_mode"
    "dehumidification_mode" = "dehumidification_mode"
    "integration_mode" = "integration_mode"
    "recirculation_mode" = "recirculation_mode"
    "season_control_mode" = "season_control_mode"
    "season" = "season"
    "fasce_orarie" = "schedules_enabled"
    "dehumidification_compressor" = "dehumidification_compressor"
    "integration_season_enable" = "integration_type"
    "bypass_function" = "bypass_function"
    "set_temperatura_inverno" = "set_winter_temp"
    "set_umidita_inverno" = "set_winter_humidity"
    "set_temperatura_estate" = "set_summer_temp"
    "set_umidita_estate" = "set_summer_humidity"
    "set_velocita_1" = "set_v1"
    "set_velocita_2" = "set_v2"
    "set_velocita_3" = "set_v3"
    "set_aumento_ricircolo" = "set_recirculation_boost"
    "set_pressurizzazione" = "set_pressurization"
    "ore_allarme_filtri" = "filter_alarm_hours"
    "ore_blocco_filtri" = "filter_block_hours"
    "max_temperatura_h2o_fredda" = "max_cold_h2o_temp"
    "max_temperatura_h2o_blocco" = "max_h2o_block_temp"
    "allarme_attivo" = "alarm_active"
    "online" = "gateway_online"
    "status" = "gateway_status"
  }

  if ($aliases.ContainsKey($name)) {
    return $aliases[$name]
  }

  return $name
}

function Get-FriendlyName {
  param($StateObject)

  if ($null -ne $StateObject.PSObject.Properties["attributes"] -and
      $null -ne $StateObject.attributes -and
      $null -ne $StateObject.attributes.PSObject.Properties["friendly_name"]) {
    return $StateObject.attributes.friendly_name
  }

  return $StateObject.entity_id
}

$snapshot = $states |
  Where-Object {
    $friendlyName = Get-FriendlyName $_
    $_.entity_id -match '^(sensor|binary_sensor|text_sensor|select|number)\.vmc_' -or
    $friendlyName -like 'VMC *'
  } |
  Sort-Object entity_id |
  ForEach-Object {
    $key = Convert-EntityToKey -EntityId $_.entity_id
    $meta = $null
    if ($catalog.ContainsKey($key)) {
      $meta = $catalog[$key]
    }

    [pscustomobject]@{
      exported_at = (Get-Date).ToString("s")
      entity_id = $_.entity_id
      friendly_name = Get-FriendlyName $_
      state = $_.state
      unit = if ($null -ne $_.PSObject.Properties["attributes"] -and $null -ne $_.attributes.PSObject.Properties["unit_of_measurement"]) { $_.attributes.unit_of_measurement } else { "" }
      key = $key
      address_base0 = if ($meta) { $meta.address_base0 } else { "" }
      address_base1 = if ($meta) { $meta.address_base1 } else { "" }
      register_name = if ($meta) { $meta.name } else { "" }
      kind = if ($meta) { $meta.kind } else { "" }
      scale = if ($meta) { $meta.scale } else { "" }
      min = if ($meta) { $meta.min } else { "" }
      max = if ($meta) { $meta.max } else { "" }
      values = if ($meta) { $meta.values } else { "" }
      notes = if ($meta) { $meta.notes } else { "" }
    }
  }

$snapshot | Export-Csv -LiteralPath $csvOut -NoTypeInformation -Encoding UTF8
$snapshot | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $jsonOut -Encoding UTF8

Write-Host "Exported $($snapshot.Count) VMC entities"
Write-Host "CSV : $csvOut"
Write-Host "JSON: $jsonOut"
