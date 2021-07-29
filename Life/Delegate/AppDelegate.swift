//
//  AppDelegate.swift
//  Life
//
//  Created by Yun Li on 2020/6/24.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseAuth
import RealmSwift
import FittedSheets

var realm = try! Realm()
let falsepredicate = NSPredicate(value: false)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        let configuration = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // if you added a new property or removed a property you don't
                    // have to do anything because Realm automatically detects that
                }
            }
        )
        Realm.Configuration.defaultConfiguration = configuration
        realm = try! Realm()
         
        setupNavigationBar()
        setupOthers()
        
        SyncEngine.initBackend()
        SyncEngine.initUpdaters()
        SyncEngine.initObservers()
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let firebaseAuth = Auth.auth()
        print("device token: \(deviceToken.toHexString())")
        print("device token: \(deviceToken.description)")
        firebaseAuth.setAPNSToken(deviceToken, type: .unknown)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        let firebaseAuth = Auth.auth()
        if (firebaseAuth.canHandleNotification(userInfo)){
            print("+++++++++++++++++++++", userInfo)
            return
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
 
    // MARK: - Firebase Messaging
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - customized setup
    func setupNavigationBar() {
        if #available(iOS 13.0, *) {
            let standardAppearance = UINavigationBarAppearance()
            // default has semi-transparent
            // opaque is not transparent
            standardAppearance.configureWithDefaultBackground()
            standardAppearance.backgroundColor = .primaryColor
//            let backImage = UIImage(named: "ic_arrow_back") //UIImage(named: "arrow.left")
            let backImage = UIImage(systemName: "chevron.left")
            backImage?.withTintColor(.white)
            standardAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            
            standardAppearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont(name: MyFont.MontserratBold, size: 20)!
            ]
            standardAppearance.shadowColor = nil

            UINavigationBar.appearance().scrollEdgeAppearance = standardAppearance
            UINavigationBar.appearance().standardAppearance = standardAppearance
        } else {
            let navigationBar = UINavigationBar.appearance()
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = .primaryColor
            let backImage = UIImage(systemName: "chevron.left")
            backImage?.withTintColor(.black)
            navigationBar.backIndicatorImage = backImage
            navigationBar.backIndicatorTransitionMaskImage = backImage
            navigationBar.tintColor = .white//.colorPrimary
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name: MyFont.MontserratBold, size: 20)!
            ]
            navigationBar.shadowImage = UIImage()
        }
    }
    
    func setupOthers() {
        // UIBarButtonItem appearance
        UIBarButtonItem.appearance().tintColor = .white
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .font: UIFont(name: MyFont.MontserratRegular, size: 15)!,
            .foregroundColor: UIColor.white
        ], for: .normal)
        // UITextField Appearance
//        UITextField.appearance().tintColor = .black
        UITextView.appearance().tintColor = .black
        
        IQKeyboardManager.shared.toolbarTintColor = .black
        IQKeyboardManager.shared.enable = true
    }

}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // Print full message.
        print(userInfo)

        let aps = userInfo["aps"] as? [AnyHashable : Any]
        let alertMessage = aps!["alert"] as? [AnyHashable : Any]
        _  = alertMessage!["body"] as! String
        
        let userId = userInfo["userId"] as? String
        
        // display alert for notification
        let vc = AppBoards.friend.viewController(withIdentifier: "AcceptDeclineVC") as! AcceptDeclineVC
        vc.userId = userId ?? ""
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360)])
        UIApplication.shared.windows.first?.rootViewController?.present(sheetController, animated: true, completion: nil)
        
        if #available(iOS 14.0, *) {
            completionHandler([[.banner, .badge, .sound]])
        } else {
            // Fallback on earlier versions
            completionHandler([[.badge, .sound]])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        print(userInfo)
        
        // push to AddFriendsVC page as soon as opened by clicking the notification
        let home = AppBoards.main.initialViewController
        let vc = AppBoards.friend.viewController(withIdentifier: "AddFriendsVC") as! AddFriendsVC
        vc.modalPresentationStyle = .fullScreen
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = home
        window?.makeKeyAndVisible()
        home.present(vc, animated: false, completion: nil)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict:[String: String] = ["token": fcmToken ?? ""]

        NotificationCenter.default.post(name: .gotNewFCMToken, object: nil, userInfo: dataDict)
        
        Persons.update(oneSignalId: fcmToken ?? "")
        
        PrefsManager.setFCMToken(fcmToken ?? "")
    }
    
    func messaging(messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("TOKEN: ", fcmToken)
    }
    // [END refresh_token]
}

