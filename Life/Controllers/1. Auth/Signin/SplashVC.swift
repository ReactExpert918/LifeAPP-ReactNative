//
//  SplashVC.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import Firebase

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let registered = PrefsManager.getRegistered()
        if registered {
            let email    = PrefsManager.getEmail()
            let password = PrefsManager.getPassword()
            
            AuthUser.signIn(email: email, password: password) { (error) in
                if error != nil {
                    self.gotoWelcomeVC()
                    return
                }
                
                let userId = AuthUser.userId()
                FireFetcher.fetchPerson(userId) { error in
                    self.dismiss(animated: true) {
                        if error != nil {
                            self.gotoWelcomeVC()
                        } else {
                            self.gotoHome()
                        }
                    }
                }
            }
        } else {
            self.gotoWelcomeVC()
        }
    }
    
    func gotoWelcomeVC() {
        let vc = self.storyboard?.instantiateViewController(identifier: "RootNavigationVC")
        UIApplication.shared.windows.first?.rootViewController = vc
    }
    
    fileprivate func gotoHome() {
        NotificationCenter.default.post(name: .loggedIn, object: nil)
        
        let vc = AppBoards.main.initialViewController
        UIApplication.shared.windows.first?.rootViewController = vc
    }

}
