import 'package:firebase_core/firebase_core.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/config/env_config.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/notification/notification_controller.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/global_function.dart';
import 'package:fluffypawuser/views/profile/components/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  if (!Hive.isBoxOpen(AppConstants.appSettingsBox)) {
    await Hive.openBox(AppConstants.appSettingsBox);
  }
  if (!Hive.isBoxOpen(AppConstants.userBox)) {
    await Hive.openBox(AppConstants.userBox);
  }
  if (!Hive.isBoxOpen(AppConstants.petBox)) {
    await Hive.openBox(AppConstants.petBox);
  }
  if (!Hive.isBoxOpen(AppConstants.petBehaviorBox)) {
    await Hive.openBox(AppConstants.petBehaviorBox);
  }
  await Hive.openBox(AppConstants.conversationBox);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EnvConfig.init();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const ProviderScope(child: MyApp())
      // DevicePreview(
      //   enabled: !kReleaseMode,
      //   builder: (context) => const ProviderScope(
      //     child: MyApp(),
      //   ),
      // ),
      );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  Locale resolveLocal({required String langCode}) {
    return Locale(langCode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLifecycleProvider);
    return ScreenUtilInit(
      designSize: const Size(390, 844), // XD Design Sizes
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: false,
      builder: (context, child) {
        return ValueListenableBuilder(
            valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
            builder: (context, appSettingsBox, _) {
              final selectedLocal = appSettingsBox.get(AppConstants.appLocal);
              final bool? isDark =
                  appSettingsBox.get(AppConstants.isDarkTheme) ?? false;
              if (isDark == null) {
                appSettingsBox.put(AppConstants.isDarkTheme, false);
              }

              if (selectedLocal == null) {
                appSettingsBox.put(
                  AppConstants.appLocal,
                  AppLanguage(name: '\ud83c\uddfa\ud83c\uddf8 ENG', value: 'en')
                      .toMap(),
                );
              }

              GlobalFunction.changeStatusBarTheme(isDark: isDark);
              return MaterialApp(
                  title: 'FluffyPaw',
                  navigatorKey: GlobalFunction.navigatorKey,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    FormBuilderLocalizations.delegate,
                  ],
                  locale: resolveLocal(
                      langCode: selectedLocal == null
                          ? 'en'
                          : selectedLocal['value']),
                  localeResolutionCallback: (deviceLocal, supportedLocales) {
                    for (final locale in supportedLocales) {
                      if (locale.languageCode == deviceLocal!.languageCode) {
                        return deviceLocal;
                      }
                    }
                    return supportedLocales.first;
                  },
                  supportedLocales: S.delegate.supportedLocales,
                  theme: getAppTheme(
                      context: context, isDarkTheme: isDark ?? false),
                  onGenerateRoute: generatedRoutes,
                  initialRoute: Routes.splash);
            });
      },
    );
  }
}

final appLifecycleProvider = Provider<AppLifecycleNotifier>((ref) {
  return AppLifecycleNotifier(ref);
});

class AppLifecycleNotifier extends WidgetsBindingObserver {
  final Ref ref;
  bool _initialized = false;

  AppLifecycleNotifier(this.ref) {
    print('AppLifecycleNotifier: Initializing...'); // Debug log
    WidgetsBinding.instance.addObserver(this);
    // Khởi tạo SignalR ngay khi tạo AppLifecycleNotifier
    _initSignalR(); 
  }

  Future<void> _initSignalR() async {
    if (_initialized) {
      print('AppLifecycleNotifier: Already initialized'); // Debug log
      return;
    }

    print('AppLifecycleNotifier: Getting token...'); // Debug log
    final token = await ref.read(hiveStoreService).getAuthToken();
    if (token != null) {
      print('AppLifecycleNotifier: Token found, initializing SignalR...'); // Debug log
      await ref.read(notificationControllerProvider.notifier).initializeSignalR();
      _initialized = true;
    } else {
      print('AppLifecycleNotifier: No token found'); // Debug log
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('AppLifecycleNotifier: State changed to $state'); // Debug log
    switch (state) {
      case AppLifecycleState.resumed:
        _initSignalR();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _initialized = false;
        ref.read(notificationControllerProvider.notifier).dispose();
        break;
      default:
        break;
    }
  }

  void dispose() {
    print('AppLifecycleNotifier: Disposing...'); // Debug log
    WidgetsBinding.instance.removeObserver(this);
  }
}
