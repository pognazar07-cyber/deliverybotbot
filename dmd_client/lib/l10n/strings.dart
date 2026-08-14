/// Lightweight string table for the app's 3 supported languages
/// (ru/ro/en — matching the languages the bot's /api/app-update endpoint
/// actually returns messages for). Not using the full intl/gen-l10n
/// pipeline to keep the MVP simple; swap for ARB files later if needed.
class AppStrings {
  final String lang;
  const AppStrings(this.lang);

  static const Map<String, Map<String, String>> _table = {
    'appName': {'ru': 'DMD', 'ro': 'DMD', 'en': 'DMD'},
    'chooseLanguage': {
      'ru': 'Выберите язык',
      'ro': 'Alegeți limba',
      'en': 'Choose language',
    },
    'continueBtn': {'ru': 'Продолжить', 'ro': 'Continuă', 'en': 'Continue'},
    'pairingTitle': {
      'ru': 'Привяжите Telegram',
      'ro': 'Asociați Telegram',
      'en': 'Link Telegram',
    },
    'pairingInstructions': {
      'ru': 'Откройте бота DeliveryMD в Telegram и отправьте команду:',
      'ro': 'Deschideți botul DeliveryMD în Telegram și trimiteți comanda:',
      'en': 'Open the DeliveryMD bot in Telegram and send the command:',
    },
    'pairingCodeHint': {
      'ru': 'Бот пришлёт 6-значный код. Он действует 30 секунд — введите его ниже:',
      'ro': 'Botul va trimite un cod din 6 cifre. Este valabil 30 de secunde — introduceți-l mai jos:',
      'en': 'The bot will send a 6-digit code. It is valid for 30 seconds — enter it below:',
    },
    'codeLabel': {'ru': 'Код из Telegram', 'ro': 'Cod din Telegram', 'en': 'Code from Telegram'},
    'verifyBtn': {'ru': 'Подтвердить', 'ro': 'Confirmă', 'en': 'Verify'},
    'openTelegram': {'ru': 'Открыть Telegram', 'ro': 'Deschide Telegram', 'en': 'Open Telegram'},
    'copyId': {'ru': 'Скопировать ID', 'ro': 'Copiază ID', 'en': 'Copy ID'},
    'idCopied': {'ru': 'ID скопирован', 'ro': 'ID copiat', 'en': 'ID copied'},
    'tabOrder': {'ru': 'Заказ', 'ro': 'Comandă', 'en': 'Order'},
    'tabHistory': {'ru': 'История', 'ro': 'Istoric', 'en': 'History'},
    'tabSupport': {'ru': 'Поддержка', 'ro': 'Suport', 'en': 'Support'},
    'tabProfile': {'ru': 'Профиль', 'ro': 'Profil', 'en': 'Profile'},
    'pickPointA': {
      'ru': 'Точка А — откуда забрать',
      'ro': 'Punctul A — de unde ridicăm',
      'en': 'Point A — pickup location',
    },
    'pickPointB': {
      'ru': 'Точка Б — куда доставить',
      'ro': 'Punctul B — unde livrăm',
      'en': 'Point B — delivery location',
    },
    'tapMapToSet': {
      'ru': 'Нажмите на карту, чтобы указать точку',
      'ro': 'Atingeți harta pentru a seta punctul',
      'en': 'Tap the map to set the point',
    },
    'cargoType': {'ru': 'Тип доставки', 'ro': 'Tipul livrării', 'en': 'Delivery type'},
    'cargoStandard': {
      'ru': 'Стандарт (10 лей/км)',
      'ro': 'Standard (10 MDL/km)',
      'en': 'Standard (10 MDL/km)',
    },
    'cargoFreight': {
      'ru': 'Грузовой (20 лей/км)',
      'ro': 'Marfă (20 MDL/km)',
      'en': 'Freight (20 MDL/km)',
    },
    'phoneSender': {
      'ru': 'Телефон отправителя',
      'ro': 'Telefonul expeditorului',
      'en': "Sender's phone",
    },
    'phoneReceiver': {
      'ru': 'Телефон получателя',
      'ro': 'Telefonul receptorului',
      'en': "Receiver's phone",
    },
    'comment': {'ru': 'Комментарий', 'ro': 'Comentariu', 'en': 'Comment'},
    'estimatedPrice': {
      'ru': 'Ориентировочная стоимость',
      'ro': 'Preț estimativ',
      'en': 'Estimated price',
    },
    'confirmOrder': {'ru': 'Заказать', 'ro': 'Comandă', 'en': 'Place order'},
    'orderPlaced': {
      'ru': 'Заказ опубликован! Ищем ближайших курьеров...',
      'ro': 'Comanda a fost publicată! Căutăm curieri...',
      'en': 'Order placed! Searching for couriers...',
    },
    'activeOrderTitle': {
      'ru': 'Текущий заказ',
      'ro': 'Comanda curentă',
      'en': 'Active order',
    },
    'noActiveOrder': {
      'ru': 'У вас нет активных заказов',
      'ro': 'Nu aveți comenzi active',
      'en': "You don't have any active orders",
    },
    'newOrder': {'ru': 'Новый заказ', 'ro': 'Comandă nouă', 'en': 'New order'},
    'statusPending': {'ru': 'Ищем курьера', 'ro': 'Căutăm curier', 'en': 'Finding a courier'},
    'statusAccepted': {
      'ru': 'Курьер в пути к точке А',
      'ro': 'Curierul se îndreaptă spre punctul A',
      'en': 'Courier heading to point A',
    },
    'statusAtA': {
      'ru': 'Курьер на точке А',
      'ro': 'Curierul este la punctul A',
      'en': 'Courier is at point A',
    },
    'statusAtB': {
      'ru': 'Курьер на точке Б',
      'ro': 'Curierul este la punctul B',
      'en': 'Courier is at point B',
    },
    'statusCompleted': {'ru': 'Заказ завершён', 'ro': 'Comanda finalizată', 'en': 'Order completed'},
    'statusCancelled': {'ru': 'Заказ отменён', 'ro': 'Comanda anulată', 'en': 'Order cancelled'},
    'cancelOrder': {'ru': 'Отменить заказ', 'ro': 'Anulează comanda', 'en': 'Cancel order'},
    'courierLabel': {'ru': 'Курьер', 'ro': 'Curier', 'en': 'Courier'},
    'historyEmpty': {
      'ru': 'Здесь появятся ваши прошлые заказы',
      'ro': 'Aici vor apărea comenzile anterioare',
      'en': 'Your past orders will show up here',
    },
    'supportTitle': {'ru': 'Поддержка', 'ro': 'Suport', 'en': 'Support'},
    'supportEmpty': {
      'ru': 'Задайте вопрос — мы ответим здесь',
      'ro': 'Puneți o întrebare — vă răspundem aici',
      'en': 'Ask a question — we will reply here',
    },
    'supportInputHint': {
      'ru': 'Введите сообщение...',
      'ro': 'Introduceți mesajul...',
      'en': 'Type a message...',
    },
    'send': {'ru': 'Отправить', 'ro': 'Trimite', 'en': 'Send'},
    'profileTitle': {'ru': 'Профиль', 'ro': 'Profil', 'en': 'Profile'},
    'profileIdLabel': {'ru': 'ID приложения', 'ro': 'ID aplicație', 'en': 'App ID'},
    'telegramLabel': {'ru': 'Telegram', 'ro': 'Telegram', 'en': 'Telegram'},
    'deleteAccount': {'ru': 'Удалить аккаунт', 'ro': 'Șterge contul', 'en': 'Delete account'},
    'deleteConfirm': {
      'ru': 'Отвязать приложение от Telegram-аккаунта?',
      'ro': 'Deconectați aplicația de contul Telegram?',
      'en': 'Unlink the app from your Telegram account?',
    },
    'cancel': {'ru': 'Отмена', 'ro': 'Anulează', 'en': 'Cancel'},
    'confirm': {'ru': 'Подтвердить', 'ro': 'Confirmă', 'en': 'Confirm'},
    'error': {'ru': 'Ошибка', 'ro': 'Eroare', 'en': 'Error'},
    'retry': {'ru': 'Повторить', 'ro': 'Reîncearcă', 'en': 'Retry'},
    'fillAllFields': {
      'ru': 'Заполните все поля',
      'ro': 'Completați toate câmpurile',
      'en': 'Fill in all fields',
    },
    'checkUpdates': {
      'ru': 'Проверить обновления',
      'ro': 'Verifică actualizări',
      'en': 'Check for updates',
    },
    'currentVersion': {'ru': 'Версия', 'ro': 'Versiune', 'en': 'Version'},
    'upToDate': {
      'ru': 'У вас последняя версия',
      'ro': 'Aveți cea mai recentă versiune',
      'en': "You're on the latest version",
    },
    'updateAvailableTitle': {
      'ru': 'Доступно обновление',
      'ro': 'Actualizare disponibilă',
      'en': 'Update available',
    },
    'updateNow': {'ru': 'Обновить сейчас', 'ro': 'Actualizează acum', 'en': 'Update now'},
    'later': {'ru': 'Позже', 'ro': 'Mai târziu', 'en': 'Later'},
    'mapWarmingUp': {
      'ru': 'Сервис карты запускается, подождите немного...',
      'ro': 'Serviciul hărții pornește, așteptați puțin...',
      'en': 'Map service is starting up, please wait...',
    },
    'orderClosedNotifBody': {
      'ru': 'Статус заказа изменился — откройте приложение',
      'ro': 'Statusul comenzii s-a schimbat — deschideți aplicația',
      'en': 'Order status changed — open the app',
    },
  };

  String _get(String key) => _table[key]?[lang] ?? _table[key]?['ru'] ?? key;

  String get appName => _get('appName');
  String get chooseLanguage => _get('chooseLanguage');
  String get continueBtn => _get('continueBtn');
  String get pairingTitle => _get('pairingTitle');
  String get pairingInstructions => _get('pairingInstructions');
  String get pairingCodeHint => _get('pairingCodeHint');
  String get codeLabel => _get('codeLabel');
  String get verifyBtn => _get('verifyBtn');
  String get openTelegram => _get('openTelegram');
  String get copyId => _get('copyId');
  String get idCopied => _get('idCopied');
  String get tabOrder => _get('tabOrder');
  String get tabHistory => _get('tabHistory');
  String get tabSupport => _get('tabSupport');
  String get tabProfile => _get('tabProfile');
  String get pickPointA => _get('pickPointA');
  String get pickPointB => _get('pickPointB');
  String get tapMapToSet => _get('tapMapToSet');
  String get cargoType => _get('cargoType');
  String get cargoStandard => _get('cargoStandard');
  String get cargoFreight => _get('cargoFreight');
  String get phoneSender => _get('phoneSender');
  String get phoneReceiver => _get('phoneReceiver');
  String get comment => _get('comment');
  String get estimatedPrice => _get('estimatedPrice');
  String get confirmOrder => _get('confirmOrder');
  String get orderPlaced => _get('orderPlaced');
  String get activeOrderTitle => _get('activeOrderTitle');
  String get noActiveOrder => _get('noActiveOrder');
  String get newOrder => _get('newOrder');
  String get cancelOrder => _get('cancelOrder');
  String get courierLabel => _get('courierLabel');
  String get historyEmpty => _get('historyEmpty');
  String get supportTitle => _get('supportTitle');
  String get supportEmpty => _get('supportEmpty');
  String get supportInputHint => _get('supportInputHint');
  String get send => _get('send');
  String get profileTitle => _get('profileTitle');
  String get profileIdLabel => _get('profileIdLabel');
  String get telegramLabel => _get('telegramLabel');
  String get deleteAccount => _get('deleteAccount');
  String get deleteConfirm => _get('deleteConfirm');
  String get cancel => _get('cancel');
  String get confirm => _get('confirm');
  String get error => _get('error');
  String get retry => _get('retry');
  String get fillAllFields => _get('fillAllFields');
  String get checkUpdates => _get('checkUpdates');
  String get currentVersion => _get('currentVersion');
  String get upToDate => _get('upToDate');
  String get updateAvailableTitle => _get('updateAvailableTitle');
  String get updateNow => _get('updateNow');
  String get later => _get('later');
  String get orderClosedNotifBody => _get('orderClosedNotifBody');
  String get mapWarmingUp => _get('mapWarmingUp');

  String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return _get('statusPending');
      case 'accepted':
        return _get('statusAccepted');
      case 'at_a':
        return _get('statusAtA');
      case 'at_b':
        return _get('statusAtB');
      case 'completed':
        return _get('statusCompleted');
      case 'cancelled':
        return _get('statusCancelled');
      default:
        return status;
    }
  }
}
