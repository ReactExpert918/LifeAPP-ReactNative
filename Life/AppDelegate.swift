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
import OneSignal
import Sinch

//-------------------------------------------------------------------------------------------------------------------------------------------------
var realm = try! Realm()
let falsepredicate = NSPredicate(value: false)

//-------------------------------------------------------------------------------------------------------------------------------------------------

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var client: SINClient?
    var push: SINManagedPush?
    var callKitProvider: CallKitProvider?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        
        let configuration = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // if you added a new property or removed a property you don't
                    // have to do anything because Realm automatically detects that
                }
            }
        )
        Realm.Configuration.defaultConfiguration = configuration
        realm = try! Realm()
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
                }
            }
        })
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // OneSignal initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        OneSignal.initWithLaunchOptions(launchOptions, appId: ONESIGNAL.ONESIGNAL_APPID, handleNotificationReceived: nil,
                                        handleNotificationAction: nil, settings: [kOSSettingsKeyAutoPrompt: false])
        OneSignal.setLogLevel(ONE_S_LOG_LEVEL.LL_NONE, visualLevel: ONE_S_LOG_LEVEL.LL_NONE)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.none
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // Manager initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        _ = ChatManager.shared
        _ = Connectivity.shared
        _ = LocationManager.shared
        
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // MediaUploader initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        _ = MediaUploader.shared
        
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // Sinch initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        push = Sinch.managedPush(with: .development)
        push?.delegate = self
        push?.setDesiredPushType(SINPushTypeVoIP)

        callKitProvider = CallKitProvider()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sinchLogInUser), name: NSNotification.Name(rawValue: NotificationStatus.NOTIFICATION_APP_STARTED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sinchLogInUser), name: NSNotification.Name(rawValue: NotificationStatus.NOTIFICATION_USER_LOGGED_IN), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sinchLogOutUser), name: NSNotification.Name(rawValue: NotificationStatus.NOTIFICATION_USER_LOGGED_OUT), object: nil)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let firebaseAuth = Auth.auth()
        print("device token: \(deviceToken.toHexString())")
        firebaseAuth.setAPNSToken(deviceToken, type: .sandbox)
        firebaseAuth.setAPNSToken(deviceToken, type: .prod)

    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        if (firebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
            return
        }
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

    // MARK: - Sinch user methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func sinchLogInUser() {

        let userId = AuthUser.userId()

        if (userId == "")    { return }
        if (client != nil)    { return }

        client = Sinch.client(withApplicationKey: SINCHINFO.SINCH_KEY, applicationSecret: SINCHINFO.SINCH_SECRET, environmentHost: SINCHINFO.SINCH_HOST, userId: userId)
        client?.delegate = self
        client?.call().delegate = self
        client?.setSupportCalling(true)
        client?.enableManagedPushNotifications()
        callKitProvider?.setClient(client)
        client?.start()
        client?.startListeningOnActiveConnection()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func sinchLogOutUser() {

        client?.terminateGracefully()
        client = nil
    }

}
// MARK: - SINClientDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: SINClientDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func clientDidStart(_ client: SINClient!) {
        print("Sinch client started successfully \(client.userId)")
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Sinch client error: \(error.localizedDescription)")
    }
}

// MARK: - SINCallClientDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: SINCallClientDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        print("Sinch client willReceiveIncomingCall \(call.callId)")
        callKitProvider?.insertCall(call: call)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("Sinch client didReceiveIncomingCall \(call.callId)")
        callKitProvider?.insertCall(call: call)

        callKitProvider?.reportNewIncomingCall(call: call)
    }
}

// MARK: - SINManagedPushDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: SINManagedPushDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable: Any]!, forType pushType: String!) {

        callKitProvider?.didReceivePush(withPayload: payload)

        DispatchQueue.main.async {
            self.sinchLogInUser()
            self.client?.relayRemotePushNotification(payload)
            self.push?.didCompleteProcessingPushPayload(payload)
        }
    }
}
