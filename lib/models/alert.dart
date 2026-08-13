class Alert {
  const Alert({
    required this.id,
    required this.message,
    required this.type,
    required this.startAt,
    this.stopAt,
    required this.area,
    this.resourceUri,
  });

  final String id;
  final String message;
  final String type;
  final DateTime startAt;
  final DateTime? stopAt;
  final List<String> area;
  final String? resourceUri;

  bool get isActive =>
      stopAt == null || stopAt!.isAfter(DateTime.now().toUtc());

  // Use the first sentence as a title, but only when it reads like a real
  // sentence: long enough to be meaningful and short enough to fit a title.
  static const _minTitleLength = 5;
  static const _maxTitleLength = 100;
  static const _fallbackTruncateAt = 90;

  String get title {
    final dutch = message.split('***').first.trim();
    // "NL-Alert." is a label prefix, not meaningful content; skip past it.
    final searchFrom = dutch.startsWith('NL-Alert.') ? 9 : 0;
    final dot = dutch.indexOf('.', searchFrom);
    if (dot > _minTitleLength && dot < _maxTitleLength) {
      return dutch.substring(0, dot);
    }
    return dutch.length > _fallbackTruncateAt
        ? '${dutch.substring(0, _fallbackTruncateAt)}…'
        : dutch;
  }

  String get dutchMessage => message.split('***').first.trim();

  String get englishMessage {
    final parts = message.split('***');
    return parts.length > 1 ? parts.last.trim() : '';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'type': type,
        'start_at': startAt.toIso8601String(),
        'stop_at': stopAt?.toIso8601String(),
        'area': area,
        'resource_uri': resourceUri,
      };

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json['id'] as String,
        message: json['message'] as String,
        type: json['type'] as String,
        startAt: DateTime.parse(json['start_at'] as String).toLocal(),
        stopAt: json['stop_at'] != null
            ? DateTime.parse(json['stop_at'] as String).toLocal()
            : null,
        area: (json['area'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        resourceUri: json['resource_uri'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Alert && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
