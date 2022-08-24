//
//  SplashViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        checkWalkThrough()
    }

    private func checkWalkThrough() {
        if PrefsManager.getIgnoreWalkthrough() {
            checkLogin()
        } else {
            gotoWalkthrough()
        }
    }

    private func gotoWalkthrough() {

        let viewModel = WalkthroughViewModel(items: [
            .init(image: .init(named: "walkthrough1"), description: "walkthrough1".localized),
            .init(image: .init(named: "walkthrough2"), description: "walkthrough2".localized),
            .init(image: .init(named: "walkthrough3"), description: "walkthrough3".localized),
            .init(image: .init(named: "walkthrough4"), description: "walkthrough4".localized),
            .init(image: .init(named: "walkthrough5"), description: "walkthrough5".localized),
            .init(image: .init(named: "walkthrough6"), description: "walkthrough6".localized)
        ])

        let walkthroughViewController = WalkthroughViewController.instantiate()
        walkthroughViewController.model = viewModel
        UIApplication.shared.windows.first?.rootViewController = walkthroughViewController
    }

    private func checkLogin() {
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
