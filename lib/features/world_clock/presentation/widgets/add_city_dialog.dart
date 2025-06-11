import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:creta_device_watch/features/world_clock/presentation/notifiers/world_clock_notifier.dart';

class AddCityDialog extends ConsumerStatefulWidget {
  const AddCityDialog({super.key});

  @override
  ConsumerState<AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends ConsumerState<AddCityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  String? _selectedTimezone;
  late final List<String> _timezones;

  @override
  void initState() {
    super.initState();
    _timezones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    _selectedTimezone =
        _timezones.firstWhere((tz) => tz == 'Asia/Seoul', orElse: () => _timezones.first);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _addCity() {
    if (_formKey.currentState!.validate()) {
      ref.read(worldClockNotifierProvider.notifier).addCity(
            _cityController.text,
            _selectedTimezone!,
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add World Clock'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a city name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedTimezone,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Timezone'),
              items: _timezones.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTimezone = newValue;
                });
              },
              validator: (value) => value == null ? 'Please select a timezone' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addCity,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
