# Instellingen

![Instellingen](screenshots/settings_screen.png)

Het instellingenscherm biedt controle over het gedrag van de app en is bereikbaar via de navigatiebalk.

## Secties

### Vernieuwen

- **Automatisch vernieuwen** — schakelaar om periodiek verversen aan/uit te zetten.
- **Interval** — keuzemenu met opties: 1, 5, 10, 15 of 30 minuten.

Zie ook: [auto-refresh.md](auto-refresh.md)

### Mijn locatie

- **Locatiemodus** — keuze uit Automatisch (GPS), Handmatig of Uit.
- **Coördinaten** — verschijnt bij handmatige modus; twee velden voor breedtegraad en lengtegraad met een Opslaan-knop.

Zie ook: [locatie.md](locatie.md)

### Kaart

- **Tile server URL** — aanpasbare URL-template voor kaarttegels (gebruik `{z}`, `{x}`, `{y}` als placeholders).
- **Presets** — snelknoppen voor veelgebruikte tile servers: OpenStreetMap, CartoDB Light, CartoDB Dark, OpenTopoMap.
- **Standaard herstellen** — zet de tile-server-URL terug naar OpenStreetMap.

### Gegevens

- **Laad alle alerts in** — haalt pagina voor pagina alle historische alerts op en slaat ze op in de lokale cache. Voortgang wordt getoond als tekst (aantal geladen alerts). Wordt ook automatisch getriggerd door de statistieken- en kaart-tab.

### Over

- Toont app-naam en versie.
- Tikken opent een dialoog met het GPLv3-licentie-bericht en een knop "Bekijk licenties" die alle pakketlicenties weergeeft (ingebouwde Flutter-licentiepagina).

### Debug (alleen in debug-build)

- **Fake alert bij elke refresh** — injecteert een synthetisch testalert dat een notificatie triggert, inclusief geluid als locatie beschikbaar is. Handig voor het testen van het notificatiesysteem.
- **Nu een testalert sturen** — triggert direct een refresh met fake alert ingeschakeld.

## Technische werking

### Persistentie

Alle instellingen worden opgeslagen in een aparte Hive-box (`settings_v1`) via `SettingsService`. De `SettingsNotifier` laadt alle waarden bij het opstarten asynchroon en werkt de state bij zodra een instelling wijzigt.

### Tile server validatie

De tile-server-URL wordt opgeslagen zonder validatie. Als de URL onjuist is, zal `flutter_map` de tegels niet kunnen laden, maar de app crasht niet.

### Coördinaten

Breedtegraad en lengtegraad worden geparsed als `double`. De opslaan-knop is alleen actief als beide velden geldige getallen bevatten die afwijken van de huidige opgeslagen waarden.

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/screens/settings_screen.dart` | Volledig instellingenscherm |
| `lib/providers/settings_provider.dart` | State en notifier |
| `lib/services/settings_service.dart` | Hive-persistentie + constanten |
