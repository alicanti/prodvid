import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Initialize RevenueCat
  // await _initRevenueCat();

  runApp(const ProviderScope(child: ProdVidApp()));
}

// Future<void> _initRevenueCat() async {
//   await Purchases.setLogLevel(LogLevel.debug);
//
//   PurchasesConfiguration configuration;
//   if (Platform.isIOS) {
//     configuration = PurchasesConfiguration(
//       const String.fromEnvironment('REVENUECAT_API_KEY_IOS'),
//     );
//   } else {
//     configuration = PurchasesConfiguration(
//       const String.fromEnvironment('REVENUECAT_API_KEY_ANDROID'),
//     );
//   }
//
//   await Purchases.configure(configuration);
// }

class ProdVidApp extends ConsumerWidget {
  const ProdVidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ProdVid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
