import 'package:flutter/material.dart';
import 'api_key.dart';
import 'package:http/http.dart';
import 'completions_request.dart';
import 'completions_response.dart';

class CompletionsApi{
  static final Uri completionsEndpoint = Uri.parse('https://api.openai.com/v1/completions');
  static final Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $openAIApiKey',
  };
  /// Gets a "weather forecast" from the OpenAI completions endpoint
  static Future<CompletionsResponse> getNewForecast(String reqText) async {

  CompletionsRequest request = CompletionsRequest(
    model: 'text-curie-001',
    prompt: reqText,
    maxTokens: 9,
    temperature: 0.6,
  );
  Response response = await post(completionsEndpoint,
      headers: headers, body: request.toJson());
  // Check to see if there was an error
  if (response.statusCode != 200) {
    // TODO handle errors
    debugPrint('Failed to get a forecast with status code, ${response.statusCode}');
  }
  CompletionsResponse completionsResponse = CompletionsResponse.fromResponse(response);
  return completionsResponse;
}
}