import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/l10n.dart';
import '../models/alert.dart';
import '../utils/geo_utils.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    required this.userLocation,
    required this.onTap,
  });

  final Alert alert;
  final LatLng? userLocation;
  final VoidCallback onTap;

  bool get _userAffected {
    if (userLocation == null || !alert.isActive) return false;
    return isUserInAlertArea(userLocation!, alert.area);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = alert.isActive;
    final affected = _userAffected;

    Color cardColor;
    Color borderColor;
    if (affected) {
      cardColor = const Color(0xFFFFE0B2);
      borderColor = Colors.deepOrange;
    } else if (isActive) {
      cardColor = const Color(0xFFFFF3E0);
      borderColor = Colors.orange;
    } else {
      cardColor = theme.colorScheme.surfaceContainerLow;
      borderColor = Colors.grey.shade300;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: affected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: affected ? 2.5 : 1),
      ),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      alert.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: affected
                            ? Colors.deepOrange.shade900
                            : isActive
                                ? Colors.orange.shade900
                                : theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(isActive: isActive, userAffected: affected),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('dd MMM yyyy HH:mm', Localizations.localeOf(context).toString()).format(alert.startAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                alert.dutchMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (affected) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.my_location,
                        size: 14, color: Colors.deepOrange.shade700),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.cardAffectsLocation,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.deepOrange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive, required this.userAffected});

  final bool isActive;
  final bool userAffected;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (userAffected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, size: 12, color: Colors.white),
            const SizedBox(width: 3),
            Text(l.statusYou, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l.statusActive,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l.statusPast,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
