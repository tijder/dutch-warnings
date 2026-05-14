# Automatisch vernieuwen

De app kan periodiek op de achtergrond nieuwe NL-Alerts ophalen zonder dat de gebruiker handmatig hoeft te verversen.

## Gebruikerservaring

- In Instellingen → Vernieuwen kan auto-refresh aan- of uitgezet worden.
- Als het aan staat, is een interval in te stellen: 1, 5, 10, 15 of 30 minuten.
- De instelling wordt direct van kracht — er is geen herstart nodig.
- Naast auto-refresh kan de gebruiker altijd handmatig verversen via de vernieuw-knop in de appbar.

## Technische werking

`autoRefreshProvider` is een `Provider<void>` die geen state bijhoudt maar als bijeffect een `Timer.periodic` aanmaakt.

```dart
final timer = Timer.periodic(
  Duration(minutes: settings.autoRefreshIntervalMinutes),
  (_) => ref.read(alertsProvider.notifier).refresh(),
);
ref.onDispose(timer.cancel);
```

Riverpod garandeert dat de provider opnieuw wordt gebouwd zodra `settingsProvider` wijzigt (auto-refresh aan/uit of interval). Bij rebuild wordt de oude timer via `onDispose` gecanceld en een nieuwe timer gestart met de nieuwe instelling. Als auto-refresh uitgeschakeld is, wordt de provider vroeg teruggekeerd en is er geen timer actief.

De provider is als `watch` geregistreerd in `main.dart` om altijd actief te blijven zolang de app draait.

### Interactie met loadAll

`refresh()` reset `hasMore` naar `true` als de API nieuwe alerts teruggeeft. De statistieken- en kaart-tab detecteren deze overgang via `ref.listen` en starten automatisch een nieuwe `loadAll()`-sessie.

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/providers/auto_refresh_provider.dart` | Timer-logica |
| `lib/providers/alerts_provider.dart` | `refresh()` methode |
| `lib/providers/settings_provider.dart` | Interval en aan/uit instelling |
| `lib/services/settings_service.dart` | Persistentie van de instellingen |
| `lib/main.dart` | Provider activeren via `watch` |
