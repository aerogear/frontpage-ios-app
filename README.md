# Sample iOS Native Application

## Introduction

This is a sample iOS Swift application showing use of DataSync, [Keycloak](https://www.keycloak.org/about.html) and Unified Push using native upstream SDK's. Backend is covered by GraphQL server - [Ionic showcase server](https://github.com/aerogear/ionic-showcase/tree/master/server).

- For DataSync - [Apollo Client](https://www.apollographql.com/docs/ios/) to query, mutate and subscribe.

- For authorization - [AppAuth](https://github.com/openid/AppAuth-iOS) to connect with Keycloak.

- For Unifiedpush - [Aerogear SDK](https://github.com/aerogear/aerogear-ios-sdk/tree/master/modules/push).

## DataSync

### Dependencies Required

Add to your `Podfile`:

```
pod 'Apollo'
pod 'Apollo/WebSocket'
``` 

### Generating queries, mutations and subscriptions

[Apollo Codegen](https://github.com/apollographql/apollo-tooling) is used to generate queries, mutations and subscriptions based off the server side schema.

### 1. Creating client

This part covers setting up the Apollo Client. To find out more information about setting up an Apollo Client visit [Apollo documentation](https://www.apollographql.com/docs/ios/).

- `URLSessionConfiguration` and `authorization payloads` must be specified as well as a `serverUrl` and `webSocketUrl` which in this example, are pulled from `mobile-services.json` file.
- Authorization payloads are `Authorization` credentials, a `"Bearer: "` string with a token value received during the authorization process.

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

### 2. Using queries, mutation and subscriptions

Client is used to run queries, mutations and subscriptions. For more information regarding GraphQL queries, mutations and subscriptions follow [Apollo documentation for iOS](https://www.apollographql.com/docs/ios/).

#### Query
On app launch a query is executed and loads data from the server to our `TaskListViewController` using `GraphQLWatcher<AllTasksQuery>`. A `GraphQLQueryWatcher` is responsible for watching the store, and calling the result handler with a new result whenever any of the data the previous result depends on changes.

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

Once `delete` button is pressed Apollo Client performs a `DeleteTaskMutation` which takes in an `ID` of a task and deletes it from the server.

```swift

@IBAction  func  delete() {

guard  let taskId = taskId else { return }

Client.instance.apolloClient.perform(mutation: DeleteTaskMutation(id: taskId)) { result in

switch result {

case .success:

break

case .failure(let error):
```
In `addTask` mutation we need to read the data from text fields and pass it in to our `CreateTaskMutation` to add a task to our backend.
```swift 
Client.instance.apolloClient.perform(mutation: CreateTaskMutation(title: titleField.text  ??  "test1", description: descriptionField.text  ??  "description of test1", status: taskStatus )) { result in

switch result {

case .success:

break

case .failure(let error):

}}
```
#### Subscriptions

`deleteSubscription` is triggered whenever an item has been deleted from the server, while `addSubscription` when an item is added to the server. Once triggered, we are instructing our `watcher` specified in queries, to refetch all data, which refreshes the task list.

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

## Keycloak implementation

[AppAuth](https://www.keycloak.org/about.html) was used to connect with Keycloak. A keycloak instance running either on OpenShift or locally is required. To run locally, follow instructions on [Ionic showcase server](https://github.com/aerogear/ionic-showcase/tree/master/server).

In order to be able to connect to Keycloak, following values must be provided. In this example, all below data comes from `mobile-services.json` file.

-  `kIssuer` - which is the OIDC issuer from which the configuration will be discovered.
-  `kClientID` - ID of the client.
-  `kRedirectURI` - which is the OAuth redirect URI for the client, `redirectURI` will redirect the client back to the app after authorization.
-  `AuthStateKey` - NSCoding key for the authState property.

More information about above values can be found in [AppAuth docs](https://github.com/openid/AppAuth-iOS).



### Dependencies Required
Add to your `Podfile`:

```
pod 'AppAuth'
``` 
### 1. Fetching well known configuration
First step is to fetch well known configuration from provided `kIssuer`.

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
### 2. Authorization request and obtaining token

- Authorization with code exchange needs a configuration, `clientSecret` and `scopes`, which are optional. 
- First step is to build authorization request and then triggering authorization flow.
- When the user is authorized he is redirected back to app and token request is performed. 
- Once token is received it can be then used in client builder which allows for execution of any query, mutation or subscription.

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

## Unifiedpush implementation

[AeroGear UnifiedPush](https://github.com/aerogear/aerogear-unifiedpush-server) was used as a server that allows sending push notifications to different platforms. 

### Dependencies Required
Add to your `Podfile`:

```
pod 'Alamofire'
``` 

### 1. External Setup

Create your application within the [Aerogear Unifiefpush Server](https://github.com/aerogear/aerogear-unifiedpush-server).  
For creating the application you will need the following information.

- [Apple Developer account](https://developer.apple.com/) 
- [APNs client TLS certificate](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_certificate-based_connection_to_apns)

Once the application variant has been set up the following information will be required in the mobile-services.json file for this example.

- Server URL
- Variant ID
- Variant Secret

### 2. Project Setup

To create http request this project uses [Alamofire](https://github.com/Alamofire/Alamofire).

In `AppDelegate.swift` set up the push configure.

- `func applicationi(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)`  

Set the configure for the alias and categories.

```swift
var pushConfig = UnifiedPusConfig()
pushConfig.alias = "simple-app"
pushConfig.categories = ["testing",  "sample"]
```

#### Setting Ups registrar

Create an instance of the Push class.

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

#### Asking user for permission

Following asks the user for permission to allow push notifications.

```swift
func registerForRemoteNotifications() {
  // bootstrap the registration process by asking the user to 'Accept' and then register with APNS thereafter
  let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
  UIApplication.shared.registerUserNotificationSettings(settings)
  UIApplication.shared.registerForRemoteNotifications()
}
```

#### Using received notifications

The `Push.instance` does most of the work when setting up the push configuration from the mobile-services.json and creating the http client.
Once the device is registered, it can start receiving push messages. 
These messages can be access when the app is running, or when the app is opened by the user by clicking on the push notification in the device notification area.
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