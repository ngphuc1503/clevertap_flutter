import 'dart:io';
import 'package:cgv_demo_flutter_firebase/pages/checkout_page.dart';
import 'package:cgv_demo_flutter_firebase/pages/product_page.dart';
import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cgv_demo_flutter_firebase/services/push_service.dart';
import 'pages/login_page.dart';
import 'pages/cart_page.dart';

@pragma('vm:entry-point')
void _onKilledStateNotificationClickedHandler(Map<String, dynamic> payload) async {
  debugPrint('[KilledState] Payload: $payload');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Đăng ký handler khi app bị kill
  CleverTapPlugin.onKilledStateNotificationClicked(_onKilledStateNotificationClickedHandler);

  await PushService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('deeplink_channel');

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _checkLaunchFromNotification();
      platform.setMethodCallHandler(_handleRuntimeDeeplink); // ✅ sửa lỗi truyền method handler
    }
  }

  /* -------------------- Cold-start push -------------------- */
  Future<void> _checkLaunchFromNotification() async {
    final launchInfo = await CleverTapPlugin.getAppLaunchNotification();
    if (launchInfo.didNotificationLaunchApp) {
      final payload = launchInfo.payload!;
      _handleDeepLink(payload);
    }
  }

  void _handleDeepLink(Map<String, dynamic> payload) {
    final deepLink = payload['wzrk_dl'] as String?;
    _handleDeepLinkString(deepLink);
  }

  /* -------------------- Runtime push via MethodChannel -------------------- */
  Future<void> _handleRuntimeDeeplink(MethodCall call) async {
    if (call.method == 'onDeeplinkReceived') {
      final String? deepLink = call.arguments;
      _handleDeepLinkString(deepLink);
    }
  }

  void _handleDeepLinkString(String? wzrkDl) {
    if (wzrkDl == null) return;

    debugPrint('[wzrk_dl] $wzrkDl');
    _navigateByDeepLink(wzrkDl);
  }

  /* -------------------- DeepLink Navigator -------------------- */
  void _navigateByDeepLink(String link) async {
    final uri = Uri.parse(link);

    if (uri.scheme == 'abc') {
      switch (uri.path) {
        case '/cart':
          _pushIfPossible(const Cartpage());
          break;
        case '/login':
          _pushIfPossible(const Loginpage());
          break;
        case '/product':
          _pushIfPossible(Productpage());
          break;
        case '/checkout':
          _pushIfPossible(const Checkoutpage());
          break;
        default:
          debugPrint('[DeepLink] Không tìm thấy path: ${uri.path}');
      }
      return;
    }

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _pushIfPossible(Widget page) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
    }
  }

  /* -------------------- UI -------------------- */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CGV Demo App',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const Loginpage(),
    );
  }
}
