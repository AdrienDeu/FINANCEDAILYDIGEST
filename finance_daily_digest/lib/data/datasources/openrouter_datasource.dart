import 'package:dio/dio.dart';

import 'exceptions/api_exception.dart';
import 'http/dio_client.dart';
import 'secure_storage_service.dart';

/// DataSource for OpenRouter AI API (Mistral)
class OpenRouterDataSource {
  final DioClient _dioClient;
  final SecureStorageService _secureStorage;

  OpenRouterDataSource({
    DioClient? dioClient,
    SecureStorageService? secureStorage,
  })  : _dioClient = dioClient ??
            DioClient(
              baseUrl: 'https://openrouter.ai/api/v1',
            ),
        _secureStorage = secureStorage ?? SecureStorageService();

  /// Get API key from secure storage
  Future<String> _getApiKey() async {
    final apiKey = await _secureStorage.getOpenRouterApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const UnauthorizedException(
        'Clé API OpenRouter manquante - configurez-la d\'abord',
      );
    }
    return apiKey;
  }

  /// Generate a completion using OpenRouter
  ///
  /// [prompt] - The user prompt
  /// [systemPrompt] - Optional system prompt for context
  /// [model] - AI model to use (default: google/gemini-2.0-flash-001)
  /// [maxTokens] - Maximum tokens in response (default: 500)
  /// [temperature] - Creativity level 0.0-1.0 (default: 0.7)
  ///
  /// Returns the AI-generated text response
  Future<String> generateCompletion({
    required String prompt,
    String? systemPrompt,
    String model = 'google/gemini-2.0-flash-001',
    int maxTokens = 500,
    double temperature = 0.7,
  }) async {
    try {
      final apiKey = await _getApiKey();

      final messages = <Map<String, String>>[];

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      }

      messages.add({
        'role': 'user',
        'content': prompt,
      });

      final response = await _dioClient.dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://finance-daily-digest.app',
            'X-Title': 'Finance Daily Digest',
          },
        ),
        data: {
          'model': model,
          'messages': messages,
          'max_tokens': maxTokens,
          'temperature': temperature,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List?;

        if (choices != null && choices.isNotEmpty) {
          final firstChoice = choices[0] as Map<String, dynamic>;
          final message = firstChoice['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;

          if (content != null && content.isNotEmpty) {
            return content.trim();
          }
        }
      }

      throw const ParseException('Format de réponse invalide');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }

      // Check for rate limiting
      if (e.response?.statusCode == 429) {
        throw const RateLimitException(
          'Limite de requêtes atteinte - veuillez réessayer plus tard',
        );
      }

      // Check for unauthorized
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException(
          'Clé API OpenRouter invalide',
        );
      }

      throw ClientException(
        e.message ?? 'Erreur lors de l\'appel à l\'IA',
        e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ParseException(
        'Erreur de parsing: ${e.toString()}',
        e,
      );
    }
  }

  /// Vulgarize a financial article for beginners
  ///
  /// [articleTitle] - The article title
  /// [articleContent] - The article content to vulgarize
  ///
  /// Returns simplified French explanation suitable for beginners
  Future<String> vulgarizeArticle({
    required String articleTitle,
    required String articleContent,
  }) async {
    const systemPrompt = '''Tu es un expert financier pédagogue qui explique les actualités financières en français simple pour des investisseurs débutants. Tu dois TOUJOURS répondre en français.''';

    final userPrompt = '''IMPORTANT: Réponds UNIQUEMENT en français.

Voici un article financier à vulgariser pour un débutant:

TITRE: $articleTitle

CONTENU: $articleContent

Explique cet article en français simple et accessible (200-300 mots maximum). Structure ta réponse ainsi:

📰 DE QUOI PARLE L'ARTICLE:
[Explication simple du sujet]

💡 POURQUOI C'EST IMPORTANT:
[Impact sur les marchés ou l'économie]

👤 CE QUE ÇA SIGNIFIE POUR UN INVESTISSEUR:
[Conseils pratiques pour un débutant]

📚 VOCABULAIRE SIMPLIFIÉ:
[2-3 termes techniques expliqués simplement]''';

    return await generateCompletion(
      prompt: userPrompt,
      systemPrompt: systemPrompt,
      maxTokens: 600,
      temperature: 0.7,
    );
  }

  /// Generate investment suggestions based on news
  ///
  /// [newsDigest] - Summary of recent financial news
  ///
  /// Returns investment suggestions in French
  Future<String> generateInvestmentSuggestions({
    required String newsDigest,
  }) async {
    const systemPrompt = '''Tu es un conseiller en investissement
pour le marché européen (PEA). Tu génères des suggestions
d'investissement basées sur l'actualité, adaptées aux débutants.''';

    final userPrompt = '''Basé sur ces actualités financières :

$newsDigest

Génère 2-3 suggestions d'investissement en français:
- Titre/ticker éligible PEA
- Type (Action, ETF, Obligation)
- Pourquoi c'est intéressant maintenant
- Niveau de risque (Faible/Moyen/Élevé)

Format: JSON avec structure:
{
  "suggestions": [
    {
      "ticker": "...",
      "name": "...",
      "type": "...",
      "reasoning": "...",
      "risk": "..."
    }
  ]
}''';

    return await generateCompletion(
      prompt: userPrompt,
      systemPrompt: systemPrompt,
      maxTokens: 800,
      temperature: 0.8,
    );
  }
}
