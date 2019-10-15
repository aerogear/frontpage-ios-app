import Foundation

/**
   Wrapper class used for network requests
 */
public class Http {
  
    public static let instance: Http = Http()

  
    let defaultHttp = HttpRequest()

    public init() {
    }

    /**
       Return shared Http instance
     */
    public func getHttp() -> HttpRequest {
        return defaultHttp
    }
}

/**
 * Header provided class used in various SDK
 */
public protocol HeaderProvider: class {
    func getHeaders(completionHandler: @escaping ([String: String]) -> Void ) -> Void
}
