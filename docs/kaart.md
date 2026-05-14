# Kaartoverzicht

![Kaartoverzicht](screenshots/map_screen.png)

De kaart-tab toont alle alertgebieden op een interactieve kaart van Nederland. Er zijn twee modi: huidig en historisch.

## Gebruikerservaring

### Huidige modus

Toont alle actieve NL-Alerts als gekleurde polygonen (oranje) op de kaart. Tikken op een markering opent het detailscherm van de bijbehorende alert. Als er geen actieve alerts zijn, verschijnt een informatiekaartje.

### Historische modus

Hiermee kan de gebruiker een datumbereik kiezen om historische alerts te bekijken op de kaart. Alerts worden gefilterd op overlap met het gekozen bereik: een alert valt binnen het bereik als hij voor het einde gestart is én na het begin nog actief was (of geen eindtijd heeft). Historische alerts zijn blauw gekleurd.

Snelknoppen:
- **Periode kiezen** — opent een datumkiezerdialoog (één stap, start + eind tegelijk)
- **Laatste 30 dagen** — stelt het bereik direct in op de afgelopen 30 dagen

### Laden van alle alerts

Historische weergave vereist alle beschikbare alerts. Wanneer de tab geopend wordt terwijl nog niet alle alerts geladen zijn, start automatisch een `loadAll()`-sessie. In historische modus wordt een laadscherm getoond met een voortgangsbalk zolang de data incompleet is, zodat de datumfilter altijd op volledige data werkt.

## Technische werking

### Polygonen

Alertgebieden zijn opgeslagen als strings van `lat,lng`-paren gescheiden door spaties. `parsePolygon()` in `geo_utils.dart` zet deze om naar een lijst `LatLng`-punten voor `flutter_map`'s `PolygonLayer`.

### Tile server

De kaart laadt tegels via een configureerbare URL-template (standaard OpenStreetMap). De gebruiker kan dit aanpassen in de instellingen. De `CancellableNetworkTileProvider` zorgt dat tiles die niet meer nodig zijn (na scrollen/zoomen) worden geannuleerd.

### Auto-load patroon

Dezelfde logica als de statistieken-tab: een `_loadAllTriggered`-vlag in de widget-state voorkomt dubbele aanroepen. Na een refresh (waarbij `hasMore` van `false` naar `true` gaat) wordt de vlag gereset zodat de volgende `loadAll()` automatisch opnieuw getriggerd wordt.

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/screens/map_overview_screen.dart` | Volledige kaart-tab UI |
| `lib/utils/geo_utils.dart` | Polygoon-parsing en centroïde-berekening |
| `lib/providers/alerts_provider.dart` | `loadAll()` en alertdata |
| `lib/providers/settings_provider.dart` | Tile server URL |
