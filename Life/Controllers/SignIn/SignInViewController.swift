//
//  SignInViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
class SignInViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var passwordEye: UIButton!
    @IBOutlet weak var bottomText: UITextView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    let hud = JGProgressHUD(style: .light)
    var eye_off = true
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomText.delegate = self
        bottomText.isSelectable = true
        bottomText.isEditable = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onRegisterTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "signupViewController") as! SignupViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onPasswordEyeTapped(_ sender: Any) {
        if eye_off{
            password.isSecureTextEntry = false
            passwordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        }else {
            password.isSecureTextEntry = true
            passwordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        eye_off = !eye_off
    }
    @IBAction func onLoginTapped(_ sender: Any) {
        if userName.text == ""{
            Util.showAlert(vc: self, "Attention" , "Please enter username first.")
            return
        }else if password.text == ""{
            Util.showAlert(vc: self, "Attention" , "Please enter password first.")
            return
        }
        DispatchQueue.main.async {
            self.hud.textLabel.text = "Logging in..."
            self.hud.show(in: self.view, animated: true)
        }
        Auth.auth().signIn(withEmail: userName.text!, password: password.text!) { [weak self] authResult, error in
            self?.hud.dismiss()
            if error != nil {
                Util.showAlert(vc: self!, error?.localizedDescription ?? "", "")
                return
            }
            self?.loadPerson()
        }
    }
    // MARK: -
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadPerson() {

        let userId = AuthUser.userId()
        FireFetcher.fetchPerson(userId) { error in
            if (error != nil) {
                self.createPerson()
            }
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: Notification.Name(NotificationStatus.NOTIFICATION_USER_LOGGED_IN), object: nil)
                
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        
                UIApplication.shared.windows.first?.rootViewController = vc
            }
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func createPerson() {

        let email = (userName.text ?? "").lowercased()

        let userId = AuthUser.userId()
        Persons.create(userId, email: email)
    }
    @IBAction func onForgotPasswordTapped(_ sender: Any) {
    }
}
