# Dutch Warnings

Een open-source NL-Alert viewer voor Nederland. De app toont actieve en historische NL-Alerts op een kaart en in een lijst, stuurt notificaties bij nieuwe waarschuwingen en werkt offline via lokale caching.

## Features

- **Overzichtslijst** — alle NL-Alerts gesorteerd op tijd, met oneindige scroll
- **Kaartweergave** — alertgebieden als polygonen op een interactieve kaart; historische modus met datumfilter
- **Statistieken** — vier grafieken over historische alertpatronen (per maand, per jaar, duur, uur van de dag)
- **Notificaties** — automatische pushmelding bij nieuwe actieve alerts; geluid als de gebruiker in het alertgebied valt
- **Offline** — alle opgehaalde data wordt lokaal gecached en is beschikbaar zonder internet
- **Locatie** — GPS, handmatig of uit; bepaalt of een alert het eigen gebied betreft
- **Auto-refresh** — instelbaar interval (1–30 minuten)
- **Meertalig** — Nederlands en Engels

## Licentie

GNU General Public License v3.0 of later — zie [LICENSE](LICENSE).

---

## Ontwikkelaarsinformatie

### Vereisten

| Tool | Versie |
|---|---|
| Flutter | 3.41.x (stable) |
| Dart | 3.11.x |
| Android SDK | API 21+ |

### Project opzetten

```bash
git clone <repo-url>
cd dutch-warnings
flutter pub get
```

#### Code genereren

De app gebruikt `auto_route` voor navigatie en `flutter gen-l10n` voor vertalingen. Beide moeten gegenereerd worden na het klonen of na wijzigingen in routes/ARB-bestanden:

```bash
# Vertalingen genereren
flutter gen-l10n

# Router genereren (auto_route)
dart run build_runner build --delete-conflicting-outputs
```

### Uitvoeren

```bash
flutter run                # standaard apparaat
flutter run -d android
flutter run -d linux
flutter run -d chrome
```

### Bouwen

```bash
flutter build apk --release
flutter build linux --release
flutter build web --release
```

### Projectstructuur

```
lib/
├── l10n/               # ARB-vertaalbestanden + gegenereerde AppLocalizations
├── models/             # Alert datamodel
├── providers/          # Riverpod state (alerts, settings, locatie, notificaties)
├── router/             # auto_route configuratie en gegenereerde router
├── screens/            # Schermen (list, detail, map, stats, settings)
├── services/           # API, cache (Hive), notificaties, instellingen
├── utils/              # Geo-hulpfuncties, URL-strategie (web)
└── widgets/            # Herbruikbare widgets (AlertCard, AlertMap)

docs/                   # Feature-documentatie (één bestand per feature)
assets/
├── fonts/roboto/       # Roboto lettertype (lokaal gebundeld)
└── icon/               # App-iconen
web/                    # Web-specifieke bestanden (index.html, manifest)
```

### Technische keuzes

| Onderwerp | Keuze | Reden |
|---|---|---|
| State management | Riverpod | Compile-time veilig, geen `BuildContext` nodig in services |
| Navigatie | auto_route | Type-safe routes, deep links, tab-navigatie |
| Kaart | flutter_map | Open-source, werkt met elke tile server |
| Lokale opslag | Hive (hive_ce_flutter) | Snel, geen extra configuratie, werkt op alle platforms |
| HTTP | Dio | Timeout-configuratie, eenvoudig te mocken in tests |
| Grafieken | fl_chart 1.2.0 | Lichtgewicht, volledig aanpasbaar |
| Vertalingen | flutter gen-l10n | Officiële Flutter-aanpak, compile-time veilig |
| Lettertype | Roboto (lokaal) | Geen externe fontverzoeken tijdens gebruik |

### Vertalingen bijwerken

1. Voeg de sleutel toe aan `lib/l10n/app_nl.arb` (Nederlands, inclusief `@`-descriptor).
2. Voeg de vertaling toe aan `lib/l10n/app_en.arb`.
3. Voer `flutter gen-l10n` uit.
4. Gebruik `context.l10n.<sleutel>` in de widget.

### Nieuwe route toevoegen

1. Maak een nieuw scherm aan in `lib/screens/` met `@RoutePage()`.
2. Voeg de route toe aan `lib/router/app_router.dart`.
3. Voer `dart run build_runner build --delete-conflicting-outputs` uit.

### Feature-documentatie

Gedetailleerde uitleg per feature staat in de [`docs/`](docs/) map. De bijbehorende documentatiesite (Docusaurus) staat in de [`website/`](website/) map.

Lokaal starten:

```bash
cd website
npm install
npm start   # opent http://localhost:3000/
```

---

## Deployment (GitHub Pages)

De pipeline draait automatisch bij elke push naar `main` via [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml). De site wordt gepubliceerd met:

- **Root (`/`)** — Flutter web-app
- **`/docs/`** — Docusaurus-documentatiesite

### Eenmalige instelling

1. Ga in de GitHub-repository naar **Settings → Pages**.
2. Stel **Source** in op **GitHub Actions**.

### Domein configureren

Standaard worden de URLs automatisch afgeleid van de GitHub-repositorynaam (bijv. `https://tijder.github.io/dutch-warnings/`). Bij een custom domain stel je één repository-variabele in:

1. Ga naar **Settings → Secrets and variables → Actions → Variables**.
2. Voeg toe: **`CUSTOM_DOMAIN`** = `jouw-domein.nl`

De workflow past dan automatisch alle base-URLs aan naar `/` in plaats van `/<repo>/`.

Voeg daarnaast een `CNAME`-bestand toe aan `web/` met daarin het domein (Flutter kopieert dit mee naar de build-output):

```
jouw-domein.nl
```

### Screenshots

De screenshots in `docs/screenshots/` worden **niet** in de repository bewaard. Ze worden bij elke deploy automatisch gegenereerd door de golden-file tests:

```bash
# Lokaal opnieuw genereren (vereist Linux desktop + display)
flutter config --enable-linux-desktop
flutter test -d linux integration_test/screenshots_test.dart
```

### SPA-routing

De Flutter web-app gebruikt path-based routing (`usePathUrlStrategy`). De workflow kopieert `index.html` naar `404.html` zodat GitHub Pages deep links correct afhandelt (bijv. `/warning/abc-123`).

### API

De app gebruikt de publieke NL-Alert API:

```
GET https://api.public-warning.app/api/v1/providers/nl-alert/alerts
GET https://api.public-warning.app/api/v1/providers/nl-alert/alerts?after=<id>
```

Paginering werkt via cursor: de `after`-parameter bevat het ID van de laatste ontvangen alert. Een lege response betekent dat alle alerts geladen zijn.
