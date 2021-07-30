//
//  AppConstant.swift
//  Life
//
//  Created by XianHuang on 6/27/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import Foundation

class AppConstant {
    static let VIDEO_LENGTH = 5
    static let agoraAppID = "7385eb633290453aaee4530d4c05f109"
}

struct ONESIGNAL {
    static let ONESIGNAL_APPID = "30b077a4-a8c5-4ee9-8119-e5189c1da75a"
}
struct SINCHINFO{
    static let SINCH_HOST = "clientapi.sinch.com"
    static let SINCH_KEY = "3ac06518-5a6b-4404-a076-ac320bcbdebc"
    static let SINCH_SECRET = "DKSRdpYDD0uqcbTnqzmfsg=="
}

struct AudioStatus{
    static let AUDIOSTATUS_STOPPED = 1
    static let AUDIOSTATUS_PLAYING = 2
}
struct MediaStatus {
    static let MEDIASTATUS_UNKNOWN = 0
    static let MEDIASTATUS_LOADING = 1
    static let MEDIASTATUS_MANUAL  = 2
    static let MEDIASTATUS_SUCCEED = 3    
}
/*
struct NotificationStatus {
    static let NOTIFICATION_APP_STARTED = "NotificationAppStarted"
    static let NOTIFICATION_USER_LOGGED_IN = "NotificationUserLoggedIn"
    static let NOTIFICATION_USER_LOGGED_OUT = "NotificationUserLoggedOut"
}*/

struct LoginInfo {
    static let LOGIN_EMAIL = "Email"
    static let LOGIN_PHONE = "Phone"
}

struct NETWORK_MODE {
    static let NETWORK_MANUAL = 1
    static let NETWORK_WIFI = 2
    static let NETWORK_ALL = 3
}

struct KEEPMEDIA_PERIOD{
    static let KEEPMEDIA_WEEK = 1
    static let KEEPMEDIA_MONTH = 2
    static let KEEPMEDIA_FOREVER = 3
}

struct MESSAGE_TYPE {
    static let MESSAGE_TEXT = "text"
    static let MESSAGE_EMOJI = "emoji"
    static let MESSAGE_PHOTO = "photo"
    static let MESSAGE_VIDEO = "video"
    static let MESSAGE_AUDIO = "audio"
    static let MESSAGE_LOCATION = "location"
    static let MESSAGE_MONEY = "pay"
}

struct TRANSACTION_STATUS {
    static let SUCCESS = 0
    static let FAILED = 1
    static let PENDING = 2
    static let DELETED = 4
}

struct LIFE_CRYPT {
    static let key = "-tM=Yn=7pEVXXGrd"
    static let iv = "AypfS&2wGr59*_U%"
}

struct UPDATE_ACCOUNT {
    static let UNKNOWN = 0
    static let NAME = 1
    static let EMAIL = 2
    static let PASSWORD = 3
    static let DELETE = 4
}

struct ZEDPAY_STATUS{
    static let PENDING = "pending"
    static let SUCCESS = "success"
    static let FAILED = "failed"
}
