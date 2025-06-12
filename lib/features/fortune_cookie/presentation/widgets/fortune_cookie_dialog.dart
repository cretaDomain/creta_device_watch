import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creta_device_watch/core/di/provider.dart';

class FortuneCookieDialog extends ConsumerStatefulWidget {
  final double width;
  final double height;
  const FortuneCookieDialog({super.key, required this.width, required this.height});

  @override
  ConsumerState<FortuneCookieDialog> createState() => _FortuneCookieDialogState();
}

class _FortuneCookieDialogState extends ConsumerState<FortuneCookieDialog> {
  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 직후에 포춘쿠키 정보를 가져오도록 요청합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fortuneCookieNotifierProvider.notifier).fetchFortuneCookie();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fortuneCookieState = ref.watch(fortuneCookieNotifierProvider);

    // Dialog가 닫힐 때 Notifier의 상태를 초기화합니다.
    ref.listen<AsyncValue>(fortuneCookieNotifierProvider, (_, next) {
      if (next.hasError || (next.hasValue && next.value == null)) {
        // This logic is to handle closing the dialog and resetting state.
        // We can add a close button or tap outside to close.
        // For now, reset happens when dialog is manually closed.
      }
    });

    return AlertDialog(
      title: const Text('오늘의 포춘쿠키'),
      content: SizedBox(
        width: widget.width * 0.5,
        height: widget.height * 0.5,
        child: Center(
          child: fortuneCookieState.when(
            data: (fortuneCookie) {
              if (fortuneCookie == null) {
                // 초기 상태 또는 fetch가 시작되기 전 아주 잠깐 동안 로딩을 표시합니다.
                return const CircularProgressIndicator();
              }
              return SingleChildScrollView(
                child: Text(
                  fortuneCookie.message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 24,
                      ),
                  textAlign: TextAlign.center,
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('오류: ${error.toString()}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(fortuneCookieNotifierProvider.notifier).fetchFortuneCookie();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('닫기'),
          onPressed: () {
            ref.read(fortuneCookieNotifierProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
