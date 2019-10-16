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
    do {
      pushConfig.alias = "sample-app"
      pushConfig.categories = ["testing", "sample"]
      let device = Push.instance
      
      try device.register(deviceToken,
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
      print("Error while trying to register device:\n>>>>\n \(error)\n<<<<")
    }
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("UPS message received: \(userInfo)")
    fetchCompletionHandler(UIBackgroundFetchResult.noData)

    // when a PUSH notification is received disply message with the app
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
      
      let response = userInfo["aps"] as! NSDictionary
      let alert = response["alert"] as! NSDictionary
      let messageBody: String = alert["body"] as! String
      showToast(controller: topController, message: messageBody, seconds: 2)

    }
  }
  
}

func showToast(controller: UIViewController, message: String, seconds: Double) {
  // Display a pop up message to the user
  let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
  alert.view.backgroundColor = UIColor.black
  alert.view.alpha = 0.6
  alert.view.layer.cornerRadius = 15
  
  controller.present(alert, animated: true)
  
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds){
    alert.dismiss(animated: true)
  }
}
