import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:creta_device_watch/core/api/api_key.dart';
import 'package:http/http.dart' as http;

abstract class FortuneCookieRemoteDataSource {
  Future<String> getFortuneCookieMessage();
}

class FortuneCookieRemoteDataSourceImpl implements FortuneCookieRemoteDataSource {
  FortuneCookieRemoteDataSourceImpl();

  @override
  Future<String> getFortuneCookieMessage() async {
    checkApiKeys();

    if (aiProvider == 'Copilot') {
      return _fetchFromCopilot();
    } else {
      return _fetchFromGemini();
    }
  }

  Future<String> _fetchFromGemini() async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);
      const prompt = '오늘의 포춘 쿠키 메시지를 생성해줘.';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? '포춘 쿠키 정보를 가져오는 데 실패했습니다.';
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _fetchFromCopilot() async {
    const prompt = '오늘의 포춘 쿠키 메시지를 생성해줘.';

    final url = Uri.parse(copilotEndpoint);
    final headers = {
      'Content-Type': 'application/json',
      'api-key': copilotApiKey,
    };
    final body = jsonEncode({
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
        return decodedBody['choices'][0]['message']['content'] ?? 'Copilot에서 포춘 쿠키를 가져오지 못했습니다.';
      } else {
        throw Exception(
            'Failed to load fortune cookie from Copilot: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
