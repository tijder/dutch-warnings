# Alerts overzicht

![Alerts overzicht](screenshots/list_screen.png)

De overzichtslijst is het startscherm van de app en toont alle geladen NL-Alerts, gesorteerd van nieuw naar oud.

## Gebruikerservaring

- Bovenaan staat een teller met het aantal actieve alerts.
- Elke alert wordt weergegeven als een kaart met: titel, start- en eindtijd, type, en of de alert voor de gebruikerslocatie geldt.
- Kaarten met een actieve alert zijn visueel onderscheiden (kleur, label).
- Als de alert het gebied van de gebruiker beslaat, verschijnt een extra label "U!" en een banner.
- Scrollen naar beneden laadt automatisch meer alerts (oneindige scroll via `loadMore()`).
- Een banner bovenaan toont wanneer de app offline is en gecachte data toont.
- Tikken op een kaart opent het detailscherm van die alert.

## Technische werking

### Paginering

De lijst gebruikt cursored paginering via de API. Bij het bereiken van de onderkant van de lijst roept de `AlertsNotifier.loadMore()` de API aan met de ID van de laatste geladen alert als `after`-parameter. Nieuwe resultaten worden samengevoegd met de cache en opnieuw gesorteerd.

```
GET /api/v1/providers/nl-alert/alerts?after=<laatste-id>
```

`hasMore` wordt `false` zodra de API een lege pagina teruggeeft.

### Locatiecheck per kaart

`AlertCard` controleert via `isUserInAlertArea()` (ray-casting algoritme) of de gebruikerslocatie binnen een van de polygonen van de alert valt. Dit bepaalt het "U!"-label en de blauwe banner.

### Staat

`AlertsState` bevat:
- `alerts` — gesorteerde lijst (nieuwste eerst)
- `isLoading` — initiële lading bezig
- `isLoadingMore` — volgende pagina bezig
- `hasMore` — zijn er nog meer te laden
- `isOffline` — laatste fetch mislukt

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/screens/list_screen.dart` | UI van de lijstweergave |
| `lib/widgets/alert_card.dart` | Individuele alertkaart |
| `lib/providers/alerts_provider.dart` | State + paginering logica |
| `lib/services/api_service.dart` | API-aanroepen |
| `lib/utils/geo_utils.dart` | Punt-in-polygoon check |
