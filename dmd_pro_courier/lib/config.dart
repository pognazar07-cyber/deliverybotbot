/// Central place to point the app at the bot's backend.
///
/// The backend lives in the DeliveryMD Telegram bot (bot.py) and exposes
/// the courier REST API (/api/courier/*) over HTTPS at deliverymd.duckdns.org.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://deliverymd.duckdns.org',
  );

  static const List<String> supportedLanguages = ['ru', 'ro', 'en'];
  static const String defaultLanguage = 'ru';

  /// Telegram @username of the DeliveryMD bot, used for the "Open Telegram"
  /// deep link on the pairing screen.
  static const String botUsername = String.fromEnvironment(
    'BOT_USERNAME',
    defaultValue: 'DeliveryMDBOTBOT',
  );

  // Chisinau, used to center the map before an order is loaded.
  static const double defaultLat = 47.0105;
  static const double defaultLon = 28.8638;
}
