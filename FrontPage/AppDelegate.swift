import UIKit
import Apollo
import AppAuth

let config = Config()
let syncUrl = config.getConfiguration("sync-app")
let syncConfig = syncUrl.config ?? ["error": JSONValue.bool(false)]
let syncWs = syncConfig["websocketUrl"]?.getString() ?? "error";

var apollo: ApolloClient = {
  let authPayloads = [
    "Authorization": "Bearer "
  ]
  let configuration = URLSessionConfiguration.default
  configuration.httpAdditionalHeaders = authPayloads
  
  let map: GraphQLMap = authPayloads
  let wsEndpointURL = URL(string: syncWs)!
  let endpointURL = URL(string: syncUrl.url)!
  let websocket = WebSocketTransport(request: URLRequest(url: wsEndpointURL), connectingPayload: map)
  
  let splitNetworkTransport = SplitNetworkTransport(
    httpNetworkTransport: HTTPNetworkTransport(
      url: endpointURL,
      configuration: configuration
    ),
    webSocketNetworkTransport: websocket
  )
  return ApolloClient(networkTransport: splitNetworkTransport)
}()



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
