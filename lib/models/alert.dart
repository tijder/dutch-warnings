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

  String get title {
    final dutch = message.split('***').first.trim();
    final dot = dutch.indexOf('.');
    if (dot > 5 && dot < 100) return dutch.substring(0, dot);
    return dutch.length > 90 ? '${dutch.substring(0, 90)}…' : dutch;
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
