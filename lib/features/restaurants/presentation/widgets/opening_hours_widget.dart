import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/restaurant_model.dart';

class OpeningHoursWidget extends StatefulWidget {
  final List<DayHours> openingHours;

  const OpeningHoursWidget({
    super.key,
    required this.openingHours,
  });

  @override
  State<OpeningHoursWidget> createState() => _OpeningHoursWidgetState();
}

class _OpeningHoursWidgetState extends State<OpeningHoursWidget> {
  bool _isExpanded = false;

  String get _currentDay {
    final now = DateTime.now();
    return DateFormat('EEEE').format(now);
  }

  DayHours? get _todayHours {
    try {
      return widget.openingHours.firstWhere(
        (hours) => hours.day == _currentDay,
      );
    } catch (e) {
      return null;
    }
  }

  String _getStatusText() {
    final today = _todayHours;
    if (today == null) return 'Hours not available';
    if (today.isClosed) return 'Closed today';

    final now = DateTime.now();
    final closeTime = _parseTime(today.closeTime ?? '');

    if (closeTime != null) {
      final hoursUntilClose = closeTime.difference(now).inHours;
      final minutesUntilClose = closeTime.difference(now).inMinutes % 60;

      if (hoursUntilClose < 0) {
        return 'Closed';
      } else if (hoursUntilClose == 0 && minutesUntilClose < 30) {
        return 'Closing soon';
      } else if (hoursUntilClose < 2) {
        return 'Open until ${today.closeTime}';
      }
    }

    return 'Open · Closes ${today.closeTime}';
  }

  DateTime? _parseTime(String timeString) {
    try {
      final now = DateTime.now();
      final format = DateFormat('h:mm a');
      final time = format.parse(timeString);
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayHours;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    today?.isClosed == true ? Icons.schedule_outlined : Icons.access_time,
                    color: today?.isClosed == true
                        ? AppColors.error
                        : AppColors.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: today?.isClosed == true
                                ? AppColors.error
                                : AppColors.darkText,
                          ),
                        ),
                        if (today != null && !today.isClosed) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$_currentDay: ${today.openTime} - ${today.closeTime}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.lightText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.mediumGrey,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: widget.openingHours.map((dayHours) {
                  final isToday = dayHours.day == _currentDay;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            dayHours.day,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                              color: isToday ? AppColors.primaryGreen : AppColors.darkText,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            dayHours.isClosed
                                ? 'Closed'
                                : '${dayHours.openTime} - ${dayHours.closeTime}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                              color: dayHours.isClosed
                                  ? AppColors.error
                                  : (isToday ? AppColors.primaryGreen : AppColors.lightText),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
