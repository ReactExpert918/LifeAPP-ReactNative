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
import RealmSwift
import FittedSheets
import PushKit
import AVFoundation

//-------------------------------------------------------------------------------------------------------------------------------------------------
var realm = try! Realm()
let falsepredicate = NSPredicate(value: false)
//-------------------------------------------------------------------------------------------------------------------------------------------------

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var callKitProvider: CallKitProvider?
    let gcmMessageIDKey = "gcm.message_id"
    var pendingChatID = ""
    var pendingUserID = ""
    var pendingVideoCall = false
    
    var audioPlayer = AVAudioPlayer()
    //var voipRegistry: PKPushRegistry?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        
        
        
//        let value: Float = 5000.0
//
//        print("TestMoney:", value.encryptedString())
       
        
        let configuration = Realm.Configuration(
            schemaVersion: 11,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 11 {
                    // if you added a new property or removed a property you don't
                    // have to do anything because Realm automatically detects that
                }
            }
        )
        Realm.Configuration.defaultConfiguration = configuration
        realm = try! Realm()
         
        
        initPushKit()
    //-----------------------------------------------------------------------------------------------------------------------------------------
        // SyncEngine initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        SyncEngine.initBackend()
        SyncEngine.initUpdaters()
        SyncEngine.initObservers()
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // Push notification initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        let authorizationOptions: UNAuthorizationOptions = [.sound, .alert, .badge]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions, completionHandler: { granted, error in
            if (error == nil) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    //UIApplication.shared.regis
                }
            }
        })
        _ = ChatManager.shared
        _ = Connectivity.shared
        _ = LocationManager.shared
        _ = MediaUploader.shared
        callKitProvider = CallKitProvider()
        Messaging.messaging().delegate = self
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
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        if (firebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
            return
        }
        completionHandler(.newData)
    }
 
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


    func topMostViewController() -> UIViewController? {
        return UIApplication.shared.windows.filter{ $0.isKeyWindow }.first?.rootViewController
    }

}

// MARK: PUSHKIT

extension AppDelegate: PKPushRegistryDelegate {
    func initPushKit() {
        let registry = PKPushRegistry(queue: nil)
        registry.delegate = self
        registry.desiredPushTypes = [PKPushType.voIP]
    }

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceId = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print(deviceId)
        PushNotification.registerDeviceId(deviceId: deviceId)
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        if let provider = self.callKitProvider {
            provider.didReceivePush(withPayload: payload.dictionaryPayload)
        }
    }
}


extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    var localizedJA: String{
        let language = "ja"
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        return NSLocalizedString(self, bundle: bundle, comment: "")
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
        if aps == nil {
            if #available(iOS 14.0, *) {
                completionHandler([[.banner, .badge, .sound]])
            } else {
                // Fallback on earlier versions
                completionHandler([[.badge, .sound]])
            }
            return
        }
        let alertMessage = aps!["alert"] as? [AnyHashable : Any]
        _  = alertMessage!["body"] as! String
        
        let userId = userInfo["userId"] as? String
        if let noti_type = userInfo["noti_type"] as? String{
            switch noti_type {
            case "0":
                // display alert for notification
                let vc = AppBoards.friend.viewController(withIdentifier: "AcceptDeclineViewController") as! AcceptDeclineViewController
                vc.userId = userId ?? ""
        
                let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360), .fixed(360)])
                UIApplication.shared.windows.first?.rootViewController?.present(sheetController, animated: true, completion: nil)
                
                if #available(iOS 14.0, *) {
                    completionHandler([[.banner, .badge, .sound]])
                } else {
                    // Fallback on earlier versions
                    completionHandler([[.badge, .sound]])
                }
            
            default:                
                if #available(iOS 14.0, *) {
                    completionHandler([[.banner, .badge, .sound]])
                } else {
                    // Fallback on earlier versions
                    completionHandler([[.badge, .sound]])
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
        print(userInfo)
        
        let aps = userInfo["aps"] as? [AnyHashable : Any]
        if aps == nil {
            completionHandler()
            return
        }
        let alertMessage = aps!["alert"] as? [AnyHashable : Any]
        _  = alertMessage!["body"] as! String
        
        let userId = userInfo["userId"] as? String
        let chatId = userInfo["chatId"] as? String
        if let noti_type = userInfo["noti_type"] as? String{
            switch noti_type {
            case "0":
                // display alert for notification
                if let viewController = topMostViewController() as? MainTabViewController {
                    if let navigationController = viewController.selectedViewController as? UINavigationController {
                        navigationController.popToRootViewController(animated: false)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc =  storyboard.instantiateViewController(identifier: "chatViewController") as! ChatViewController
                        vc.setParticipant(chatId: chatId ?? "", recipientId: userId ?? "")
                        vc.modalPresentationStyle = .fullScreen
                        vc.hidesBottomBarWhenPushed = true
                        //self.present(vc, animated: true, completion: nil)
                        navigationController.pushViewController(vc, animated: true)
                    }
                } else {
                    self.pendingChatID = chatId ?? ""
                    self.pendingUserID = userId ?? ""
                }
            
            default:
                
                if let viewController = topMostViewController() as? MainTabViewController {
                    if let navigationController = viewController.selectedViewController as? UINavigationController {
                        navigationController.popToRootViewController(animated: false)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc =  storyboard.instantiateViewController(identifier: "chatViewController") as! ChatViewController
                        vc.setParticipant(chatId: chatId ?? "", recipientId: userId ?? "")
                        vc.modalPresentationStyle = .fullScreen
                        vc.hidesBottomBarWhenPushed = true
                        //self.present(vc, animated: true, completion: nil)
                        navigationController.pushViewController(vc, animated: true)
                    }
                } else {
                    self.pendingChatID = chatId ?? ""
                    self.pendingUserID = userId ?? ""
                }
            }
        }
        
        
        
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
        
        PrefsManager.setFCMToken(val: fcmToken ?? "")
    }
    
    func messaging(messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("TOKEN: ", fcmToken)
    }
    // [END refresh_token]
}

extension AppDelegate {
    func playAudio() {
        guard let sound = Bundle.main.path(forResource: "call_ringback", ofType: "wav") else {
            print("Error getting the mp3 file from the main bundle.")
            return
        }
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
        } catch {
            print("Audio file error.")
        }
        audioPlayer.play()
    }
    func stopAudio() {
        audioPlayer.stop()
    }
}

enum AppBoards: String {
    
    case login   = "Login"
    case main    = "Main"
    case group   = "Group"
    case friend  = "Friend"
    case setting = "Setting"
    case zedpay  = "ZedPay"
    
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
    
    var initialViewController: UIViewController {
        return self.instance.instantiateInitialViewController()!
    }

    func viewController(withIdentifier identifier: String) -> UIViewController {
        return instance.instantiateViewController(withIdentifier: identifier)
    }
}

enum NotiType: Int {
    case friendRequest = 0
    case sendText = 1
    case sendImage = 2
    case sendPhoto = 3
    case sendMoney = 4
    case sendVideoCalling = 5
    case sendVoiceCalling = 6
}
