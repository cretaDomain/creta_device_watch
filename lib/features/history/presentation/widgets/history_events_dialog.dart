import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:creta_device_watch/features/history/presentation/notifiers/history_notifier.dart';

class HistoryEventsDialog extends ConsumerWidget {
  final DateTime date;

  const HistoryEventsDialog({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyNotifierProvider(date));

    return AlertDialog(
      title: Text('${DateFormat.MMMMd('ko_KR').format(date)}, 역사 속 오늘'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: historyState.when(
          data: (events) {
            if (events.isEmpty) {
              return const Center(
                child: Text('해당 날짜의 역사적 사건 정보가 없습니다.'),
              );
            }
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event.imageUrl != null)
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                event.imageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.history_edu_outlined, size: 40);
                                },
                              ),
                            ),
                          )
                        else
                          const SizedBox(
                            width: 80,
                            height: 80,
                            child: Icon(Icons.history_edu_outlined, size: 40),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${event.year}년',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(event.text),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('정보를 불러오는 데 실패했습니다.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(historyNotifierProvider(date).notifier).fetchHistoricalEvents();
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
