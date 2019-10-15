import UIKit
import AppAuth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var currentAuthorizationFlow: OIDExternalUserAgentSession?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {    
    // bootstrap the registration process by asking the user to 'Accept' and then register with APNS thereafter
    let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
    UIApplication.shared.registerUserNotificationSettings(settings)
    UIApplication.shared.registerForRemoteNotifications()
    
    // Send metrics when app is launched due to push notification
//    PushAnalytics.sendMetricsWhenAppLaunched(launchOptions: launchOptions)
    
    // Display all push messages (even the message used to open the app)
    if let options = launchOptions {
      if let option = options[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
            let defaults: UserDefaults = UserDefaults.standard;
            // Send a message received signal to display the notification in the table.
            if let aps = option["aps"] as? [String: Any] {
                if let alert = aps["alert"] as? String {
                    defaults.set(alert, forKey: "message_received")
                    defaults.synchronize()
                } else {
                    if let alert = aps["alert"] as? [String: Any] {
                        let msg = alert["body"]
                        defaults.set(msg, forKey: "message_received")
                        defaults.synchronize()
                    }
                }
            }
        }
    }
  
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeExternalUserAgentFlow(with: url) {
      self.currentAuthorizationFlow = nil
      return true
    }
    
    return false
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      // time to register user with the "AeroGear UnifiedPush Server"
      // perform registration of this device
    print("This does get called")
    do {
      pushConfig.alias = "sample-alias"
      pushConfig.categories = ["demo", "sample"]
      let device = Push.instance

    try device.register(Data(contentsOf: URL(fileURLWithPath: "https://unifiedpush-unifiedpush-proxy-mobile-unifiedpush.apps.ire-586a.open.redhat.com")),
                    pushConfig,
                    success: {
                        // successfully registered!
                        print("successfully registered with UPS!")
          
                        // send Notification for success_registered, will be handle by registered ViewController
                        let notification = Notification(name: Notification.Name(rawValue: "success_registered"), object: nil)
                        NotificationCenter.default.post(notification as Notification)
                    },
                    failure: {(error: Error!) in
                                  print("Error Registering with UPS: \(error.localizedDescription)")
                    
                                  let notification = Notification(name: Notification.Name(rawValue: "error_register"), object: nil)
                                  NotificationCenter.default.post(notification as Notification)
                          })
    } catch {
        print("There was some kind of error")
    }
  }
  
}
