# Alert detail

![Alert detail](screenshots/detail_screen.png)

Het detailscherm toont alle informatie over één NL-Alert en is bereikbaar via de overzichtslijst of via een notificatietap.

## Gebruikerservaring

- Bovenaan staat een statuschip (Actief / Afgelopen) en eventueel een chip "Geldt voor uw locatie".
- Start- en eindtijd worden getoond in de taal en tijdzone van het apparaat.
- De volledige Nederlandse en Engelse tekst van de alert zijn apart weergegeven.
- Een ingebedde kaart toont de polygoon(en) van het waarschuwingsgebied en de gebruikerslocatie als blauwe pin.
- Als de gebruiker binnen het waarschuwingsgebied valt, verschijnt een oranje waarschuwingsbanner bovenaan het scherm.
- Onderaan staat het alert-ID voor referentiedoeleinden.

## Technische werking

### Navigatie

Het detailscherm is een aparte route (`/warning/:id`) buiten de tab-navigatie, zodat het via een deep link of notificatie geopend kan worden. De `AlertsNotifier` zoekt het alert op via het ID; als het niet gevonden wordt, verschijnt een foutmelding.

### Kaart

De ingebedde kaart (`AlertMap` widget) gebruikt `flutter_map` met `PolygonLayer` voor het waarschuwingsgebied en een `MarkerLayer` voor de gebruikerslocatie. De kaart past automatisch de weergave aan op de bounding box van de polygonen (camera fit).

### Locatiecheck

Hetzelfde `isUserInAlertArea()` ray-casting algoritme als in de overzichtslijst bepaalt of de oranje banner en de locatiechip getoond worden.

### Berichtopmaak

De API stuurt Nederlands en Engels in één string, gescheiden door `***`. De `Alert`-klasse splitst dit in `dutchMessage` en `englishMessage`. De titel wordt afgeleid van de eerste zin van het Nederlandse bericht (tot aan de eerste punt, maximaal 90 tekens).

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/screens/detail_screen.dart` | UI van het detailscherm |
| `lib/widgets/alert_map.dart` | Ingebedde kaartwidget |
| `lib/models/alert.dart` | Datamodel + berichtopmaak |
| `lib/router/app_router.dart` | Route-definitie `/warning/:id` |
| `lib/utils/geo_utils.dart` | Punt-in-polygoon check |
