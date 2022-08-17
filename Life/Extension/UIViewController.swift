//
//  UIViewController.swift
//  Life
//
//  Created by Farbod Rahiminik on 8/17/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

func showAlert(title: String, subtitle: String, shouldDismiss: Bool = false, dismissTitle: String = "", handlerTitle: String = "", handler: ((UIAlertAction) -> Void)? = nil){
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: UIAlertController.Style.alert)
        if handler != nil {
        alert.addAction(UIAlertAction(title: handlerTitle, style: UIAlertAction.Style.default, handler: handler))
        }
        if shouldDismiss {
            alert.addAction(UIAlertAction(title: dismissTitle, style: .default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }

}
