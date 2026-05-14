# Locatie

De app kan de locatie van de gebruiker gebruiken om te bepalen of een actief NL-Alert het eigen gebied betreft. Er zijn drie modi.

## Gebruikerservaring

De locatiemodus is in te stellen via Instellingen → Mijn locatie:

| Modus | Beschrijving |
|---|---|
| Automatisch (GPS) | Vraagt GPS-locatie op via het apparaat |
| Handmatig | De gebruiker voert breedtegraad en lengtegraad in |
| Uit | Locatie wordt niet gebruikt |

Als de locatie beschikbaar is, verschijnt een blauw icoon in de appbar. Alerts die het eigen gebied beslaan, krijgen een extra chip "Geldt voor uw locatie" en een waarschuwingsbanner in de detailweergave.

## Technische werking

### locationProvider

`locationProvider` is een `FutureProvider<LatLng?>` die elke keer opnieuw wordt uitgevoerd als de locatierelevante instellingen veranderen (modus, handmatige coördinaten). Dit is bewust geïsoleerd van andere instellingswijzigingen (zoals de tile-server-URL) via `select()` op de settingsprovider.

```dart
final mode = ref.watch(settingsProvider.select((s) => s.locationMode));
```

### GPS-modus

1. Controleert of de locatieservice ingeschakeld is.
2. Vraagt toestemming aan als die nog niet gegeven is.
3. Haalt de huidige positie op met lage nauwkeurigheid (energiezuinig) en een timeout van 10 seconden.
4. Bij een fout of geweigerde toestemming wordt `null` teruggegeven.

### Handmatige modus

De gebruiker voert coördinaten in via twee tekstvelden in de instellingen. Na opslaan worden ze bewaard in Hive en direct beschikbaar gesteld als `LatLng`.

### Gebruik in de app

`locationProvider.value` (`LatLng?`) wordt op meerdere plekken gebruikt:

- **AlertCard / DetailScreen**: `isUserInAlertArea()` bepaalt of de alert het eigen gebied beslaat.
- **Notificatieservice**: bepaalt of een notificatie geluid krijgt.
- **Kaartscherm**: plaatst een blauwe "persoon"-marker op de kaart.

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/providers/location_provider.dart` | GPS/handmatig/uit logica |
| `lib/services/settings_service.dart` | Opslag van locatiemodus en coördinaten |
| `lib/screens/settings_screen.dart` | UI voor locatie-instellingen |
| `lib/utils/geo_utils.dart` | `isUserInAlertArea()` |
