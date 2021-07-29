//
//  NotificationName+Extension.swift
//

import Foundation

extension Notification.Name {
    static let gotNewFCMToken = Notification.Name("gotNewFCMToken")
    
    static let appStarted = Notification.Name("AppStarted")
    static let loggedIn  = Notification.Name("UserLoggedIn")
    static let loggedOut = Notification.Name("UserLoggedOut")
}
