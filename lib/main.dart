import 'dart:io';
import 'package:cgv_demo_flutter_firebase/pages/checkout_page.dart';
import 'package:cgv_demo_flutter_firebase/pages/product_page.dart';
import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cgv_demo_flutter_firebase/services/push_service.dart';
import 'pages/login_page.dart';
import 'pages/cart_page.dart';

/// Global navigatorKey để điều hướng / hiển thị SnackBar từ bất cứ đâu
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo PushService (FCM + CleverTap)
  await PushService().init();

  runApp(const MyApp());
}

/// MyApp Stateful để xử lý deeplink khi app khởi động từ push
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) _checkLaunchFromNotification();
  }

  /* ------------------------------------------------------------------ */
  /*      XỬ LÝ PUSH mở app từ trạng thái KILL (cold‑start deeplink)     */
  /* ------------------------------------------------------------------ */

  Future<void> _checkLaunchFromNotification() async {
    final launchInfo = await CleverTapPlugin.getAppLaunchNotification();
    if (launchInfo.didNotificationLaunchApp) {
      final payload = launchInfo.payload!;
      _handleDeepLink(payload);
    }
  }

  void _handleDeepLink(Map<String, dynamic> payload) {
    // Deeplink từ CleverTap nằm trong key "wzrk_dl"
    final deepLink = payload['wzrk_dl'] as String?;
    if (deepLink == null) return;

    debugPrint('[ColdStart wzrk_dl] $deepLink');
    _navigateByDeepLink(deepLink);
  }

  /* ------------------------------------------------------------------ */
  /*                ĐIỀU HƯỚNG DỰA TRÊN GIÁ TRỊ wzrk_dl                 */
  /* ------------------------------------------------------------------ */

  void _navigateByDeepLink(String link) async {
    final uri = Uri.parse(link);

    // Scheme nội bộ "abc://" → điều hướng trong app
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

    // Nếu là http/https → mở trình duyệt ngoài
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  /// Đẩy route chỉ khi navigatorKey đã sẵn sàng
  void _pushIfPossible(Widget page) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
    }
  }

  /* ------------------------------------------------------------------ */

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
