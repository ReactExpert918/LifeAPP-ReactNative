//
//  SplashViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let email = PrefsManager.getEmail()
        if email != "" {
            let password = PrefsManager.getPassword()
            AuthUser.signIn(email: email, password: password) {[weak self] (error) in
                guard let self = self else { return }
                if error != nil {
                    self.postUserLogin()
                    self.gotoMainViewController()
                    return
                }
                let userId = AuthUser.userId()
                FireFetcher.fetchPerson(userId) { error in
                    self.dismiss(animated: true) {
                        if error != nil {
                            self.gotoWelcomeViewController()
                        }
                        else {
                            self.postUserLogin()
                            self.gotoMainViewController()
                        }
                    }
                }
            }
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.gotoWelcomeViewController()
            }
        }
    }

    private func postUserLogin() {
        NotificationCenter.default.post(name: Notification.Name(NotificationStatus.NOTIFICATION_USER_LOGGED_IN), object: nil)
    }

    private func gotoWelcomeViewController() {
        let mainstoryboard = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "rootNavigationViewController")
        UIApplication.shared.windows.first?.rootViewController = vc
    }

    private func gotoMainViewController() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        UIApplication.shared.windows.first?.rootViewController = vc
    }

}
