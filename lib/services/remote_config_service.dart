import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  FirebaseRemoteConfig? _remoteConfig;
  
  // Ключи конфига
  static const String _keyUrl = 'url'; // Единый параметр с условиями по странам
  static const String _keyOpen = 'open'; // Флаг для органики: true = показать WebView, false = показать планнер
  static const String _keyShowWebView = 'show_webview';

  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;
    
    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    // Дефолтные значения
    await _remoteConfig!.setDefaults({
      _keyUrl: '',
      _keyOpen: false,
      _keyShowWebView: false,
    });

    try {
      await _remoteConfig!.fetchAndActivate();
      print('Remote Config: Fetched and activated');
    } catch (e) {
      print('Remote Config: Error fetching - $e');
    }
  }

  // Проверить параметр 'open' для органических установок
  // true = показать WebView, false = показать планнер
  bool get isOpen {
    final open = _remoteConfig?.getBool(_keyOpen) ?? false;
    print('Remote Config open: $open');
    return open;
  }

  // Получить URL из Remote Config
  // Firebase сам вернет значение по условию страны устройства
  String? getWebViewUrl() {
    final url = _remoteConfig?.getString(_keyUrl);
    if (url != null && url.isNotEmpty) {
      print('Remote Config URL: $url');
      return url;
    }
    print('Remote Config URL: empty or null');
    return null;
  }

  // Проверить, нужно ли показывать WebView глобально
  bool get shouldShowWebView {
    return _remoteConfig?.getBool(_keyShowWebView) ?? false;
  }

  // Получить любое значение по ключу
  String getString(String key) {
    return _remoteConfig?.getString(key) ?? '';
  }

  bool getBool(String key) {
    return _remoteConfig?.getBool(key) ?? false;
  }

  int getInt(String key) {
    return _remoteConfig?.getInt(key) ?? 0;
  }

  double getDouble(String key) {
    return _remoteConfig?.getDouble(key) ?? 0.0;
  }

  // Сохранить URL локально (для оффлайн)
  Future<void> cacheUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_webview_url', url);
  }

  // Получить закэшированный URL
  Future<String?> getCachedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cached_webview_url');
  }

  // Сохранить решение о показе WebView
  Future<void> saveWebViewDecision(bool showWebView, String? url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('should_show_webview', showWebView);
    if (url != null) {
      await prefs.setString('cached_webview_url', url);
    }
  }

  // Получить сохраненное решение
  static Future<(bool, String?)> getSavedWebViewDecision() async {
    final prefs = await SharedPreferences.getInstance();
    final showWebView = prefs.getBool('should_show_webview') ?? false;
    final url = prefs.getString('cached_webview_url');
    return (showWebView, url);
  }
}
