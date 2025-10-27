import 'dart:convert';
import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/notifications/fast_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Screen for managing lock schedules
/// Allows users to view, edit, enable/disable schedules
class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  final StorageService _storage = StorageService();
  final ScreenTimeService _screenTimeService = ScreenTimeService();

  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final schedulesJson = await _storage.readString('onboarding_schedules');

      if (schedulesJson != null && schedulesJson.isNotEmpty) {
        final List<dynamic> schedulesData = jsonDecode(schedulesJson);
        setState(() {
          _schedules = schedulesData
              .map((s) => Map<String, dynamic>.from(s))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading schedules: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndResetupSchedules() async {
    try {
      // Save to storage
      await _storage.writeString(
        'onboarding_schedules',
        jsonEncode(_schedules),
      );

      // Re-setup native DeviceActivity schedules
      await _screenTimeService.setupSchedules(_schedules);

      if (mounted) {
        FastToast.showSuccess(
          context: context,
          title: 'Schedules Updated',
          message: 'Your lock schedules have been updated successfully',
        );
      }
    } catch (e) {
      print('Error saving schedules: $e');
      if (mounted) {
        FastToast.showError(
          context: context,
          title: 'Error',
          message: 'Failed to update schedules: $e',
        );
      }
    }
  }

  void _toggleSchedule(int index) {
    setState(() {
      _schedules[index]['enabled'] = !_schedules[index]['enabled'];
    });
    _saveAndResetupSchedules();
  }

  Future<void> _editScheduleTime(int index, bool isStart) async {
    final currentHour = _schedules[index][isStart ? 'startHour' : 'endHour'] as int;
    final currentMinute = _schedules[index][isStart ? 'startMinute' : 'endMinute'] as int;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: OnboardingTheme.goldColor,
              onPrimary: Colors.black,
              surface: OnboardingTheme.cardBackground,
              onSurface: OnboardingTheme.labelPrimary,
              shadow: Colors.transparent,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: OnboardingTheme.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _schedules[index][isStart ? 'startHour' : 'endHour'] = picked.hour;
        _schedules[index][isStart ? 'startMinute' : 'endMinute'] = picked.minute;
      });
      _saveAndResetupSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: OnboardingTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Lock Schedules',
          style: OnboardingTheme.title2.copyWith(
            color: OnboardingTheme.labelPrimary,
          ),
        ),
        iconTheme: IconThemeData(
          color: OnboardingTheme.goldColor,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? _buildEmptyState()
              : _buildScheduleList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 80,
              color: OnboardingTheme.labelTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Schedules Found',
              style: OnboardingTheme.title3.copyWith(
                color: OnboardingTheme.labelPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete the onboarding to set up your lock schedules',
              style: OnboardingTheme.body.copyWith(
                color: OnboardingTheme.labelSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Manage your app lock schedules below. Changes are applied immediately.',
          style: OnboardingTheme.body.copyWith(
            color: OnboardingTheme.labelSecondary,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(
          _schedules.length,
          (index) => _buildScheduleCard(index),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(int index) {
    final schedule = _schedules[index];
    final isEnabled = schedule['enabled'] as bool;
    final name = schedule['name'] as String;
    final icon = schedule['icon'] as String;
    final startHour = schedule['startHour'] as int;
    final startMinute = schedule['startMinute'] as int;
    final endHour = schedule['endHour'] as int;
    final endMinute = schedule['endMinute'] as int;

    String formatTime(int hour, int minute) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    // Calculate duration
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    var durationMinutes = endMinutes - startMinutes;
    if (durationMinutes < 0) durationMinutes += 24 * 60;
    final durationHours = (durationMinutes / 60).floor();
    final durationMins = durationMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled
            ? OnboardingTheme.cardBackground
            : OnboardingTheme.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
        border: Border.all(
          color: isEnabled
              ? OnboardingTheme.goldColor.withValues(alpha: 0.3)
              : OnboardingTheme.cardBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon & Name
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: OnboardingTheme.body.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? OnboardingTheme.labelPrimary
                            : OnboardingTheme.labelTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${durationHours}h ${durationMins}m lock',
                      style: OnboardingTheme.footnote.copyWith(
                        fontSize: 13,
                        color: OnboardingTheme.labelTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle switch
              GestureDetector(
                onTap: () => _toggleSchedule(index),
                child: Container(
                  width: 51,
                  height: 31,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isEnabled
                        ? OnboardingTheme.goldColor
                        : OnboardingTheme.labelTertiary.withValues(alpha: 0.3),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment:
                        isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      width: 27,
                      height: 27,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _editScheduleTime(index, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.backgroundColor.withValues(
                        alpha: isEnabled ? 1.0 : 0.5,
                      ),
                      borderRadius:
                          BorderRadius.circular(OnboardingTheme.radiusSmall),
                      border: Border.all(
                        color: (isEnabled
                            ? OnboardingTheme.goldColor
                            : OnboardingTheme.labelTertiary).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start',
                          style: OnboardingTheme.footnote.copyWith(
                            fontSize: 11,
                            color: OnboardingTheme.labelTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatTime(startHour, startMinute),
                          style: OnboardingTheme.body.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isEnabled
                                ? OnboardingTheme.goldColor
                                : OnboardingTheme.labelTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '→',
                style: TextStyle(
                  fontSize: 20,
                  color: OnboardingTheme.labelTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _editScheduleTime(index, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.backgroundColor.withValues(
                        alpha: isEnabled ? 1.0 : 0.5,
                      ),
                      borderRadius:
                          BorderRadius.circular(OnboardingTheme.radiusSmall),
                      border: Border.all(
                        color: (isEnabled
                            ? OnboardingTheme.goldColor
                            : OnboardingTheme.labelTertiary).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End',
                          style: OnboardingTheme.footnote.copyWith(
                            fontSize: 11,
                            color: OnboardingTheme.labelTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatTime(endHour, endMinute),
                          style: OnboardingTheme.body.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isEnabled
                                ? OnboardingTheme.goldColor
                                : OnboardingTheme.labelTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
