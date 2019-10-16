import Foundation
import Apollo
import AppAuth

class Client{
  static let instance = Client()
  static var token: String!
  
  private(set) lazy var apolloClient: ApolloClient = {
    let authPayloads = [
      "Authorization": "Bearer \(Client.token ?? "")"
    ]
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = authPayloads
    
    let map: GraphQLMap = authPayloads
    let wsEndpointURL = URL(string: Config.sharedInstance.getWsUrl())!
    let endpointURL = URL(string: Config.sharedInstance.getSyncUrl())!
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
