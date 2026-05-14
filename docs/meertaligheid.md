# Meertaligheid

De app ondersteunt Nederlands en Engels via Flutter's ingebouwde lokalisatiemechanisme (`flutter_localizations` + `gen-l10n`).

## Gebruikerservaring

De taal wordt automatisch gekozen op basis van de apparaatinstelling. Er is geen handmatige taalwissel in de app. Ondersteunde talen:

- 🇳🇱 **Nederlands** (standaard / fallback)
- 🇬🇧 **Engels**

## Technische werking

### ARB-bestanden

Alle teksten zijn gedefinieerd in twee ARB-bestanden:

| Bestand | Taal |
|---|---|
| `lib/l10n/app_nl.arb` | Nederlands (template) |
| `lib/l10n/app_en.arb` | Engels |

Het Nederlandse bestand is de template (`template-arb-file: app_nl.arb` in `l10n.yaml`). Nieuwe strings worden altijd eerst hier toegevoegd.

### Codegeneratie

`flutter gen-l10n` genereert `AppLocalizations` en de taalspecifieke subklassen. De gegenereerde bestanden staan in `lib/l10n/` en zijn niet handmatig te bewerken:

- `app_localizations.dart` — abstracte basisklasse
- `app_localizations_nl.dart` — Nederlandse implementatie
- `app_localizations_en.dart` — Engelse implementatie

### Gebruik in code

Een extensie op `BuildContext` maakt de lokalisatie compact beschikbaar:

```dart
// lib/l10n/l10n.dart
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// Gebruik in widgets:
Text(context.l10n.navOverview)
```

### Meervoudsvormen en parameters

ARB ondersteunt ICU-berichtformaat voor plurals en variabelen:

```json
"activeAlertsCount": "{count, plural, =1{1 actief NL-Alert} other{{count} actieve NL-Alerts}}",
"intervalMinutes": "{count, plural, =1{1 minuut} other{{count} minuten}}"
```

### Locaalgevoelige opmaak

Datum- en tijdopmaak gebruikt `Localizations.localeOf(context).toString()` om de juiste taal door te geven aan `intl`'s `DateFormat`:

```dart
final fmt = DateFormat('dd/MM/yy', locale);
```

Maandafkortingen in grafieken worden ook via `DateFormat('MMM', locale)` gegenereerd zodat ze automatisch in de juiste taal verschijnen.

## Nieuwe string toevoegen

1. Voeg de sleutel toe aan `app_nl.arb` (met `@`-descriptor).
2. Voeg de vertaling toe aan `app_en.arb`.
3. Voer `flutter gen-l10n` uit.
4. Gebruik `context.l10n.<sleutel>` in de widget.

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/l10n/app_nl.arb` | Nederlandse teksten (template) |
| `lib/l10n/app_en.arb` | Engelse teksten |
| `lib/l10n/l10n.dart` | `BuildContext`-extensie |
| `lib/l10n/app_localizations.dart` | Gegenereerde basisklasse |
| `l10n.yaml` | Configuratie voor `gen-l10n` |
| `pubspec.yaml` | `generate: true` en `flutter_localizations` |
