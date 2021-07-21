//
//  AppBoards.swift
//

import UIKit

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
