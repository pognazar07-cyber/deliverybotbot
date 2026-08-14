/// Lightweight string table for the app's 3 supported languages (ru/ro/en).
/// Mirrors dmd_client's approach — not the full intl/gen-l10n pipeline.
class AppStrings {
  final String lang;
  const AppStrings(this.lang);

  static const Map<String, Map<String, String>> _table = {
    'appName': {'ru': 'DMD Pro Courier', 'ro': 'DMD Pro Courier', 'en': 'DMD Pro Courier'},
    'chooseLanguage': {'ru': 'Выберите язык', 'ro': 'Alegeți limba', 'en': 'Choose language'},
    'pairingTitle': {'ru': 'Привяжите Telegram', 'ro': 'Asociați Telegram', 'en': 'Link Telegram'},
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
    'photoTitle': {'ru': 'Верификация личности', 'ro': 'Verificarea identității', 'en': 'Identity verification'},
    'photoInstructions': {
      'ru': 'Сфотографируйте себя с паспортом или ID-картой — администратор проверит и одобрит вашу заявку.',
      'ro': 'Fotografiați-vă cu buletinul sau ID-ul — administratorul va verifica și aproba cererea.',
      'en': 'Take a photo of yourself with your ID — an admin will review and approve your application.',
    },
    'takePhoto': {'ru': 'Сделать фото', 'ro': 'Faceți o fotografie', 'en': 'Take a photo'},
    'choosePhoto': {'ru': 'Выбрать из галереи', 'ro': 'Alege din galerie', 'en': 'Choose from gallery'},
    'submitPhoto': {'ru': 'Отправить на проверку', 'ro': 'Trimite spre verificare', 'en': 'Submit for review'},
    'pendingTitle': {'ru': 'Заявка на рассмотрении', 'ro': 'Cererea este în curs de verificare', 'en': 'Application under review'},
    'pendingMessage': {
      'ru': 'Администратор проверяет вашу заявку. Обычно это занимает немного времени.',
      'ro': 'Administratorul verifică cererea dvs. De obicei durează puțin.',
      'en': "An admin is reviewing your application. This usually doesn't take long.",
    },
    'checkStatus': {'ru': 'Проверить статус', 'ro': 'Verifică statusul', 'en': 'Check status'},
    'tabShift': {'ru': 'Смена', 'ro': 'Tură', 'en': 'Shift'},
    'tabHistory': {'ru': 'История', 'ro': 'Istoric', 'en': 'History'},
    'tabProfile': {'ru': 'Профиль', 'ro': 'Profil', 'en': 'Profile'},
    'onShift': {'ru': 'Вы на смене', 'ro': 'Sunteți pe tură', 'en': "You're on shift"},
    'offShift': {'ru': 'Вы не на смене', 'ro': 'Nu sunteți pe tură', 'en': "You're off shift"},
    'goOnline': {'ru': 'Встать на смену', 'ro': 'Începe tura', 'en': 'Go online'},
    'goOffline': {'ru': 'Уйти со смены', 'ro': 'Termină tura', 'en': 'Go offline'},
    'noOrdersYet': {
      'ru': 'Пока нет доступных заказов. Оставайтесь на смене — новые придут автоматически.',
      'ro': 'Momentan nu sunt comenzi disponibile. Rămâneți pe tură — vor apărea automat.',
      'en': 'No available orders yet. Stay online — new ones will show up automatically.',
    },
    'goOnlinePrompt': {
      'ru': 'Встаньте на смену, чтобы видеть новые заказы',
      'ro': 'Porniți tura pentru a vedea comenzi noi',
      'en': 'Go online to see new orders',
    },
    'cargoStandard': {'ru': 'Стандарт', 'ro': 'Standard', 'en': 'Standard'},
    'cargoFreight': {'ru': 'Грузовой', 'ro': 'Marfă', 'en': 'Freight'},
    'acceptOrder': {'ru': 'Принять заказ', 'ro': 'Acceptă comanda', 'en': 'Accept order'},
    'activeDeliveryTitle': {'ru': 'Текущая доставка', 'ro': 'Livrarea curentă', 'en': 'Active delivery'},
    'statusAccepted': {'ru': 'В пути к точке А', 'ro': 'Spre punctul A', 'en': 'Heading to point A'},
    'statusAtA': {'ru': 'На точке А', 'ro': 'La punctul A', 'en': 'At point A'},
    'statusAtB': {'ru': 'На точке Б', 'ro': 'La punctul B', 'en': 'At point B'},
    'statusCompleted': {'ru': 'Завершено', 'ro': 'Finalizat', 'en': 'Completed'},
    'actionArrivedA': {'ru': 'Я на точке А', 'ro': 'Sunt la punctul A', 'en': 'Arrived at point A'},
    'actionArrivedB': {'ru': 'Я на точке Б', 'ro': 'Sunt la punctul B', 'en': 'Arrived at point B'},
    'actionComplete': {'ru': 'Завершить заказ', 'ro': 'Finalizează comanda', 'en': 'Complete order'},
    'senderPhone': {'ru': 'Телефон отправителя', 'ro': 'Telefonul expeditorului', 'en': "Sender's phone"},
    'receiverPhone': {'ru': 'Телефон получателя', 'ro': 'Telefonul receptorului', 'en': "Receiver's phone"},
    'historyEmpty': {
      'ru': 'Здесь появятся ваши выполненные заказы',
      'ro': 'Aici vor apărea comenzile finalizate',
      'en': 'Your completed orders will show up here',
    },
    'earningsThisMonth': {'ru': 'Заработок за месяц', 'ro': 'Câștig lunar', 'en': 'Earnings this month'},
    'ordersThisMonth': {'ru': 'заказов', 'ro': 'comenzi', 'en': 'orders'},
    'profileTitle': {'ru': 'Профиль', 'ro': 'Profil', 'en': 'Profile'},
    'telegramLabel': {'ru': 'Telegram', 'ro': 'Telegram', 'en': 'Telegram'},
    'profileIdLabel': {'ru': 'ID приложения', 'ro': 'ID aplicație', 'en': 'App ID'},
    'error': {'ru': 'Ошибка', 'ro': 'Eroare', 'en': 'Error'},
    'retry': {'ru': 'Повторить', 'ro': 'Reîncearcă', 'en': 'Retry'},
    'logout': {'ru': 'Выйти', 'ro': 'Deconectare', 'en': 'Logout'},
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
    'newOrderNotifBody': {
      'ru': 'Доступен новый заказ — откройте приложение',
      'ro': 'O comandă nouă este disponibilă — deschideți aplicația',
      'en': 'A new order is available — open the app',
    },
  };

  String _get(String key) => _table[key]?[lang] ?? _table[key]?['ru'] ?? key;

  String get appName => _get('appName');
  String get chooseLanguage => _get('chooseLanguage');
  String get pairingTitle => _get('pairingTitle');
  String get pairingInstructions => _get('pairingInstructions');
  String get pairingCodeHint => _get('pairingCodeHint');
  String get codeLabel => _get('codeLabel');
  String get verifyBtn => _get('verifyBtn');
  String get openTelegram => _get('openTelegram');
  String get copyId => _get('copyId');
  String get idCopied => _get('idCopied');
  String get photoTitle => _get('photoTitle');
  String get photoInstructions => _get('photoInstructions');
  String get takePhoto => _get('takePhoto');
  String get choosePhoto => _get('choosePhoto');
  String get submitPhoto => _get('submitPhoto');
  String get pendingTitle => _get('pendingTitle');
  String get pendingMessage => _get('pendingMessage');
  String get checkStatus => _get('checkStatus');
  String get tabShift => _get('tabShift');
  String get tabHistory => _get('tabHistory');
  String get tabProfile => _get('tabProfile');
  String get onShift => _get('onShift');
  String get offShift => _get('offShift');
  String get goOnline => _get('goOnline');
  String get goOffline => _get('goOffline');
  String get noOrdersYet => _get('noOrdersYet');
  String get goOnlinePrompt => _get('goOnlinePrompt');
  String get acceptOrder => _get('acceptOrder');
  String get activeDeliveryTitle => _get('activeDeliveryTitle');
  String get actionArrivedA => _get('actionArrivedA');
  String get actionArrivedB => _get('actionArrivedB');
  String get actionComplete => _get('actionComplete');
  String get senderPhone => _get('senderPhone');
  String get receiverPhone => _get('receiverPhone');
  String get historyEmpty => _get('historyEmpty');
  String get earningsThisMonth => _get('earningsThisMonth');
  String get ordersThisMonth => _get('ordersThisMonth');
  String get profileTitle => _get('profileTitle');
  String get telegramLabel => _get('telegramLabel');
  String get profileIdLabel => _get('profileIdLabel');
  String get error => _get('error');
  String get retry => _get('retry');
  String get logout => _get('logout');
  String get checkUpdates => _get('checkUpdates');
  String get currentVersion => _get('currentVersion');
  String get upToDate => _get('upToDate');
  String get updateAvailableTitle => _get('updateAvailableTitle');
  String get updateNow => _get('updateNow');
  String get later => _get('later');
  String get newOrderNotifBody => _get('newOrderNotifBody');

  String cargoLabel(String cargoType) => cargoType == 'freight' ? _get('cargoFreight') : _get('cargoStandard');

  String statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return _get('statusAccepted');
      case 'at_a':
        return _get('statusAtA');
      case 'at_b':
        return _get('statusAtB');
      case 'completed':
        return _get('statusCompleted');
      default:
        return status;
    }
  }

  String actionLabelFor(String nextStatus) {
    switch (nextStatus) {
      case 'at_a':
        return actionArrivedA;
      case 'at_b':
        return actionArrivedB;
      case 'completed':
        return actionComplete;
      default:
        return '';
    }
  }
}
