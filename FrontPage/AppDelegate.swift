import UIKit
import Apollo
import AppAuth

let config = Config()
let syncUrl = config.getConfiguration("sync-app")


// Change localhost to your machine's local IP address when running from a device
let apollo = ApolloClient(url: URL(string: syncUrl.url)!)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var currentAuthorizationFlow: OIDExternalUserAgentSession?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    apollo.cacheKeyForObject = { $0["id"] }
    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeExternalUserAgentFlow(with: url) {
          self.currentAuthorizationFlow = nil
          return true
      }

      return false
  }
  
}
