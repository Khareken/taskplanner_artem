/// Конфигурация приложения
/// ВАЖНО: Замените значения на свои реальные ключи перед релизом!
class AppConfig {
  // Debug mode
  static const bool isDebug = true;

  // AppsFlyer Configuration
  // Получить в AppsFlyer Dashboard: https://hq1.appsflyer.com/
  static const String appsFlyerDevKey = 'kkZdxk9EV8RaQwwYjLYLiP';
  static const String appsFlyerAppId = 'com.multi.planner';

  // OneSignal Configuration
  // Получить в OneSignal Dashboard: https://onesignal.com/
  static const String oneSignalAppId = 'd75b4689-ddf3-45e4-985b-20e60ac6e37e';

  // Firebase Configuration
  // Настраивается через google-services.json (Android) и GoogleService-Info.plist (iOS)
  
  // Remote Config Keys
  // Эти ключи используются в Firebase Remote Config
  static const remoteConfigKeys = RemoteConfigKeys();
}

class RemoteConfigKeys {
  const RemoteConfigKeys();
  
  /// Префикс для URL по странам: url_US, url_RU, url_DE и т.д.
  /// Значение: https://example.com/landing
  String urlForCountry(String countryCode) => 'url_${countryCode.toUpperCase()}';
  
  /// Дефолтный URL если нет специфичного для страны
  String get defaultUrl => 'default_url';
  
  /// Глобальный флаг показа WebView (true/false)
  String get showWebView => 'show_webview';
  
  /// Список стран через запятую: "US,RU,DE,GB,FR"
  String get enabledCountries => 'enabled_countries';
}

/*
================================================================================
ИНСТРУКЦИЯ ПО НАСТРОЙКЕ
================================================================================

1. APPSFLYER:
   - Зарегистрируйтесь на https://www.appsflyer.com/
   - Создайте приложение в дашборде
   - Скопируйте Dev Key из Settings > App Settings
   - Для iOS используйте Apple App ID (только цифры)
   - Для Android используйте package name

2. ONESIGNAL:
   - Зарегистрируйтесь на https://onesignal.com/
   - Создайте приложение
   - Скопируйте App ID из Keys & IDs
   - Настройте FCM для Android и APNs для iOS

3. FIREBASE REMOTE CONFIG:
   - Создайте проект в Firebase Console
   - Добавьте приложения Android и iOS
   - Скачайте google-services.json и GoogleService-Info.plist
   - В Remote Config создайте параметры:
   
   Пример конфигурации:
   
   | Parameter Key    | Value                           | Conditions      |
   |------------------|--------------------------------|-----------------|
   | url_US           | https://us.example.com/offer   | Country: US     |
   | url_RU           | https://ru.example.com/offer   | Country: RU     |
   | url_DE           | https://de.example.com/offer   | Country: DE     |
   | default_url      | https://example.com/offer      | Default         |
   | enabled_countries| US,RU,DE,GB,FR,IT,ES           | Default         |
   | show_webview     | true                           | Default         |

4. ANDROID SETUP:
   - Положите google-services.json в android/app/
   - Обновите android/build.gradle.kts и android/app/build.gradle.kts

5. iOS SETUP:
   - Положите GoogleService-Info.plist в ios/Runner/
   - Настройте capabilities в Xcode

================================================================================
*/
