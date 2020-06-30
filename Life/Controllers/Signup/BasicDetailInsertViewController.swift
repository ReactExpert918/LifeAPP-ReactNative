//
//  BasicDetailInsertViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/29.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class BasicDetailInsertViewController: UIViewController {
    
    var password_eye_off = true
    var confirmPassword_eye_off = true
    let hud = JGProgressHUD(style: .light)

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var passwordEye: UIButton!
    @IBOutlet weak var confirmPasswordEye: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func submitTapped(_ sender: Any) {
        if userName.text == ""{
            Util.showAlert(vc: self, "Attention" , "Please enter username first.")
            return
        }else if password.text == ""{
            Util.showAlert(vc: self, "Attention" , "Please enter password first.")
            return
        }else if confirmPassword.text == ""{
            Util.showAlert(vc: self, "Attention" , "Please enter confirm password first.")
            return
        }else if password.text != confirmPassword.text{
            Util.showAlert(vc: self, "Attention" , "Confirm password should be matched with password.")
            return
        }
        DispatchQueue.main.async {
            self.hud.textLabel.text = "Updating..."
            self.hud.show(in: self.view, animated: true)
        }
        Auth.auth().currentUser?.updateEmail(to: userName.text!) { (error) in
            if error != nil {
                self.hud.dismiss(afterDelay: 1.0, animated: true)
                Util.showAlert(vc: self, error?.localizedDescription ?? "", "")
                return
            }
            Auth.auth().currentUser?.updatePassword(to: self.password.text!) { (error) in
                self.hud.dismiss(afterDelay: 1.0, animated: true)
                if error != nil {
                    Util.showAlert(vc: self, error?.localizedDescription ?? "", "")
                    return
                }
                let vc =  self.storyboard?.instantiateViewController(identifier: "addPictureVC") as! AddPictureViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        
        }
    }
    @IBAction func passwordEyeTapped(_ sender: Any) {
        if password_eye_off {
            password.isSecureTextEntry = false
            passwordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        } else {
            password.isSecureTextEntry = true
            passwordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }

        password_eye_off = !password_eye_off
    }
    @IBAction func confirmPasswordEyeTapped(_ sender: Any) {
        if confirmPassword_eye_off {
            confirmPassword.isSecureTextEntry = false
            confirmPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        } else {
            confirmPassword.isSecureTextEntry = true
            confirmPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }

        confirmPassword_eye_off = !confirmPassword_eye_off
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
