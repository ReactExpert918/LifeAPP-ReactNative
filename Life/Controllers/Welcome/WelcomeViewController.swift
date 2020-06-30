//
//  LoginViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        //gotoMainViewController()
        let vc =  self.storyboard?.instantiateViewController(identifier: "signinVC") as! SignInViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onSignupPressed(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "signupViewController") as! SignupViewController
        self.navigationController?.pushViewController(vc, animated: true)
//        let vc =  self.storyboard?.instantiateViewController(identifier: "basicDetailInsertVC") as! BasicDetailInsertViewController
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoMainViewController() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        UIApplication.shared.windows.first?.rootViewController = vc
    }
}
