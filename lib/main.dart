import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:jackdigitalstore_app/admob/constant/ad_mob_constant.dart';
import 'package:jackdigitalstore_app/deeplink/deeplink_config.dart';
import 'package:jackdigitalstore_app/model/categories/category_model.dart';
import 'package:jackdigitalstore_app/model/chat/chat.dart';
import 'package:jackdigitalstore_app/provider/applocalitations_provider.dart';
import 'package:jackdigitalstore_app/provider/appnotifier_provider.dart';
import 'package:jackdigitalstore_app/provider/attribute_provider.dart';
import 'package:jackdigitalstore_app/provider/auth_provider.dart';
import 'package:jackdigitalstore_app/provider/blog_provider.dart';
import 'package:jackdigitalstore_app/provider/cart_provider.dart';
import 'package:jackdigitalstore_app/provider/categories_provider.dart';
import 'package:jackdigitalstore_app/provider/coupon_provider.dart';
import 'package:jackdigitalstore_app/provider/detail_chat_provider.dart';
import 'package:jackdigitalstore_app/provider/general_settings_provider.dart';
import 'package:jackdigitalstore_app/provider/home_provider.dart';
import 'package:jackdigitalstore_app/provider/list_notification.dart';
import 'package:jackdigitalstore_app/provider/order_provider.dart';
import 'package:jackdigitalstore_app/provider/product_provider.dart';
import 'package:jackdigitalstore_app/provider/profile_provider.dart';
import 'package:jackdigitalstore_app/provider/register_update_vendor.dart';
import 'package:jackdigitalstore_app/provider/search_provider.dart';
import 'package:jackdigitalstore_app/provider/shipping_service_provider.dart';
import 'package:jackdigitalstore_app/provider/signup_provider.dart';
import 'package:jackdigitalstore_app/provider/store_provider.dart';
import 'package:jackdigitalstore_app/provider/wallet_provider.dart';
import 'package:jackdigitalstore_app/provider/wishlist_provider.dart';
import 'package:jackdigitalstore_app/screen/pages.dart';
import 'package:jackdigitalstore_app/services/mv_notification.dart';
import 'package:jackdigitalstore_app/session/session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jackdigitalstore_app/utils/global_variable.dart';
import 'package:jackdigitalstore_app/utils/shared.dart';
import 'package:uni_links/uni_links.dart';

import 'model/account/language.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  await Firebase.initializeApp();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = "Initial Route";
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    initialRoute = "Initial Route : $selectedNotificationPayload";
    print(initialRoute);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  AdMobConstant.initAdMob();
  await Firebase.initializeApp();
  await Session.init().then((value) => Session().checkCookieSession());
  await MVNotification.init();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = "Initial Route";
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    initialRoute = "Initial Route : $selectedNotificationPayload";
    print(initialRoute);
  }
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  //session language
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  //
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AppLanguage()),
      ChangeNotifierProvider(create: (context) => Language()),
      ChangeNotifierProvider(create: (context) => CategoriesModel()),
      ChangeNotifierProvider(create: (context) => ChatMessage()),
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => SignUpProvider()),
      ChangeNotifierProvider(create: (context) => HomeProvider()),
      ChangeNotifierProvider(create: (context) => StoreProvider()),
      ChangeNotifierProvider(create: (context) => GeneralSettingsProvider()),
      ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ChangeNotifierProvider(create: (context) => SearchProvider()),
      ChangeNotifierProvider(create: (context) => CategoryProvider()),
      ChangeNotifierProvider(create: (context) => ProductProvider()),
      ChangeNotifierProvider(create: (context) => CartProvider()),
      ChangeNotifierProvider(create: (context) => OrderProvider()),
      ChangeNotifierProvider(create: (context) => ListNotificationProvider()),
      ChangeNotifierProvider(create: (context) => WishlistProvider()),
      ChangeNotifierProvider(create: (context) => DetailChatProvider()),
      ChangeNotifierProvider(create: (context) => RegisterUpdateVendor()),
      ChangeNotifierProvider(create: (context) => BlogProvider()),
      ChangeNotifierProvider(create: (context) => ShippingServiceProvider()),
      ChangeNotifierProvider(create: (context) => AttributeProvider()),
      ChangeNotifierProvider(create: (context) => AppNotifier()),
      ChangeNotifierProvider(
        create: (context) => WalletProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => CouponProvider(),
      ),
    ],
    child: Phoenix(
      child: MyApp(appLanguage: appLanguage),
    ),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  final AppLanguage? appLanguage;

  const MyApp({super.key, this.appLanguage});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  void initState() {
    super.initState();
    MVNotification.requestPermissions();
    MVNotification.configureDidReceiveLocalNotificationSubject(context);
    MVNotification.configureSelectNotificationSubject(context);
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('Uri: $uri');
        DeeplinkConfig().pathUrl(uri!, context, false);
      }, onError: (Object err) {
        if (!mounted) return;
        print('Error: $err');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    _sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ChangeNotifierProvider<AppLanguage?>(
          create: (_) => widget.appLanguage,
          child: child,
        );
      },
      child: Consumer2<AppLanguage, AppNotifier>(
        builder: (context, model, value, child) {
          return MaterialApp(
            navigatorKey: GlobalVariable.navState,
            builder: (BuildContext context, Widget? child) {
              final MediaQueryData data = MediaQuery.of(context);
              return MediaQuery(
                data: data.copyWith(textScaleFactor: 1),
                child: child!,
              );
            },
            locale: model.appLocal,
            supportedLocales: [
              Locale('en', 'US'),
              Locale('id', ''),
              Locale('vi', ''),
              Locale('es', ''),
              Locale('fr', ''),
              Locale('zh', ''),
              Locale('ja', ''),
              Locale('ko', ''),
              Locale('km', ''),
              Locale('pt', ''),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            title: 'Revo Multivendor',
            theme: value.getTheme(),
            home: Builder(builder: (context) {
              return FutureBuilder(
                future: DeeplinkConfig().initUniLinks(context),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  return snapshot.data as Widget;
                },
              );
            }),
            routes: {HomeScreen.id: (context) => HomeScreen()},
          );
        },
      ),
    );
  }
}
