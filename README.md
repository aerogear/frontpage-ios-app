# Sample iOS Native Application

## Implementation

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
