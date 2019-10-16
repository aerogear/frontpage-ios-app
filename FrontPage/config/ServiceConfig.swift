import Foundation

/**
 AeroGear Mobile Services Configuration
 Entrypoint for parsing and processing configuration for individual services.
 This class is responsible for providing configurations for services of certain types.
 Configuration is stored in single json file
 that contains multiple individual service configurations and metadata.
 Service developers can query configuration for certain types.
 See top level core interface for more information
 - Example usage:
 `config['myServiceType']`
 */
public class ServiceConfig {
  let configFileName: String
  var config: MobileConfig?
  
  public init(_ configFileName: String = "mobile-services") {
    self.configFileName = configFileName
    readConfiguration()
  }
  
  /**
   Fetch configuration for specific type
   - Parameter type: type of the service to fetch
   - return: MobileService array
   */
  public func getConfigurationByType(_ type: String) -> [MobileService] {
    if let config = config {
      let lowerCaseType = type.lowercased()
      return config.services.filter { $0.type.lowercased() == lowerCaseType }
    } else {
      return []
    }
  }
  
  /**
   Fetch configuration for specific id
   Should be used for elements that can appear multiple times in the config
   - Parameter id: unique id of the service
   - return: MobileService
   */
  private func getConfigurationById(_ id: String) -> MobileService? {
    if let config = config {
      return config.services.first { $0.id == id }
    }
    return nil
  }
  
  private func getConfiguration(_ serviceType: String) -> MobileService {
    let configuration = self.getConfigurationByType(serviceType)
    if configuration.count > 1 {
      print("Config contains more than one service of same type")
    }
    return configuration[0]
  }
  
  private func readConfiguration() {
    let jsonData = ConfigParser.readLocalJsonData(configFileName)
    guard let data = jsonData else {
      return
    }
    let decoder = JSONDecoder()
    do {
      config = try decoder.decode(MobileConfig.self, from: data)
    } catch {
      print("Error when decoding configuration file. Cannot decode \(configFileName). Error = \(error.localizedDescription)")
    }
  }
  
  public func getKIssuer() -> String!{
    let authConfig = self.getConfiguration("keycloak").config ?? ["error": JSONValue.bool(false)]
    let server = authConfig["auth-server-url"]?.getString() ?? "error"
    let realms = authConfig["realm"]?.getString() ?? "error"
    let kIssuer = server + "/realms/" + realms + "/"
    
    return kIssuer
  }
  
  public func getKClientId() -> String!{
    let authConfig = Config.sharedInstance.getConfiguration("keycloak").config ?? ["error": JSONValue.bool(false)]
    let kClientId = authConfig["resource"]?.getString() ?? "error"
    
    return kClientId
  }
  
  public func getSyncUrl() -> String!{
    let syncUrl = Config.sharedInstance.getConfiguration("sync-app")
    
    return syncUrl.url
  }
  
  public func getWsUrl() -> String!{
    let syncUrl = Config.sharedInstance.getConfiguration("sync-app")
    let syncConfig = syncUrl.config ?? ["error": JSONValue.bool(false)]
    let wsUrl = syncConfig["websocketUrl"]?.getString() ?? "error";
    
    return wsUrl
  }
}
