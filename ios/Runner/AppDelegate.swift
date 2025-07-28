import Flutter
import UIKit
import UserNotifications
import CleverTapSDK
import clevertap_plugin
import CleverTapGeofence

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    CleverTap.autoIntegrate()
    CleverTapPlugin.sharedInstance()?.applicationDidLaunch(options: launchOptions)

    let locationManager = CLLocationManager()
    locationManager.requestAlwaysAuthorization()

    CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions)

    registerForPush()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func registerForPush() {
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if granted {
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
  }

  // MARK: - Push Notification Delegate Methods

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("[Push Notification] ✅ Registered for remote notifications: \(deviceToken.description)")
    CleverTap.sharedInstance()?.setPushToken(deviceToken)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("[Push Notification] ❌ Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    print("[Push Notification] 📩 Received notification response: \(response.notification.request.content.userInfo)")
    completionHandler()
  }

  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("[Push Notification] 🔔 Will present notification: \(notification.request.content.userInfo)")
    CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: notification.request.content.userInfo)
    completionHandler([.badge, .sound, .alert])
  }

  override func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("[Push Notification] 📬 Did receive remote notification with background fetch: \(userInfo)")
    completionHandler(UIBackgroundFetchResult.noData)
  }

  func pushNotificationTapped(withCustomExtras customExtras: [AnyHashable : Any]!) {
    print("[Push Notification] 🎯 Push tapped with custom extras: \(customExtras ?? [:])")
  }
}
