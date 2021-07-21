//
//  NotificationName+Extension.swift
//

import Foundation

extension Notification.Name {
    static let FCMToken = Notification.Name("FCMToken")
    
    static let appStarted = Notification.Name("AppStarted")
    static let loggedIn  = Notification.Name("UserLoggedIn")
    static let loggedOut = Notification.Name("UserLoggedOut")
}
