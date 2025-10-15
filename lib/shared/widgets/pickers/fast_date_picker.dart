import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum FastDatePickerMode {
  date,
  time,
  dateAndTime,
}

class FastDatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateChanged;
  final FastDatePickerMode mode;
  final bool use24hFormat;
  final EdgeInsetsGeometry? padding;

  const FastDatePicker({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
    this.mode = FastDatePickerMode.date,
    this.use24hFormat = false,
    this.padding,
  });

  static Future<DateTime?> showPicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    FastDatePickerMode mode = FastDatePickerMode.date,
    bool use24hFormat = false,
  }) async {
    final DateTime initial = initialDate ?? DateTime.now();
    final DateTime first = firstDate ?? DateTime(1900);
    final DateTime last = lastDate ?? DateTime(2100);

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      DateTime? selectedDate = initial;

      await showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 280,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('cancel'.tr),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('done'.tr),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: _toCupertinoMode(mode),
                      initialDateTime: initial,
                      minimumDate: first,
                      maximumDate: last,
                      use24hFormat: use24hFormat,
                      onDateTimeChanged: (DateTime newDate) {
                        selectedDate = newDate;
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      return selectedDate;
    } else {
      // Android Material Design
      if (mode == FastDatePickerMode.date) {
        return await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: first,
          lastDate: last,
        );
      } else if (mode == FastDatePickerMode.time) {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initial),
        );
        if (time != null) {
          return DateTime(
            initial.year,
            initial.month,
            initial.day,
            time.hour,
            time.minute,
          );
        }
      } else {
        // dateAndTime - show date first, then time
        final DateTime? date = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: first,
          lastDate: last,
        );
        if (date != null) {
          final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initial),
          );
          if (time != null) {
            return DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          }
        }
      }
      return null;
    }
  }

  static CupertinoDatePickerMode _toCupertinoMode(FastDatePickerMode mode) {
    switch (mode) {
      case FastDatePickerMode.date:
        return CupertinoDatePickerMode.date;
      case FastDatePickerMode.time:
        return CupertinoDatePickerMode.time;
      case FastDatePickerMode.dateAndTime:
        return CupertinoDatePickerMode.dateAndTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: SizedBox(
        height: 200,
        child: isIOS
            ? CupertinoDatePicker(
                mode: _toCupertinoMode(mode),
                initialDateTime: initialDate ?? DateTime.now(),
                minimumDate: firstDate,
                maximumDate: lastDate,
                use24hFormat: use24hFormat,
                onDateTimeChanged: onDateChanged ?? (_) {},
              )
            : _buildMaterialDatePicker(context),
      ),
    );
  }

  Widget _buildMaterialDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showPicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          mode: mode,
          use24hFormat: use24hFormat,
        );
        if (picked != null && onDateChanged != null) {
          onDateChanged!(picked);
        }
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForMode(mode),
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                _getTextForMode(mode),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (initialDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(initialDate!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForMode(FastDatePickerMode mode) {
    switch (mode) {
      case FastDatePickerMode.date:
        return Icons.calendar_today;
      case FastDatePickerMode.time:
        return Icons.access_time;
      case FastDatePickerMode.dateAndTime:
        return Icons.event;
    }
  }

  String _getTextForMode(FastDatePickerMode mode) {
    switch (mode) {
      case FastDatePickerMode.date:
        return 'tap_to_select_date'.tr;
      case FastDatePickerMode.time:
        return 'tap_to_select_time'.tr;
      case FastDatePickerMode.dateAndTime:
        return 'tap_to_select_date_time'.tr;
    }
  }

  String _formatDate(DateTime date) {
    switch (mode) {
      case FastDatePickerMode.time:
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      case FastDatePickerMode.date:
        return '${date.day}/${date.month}/${date.year}';
      case FastDatePickerMode.dateAndTime:
        return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
