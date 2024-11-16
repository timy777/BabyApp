import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prueba/routes.dart';
import 'package:prueba/screen/home_screen.dart';
import 'package:prueba/screen/splash_screen.dart';
import 'package:prueba/services/http_service.dart';

void main() {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SplashScreen();
        } else {
          return showIndexScreen(context);
        }
      },
    );
  }

  showIndexScreen(BuildContext context) {
    HttpService httpService = HttpService();
    return PopScope(
      canPop: false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'WEB TEMPLATE',
        builder: (context, child) {
          return MultiProvider(
            providers: [
              Provider<HttpService>(
                create: (ctx) => httpService,
              ),
            ],
            child: child,
          );
        },
        initialRoute: HomeScreen.routeName,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}
