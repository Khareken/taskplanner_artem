import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  Future<void> initialize({
    required String appId,
    bool isDebug = false,
  }) async {
    // Включить отладку
    if (isDebug) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }

    // Инициализация
    OneSignal.initialize(appId);

    // Запросить разрешение на push
    await OneSignal.Notifications.requestPermission(true);

    // Слушатели
    OneSignal.Notifications.addClickListener((event) {
      print('OneSignal: Notification clicked - ${event.notification.body}');
      _handleNotificationClick(event);
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('OneSignal: Notification received in foreground');
      // Показать уведомление
      event.notification.display();
    });

    // Получить ID пользователя
    final userId = await OneSignal.User.getOnesignalId();
    print('OneSignal User ID: $userId');
  }

  void _handleNotificationClick(OSNotificationClickEvent event) {
    final data = event.notification.additionalData;
    if (data != null) {
      // Обработка данных из пуша
      final url = data['url'];
      if (url != null) {
        // Можно открыть URL в WebView
        print('OneSignal: Open URL from push - $url');
      }
    }
  }

  // Установить external user id (например, ID пользователя из вашей системы)
  Future<void> setExternalUserId(String userId) async {
    await OneSignal.login(userId);
  }

  // Удалить external user id (при логауте)
  Future<void> removeExternalUserId() async {
    await OneSignal.logout();
  }

  // Установить тег
  Future<void> setTag(String key, String value) async {
    await OneSignal.User.addTagWithKey(key, value);
  }

  // Установить несколько тегов
  Future<void> setTags(Map<String, String> tags) async {
    await OneSignal.User.addTags(tags);
  }

  // Удалить тег
  Future<void> removeTag(String key) async {
    await OneSignal.User.removeTag(key);
  }

  // Установить email
  Future<void> setEmail(String email) async {
    await OneSignal.User.addEmail(email);
  }

  // Установить телефон
  Future<void> setPhone(String phone) async {
    await OneSignal.User.addSms(phone);
  }

  // Проверить разрешение на push
  Future<bool> hasPermission() async {
    return OneSignal.Notifications.permission;
  }

  // Получить OneSignal ID
  Future<String?> getOneSignalId() async {
    return await OneSignal.User.getOnesignalId();
  }

  // Получить External ID
  Future<String?> getExternalId() async {
    return await OneSignal.User.getExternalId();
  }
}
