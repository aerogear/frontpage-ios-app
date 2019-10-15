import Foundation
import UIKit
import AppAuth


typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

let authConfig = config.getConfiguration("keycloak").config ?? ["error": JSONValue.bool(false)]
let server = authConfig["auth-server-url"]?.getString() ?? "error";
let realms = authConfig["realm"]?.getString() ?? "error"

let kIssuer: String = server + "/realms/" + realms + "/";
let kClientID: String? = authConfig["resource"]?.getString() ?? "error";
let kRedirectURI: String = "com.myapp://restore";
let AuthStateKey: String = "authState";

class AuthViewController: UIViewController {
  
  private var authState: OIDAuthState?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadState()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if (authState?.isAuthorized ?? false){
      self.setAuthState(nil)
      self.changeView()
    } else {
      self.authWithAutoCodeExchange()
    }
  }
}

// MARK: Authentitcating with code exchange

extension AuthViewController {
  func authWithAutoCodeExchange() {
    
    guard let issuer = URL(string: kIssuer) else {
      self.logMessage("Error creating URL for : \(kIssuer)")
      return
    }
    
    self.logMessage("Fetching configuration for issuer: \(issuer)")
    
    // discovers endpoints
    OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
      
      guard let config = configuration else {
        self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
        self.setAuthState(nil)
        return
      }
      
      self.logMessage("Got configuration: \(config)")
      
      if let clientId = kClientID {
        self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: nil)
      } else {
        self.doClientRegistration(configuration: config) { configuration, response in
          
          guard let configuration = configuration, let clientID = response?.clientID else {
            self.logMessage("Error retrieving configuration OR clientID")
            return
          }
          
          self.doAuthWithAutoCodeExchange(configuration: configuration,
                                          clientID: clientID,
                                          clientSecret: response?.clientSecret)
        }
      }
    }
    
  }
}

//MARK: AppAuth Methods
extension AuthViewController {
  
  func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {
    
    guard let redirectURI = URL(string: kRedirectURI) else {
      self.logMessage("Error creating URL for : \(kRedirectURI)")
      return
    }
    
    let request: OIDRegistrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                                 redirectURIs: [redirectURI],
                                                                 responseTypes: nil,
                                                                 grantTypes: nil,
                                                                 subjectType: nil,
                                                                 tokenEndpointAuthMethod: "client_secret_post",
                                                                 additionalParameters: nil)
    
    // performs registration request
    self.logMessage("Initiating registration request")
    
    OIDAuthorizationService.perform(request) { response, error in
      
      if let regResponse = response {
        self.setAuthState(OIDAuthState(registrationResponse: regResponse))
        self.logMessage("Got registration response: \(regResponse)")
        callback(configuration, regResponse)
      } else {
        self.logMessage("Registration error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
        self.setAuthState(nil)
      }
    }
  }
  
  func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
    
    guard let redirectURI = URL(string: kRedirectURI) else {
      self.logMessage("Error creating URL for : \(kRedirectURI)")
      return
    }
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      self.logMessage("Error accessing AppDelegate")
      return
    }
    
    // builds authentication request
    let request = OIDAuthorizationRequest(configuration: configuration,
                                          clientId: clientID,
                                          clientSecret: clientSecret,
                                          scopes: [OIDScopeOpenID, OIDScopeProfile],
                                          redirectURL: redirectURI,
                                          responseType: OIDResponseTypeCode,
                                          additionalParameters: nil)
    
    // performs authentication request
    logMessage("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
    
    appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
      
      if let authState = authState {
        self.setAuthState(authState)
        self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
        self.changeView()
        
      } else {
        self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
        self.setAuthState(nil)
      }
    }
  }
  
}

//MARK: OIDAuthState Delegate
extension AuthViewController: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
  
  func didChange(_ state: OIDAuthState) {
    self.stateChanged()
  }
  
  func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
    self.logMessage("Received authorization error: \(error)")
  }
}

//MARK: Helper Methods
extension AuthViewController {
  
  func saveState() {
    
    var data: Data? = nil
    
    if let authState = self.authState {
      data = NSKeyedArchiver.archivedData(withRootObject: authState)
    }
    
    UserDefaults.standard.set(data, forKey: AuthStateKey)
    UserDefaults.standard.synchronize()
  }
  
  func loadState() {
    guard let data = UserDefaults.standard.object(forKey: AuthStateKey) as? Data else {
      return
    }
    
    if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
      self.setAuthState(authState)
    }
  }
  
  func setAuthState(_ authState: OIDAuthState?) {
    if (self.authState == authState) {
      return;
    }
    self.authState = authState;
    self.authState?.stateChangeDelegate = self;
    self.stateChanged()
  }
  
  func stateChanged() {
    self.saveState()
  }
  
  func logMessage(_ message: String) {
    print(message)
  }
  
  func changeView() {
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let newViewController = storyBoard.instantiateViewController(withIdentifier: "PostView") as! TaskListViewController
    self.present(newViewController, animated: true, completion: nil)
    
  }
  
}
