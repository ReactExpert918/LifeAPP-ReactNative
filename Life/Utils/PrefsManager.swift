//
//  PrefsManager.swift
//  CIUWApp
//
//  Created by XianHuang on 5/12/20.
//  Copyright © 2020 ciuw. All rights reserved.
//

import Foundation

extension PrefsManager {
    // MARK: - customized functions
    class func setLaunchedByNotification(_ val: Bool) {
        setBool(key: "LaunchedByNotification", value: val)
    }
    
    class func launchedByNotification() -> Bool {
        return getBool(key: "LaunchedByNotification")
    }
    
    class func setRegistered(_ val: Bool) {
        setBool(key: "registered", value: val)
    }
    
    class func getRegistered() -> Bool {
        return getBool(key: "registered")
    }
    
    class func setUserID(_ val : String) {
        setString(key: "userid", value: val)
    }
    
    class func  getUserID() -> String {
        return getString(key: "userid")
    }
    
    
    class func setEmail(_ val : String) {
        setString(key: "email", value: val)
    }
    
    class func  getEmail() -> String {
        return getString(key: "email")
    }
    
    class func setAvatar(_ val : String) {
        setString(key: "avatar", value: val)
    }
    
    class func  getAvatar() -> String {
        return getString(key: "avatar")
    }
    

    class func setFirstName(_ val : String) {
        setString(key: "firstname", value: val)
    }
    
    class func  getFirstName() -> String {
        return getString(key: "firstname")
    }
    
    class func setLastName(_ val : String) {
        setString(key: "lastname", value: val)
    }
    
    class func  getLastName() -> String {
        return getString(key: "lastname")
    }
    
    class func setPassword(_ val : String) {
        setString(key: "password", value: val)
    }
    
    class func  getPassword() -> String {
        return getString(key: "password")
    }

    class func setFCMToken(_ val : String) {
        setString(key: "fcmToken", value: val)
    }
    
    class func  getFCMToken() -> String {
        return getString(key: "fcmToken")
    }
    

}

class PrefsManager: NSObject {
    
    class func set(key:String,value:Bool) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func get(key:String) -> Bool {
        let value = UserDefaults.standard.bool(forKey: key)
        return value
    }
    
    class func setString(key:String,value:String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getString(key:String) -> String {
        let value = UserDefaults.standard.string(forKey: key) ?? ""
        return value
    }
    
    class func setInt(key:String,value:Int) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getInt(key:String) -> Int{
        let value = UserDefaults.standard.integer(forKey: key)
        return value
    }
    
    class func setBool(key:String,value:Bool) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getBool(key:String) -> Bool {
        let value = UserDefaults.standard.bool(forKey: key)
        return value
    }
}
