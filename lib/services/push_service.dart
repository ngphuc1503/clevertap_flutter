// PushService.dart – phiên bản đã thêm onMessage & onMessageOpenedApp để xử lý click
import 'dart:convert';
import 'dart:io';

import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../pages/cart_page.dart';
import '../pages/login_page.dart';

class PushService {
  PushService._internal();
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;

  final CleverTapPlugin _ct = CleverTapPlugin();

  Future<void> init() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.requestPermission();

    _configureCleverTapChannel();

    // 1️⃣ Foreground: khi FCM đến → để CT tự render và gắn PendingIntent
    FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      debugPrint('[FCM onMessage] ${m.data}');
      // Dữ liệu push luôn nằm trong m.data (đối với CleverTap)
      CleverTapPlugin.createNotification(jsonEncode(m.data));
    });

    // 2️⃣ Background ➜ tap ➜ app mở
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      debugPrint('[FCM onMessageOpenedApp] ${m.data}');
      _handleNotificationClick(m.data);
    });

    // 3️⃣ Foreground / background khi Flutter engine đã sẵn sàng
    _ct.setCleverTapPushClickedPayloadReceivedHandler(pushClickedPayloadReceived);

    // 4️⃣ Headless background isolate
    FirebaseMessaging.onBackgroundMessage(_onBackground);
  }

  /* ---------------- HANDLER PUSH CLICK (từ CT callback) ------------- */
  void pushClickedPayloadReceived(Map<String, dynamic> payload) {
    debugPrint('[CT Push Clicked] $payload');
    _handleNotificationClick(payload);
  }

  /* -------------------- COMMON CLICK HANDLER ------------------------ */
  void _handleNotificationClick(Map<String, dynamic> payload) {
    final link = payload['wzrk_dl'] as String?;
    if (link == null) return;
    debugPrint('[Navigate] wzrk_dl = $link');
    _navigateByDeepLink(link);
  }

  /* --------------------- NAVIGATION LOGIC --------------------------- */
  void _navigateByDeepLink(String link) async {
    final uri = Uri.parse(link);

    if (uri.scheme == 'abc') {
      switch (uri.path) {
        case '/cart':
          _pushIfPossible(const Cartpage());
          return;
        case '/login':
          _pushIfPossible(const Loginpage());
          return;
        default:
          debugPrint('[DeepLink] Unhandled path: ${uri.path}');
          return;
      }
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
    } else {
      debugPrint('[Navigator] Context not ready, cannot push');
    }
  }

  /* ------------- BACKGROUND ISOLATE HANDLER ------------------------- */
  static Future<void> _onBackground(RemoteMessage msg) async {
    debugPrint('[FCM BG isolate] ${msg.data}');
    // Khi app hoàn toàn headless, chỉ log; deeplink sẽ được xử lý khi app mở lại.
  }

  /* ----------------- NOTIFICATION CHANNEL --------------------------- */
  void _configureCleverTapChannel() {
    if (Platform.isAndroid) {
      CleverTapPlugin.createNotificationChannel(
        'fluttertest', 'Flutter Test', 'Flutter Test', 3, true,
      );
    }
    CleverTapPlugin.setDebugLevel(4); // verbose log
  }
}
