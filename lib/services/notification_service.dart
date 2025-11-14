import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  NotificationService._();

  bool _notificationsEnabled = false;
  static const String _prefsKey = 'notifications_enabled';

  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_prefsKey) ?? false;
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      // Сначала optIn, если был optOut
      await OneSignal.User.pushSubscription.optIn();
      
      // Запрос разрешения на уведомления (БЕЗ id)
      await OneSignal.Notifications.requestPermission(true);
      
      // Проверяем статус подписки после запроса разрешения
      await Future.delayed(const Duration(milliseconds: 500));
      final deviceState = OneSignal.User.pushSubscription;
      final isOptedIn = deviceState.optedIn ?? false;
      
      if (isOptedIn) {
        _notificationsEnabled = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefsKey, true);
        return true;
      } else {
        // Разрешение не дано, оставляем выключенным
        _notificationsEnabled = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefsKey, false);
        return false;
      }
    } else {
      // Отключение уведомлений - сразу выключаем без запроса
      await OneSignal.User.pushSubscription.optOut();
      _notificationsEnabled = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, false);
      return false; // Возвращаем false, так как уведомления выключены
    }
  }
}

