# Statistieken

![Statistieken](screenshots/stats_screen.png)

De statistieken-tab geeft een historisch overzicht van alle NL-Alerts via vier interactieve grafieken. De data wordt volledig client-side berekend uit de geladen alerts — er zijn geen extra API-aanroepen nodig.

## Gebruikerservaring

Wanneer nog niet alle alerts geladen zijn, start de tab automatisch een `loadAll()`-sessie en toont een voortgangsbalk met teller. Zodra alle data beschikbaar is, verschijnen de grafieken.

Elke grafiek heeft een **info-icoontje** (ⓘ). Tikken hierop opent een dialoog met uitleg over wat de grafiek weergeeft.

### Grafieken

| Grafiek | Type | Beschrijving |
|---|---|---|
| Alerts per maand | Staafdiagram | Totaal per kalendermaand (jan–dec), opgeteld over alle jaren |
| Alerts over tijd | Lijndiagram | Aantal alerts per jaar, toont groei/afname van het systeem |
| Duur van alerts | Staafdiagram | Verdeling in vier categorieën: < 1u, 1–4u, 4–24u, > 24u |
| Alerts per uur | Staafdiagram | Op welk uur van de dag worden de meeste alerts afgegeven (0–23u) |

Tooltips verschijnen bij hover/tap en tonen de exacte waarde. Alle tooltips gebruiken alleen tekens die in het Roboto-lettertype aanwezig zijn, zodat er geen externe fonts worden opgehaald.

## Technische werking

### Data-berekening

Alle berekeningen vinden plaats in de `build`-methode van de respectieve grafiekwidgets. Er is geen aparte provider of cache — elke rebuild herberekent de data puur functioneel uit `AlertsState.alerts`.

```dart
// Voorbeeld: alerts per maand
final counts = List.filled(12, 0);
for (final alert in alerts) {
  counts[alert.startAt.month - 1]++;
}
```

### Auto-load patroon

Bij het openen van de tab controleert `_maybeLoadAll()`:
1. Is `_loadAllTriggered` al `true`? Dan stoppen.
2. Is `hasMore == true` én is er geen lading bezig én zijn er al alerts? Dan `loadAll()` aanroepen.

Na een refresh (wanneer `hasMore` van `false` naar `true` gaat) reset `ref.listen` de vlag, zodat `loadAll()` opnieuw getriggerd wordt.

### Grafieken met fl_chart

Alle vier grafieken gebruiken `fl_chart 1.2.0`. Kleuren komen uit het Material 3-thema (`colorScheme.primary`). Animaties bij de eerste render zijn uitgeschakeld voor betere prestaties op grote datasets.

### Externe fonts voorkomen

Flutter web haalt automatisch Noto-fallbackfonts op voor tekens die niet in het primaire font zitten. De app gebruikt uitsluitend ASCII-tekens in grafiek-tooltips om dit te voorkomen.

## Relevante bestanden

| Bestand | Rol |
|---|---|
| `lib/screens/stats_screen.dart` | Volledig statistieken-scherm |
| `lib/providers/alerts_provider.dart` | `loadAll()` en alertdata |
| `pubspec.yaml` | `fl_chart: 1.2.0` dependency |
