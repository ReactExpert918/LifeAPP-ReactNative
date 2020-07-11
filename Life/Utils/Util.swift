//
//  Util.swift
//  Life
//
//  Created by XianHuang on 6/24/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class Util{
    /**
    * Show alert dialog
    *
    * @param title Dialog title
    * @param message Dialog message
    * @return void
    */
    static func showAlert(vc: UIViewController, _ title: String, _ message: String){
        let topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindow.Level.alert + 1
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )

        alert.addAction(UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        ))
        vc.present(alert, animated: true, completion: nil)
    }
    static func showSuccessAlert(vc: UIViewController, _ title: String, _ message: String){
        _ = SCLAlertView().showSuccess(title, subTitle: message, closeButtonTitle: "OK")
    }
}
