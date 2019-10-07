import Foundation

public class Config{
  let config: ServiceConfig
  
  
  public init() {
    config = ServiceConfig()
  }
  
  public func getConfiguration(_ serviceType: String) -> MobileService {
    let configuration = config.getConfigurationByType(serviceType)
    if configuration.count > 1 {
      print("Config contains more than one service of same type")
    }
    return configuration[0]
  }
}
