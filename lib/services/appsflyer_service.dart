import 'dart:async';
import 'dart:io';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppsFlyerService {
  static final AppsFlyerService _instance = AppsFlyerService._internal();
  factory AppsFlyerService() => _instance;
  AppsFlyerService._internal();

  AppsflyerSdk? _appsflyerSdk;
  
  // Статус атрибуции
  bool _isNonOrganic = false;
  String? _campaign;
  String? _mediaSource;
  String? _afStatus;
  Map<String, dynamic>? _conversionData;
  
  final Completer<bool> _attributionCompleter = Completer<bool>();
  
  bool get isNonOrganic => _isNonOrganic;
  String? get campaign => _campaign;
  String? get mediaSource => _mediaSource;
  String? get afStatus => _afStatus;
  Map<String, dynamic>? get conversionData => _conversionData;
  
  Future<bool> waitForAttribution() => _attributionCompleter.future;

  Future<void> initialize({
    required String devKey,
    required String appId,
    bool isDebug = false,
  }) async {
    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: devKey,
      appId: appId,
      showDebug: isDebug,
      timeToWaitForATTUserAuthorization: 10,
      manualStart: false,
    );

    _appsflyerSdk = AppsflyerSdk(options);

    // Слушаем conversion data
    _appsflyerSdk!.onInstallConversionData((data) {
      print('AppsFlyer Conversion Data: $data');
      _handleConversionData(data);
    });

    _appsflyerSdk!.onAppOpenAttribution((data) {
      print('AppsFlyer App Open Attribution: $data');
      _handleDeepLink(data);
    });

    _appsflyerSdk!.onDeepLinking((DeepLinkResult dp) {
      print('AppsFlyer Deep Link: ${dp.toJson()}');
    });

    await _appsflyerSdk!.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    // Timeout для атрибуции (5 секунд)
    Future.delayed(const Duration(seconds: 5), () {
      if (!_attributionCompleter.isCompleted) {
        print('AppsFlyer: Attribution timeout, treating as organic');
        _attributionCompleter.complete(false);
      }
    });
  }

  void _handleConversionData(Map<String, dynamic> data) async {
    _conversionData = data;
    
    final status = data['status'];
    if (status == 'success') {
      final payload = data['payload'] ?? data;
      
      _afStatus = payload['af_status']?.toString();
      _mediaSource = payload['media_source']?.toString();
      _campaign = payload['campaign']?.toString();
      
      // Non-Organic = пришел с рекламы
      _isNonOrganic = _afStatus == 'Non-organic';
      
      print('AppsFlyer Status: $_afStatus');
      print('AppsFlyer Is Non-Organic: $_isNonOrganic');
      print('AppsFlyer Media Source: $_mediaSource');
      print('AppsFlyer Campaign: $_campaign');
      
      // Сохраняем в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('af_is_non_organic', _isNonOrganic);
      await prefs.setString('af_status', _afStatus ?? '');
      await prefs.setString('af_media_source', _mediaSource ?? '');
      await prefs.setString('af_campaign', _campaign ?? '');
    }
    
    if (!_attributionCompleter.isCompleted) {
      _attributionCompleter.complete(_isNonOrganic);
    }
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    print('AppsFlyer Deep Link Data: $data');
  }

  // Получить сохраненный статус атрибуции
  static Future<bool> getSavedAttributionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('af_is_non_organic') ?? false;
  }

  // Логировать событие
  Future<void> logEvent(String eventName, Map<String, dynamic>? eventValues) async {
    await _appsflyerSdk?.logEvent(eventName, eventValues);
  }

  // Получить AppsFlyer UID
  Future<String?> getAppsFlyerUID() async {
    return await _appsflyerSdk?.getAppsFlyerUID();
  }
}
