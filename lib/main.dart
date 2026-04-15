import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'src/app/app_theme.dart';
import 'src/app/window_args.dart';
import 'src/features/todos/presentation/todos_shell_screen.dart';
import 'src/features/widget/presentation/widget_window_screen.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final controller = await WindowController.fromCurrentEngine();
  final windowArgs = NexoWindowArgs.decode(controller.arguments);

  if (windowArgs.type == NexoWindowType.widget) {
    await _configureWidgetWindow();
    runApp(const ProviderScope(child: WidgetWindowApp()));
    return;
  }

  await _configureMainWindow();
  runApp(const NexoRoot());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TodosShellScreen(),
    ),
  ],
);

class NexoRoot extends StatelessWidget {
  const NexoRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: NexoApp());
  }
}

class NexoApp extends StatelessWidget {
  const NexoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.build();
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}

Future<void> _configureMainWindow() async {
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      title: 'Nexo',
      center: true,
      minimumSize: Size(920, 640),
      titleBarStyle: TitleBarStyle.normal,
    ),
  );
  await windowManager.setOpacity(1.0);
  await windowManager.show();
  await windowManager.focus();
}

Future<void> _configureWidgetWindow() async {
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      title: 'Nexo',
      center: true,
      size: Size(420, 560),
      minimumSize: Size(320, 420),
      titleBarStyle: TitleBarStyle.hidden,
      alwaysOnTop: true,
      skipTaskbar: true,
    ),
  );
  await windowManager.setOpacity(1.0);
  await windowManager.setResizable(false);
  await windowManager.setMinimizable(false);
  await windowManager.setMaximizable(false);
  await windowManager.show();
  await windowManager.focus();
}
