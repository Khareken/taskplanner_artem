import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/appsflyer_service.dart';
import '../services/remote_config_service.dart';
import '../services/onesignal_service.dart';
import '../config/app_config.dart';
import 'home_screen.dart';
import 'webview_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusMessage = 'Initializing...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Проверяем, не первый ли это запуск после установки
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
      
      if (!isFirstLaunch) {
        // Не первый запуск - используем сохраненное решение
        await _handleReturningUser(prefs);
        return;
      }

      // Первый запуск - выполняем полную инициализацию
      await _handleFirstLaunch(prefs);
      
    } catch (e) {
      print('Splash Error: $e');
      setState(() {
        _hasError = true;
        _statusMessage = 'Error: $e';
      });
      
      // В случае ошибки показываем Task Planner
      await Future.delayed(const Duration(seconds: 2));
      _navigateToTaskPlanner();
    }
  }

  Future<void> _handleFirstLaunch(SharedPreferences prefs) async {
    setState(() => _statusMessage = 'Setting up...');

    // 1. Инициализируем Firebase Remote Config
    setState(() => _statusMessage = 'Loading configuration...');
    await RemoteConfigService().initialize();

    // 2. Инициализируем AppsFlyer
    setState(() => _statusMessage = 'Checking attribution...');
    final appsFlyerService = AppsFlyerService();
    await appsFlyerService.initialize(
      devKey: AppConfig.appsFlyerDevKey,
      appId: AppConfig.appsFlyerAppId,
      isDebug: AppConfig.isDebug,
    );

    // 3. Инициализируем OneSignal
    setState(() => _statusMessage = 'Setting up notifications...');
    await OneSignalService().initialize(
      appId: AppConfig.oneSignalAppId,
      isDebug: AppConfig.isDebug,
    );

    // 4. Ждем атрибуцию от AppsFlyer (с таймаутом)
    setState(() => _statusMessage = 'Verifying...');
    final isNonOrganic = await appsFlyerService.waitForAttribution();
    
    // 5. Получаем URL из Remote Config (Firebase сам определит страну по условиям)
    final remoteConfigService = RemoteConfigService();
    final webViewUrl = remoteConfigService.getWebViewUrl();
    
    // 7. Определяем, что показывать
    bool shouldShowWebView = false;
    String? finalUrl;

    if (isNonOrganic) {
      // Пользователь пришел с рекламы (AppsFlyer) - показываем WebView
      finalUrl = webViewUrl;
      shouldShowWebView = finalUrl != null && finalUrl.isNotEmpty;
      print('Non-organic user, WebView URL: $finalUrl');
    } else {
      // Органический пользователь - сначала проверяем параметр 'open'
      final isOpen = remoteConfigService.isOpen;
      
      if (isOpen) {
        // open = true: проверяем URL по стране
        if (webViewUrl != null && webViewUrl.isNotEmpty) {
          finalUrl = webViewUrl;
          shouldShowWebView = true;
          print('Organic user, open=true, WebView URL: $finalUrl');
        } else {
          // Нет URL для страны - показываем Task Planner
          shouldShowWebView = false;
          print('Organic user, open=true but no URL, showing Task Planner');
        }
      } else {
        // open = false: показываем Task Planner
        shouldShowWebView = false;
        print('Organic user, open=false, showing Task Planner');
      }
    }

    // 8. Сохраняем решение для следующих запусков
    await prefs.setBool('is_first_launch', false);
    await prefs.setBool('should_show_webview', shouldShowWebView);
    if (finalUrl != null) {
      await prefs.setString('cached_webview_url', finalUrl);
    }

    // 9. Навигация
    setState(() => _statusMessage = 'Ready!');
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (shouldShowWebView && finalUrl != null) {
      _navigateToWebView(finalUrl);
    } else {
      _navigateToTaskPlanner();
    }
  }

  Future<void> _handleReturningUser(SharedPreferences prefs) async {
    setState(() => _statusMessage = 'Loading...');

    // Используем сохраненное решение
    final shouldShowWebView = prefs.getBool('should_show_webview') ?? false;
    final cachedUrl = prefs.getString('cached_webview_url');

    // Инициализируем сервисы в фоне
    _initializeServicesInBackground();

    await Future.delayed(const Duration(milliseconds: 800));

    if (shouldShowWebView && cachedUrl != null && cachedUrl.isNotEmpty) {
      _navigateToWebView(cachedUrl);
    } else {
      _navigateToTaskPlanner();
    }
  }

  Future<void> _initializeServicesInBackground() async {
    try {
      await RemoteConfigService().initialize();
      await OneSignalService().initialize(
        appId: AppConfig.oneSignalAppId,
        isDebug: AppConfig.isDebug,
      );
    } catch (e) {
      print('Background init error: $e');
    }
  }

  Future<String> _getUserCountry() async {
    try {
      // Пробуем получить страну из системы
      final locale = Platform.localeName;
      if (locale.contains('_')) {
        return locale.split('_').last.toUpperCase();
      }
      
      // Fallback на локаль
      final languageCode = Platform.localeName.substring(0, 2).toUpperCase();
      
      // Маппинг языка на страну (примерный)
      final languageToCountry = {
        'EN': 'US',
        'RU': 'RU',
        'DE': 'DE',
        'FR': 'FR',
        'ES': 'ES',
        'IT': 'IT',
        'PT': 'BR',
        'JA': 'JP',
        'KO': 'KR',
        'ZH': 'CN',
        'TR': 'TR',
        'PL': 'PL',
        'UK': 'UA',
      };
      
      return languageToCountry[languageCode] ?? 'US';
    } catch (e) {
      print('Error getting country: $e');
      return 'US';
    }
  }

  void _navigateToWebView(String url) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WebViewScreen(url: url, allowBack: false),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToTaskPlanner() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 60,
                color: Colors.white,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            
            const SizedBox(height: 32),
            
            // App name
            const Text(
              'Multi Planner',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            if (!_hasError)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 16),
            
            // Status message
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 14,
                color: _hasError ? Colors.red[300] : Colors.white54,
              ),
            ).animate().fadeIn(delay: 400.ms),
            
            // Retry button on error
            if (_hasError) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _statusMessage = 'Retrying...';
                  });
                  _initialize();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
