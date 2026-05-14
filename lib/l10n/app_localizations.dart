import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// App title shown in the navigation bar
  ///
  /// In nl, this message translates to:
  /// **'Dutch Warnings'**
  String get appTitle;

  /// Navigation label for the alerts list tab
  ///
  /// In nl, this message translates to:
  /// **'Overzicht'**
  String get navOverview;

  /// Navigation label for the map tab
  ///
  /// In nl, this message translates to:
  /// **'Kaart'**
  String get navMap;

  /// Navigation label for the settings tab
  ///
  /// In nl, this message translates to:
  /// **'Instellingen'**
  String get navSettings;

  /// Refresh action label and settings section header
  ///
  /// In nl, this message translates to:
  /// **'Vernieuwen'**
  String get refresh;

  /// Cancel button label
  ///
  /// In nl, this message translates to:
  /// **'Annuleren'**
  String get cancel;

  /// Done/confirm button label
  ///
  /// In nl, this message translates to:
  /// **'Klaar'**
  String get done;

  /// Save button label
  ///
  /// In nl, this message translates to:
  /// **'Opslaan'**
  String get save;

  /// Tooltip shown when the app is offline
  ///
  /// In nl, this message translates to:
  /// **'Offline – gecachte berichten worden getoond'**
  String get offlineBanner;

  /// Tooltip shown when GPS location is available
  ///
  /// In nl, this message translates to:
  /// **'Locatie beschikbaar'**
  String get locationAvailable;

  /// Tooltip shown when GPS location is not available
  ///
  /// In nl, this message translates to:
  /// **'Locatie niet beschikbaar'**
  String get locationUnavailable;

  /// Number of active alerts shown in the list header
  ///
  /// In nl, this message translates to:
  /// **'{count, plural, =1{1 actief NL-Alert} other{{count} actieve NL-Alerts}}'**
  String activeAlertsCount(int count);

  /// Empty state label when no alerts are found
  ///
  /// In nl, this message translates to:
  /// **'Geen NL-Alerts gevonden'**
  String get noAlertsFound;

  /// Footer text when all alerts have been loaded
  ///
  /// In nl, this message translates to:
  /// **'Alle berichten geladen'**
  String get allMessagesLoaded;

  /// Title of the map overview screen
  ///
  /// In nl, this message translates to:
  /// **'Kaartoverzicht'**
  String get mapOverviewTitle;

  /// Segmented button label for current alerts mode
  ///
  /// In nl, this message translates to:
  /// **'Huidig'**
  String get mapModeCurrent;

  /// Segmented button label for history mode
  ///
  /// In nl, this message translates to:
  /// **'Historie'**
  String get mapModeHistory;

  /// Period selector button label and date picker help text
  ///
  /// In nl, this message translates to:
  /// **'Selecteer periode'**
  String get selectPeriod;

  /// Button label that opens the date range picker
  ///
  /// In nl, this message translates to:
  /// **'Periode kiezen'**
  String get choosePeriodButton;

  /// Button label to set the date range to the last 30 days
  ///
  /// In nl, this message translates to:
  /// **'Laatste 30 dagen'**
  String get last30Days;

  /// Title in the history mode empty state card
  ///
  /// In nl, this message translates to:
  /// **'Selecteer een periode'**
  String get selectPeriodTitle;

  /// Description in the history mode empty state card
  ///
  /// In nl, this message translates to:
  /// **'Kies een datumbereik om historische\nNL-Alerts op de kaart te zien.'**
  String get selectPeriodDesc;

  /// Title shown when there are no active alerts on the map
  ///
  /// In nl, this message translates to:
  /// **'Geen actieve NL-Alerts'**
  String get noActiveAlerts;

  /// Description shown when there are no active alerts on the map
  ///
  /// In nl, this message translates to:
  /// **'Er zijn momenteel geen actieve waarschuwingen.'**
  String get noActiveAlertsDesc;

  /// Map attribution text
  ///
  /// In nl, this message translates to:
  /// **'OpenStreetMap bijdragers'**
  String get osmContributors;

  /// Settings screen title
  ///
  /// In nl, this message translates to:
  /// **'Instellingen'**
  String get settingsTitle;

  /// Label for the auto-refresh toggle
  ///
  /// In nl, this message translates to:
  /// **'Automatisch vernieuwen'**
  String get autoRefresh;

  /// Label for the refresh interval dropdown
  ///
  /// In nl, this message translates to:
  /// **'Interval'**
  String get interval;

  /// Refresh interval expressed in minutes
  ///
  /// In nl, this message translates to:
  /// **'{count, plural, =1{1 minuut} other{{count} minuten}}'**
  String intervalMinutes(int count);

  /// Settings section header for location
  ///
  /// In nl, this message translates to:
  /// **'Mijn locatie'**
  String get sectionLocation;

  /// Label for the location mode dropdown
  ///
  /// In nl, this message translates to:
  /// **'Locatiemodus'**
  String get locationMode;

  /// Location mode: automatic via GPS
  ///
  /// In nl, this message translates to:
  /// **'Automatisch (GPS)'**
  String get locationAutomatic;

  /// Location mode: manual coordinates
  ///
  /// In nl, this message translates to:
  /// **'Handmatig'**
  String get locationManual;

  /// Location mode: disabled
  ///
  /// In nl, this message translates to:
  /// **'Uit'**
  String get locationOff;

  /// Label for the manual coordinates input section
  ///
  /// In nl, this message translates to:
  /// **'Coördinaten'**
  String get coordinates;

  /// Latitude input field label
  ///
  /// In nl, this message translates to:
  /// **'Breedtegraad'**
  String get latitude;

  /// Longitude input field label
  ///
  /// In nl, this message translates to:
  /// **'Lengtegraad'**
  String get longitude;

  /// Snackbar message after saving coordinates
  ///
  /// In nl, this message translates to:
  /// **'Coördinaten opgeslagen'**
  String get coordinatesSaved;

  /// Settings section header for map options
  ///
  /// In nl, this message translates to:
  /// **'Kaart'**
  String get sectionMap;

  /// Label for the tile server URL input field
  ///
  /// In nl, this message translates to:
  /// **'Tile server URL'**
  String get tileServerUrl;

  /// Hint text below the tile server URL field
  ///
  /// In nl, this message translates to:
  /// **'Gebruik {z}, {x}, {y} als placeholders.'**
  String tileServerHint(String z, String x, String y);

  /// Snackbar message after saving tile server URL
  ///
  /// In nl, this message translates to:
  /// **'Tile server opgeslagen'**
  String get tileServerSaved;

  /// Label above the preset tile server chips
  ///
  /// In nl, this message translates to:
  /// **'Presets'**
  String get presets;

  /// Button to reset tile server URL to the default
  ///
  /// In nl, this message translates to:
  /// **'Standaard herstellen'**
  String get resetDefaults;

  /// Settings section header for data management
  ///
  /// In nl, this message translates to:
  /// **'Gegevens'**
  String get sectionData;

  /// Button to fetch all available alerts
  ///
  /// In nl, this message translates to:
  /// **'Laad alle alerts in'**
  String get loadAllAlerts;

  /// Status text while loading all alerts
  ///
  /// In nl, this message translates to:
  /// **'{count} alerts geladen…'**
  String alertsLoadingCount(int count);

  /// Status text when all alerts are fully loaded
  ///
  /// In nl, this message translates to:
  /// **'Alle {count} alerts zijn geladen.'**
  String allAlertsLoadedCount(int count);

  /// Status text showing how many alerts are currently loaded
  ///
  /// In nl, this message translates to:
  /// **'{count} alerts geladen.'**
  String alertsCount(int count);

  /// Settings section header for debug options
  ///
  /// In nl, this message translates to:
  /// **'Debug'**
  String get sectionDebug;

  /// Toggle label for injecting a test alert on every refresh
  ///
  /// In nl, this message translates to:
  /// **'Fake alert bij elke refresh'**
  String get debugFakeAlert;

  /// Description of the fake alert debug feature
  ///
  /// In nl, this message translates to:
  /// **'Genereert een actieve testalert die een notificatie triggert. Met geluid als locatie beschikbaar is.'**
  String get debugFakeAlertDesc;

  /// Button to immediately send a test alert
  ///
  /// In nl, this message translates to:
  /// **'Nu een testalert sturen'**
  String get debugSendAlert;

  /// Shown when an alert cannot be found by its ID
  ///
  /// In nl, this message translates to:
  /// **'Waarschuwing niet gevonden'**
  String get alertNotFound;

  /// Label for the alert start time
  ///
  /// In nl, this message translates to:
  /// **'Starttijd'**
  String get startTime;

  /// Label for the alert end time
  ///
  /// In nl, this message translates to:
  /// **'Eindtijd'**
  String get endTime;

  /// Section label for the Dutch alert message
  ///
  /// In nl, this message translates to:
  /// **'Nederlands'**
  String get messageLabelDutch;

  /// Section label for the English alert message
  ///
  /// In nl, this message translates to:
  /// **'English'**
  String get messageLabelEnglish;

  /// Badge/chip label for an active alert
  ///
  /// In nl, this message translates to:
  /// **'Actief'**
  String get statusActive;

  /// Badge/chip label for a past alert
  ///
  /// In nl, this message translates to:
  /// **'Afgelopen'**
  String get statusPast;

  /// Chip label when an alert affects the user's location
  ///
  /// In nl, this message translates to:
  /// **'Geldt voor uw locatie'**
  String get affectsYourLocation;

  /// Warning banner when the user is inside the alert area
  ///
  /// In nl, this message translates to:
  /// **'Let op: uw huidige locatie valt binnen het waarschuwingsgebied van dit NL-Alert.'**
  String get affectedBannerText;

  /// Row text on alert card when the user is in the affected area
  ///
  /// In nl, this message translates to:
  /// **'Dit waarschuwingsgebied geldt voor uw locatie'**
  String get cardAffectsLocation;

  /// Short badge label when the user is in the affected area
  ///
  /// In nl, this message translates to:
  /// **'U!'**
  String get statusYou;

  /// Navigation label for the statistics tab
  ///
  /// In nl, this message translates to:
  /// **'Statistieken'**
  String get navStats;

  /// Statistics screen title
  ///
  /// In nl, this message translates to:
  /// **'Statistieken'**
  String get statsTitle;

  /// Loading message shown while fetching all alerts for statistics
  ///
  /// In nl, this message translates to:
  /// **'Alle alerts worden geladen…'**
  String get statsLoading;

  /// Counter shown below the progress bar while loading
  ///
  /// In nl, this message translates to:
  /// **'{count} alerts geladen'**
  String statsLoadingCount(int count);

  /// Title for the monthly alerts bar chart
  ///
  /// In nl, this message translates to:
  /// **'Alerts per maand'**
  String get statsChartMonthly;

  /// Info text for the monthly chart
  ///
  /// In nl, this message translates to:
  /// **'Toont het totale aantal NL-Alerts per kalendermaand, opgeteld over alle beschikbare jaren. Zo is zichtbaar in welke maanden historisch de meeste waarschuwingen worden afgegeven.'**
  String get statsChartMonthlyInfo;

  /// Title for the alerts-over-time line chart (per year)
  ///
  /// In nl, this message translates to:
  /// **'Alerts over tijd'**
  String get statsChartTimeline;

  /// Info text for the timeline chart
  ///
  /// In nl, this message translates to:
  /// **'Toont het aantal NL-Alerts per jaar. Hiermee is de groei of afname van het NL-Alertsysteem over de tijd zichtbaar.'**
  String get statsChartTimelineInfo;

  /// Title for the alert duration histogram
  ///
  /// In nl, this message translates to:
  /// **'Duur van alerts'**
  String get statsChartDuration;

  /// Info text for the duration chart
  ///
  /// In nl, this message translates to:
  /// **'Toont hoe lang alerts actief waren, ingedeeld in vier tijdscategorieën. Alleen alerts met een bekende eindtijd worden meegeteld.'**
  String get statsChartDurationInfo;

  /// Title for the alerts-by-hour-of-day chart
  ///
  /// In nl, this message translates to:
  /// **'Alerts per uur'**
  String get statsChartByHour;

  /// Info text for the by-hour chart
  ///
  /// In nl, this message translates to:
  /// **'Toont op welk uur van de dag de meeste NL-Alerts worden afgegeven, op basis van de starttijd. De getallen op de x-as zijn uren in 24-uursnotatie.'**
  String get statsChartByHourInfo;

  /// Duration bucket label: less than 1 hour
  ///
  /// In nl, this message translates to:
  /// **'< 1u'**
  String get statsDurLt1h;

  /// Duration bucket label: 1 to 4 hours
  ///
  /// In nl, this message translates to:
  /// **'1–4u'**
  String get statsDur1to4h;

  /// Duration bucket label: 4 to 24 hours
  ///
  /// In nl, this message translates to:
  /// **'4–24u'**
  String get statsDur4to24h;

  /// Duration bucket label: more than 24 hours
  ///
  /// In nl, this message translates to:
  /// **'> 24u'**
  String get statsDurGt24h;

  /// Shown inside a chart when there is no data to display
  ///
  /// In nl, this message translates to:
  /// **'Geen data beschikbaar'**
  String get statsNoData;

  /// Alert identifier shown at the bottom of the detail panel
  ///
  /// In nl, this message translates to:
  /// **'ID: {id}'**
  String alertId(String id);

  /// Settings section header for About
  ///
  /// In nl, this message translates to:
  /// **'Over'**
  String get sectionAbout;

  /// List tile label that opens the About dialog
  ///
  /// In nl, this message translates to:
  /// **'Over Dutch Warnings'**
  String get aboutApp;

  /// Version line shown in the About dialog
  ///
  /// In nl, this message translates to:
  /// **'Versie {version}'**
  String aboutVersion(String version);

  /// License notice shown in the About dialog
  ///
  /// In nl, this message translates to:
  /// **'Copyright © 2026 Dutch Warnings bijdragers\n\nDit programma is vrije software: u mag het verspreiden en/of aanpassen onder de voorwaarden van de GNU General Public License zoals gepubliceerd door de Free Software Foundation, versie 3 of later.'**
  String get aboutLegalese;

  /// Button in About dialog that opens the full license page
  ///
  /// In nl, this message translates to:
  /// **'Bekijk licenties'**
  String get aboutViewLicenses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
