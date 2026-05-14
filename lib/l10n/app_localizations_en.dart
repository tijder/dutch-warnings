// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dutch Warnings';

  @override
  String get navOverview => 'Overview';

  @override
  String get navMap => 'Map';

  @override
  String get navSettings => 'Settings';

  @override
  String get refresh => 'Refresh';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get offlineBanner => 'Offline – showing cached messages';

  @override
  String get locationAvailable => 'Location available';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String activeAlertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active NL-Alerts',
      one: '1 active NL-Alert',
    );
    return '$_temp0';
  }

  @override
  String get noAlertsFound => 'No NL-Alerts found';

  @override
  String get allMessagesLoaded => 'All messages loaded';

  @override
  String get mapOverviewTitle => 'Map overview';

  @override
  String get mapModeCurrent => 'Current';

  @override
  String get mapModeHistory => 'History';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get choosePeriodButton => 'Choose period';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get selectPeriodTitle => 'Select a period';

  @override
  String get selectPeriodDesc =>
      'Choose a date range to see historical\nNL-Alerts on the map.';

  @override
  String get noActiveAlerts => 'No active NL-Alerts';

  @override
  String get noActiveAlertsDesc => 'There are currently no active warnings.';

  @override
  String get osmContributors => 'OpenStreetMap contributors';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get autoRefresh => 'Auto refresh';

  @override
  String get interval => 'Interval';

  @override
  String intervalMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get sectionLocation => 'My location';

  @override
  String get locationMode => 'Location mode';

  @override
  String get locationAutomatic => 'Automatic (GPS)';

  @override
  String get locationManual => 'Manual';

  @override
  String get locationOff => 'Off';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get coordinatesSaved => 'Coordinates saved';

  @override
  String get sectionMap => 'Map';

  @override
  String get tileServerUrl => 'Tile server URL';

  @override
  String tileServerHint(String z, String x, String y) {
    return 'Use $z, $x, $y as placeholders.';
  }

  @override
  String get tileServerSaved => 'Tile server saved';

  @override
  String get presets => 'Presets';

  @override
  String get resetDefaults => 'Reset to defaults';

  @override
  String get sectionData => 'Data';

  @override
  String get loadAllAlerts => 'Load all alerts';

  @override
  String alertsLoadingCount(int count) {
    return '$count alerts loaded…';
  }

  @override
  String allAlertsLoadedCount(int count) {
    return 'All $count alerts loaded.';
  }

  @override
  String alertsCount(int count) {
    return '$count alerts loaded.';
  }

  @override
  String get sectionDebug => 'Debug';

  @override
  String get debugFakeAlert => 'Fake alert on every refresh';

  @override
  String get debugFakeAlertDesc =>
      'Generates an active test alert that triggers a notification. With sound if location is available.';

  @override
  String get debugSendAlert => 'Send a test alert now';

  @override
  String get alertNotFound => 'Warning not found';

  @override
  String get startTime => 'Start time';

  @override
  String get endTime => 'End time';

  @override
  String get messageLabelDutch => 'Dutch';

  @override
  String get messageLabelEnglish => 'English';

  @override
  String get statusActive => 'Active';

  @override
  String get statusPast => 'Past';

  @override
  String get affectsYourLocation => 'Applies to your location';

  @override
  String get affectedBannerText =>
      'Warning: your current location is within the warning area of this NL-Alert.';

  @override
  String get cardAffectsLocation =>
      'This warning area applies to your location';

  @override
  String get statusYou => 'You!';

  @override
  String get navStats => 'Statistics';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsLoading => 'Loading all alerts…';

  @override
  String statsLoadingCount(int count) {
    return '$count alerts loaded';
  }

  @override
  String get statsChartMonthly => 'Alerts per month';

  @override
  String get statsChartMonthlyInfo =>
      'Shows the total number of NL-Alerts per calendar month, summed across all available years. This reveals which months historically see the most warnings.';

  @override
  String get statsChartTimeline => 'Alerts over time';

  @override
  String get statsChartTimelineInfo =>
      'Shows the number of NL-Alerts per year, revealing the growth or decline in NL-Alert usage over time.';

  @override
  String get statsChartDuration => 'Alert duration';

  @override
  String get statsChartDurationInfo =>
      'Shows how long alerts were active, grouped into four time categories. Only alerts with a known end time are included.';

  @override
  String get statsChartByHour => 'Alerts by hour';

  @override
  String get statsChartByHourInfo =>
      'Shows which hour of the day most NL-Alerts are issued, based on start time. Numbers on the x-axis are hours in 24-hour format.';

  @override
  String get statsDurLt1h => '< 1h';

  @override
  String get statsDur1to4h => '1–4h';

  @override
  String get statsDur4to24h => '4–24h';

  @override
  String get statsDurGt24h => '> 24h';

  @override
  String get statsNoData => 'No data available';

  @override
  String alertId(String id) {
    return 'ID: $id';
  }

  @override
  String get sectionAbout => 'About';

  @override
  String get aboutApp => 'About Dutch Warnings';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutLegalese =>
      'Copyright © 2026 Dutch Warnings contributors\n\nThis program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 or later.';

  @override
  String get aboutViewLicenses => 'View licenses';
}
