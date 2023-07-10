import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../global/localization.dart';

abstract class BaseAppState<T extends StatefulWidget> extends State<T> {
  //properties
  String get title;

  List<SingleChildWidget> get providers;

  ThemeData get theme;

  GlobalKey<NavigatorState> get key;

  RouteFactory get onGenerateRoute;

  //methods
  Future<bool> onInitializedAuth();

  Future<void> onReady();

  //build
  Widget buildLoading();

  Widget buildNetwork();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: providers,
      builder: (context, child) {
        return MaterialApp(
          title: title,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [
            Locale('vi', 'VN'),
            Locale('en', 'US'),
          ],
          localeListResolutionCallback: onLocaleListResolutionCallback,
          theme: theme,
          builder: appBuilder,
        );
      },
    );
  }

  Locale? onLocaleListResolutionCallback(
      List<Locale>? locales, Iterable<Locale> supportedLocales) {
    final locale = locales?.first.languageCode;
    if (locale == 'vi') {
      return const Locale('vi', 'VN');
    }
    return const Locale('en', 'US');
  }

  Widget appBuilder(BuildContext context, Widget? child) {
    Localization().initialize(context);
    return FutureBuilder<bool>(
        future: onInitializedAuth(),
        builder: (context, snapshot) {
          return snapshot.data == true
              ? _buildInitializedAuth()
              : buildLoading();
        });
  }

  Widget _buildInitializedAuth() {
    return Builder(
        builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: Stack(
              children: [
                Navigator(
                  key: key,
                  initialRoute: "launch",
                  onGenerateRoute: onGenerateRoute,
                ),
                buildNetwork(),
                buildLoading(),
              ],
            )));
  }
}
