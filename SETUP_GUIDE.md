# Руководство по настройке

## Обзор архитектуры

```
┌─────────────────────────────────────────────────────────────┐
│                      SPLASH SCREEN                          │
├─────────────────────────────────────────────────────────────┤
│  1. Первый запуск?                                          │
│     ├─ ДА → Инициализация всех SDK                         │
│     └─ НЕТ → Используем сохраненное решение                │
│                                                             │
│  2. AppsFlyer → Получаем атрибуцию                         │
│     ├─ Non-organic (с рекламы) → WebView с URL по стране   │
│     └─ Organic (органика) → Проверяем Remote Config        │
│                                                             │
│  3. Firebase Remote Config → Получаем URL по стране        │
│     ├─ Есть URL → WebView                                  │
│     └─ Нет URL → Task Planner                              │
└─────────────────────────────────────────────────────────────┘
```

## 1. Firebase Setup

### Шаг 1: Создание проекта
1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Создайте новый проект
3. Добавьте приложения Android и iOS

### Шаг 2: Android
1. Package name: `com.example.taskplanner` (измените на свой)
2. Скачайте `google-services.json`
3. Положите в `android/app/google-services.json`

### Шаг 3: iOS
1. Bundle ID: `com.example.taskplanner` (измените на свой)
2. Скачайте `GoogleService-Info.plist`
3. Добавьте в `ios/Runner/` через Xcode

### Шаг 4: Remote Config
В Firebase Console → Remote Config создайте параметры:

| Ключ | Тип | Значение | Описание |
|------|-----|----------|----------|
| `url_US` | String | `https://us.example.com/offer` | URL для США |
| `url_RU` | String | `https://ru.example.com/offer` | URL для России |
| `url_DE` | String | `https://de.example.com/offer` | URL для Германии |
| `url_GB` | String | `https://uk.example.com/offer` | URL для Великобритании |
| `default_url` | String | `https://example.com/offer` | Дефолтный URL |
| `enabled_countries` | String | `US,RU,DE,GB,FR,IT,ES` | Список стран |
| `show_webview` | Boolean | `true` | Глобальный флаг |

**Условия по странам:**
- Можно создать условия (Conditions) в Remote Config для каждой страны
- Или использовать один параметр с JSON для всех стран

## 2. AppsFlyer Setup

### Шаг 1: Регистрация
1. Зарегистрируйтесь на [AppsFlyer](https://www.appsflyer.com/)
2. Создайте приложение в дашборде

### Шаг 2: Получение ключей
1. Перейдите в Settings → App Settings
2. Скопируйте **Dev Key**
3. Для iOS: используйте Apple App ID (только цифры, например `123456789`)
4. Для Android: используйте package name (`com.example.taskplanner`)

### Шаг 3: Настройка в коде
Откройте `lib/config/app_config.dart`:

```dart
static const String appsFlyerDevKey = 'ВАШ_DEV_KEY';
static const String appsFlyerAppId = 'ВАШ_APP_ID';
```

### Атрибуция
AppsFlyer возвращает:
- `af_status: "Non-organic"` — пользователь пришел с реклаp2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-zsc1idjgy-sessTime-15:uxulc17jj2v
p2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-db8lpdzwd-sessTime-15:uxulc17jj2v
p2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-4t90q9xuy-sessTime-15:uxulc17jj2v
p2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-6j0p7338x-sessTime-15:uxulc17jj2v
p2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-0fd8fu35q-sessTime-15:uxulc17jj2v
p2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-jgrecm606-sessTime-15:uxulc17jj2v
p2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-q0z55e3hq-sessTime-15:uxulc17jj2v
p2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-d3my6b36x-sessTime-15:uxulc17jj2v
p2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-eyz3q5thy-sessTime-15:uxulc17jj2v
p2.mangoproxy.com:2333:uz0bhsy8ffs-zone-cis-region-uz-st-tashkent-city-tashkent-session-keyd5se6k-sessTime-15:uxulc17jj2vмы
- `af_status: "Organic"` — органическая установка
- `media_source` — источник трафика
- `campaign` — название кампании

## 3. OneSignal Setup

### Шаг 1: Регистрация
1. Зарегистрируйтесь на [OneSignal](https://onesignal.com/)
2. Создайте приложение

### Шаг 2: Android (FCM)
1. В Firebase Console → Project Settings → Cloud Messaging
2. Скопируйте Server Key и Sender ID
3. В OneSignal → Settings → Platforms → Google Android
4. Вставьте Firebase Server Key

### Шаг 3: iOS (APNs)
1. Создайте APNs Key в Apple Developer Console
2. В OneSignal → Settings → Platforms → Apple iOS
3. Загрузите .p8 файл

### Шаг 4: Настройка в коде
```dart
static const String oneSignalAppId = 'ВАШ_ONESIGNAL_APP_ID';
```

## 4. Логика работы

### Первый запуск (is_first_launch = true)

```
1. Инициализация Firebase Remote Config
2. Инициализация AppsFlyer (ждем атрибуцию до 5 сек)
3. Инициализация OneSignal
4. Определяем страну пользователя
5. Получаем URL из Remote Config для этой страны

ЕСЛИ AppsFlyer вернул Non-organic:
  → Показываем WebView с URL по стране
  
ИНАЧЕ (Organic):
  ЕСЛИ есть URL в Remote Config для страны:
    → Показываем WebView
  ИНАЧЕ:
    → Показываем Task Planner
    
6. Сохраняем решение в SharedPreferences
```

### Повторные запуски

```
1. Читаем сохраненное решение из SharedPreferences
2. Показываем WebView или Task Planner
3. В фоне инициализируем сервисы
```

## 5. Тестирование

### Тестовые установки AppsFlyer
Для тестирования атрибуции используйте тестовые ссылки AppsFlyer:
1. В AppsFlyer Dashboard → Integrated Partners → выберите источник
2. Создайте тестовую ссылку
3. Установите приложение по этой ссылке

### Тестирование Remote Config
1. В Firebase Console → Remote Config
2. Используйте Preview для тестирования без публикации
3. Или создайте тестовые условия

### Сброс состояния
Для сброса first_launch состояния:
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

## 6. Структура файлов

```
lib/
├── config/
│   └── app_config.dart          # Ключи API
├── services/
│   ├── appsflyer_service.dart   # AppsFlyer SDK
│   ├── remote_config_service.dart # Firebase Remote Config
│   └── onesignal_service.dart   # OneSignal Push
├── screens/
│   ├── splash_screen.dart       # Логика роутинга
│   ├── webview_screen.dart      # WebView экран
│   └── home_screen.dart         # Task Planner
└── main.dart                    # Entry point
```

## 7. Команды

```bash
# Установка зависимостей
flutter pub get

# Запуск на Android
flutter run

# Запуск на iOS
cd ios && pod install && cd ..
flutter run

# Сборка APK
flutter build apk --release

# Сборка iOS
flutter build ios --release
```

## 8. Troubleshooting

### Firebase не инициализируется
- Проверьте наличие `google-services.json` (Android)
- Проверьте наличие `GoogleService-Info.plist` (iOS)
- Для iOS: откройте `ios/Runner.xcworkspace` в Xcode и добавьте файл вручную

### AppsFlyer не возвращает атрибуцию
- Проверьте Dev Key
- Убедитесь что приложение установлено по рекламной ссылке
- Проверьте логи: `print('AppsFlyer Conversion Data: $data')`

### Push уведомления не работают
- Android: проверьте FCM Server Key в OneSignal
- iOS: проверьте APNs сертификаты
- Проверьте разрешения в настройках устройства
