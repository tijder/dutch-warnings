# Offline caching

De app toont alerts ook zonder internetverbinding door alle ontvangen data lokaal op te slaan met Hive.

## Gebruikerservaring

- Bij het opstarten worden eerst de gecachte alerts getoond, daarna wordt op de achtergrond een refresh uitgevoerd.
- Als de refresh mislukt (geen internet), blijven de gecachte alerts zichtbaar en verschijnt een oranje banner: "Offline – gecachte berichten worden getoond".
- Nieuwe alerts die via `loadMore()` of `loadAll()` zijn opgehaald worden direct aan de cache toegevoegd.

## Technische werking

### Opslag

`CacheService` gebruikt een Hive-box (`alerts_v1`). Elke alert wordt opgeslagen als een JSON-map met de alert-ID als sleutel. Dit maakt upserts efficiënt: opnieuw opslaan van een bestaande alert overschrijft de bestaande waarde zonder duplicaten te maken.

```dart
final batch = {for (final a in alerts) a.id: a.toJson()};
await box.putAll(batch);
```

### Laadvolgorde bij opstarten

1. `CacheService.loadAlerts()` — laadt alle gecachte alerts, gesorteerd op `startAt` aflopend.
2. Als de cache niet leeg is, worden ze direct in `AlertsState` gezet zodat de UI direct iets toont.
3. Daarna roept `_initialize()` altijd `refresh()` aan voor verse data van de API.

### Sortering

`loadAlerts()` sorteert altijd op `startAt` aflopend. Dit zorgt voor een consistente volgorde ongeacht de ophaolvolgorde.

### Gegevensgroei

Elke `loadMore()` en `loadAll()` slaat nieuwe pagina's op in de cache. De cache groeit hierdoor mee met het aantal geladen alerts en blijft beschikbaar voor offline gebruik.

### Box-naam versioning

De Hive-box heet `alerts_v1`. Als het datamodel in de toekomst incompatibel wijzigt, kan een nieuwe box-naam (`alerts_v2`) gebruikt worden om de oude cache te omzeilen zonder migratiecode.

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/services/cache_service.dart` | Lezen en schrijven van de Hive-box |
| `lib/providers/alerts_provider.dart` | Volgorde van cache + API aanroepen |
| `lib/screens/list_screen.dart` | Offline-banner weergave |
