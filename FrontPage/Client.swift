import Foundation
import Apollo
import AppAuth

let config = Config()
let syncUrl = config.getConfiguration("sync-app")
let syncConfig = syncUrl.config ?? ["error": JSONValue.bool(false)]
let syncWs = syncConfig["websocketUrl"]?.getString() ?? "error";

class Client{
  static let instance = Client()
  let auth = AuthViewController()
  
  private(set) lazy var client: ApolloClient = {
    let authPayloads = [
      "Authorization": "Bearer \(auth.getToken() ?? "")"
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
  
}
