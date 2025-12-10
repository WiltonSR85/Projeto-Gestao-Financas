import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String apiUrl = "https://openrouter.ai/api/v1/chat/completions";

  // Cole sua chave aqui
  static const String apiKey = 'sua-api-key-aqui';

  static String getApiKey() {
    return apiKey;
  }

  static bool isKeyConfigured() {
    final key = getApiKey();
    return key.isNotEmpty;
  }
}