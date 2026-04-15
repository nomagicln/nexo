import 'package:shared_preferences/shared_preferences.dart';

class WindowPrefs {
  // kept for backward compatibility of existing prefs; widget window uses
  // window_manager runtime state.
  static const _kAlwaysOnTop = 'window.alwaysOnTop';
  static const _kWidgetMode = 'window.widgetMode';

  static Future<bool> getAlwaysOnTop() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kAlwaysOnTop) ?? false;
  }

  static Future<void> setAlwaysOnTop(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAlwaysOnTop, v);
  }

  static Future<bool> getWidgetMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kWidgetMode) ?? false;
  }

  static Future<void> setWidgetMode(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kWidgetMode, v);
  }

  static Future<double> getOpacity() async {
    return 1.0;
  }

  static Future<void> setOpacity(double v) async {
    // no-op: app window must not be transparent
  }
}

