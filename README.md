# Sample Android Native Application

  

## Introduction

  

This is a sample iOS Swift application showing use of DataSync, [Keycloak](https://www.keycloak.org/about.html) and Unified Push using native upstream SDK's. Application is sending requests to [Ionic showcase server]([https://github.com/aerogear/ionic-showcase/tree/master/server](https://github.com/aerogear/ionic-showcase/tree/master/server)) which is a GraphQL server.

  

- For DataSync, application uses [Apollo Client](https://www.apollographql.com/docs/ios/) to query, mutate and subscribe.

- For authorization we are using [AppAuth](https://github.com/openid/AppAuth-iOS) to connect with Keycloak.

- For Unifiedpush support we are using [Aerogear SDK](https://github.com/aerogear/aerogear-ios-sdk/tree/master/modules/push).

  

## Implementation

### 1. DataSync

#### Generating queries, mutations and subscriptions

To generate queries, mutations and subscriptions of running GraphQL server [Apollo Codegen]([https://github.com/apollographql/apollo-tooling](https://github.com/apollographql/apollo-tooling)) was used.

  

#### Creating client

- During initialization of Apollo Client we have to set authorization payloads, which are going to be our `Authorization` credentials, a `Bearer: TOKEN VALUE` and token is received through AppAuth implementation. Then we have to set our `URLSessionConfiguration` and add authorization payloads specified above. We are also providing a `serverUrl` and `webSocketUrl` which in our example, are pulled from `mobile-services.json` file.

  

```swift

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

session: URLSession(configuration: configuration)

),

webSocketNetworkTransport: websocket

)
return ApolloClient(networkTransport: splitNetworkTransport)
}()
}

```

#### Using queries, mutation and subscriptions

Once client is build we can use it to run queries, mutations and subscriptions.

  

#### Query
On application launch, a query is executed and it loads data from the server to our `TaskListViewController` using `GraphQLWatcher<AllTasksQuery>`. A `GraphQLQueryWatcher` is responsible for watching the store, and calling the result handler with a new result whenever any of the data the previous result depends on changes. We are instructing our Apollo Client to watch for the provided query and that allows us to fetch that query whenever there's been a mutation or subscription triggered.

  

```swift

var watcher: GraphQLQueryWatcher<AllTasksQuery>?

func loadData() {

watcher = Client.instance.apolloClient.watch(query: AllTasksQuery()) { result in

switch result {

case .success(let graphQLResult):

self.tasks = graphQLResult.data?.allTasks as? [AllTasksQuery.Data.AllTask]

case .failure(let error):

NSLog("Error while fetching query: \(error.localizedDescription)")
}}}

```

  

#### Mutation

Once `delete` button is pressed we are instructing Apollo Client to perform a `DeleteTaskMutation` which takes in an `ID` of a task and deletes it from the server.

```swift

@IBAction  func  delete() {

guard  let taskId = taskId else { return }

Client.instance.apolloClient.perform(mutation: DeleteTaskMutation(id: taskId)) { result in

switch result {

case .success:

break

case .failure(let error):

NSLog("Error while attempting to upvote post: \(error.localizedDescription)")
}}}
```
In `addTask` mutation we need to read the data from text fields and pass it in to our `CreateTaskMutation` to add a task to our backend.
```swift 
Client.instance.apolloClient.perform(mutation: CreateTaskMutation(title: titleField.text  ??  "test1", description: descriptionField.text  ??  "description of test1", status: taskStatus )) { result in

switch result {

case .success:

break

case .failure(let error):

NSLog("Error while attempting to upvote post: \(error.localizedDescription)")
}}
```

  

#### Subscriptions

`deleteSubscription` is triggered whenever an item has been deleted from the server while `addSubscription` when an item is added to the list. Once triggered, we are instructing our `watcher` specified in queries to refetch all data, which refreshes the task list.

```swift

func  deleteSubscription(){

Client.instance.apolloClient.subscribe(subscription: DeleteSubscription()) { result in

self.watcher?.refetch()

}}

func  addSubscription(){

Client.instance.apolloClient.subscribe(subscription: AddSubscription()) { result in

self.watcher?.refetch()

}}
```

### 2. Keycloak implementation

To implement Keycloak with our app we have used [AppAuth](https://www.keycloak.org/about.html). You will need a keycloak instance running either on OpenShift or you can set it up locally on Ionic Showcase server that has been used in our example app.

  

You will have to provide the following:

-  `kIssuer` - which is the OIDC issuer from which the configuration will be discovered.
-  `kClientID` - ID of the client.
-  `kRedirectURI` - which is the OAuth redirect URI for the client, `redirectURI` will redirect the client back to the app after authorization.
-  `AuthStateKey` - NSCoding key for the authState property.

Data in our example comes from `mobile-services.json` file.
```swift

private  var kIssuer: String = Config.sharedInstance.getKIssuer()

private  var kClientID: String? = Config.sharedInstance.getKClientId()

private  var kRedirectURI: String = "com.myapp://restore"

private  var AuthStateKey: String = "authState"

```

Our next step is to perform authorization with code exchange, first, we need to check if the `kIssuer` has been provided, then we need to fetch configuration for the `kIssuer` provided, which in our case, is Keycloak.

  

```swift

func  authWithAutoCodeExchange() {

guard  let issuer = URL(string: kIssuer) else {

self.logMessage("Error creating URL for : \(kIssuer)")

return

}

self.logMessage("Fetching configuration for issuer: \(issuer)")

  

OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

guard  let config = configuration else {

self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")

self.setAuthState(nil)

return

}

self.logMessage("Got configuration: \(config)")

if  let clientId = self.kClientID {

self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: nil)
}}}

```

Once we have received configuration and we do have client ID, we can perform next step of authorization with code exchange which needs a configuration, `clientSecret` and `scopes` are optional. First we need to build our request passing in the configuration received, `clientID`, optional `clientSecret` and `scopes`, `redirectUri` and `responseType`. After having our request constructed we can trigger authorization flow and receive the token from the issuer. Once we have the token, we can pass it in to our client builder and from now onwards, any query, mutation or subscription will use the token to communicate with the server.

  

```swift

func  doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {

  

let request = OIDAuthorizationRequest(configuration: configuration,

clientId: clientID,

clientSecret: clientSecret,

scopes: [OIDScopeOpenID, OIDScopeProfile],

redirectURL: redirectURI,

responseType: OIDResponseTypeCode,

additionalParameters: nil)

  

logMessage("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")

appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in

if  let authState = authState {

self.setAuthState(authState)

Client.token = authState.lastTokenResponse?.accessToken

self.changeView()

} else {

self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")

self.setAuthState(nil)

}}}

```

### 3. Unifiedpush implementation
#### External Setup
With in the [Aerogear Unifiefpush Server](https://github.com/aerogear/aerogear-unifiedpush-server) create your application. 
For creating the application you will need the following information.

- Apple Developer account 
- APNs client TLS certificate

Once the application variant has been set up the follow information will be required in the mobile-services.json file.

- Server URL
- Variant ID
- Variant Secret

The mobile-services.json file is located under the `FrontPage`.
See the sample configure data below.

```json
{
  "config": {
    "ios": {
      "variantID": "variantID (e.g. 1234456-234320)",
      "variantSecret": "variantSecret (e.g. 1234456-234320)"
    }
  },
  "name": "push",
  "type": "push",
  "url": "https://push.example.com"
}
```

#### Project Setup

To create http request this project uses [Alamofire](https://github.com/Alamofire/Alamofire).

```bash
pod install allamofire
```
In `AppDelegate.swift` set up the push configure.

- `func applicationi(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)`  

Set the configure for the alias and categories.

```swift
var pushConfig = UnifiedPusConfig()
pushConfig.alias = "simple-app"
pushConfig.categories = ["testing",  "sample"]
```

Next create an instance of the Push class.

```swift
do {
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
                      }
                      )
} catch {
  print("Error while trying to register device:\n>>>>\n \(error)\n<<<<")
}
```

- `func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)`

In this application function we register for remote notifications.
This asks the user for permission to allow push notifications.

```swift
func registerForRemoteNotifications() {
  // bootstrap the registration process by asking the user to 'Accept' and then register with APNS thereafter
  let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
  UIApplication.shared.registerUserNotificationSettings(settings)
  UIApplication.shared.registerForRemoteNotifications()
}
```

The `Push.instance` does most of the work when with setting up the push configure from the mobile-services.json and creating the http client.
Once the device is registered, it can start receiving push messages. 
These messages can be access when the app is running or when the app is opened by the user clicking on the push notification in the device notification area.
This happens in side `func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void)`

```swift
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
```

This formats the received data into a format that can be used in the `showToast()` method. 
The `showToast()` is an example of what can be do if there is a message received.

```swift
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
```

### 4. Mobile-services parser  

For this example the `mobile-services.json` is saved in `FrontPage`. 
There are three types of services in the services list. 
Each of these have the configuration for the different type services.
The different types of services are:

- **sync-app** 
- **keycloak**
- **push** 

##### sync-app
Sync-app holds the configuration for connecting to a graphQL server.
The JSON object in the services list at minimum needs the fields in the example below.

Working with subscriptions on an Apollo server requires a web socket URL which is placed in the `config` object.

```json
  {
    "config": {
      "websocketUrl": "wss://server.example.com/graphql"
    },
    "name": "sync-app",
    "type": "sync-app",
    "url": "https://server.example.com/graphql"
  }
```

##### Keycloak

The JSON object example below holds the configuration for a keycloak server which would be in the services array.
When the `mobile-service.json` file is parsed this configuration build is converted to a java `Keycloak.class` object.


```json
    {
      "config": {
        "auth-server-url": "https://sso.example.com/auth",
        "confidential-port": 0,
        "public-client": true,
        "realm": "example-app-realm",
        "resource": "example-app-client",
        "ssl-required": "external"
      },
      "name": "keycloak",
      "type": "keycloak",
      "url": "https://sso.example.com/auth"
    }
```

##### Push
The push configuration follow the format that is below. 

```json
    {
      "config": {
        "ios": {
          "variantID": "variantID (e.g. 1234456-234320)",
          "variantSecret": "variantSecret (e.g. 1234456-234320)"
        }
      },
      "name": "push",
      "type": "push",
      "url": "https://push.example.com"
    }
```

##### Working with the mobile-services file.

To read in the mobile-services.json file, an instance of the `Config` class.

```swift
let config = Config.shareInstance
```

This creates an object of the mobile-services.json file that now can be access with the following methods.

- `getKIssuer()` -> returns the realms connection URL as a string.
- `getKClientId()` -> returns the client Id as a String.
- `getSyncUrl()` -> returns the URL as string (HTTP protocol).
- `getWsUrl()` -> returns the websocket URL as string (websocket protocol).
- `getPush()` -> returns a full object containing the push configuration.

The values for the methods can then be used to configure the different services.

The brake down of the mobile-services object can be found in `ForntPage/config/MobileConfig.swift`

