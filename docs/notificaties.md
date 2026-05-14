# Notificaties

De app stuurt een pushmelding zodra er een nieuw actief NL-Alert verschijnt dat niet eerder gezien is. Als de gebruikerslocatie beschikbaar is en binnen het alertgebied valt, klinkt er ook een geluid.

## Gebruikerservaring

- Notificaties verschijnen automatisch na elke refresh waarbij nieuwe actieve alerts gevonden worden.
- **Gewone alert**: hoge prioriteit, vibratie, geen geluid.
- **Alert in eigen gebied**: maximale prioriteit, vibratie én geluid.
- Tikken op de notificatie opent direct het detailscherm van de bijbehorende alert.
- Op web zijn notificaties uitgeschakeld (`kIsWeb`-check).

## Technische werking

### Kanalen (Android)

Er zijn twee notificatiekanalen aangemaakt:

| Kanaal-ID | Naam | Geluid |
|---|---|---|
| `nl_alerts_v2` | NL-Alerts | Nee |
| `nl_alerts_location_v2` | NL-Alerts in jouw gebied | Ja |

Bij het initialiseren worden eventuele oude v1-kanalen verwijderd om verouderde instellingen te wissen.

### NotificationWatcher

`NotificationWatcherProvider` luistert via `ref.listen` naar elke wijziging van `AlertsState`. Bij de eerste lading worden alle reeds aanwezige alerts geregistreerd als "gezien" zonder notificatie te sturen — dit voorkomt een notificatiesalvo bij de eerste app-start.

Bij elke volgende wijziging worden nieuwe actieve alerts gevonden (die nog niet in de geziene set zitten). Voor elk nieuw alert:

1. Wordt de locatie van de gebruiker opgevraagd via `locationProvider`.
2. `isUserInAlertArea()` controleert of de locatie binnen het alertgebied valt.
3. `NotificationService.showAlertNotification()` stuurt de notificatie met het juiste kanaal.

IDs in de geziene set blijven voor de gehele sessie bewaard, zodat een alert nooit twee keer gemeld wordt.

### Notificatie-ID

Het notificatie-ID wordt afgeleid van de hash van het alert-ID: `alert.id.hashCode & 0x7FFFFFFF`. Dit garandeert dat twee notificaties voor hetzelfde alert elkaar overschrijven in plaats van stapelen.

### Deep link via payload

Het alert-ID wordt meegegeven als `payload` van de notificatie. `NotificationService.onNotificationTap` is een callback die in `main.dart` gekoppeld wordt aan de router, zodat tikken op een notificatie direct naar de juiste route navigeert.

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/services/notification_service.dart` | Kanaalconfiguratie en weergave |
| `lib/providers/notification_watcher_provider.dart` | Watcher die nieuwe alerts detecteert |
| `lib/providers/location_provider.dart` | Gebruikerslocatie voor geluidsbeslissing |
| `lib/utils/geo_utils.dart` | `isUserInAlertArea()` |
| `lib/main.dart` | Initialisatie en notificatie-tap koppeling |
