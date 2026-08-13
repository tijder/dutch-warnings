// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Dutch Warnings';

  @override
  String get navOverview => 'Overzicht';

  @override
  String get navMap => 'Kaart';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get done => 'Klaar';

  @override
  String get save => 'Opslaan';

  @override
  String get offlineBanner => 'Offline – gecachte berichten worden getoond';

  @override
  String get locationAvailable => 'Locatie beschikbaar';

  @override
  String get locationUnavailable => 'Locatie niet beschikbaar';

  @override
  String activeAlertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actieve NL-Alerts',
      one: '1 actief NL-Alert',
    );
    return '$_temp0';
  }

  @override
  String get noAlertsFound => 'Geen NL-Alerts gevonden';

  @override
  String get allMessagesLoaded => 'Alle berichten geladen';

  @override
  String get mapOverviewTitle => 'Kaartoverzicht';

  @override
  String get mapModeCurrent => 'Huidig';

  @override
  String get mapModeHistory => 'Historie';

  @override
  String get selectPeriod => 'Selecteer periode';

  @override
  String get choosePeriodButton => 'Periode kiezen';

  @override
  String get last30Days => 'Laatste 30 dagen';

  @override
  String get selectPeriodTitle => 'Selecteer een periode';

  @override
  String get selectPeriodDesc =>
      'Kies een datumbereik om historische\nNL-Alerts op de kaart te zien.';

  @override
  String get noActiveAlerts => 'Geen actieve NL-Alerts';

  @override
  String get noActiveAlertsDesc =>
      'Er zijn momenteel geen actieve waarschuwingen.';

  @override
  String get osmContributors => 'OpenStreetMap bijdragers';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get autoRefresh => 'Automatisch vernieuwen';

  @override
  String get interval => 'Interval';

  @override
  String intervalMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuten',
      one: '1 minuut',
    );
    return '$_temp0';
  }

  @override
  String get sectionLocation => 'Mijn locatie';

  @override
  String get locationMode => 'Locatiemodus';

  @override
  String get locationAutomatic => 'Automatisch (GPS)';

  @override
  String get locationManual => 'Handmatig';

  @override
  String get locationOff => 'Uit';

  @override
  String get coordinates => 'Coördinaten';

  @override
  String get latitude => 'Breedtegraad';

  @override
  String get longitude => 'Lengtegraad';

  @override
  String get coordinatesSaved => 'Coördinaten opgeslagen';

  @override
  String get coordinatesInvalid =>
      'Ongeldig: breedtegraad −90…90, lengtegraad −180…180';

  @override
  String get locationPermissionDenied =>
      'Locatietoegang geweigerd. Controleer de app-instellingen.';

  @override
  String get errorRefreshFailed =>
      'Vernieuwen mislukt – gecachte gegevens worden getoond';

  @override
  String get sectionMap => 'Kaart';

  @override
  String get tileServerUrl => 'Tile server URL';

  @override
  String tileServerHint(String z, String x, String y) {
    return 'Gebruik $z, $x, $y als placeholders.';
  }

  @override
  String get tileServerSaved => 'Tile server opgeslagen';

  @override
  String get presets => 'Presets';

  @override
  String get resetDefaults => 'Standaard herstellen';

  @override
  String get sectionData => 'Gegevens';

  @override
  String get loadAllAlerts => 'Laad alle alerts in';

  @override
  String alertsLoadingCount(int count) {
    return '$count alerts geladen…';
  }

  @override
  String allAlertsLoadedCount(int count) {
    return 'Alle $count alerts zijn geladen.';
  }

  @override
  String alertsCount(int count) {
    return '$count alerts geladen.';
  }

  @override
  String get sectionDebug => 'Debug';

  @override
  String get debugFakeAlert => 'Fake alert bij elke refresh';

  @override
  String get debugFakeAlertDesc =>
      'Genereert een actieve testalert die een notificatie triggert. Met geluid als locatie beschikbaar is.';

  @override
  String get debugSendAlert => 'Nu een testalert sturen';

  @override
  String get alertNotFound => 'Waarschuwing niet gevonden';

  @override
  String get startTime => 'Starttijd';

  @override
  String get endTime => 'Eindtijd';

  @override
  String get messageLabelDutch => 'Nederlands';

  @override
  String get messageLabelEnglish => 'English';

  @override
  String get statusActive => 'Actief';

  @override
  String get statusPast => 'Afgelopen';

  @override
  String get affectsYourLocation => 'Geldt voor uw locatie';

  @override
  String get affectedBannerText =>
      'Let op: uw huidige locatie valt binnen het waarschuwingsgebied van dit NL-Alert.';

  @override
  String get cardAffectsLocation =>
      'Dit waarschuwingsgebied geldt voor uw locatie';

  @override
  String get statusYou => 'U!';

  @override
  String get navStats => 'Statistieken';

  @override
  String get statsTitle => 'Statistieken';

  @override
  String get statsLoading => 'Alle alerts worden geladen…';

  @override
  String statsLoadingCount(int count) {
    return '$count alerts geladen';
  }

  @override
  String get statsChartMonthly => 'Alerts per maand';

  @override
  String get statsChartMonthlyInfo =>
      'Toont het totale aantal NL-Alerts per kalendermaand, opgeteld over alle beschikbare jaren. Zo is zichtbaar in welke maanden historisch de meeste waarschuwingen worden afgegeven.';

  @override
  String get statsChartTimeline => 'Alerts over tijd';

  @override
  String get statsChartTimelineInfo =>
      'Toont het aantal NL-Alerts per jaar. Hiermee is de groei of afname van het NL-Alertsysteem over de tijd zichtbaar.';

  @override
  String get statsChartDuration => 'Duur van alerts';

  @override
  String get statsChartDurationInfo =>
      'Toont hoe lang alerts actief waren, ingedeeld in vier tijdscategorieën. Alleen alerts met een bekende eindtijd worden meegeteld.';

  @override
  String get statsChartByHour => 'Alerts per uur';

  @override
  String get statsChartByHourInfo =>
      'Toont op welk uur van de dag de meeste NL-Alerts worden afgegeven, op basis van de starttijd. De getallen op de x-as zijn uren in 24-uursnotatie.';

  @override
  String get statsDurLt1h => '< 1u';

  @override
  String get statsDur1to4h => '1–4u';

  @override
  String get statsDur4to24h => '4–24u';

  @override
  String get statsDurGt24h => '> 24u';

  @override
  String get statsNoData => 'Geen data beschikbaar';

  @override
  String alertId(String id) {
    return 'ID: $id';
  }

  @override
  String get sectionAbout => 'Over';

  @override
  String get aboutApp => 'Over Dutch Warnings';

  @override
  String aboutVersion(String version) {
    return 'Versie $version';
  }

  @override
  String get aboutLegalese =>
      'Copyright © 2026 Dutch Warnings bijdragers\n\nDit programma is vrije software: u mag het verspreiden en/of aanpassen onder de voorwaarden van de GNU General Public License zoals gepubliceerd door de Free Software Foundation, versie 3 of later.';

  @override
  String get aboutViewLicenses => 'Bekijk licenties';
}
