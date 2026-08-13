/// Central place to point the app at the bot's backend.
///
/// The backend lives in the DeliveryMD Telegram bot (bot.py) and exposes
/// its REST API over HTTPS. Until that domain is set up, requests will
/// simply fail to connect — this is expected in local development.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.deliverymd.example',
  );

  static const List<String> supportedLanguages = ['ru', 'ro', 'en'];
  static const String defaultLanguage = 'ru';

  /// Telegram @username of the DeliveryMD bot, used for the "Open Telegram"
  /// deep link on the pairing screen. Fill in the real handle before release.
  static const String botUsername = String.fromEnvironment(
    'BOT_USERNAME',
    defaultValue: 'DeliveryMD_bot',
  );

  // Chisinau, used to center the map before the user picks a location.
  static const double defaultLat = 47.0105;
  static const double defaultLon = 28.8638;
}
