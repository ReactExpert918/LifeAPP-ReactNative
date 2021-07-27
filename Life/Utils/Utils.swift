//
//  Utils.swift
//  Life
//
//  Created by XianHuang on 6/24/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import Foundation
import UIKit
//import SCLAlertView

class Utils {
    
    static let shared = Utils()
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    
}


class MyFont: NSObject {
    static let MontserratLight    = "Montserrat-Light"
    static let MontserratMedium   = "Montserrat-Medium"
    static let MontserratRegular  = "Montserrat-Regular"
    static let MontserratBold     = "Montserrat-Bold"
    static let MontserratSemiBold = "Montserrat-SemiBold"
}
