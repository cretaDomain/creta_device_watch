import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlarmSettingsDialog extends StatefulWidget {
  final List<String> alarmTimes;
  final Function(DateTime) onAddAlarm;
  final Function(int) onDeleteAlarm;

  const AlarmSettingsDialog({
    super.key,
    required this.alarmTimes,
    required this.onAddAlarm,
    required this.onDeleteAlarm,
  });

  @override
  State<AlarmSettingsDialog> createState() => _AlarmSettingsDialogState();
}

class _AlarmSettingsDialogState extends State<AlarmSettingsDialog> {
  Future<void> _handleAddAlarm() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    final newAlarm = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Parent state is the source of truth, but we call setState to rebuild the dialog UI instantly.
    setState(() {
      widget.onAddAlarm(newAlarm);
    });
  }

  void _handleDeleteAlarm(int index) {
    // Parent state is the source of truth, but we call setState to rebuild the dialog UI instantly.
    setState(() {
      widget.onDeleteAlarm(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.alarm, size: 28),
          SizedBox(width: 10),
          Text('알람 설정'),
        ],
      ),
      content: SizedBox(
        height: 220, // Adjusted height to keep the whole dialog around 400px
        width: 300, // Fixed width for better layout
        child: widget.alarmTimes.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('설정된 알람이 없습니다.', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: widget.alarmTimes.length,
                itemBuilder: (context, index) {
                  final alarmString = widget.alarmTimes[index];
                  // Let's format the date for better readability
                  final dateTime = DateFormat('yyyy/MM/dd HH:mm').parse(alarmString);
                  final formattedDate = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(dateTime);
                  final formattedTime = DateFormat('a hh:mm', 'ko_KR').format(dateTime);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: const Icon(Icons.alarm_on),
                      title: Text(formattedDate),
                      subtitle: Text(formattedTime, style: Theme.of(context).textTheme.titleLarge),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _handleDeleteAlarm(index),
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.add_alarm),
          label: const Text('추가'),
          onPressed: _handleAddAlarm,
        ),
      ],
    );
  }
}
