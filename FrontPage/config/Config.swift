import Foundation

public class Config{
  
  static let sharedInstance: ServiceConfig = {
      let instance = ServiceConfig()
    
      return instance
  }()
}
