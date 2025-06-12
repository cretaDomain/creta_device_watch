const String aiProvider = String.fromEnvironment('AI', defaultValue: 'Gemini');

const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const String location = String.fromEnvironment('LOCATION', defaultValue: 'Seoul');

const String copilotApiKey = String.fromEnvironment('COPILOT_API_KEY');
const String copilotEndpoint = String.fromEnvironment('COPILOT_ENDPOINT');

void checkApiKeys() {
  if (aiProvider == 'Gemini' && geminiApiKey.isEmpty) {
    throw AssertionError('AI is set to Gemini, but GEMINI_API_KEY is not set. '
        'Run the app with --dart-define=GEMINI_API_KEY=YOUR_API_KEY');
  } else if (aiProvider == 'Copilot' && (copilotApiKey.isEmpty || copilotEndpoint.isEmpty)) {
    throw AssertionError(
        'AI is set to Copilot, but COPILOT_API_KEY or COPILOT_ENDPOINT is not set.');
  }
}
