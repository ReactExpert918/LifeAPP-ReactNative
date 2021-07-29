//
//  BasicDetailInsertVC.swift
//  Life
//
//  Created by Yun Li on 2020/6/29.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseAuth
import RealmSwift

class BasicDetailInsertVC: BaseVC {
    
    var password_eye_off = true
    var confirm_eye_off = true
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPwd: UITextField!
    
    @IBOutlet weak var passwordEye: UIButton!
    @IBOutlet weak var confirmPasswordEye: UIButton!
    
    private var person: Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtEmail.delegate = self
        txtPassword.delegate = self
        txtConfirmPwd.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        if checkValid() {
            doUploadDetail()
        }
    }
    
    fileprivate func checkValid() -> Bool {
        if txtEmail.text!.trim().isEmpty {
            showAlert(R.msgEnterEmail)
            return false
        }
        
        if txtPassword.text!.trim().isEmpty {
            showAlert(R.msgEnterPassword)
            return false
        }
        
        if txtConfirmPwd.text!.trim().isEmpty {
            showAlert(R.msgConfirmPassword)
            return false
        }
        
        if txtPassword.text!.trim() != txtConfirmPwd.text!.trim() {
            showAlert(R.msgPwdDontMatch)
            return false
        }
        
        return true
    }
    
    fileprivate func doUploadDetail() {
        
        showProgress("Updating...")
        
        Auth.auth().currentUser?.updateEmail(to: txtEmail.text!) { (error) in
            if error != nil {
                self.hideProgress()
                self.showAlert(error?.localizedDescription)
                return
            }
            
            Auth.auth().currentUser?.updatePassword(to: self.txtPassword.text!) { (error) in
                if error != nil {
                    self.hideProgress()
                    self.showAlert(error?.localizedDescription)
                    return
                }
                
                self.hideProgress()
                
                let realm = try! Realm()
                try! realm.safeWrite {
                    self.person.email = self.txtEmail.text!
                    self.person.syncRequired = true
                    self.person.updatedAt = Date().timestamp()
                }
                // Save to the UserDefaults
                PrefsManager.setEmail(self.txtEmail.text!)
                PrefsManager.setPassword(self.txtPassword.text!)
                
                self.gotoNext()
            }
        }
    }
    
    @IBAction func passwordEyeTapped(_ sender: Any) {
        if password_eye_off {
            txtPassword.isSecureTextEntry = false
            passwordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        } else {
            txtPassword.isSecureTextEntry = true
            passwordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }

        password_eye_off = !password_eye_off
    }
    
    @IBAction func confirmPasswordEyeTapped(_ sender: Any) {
        if confirm_eye_off {
            txtConfirmPwd.isSecureTextEntry = false
            confirmPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        } else {
            txtConfirmPwd.isSecureTextEntry = true
            confirmPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }

        confirm_eye_off = !confirm_eye_off
    }

    fileprivate func gotoNext() {
        let vc = self.storyboard?.instantiateViewController(identifier: "AddPictureVC") as! AddPictureVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BasicDetailInsertVC: UITextFieldDelegate {
    // MARK: - UITextField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == txtPassword) {
            txtConfirmPwd.becomeFirstResponder()
        } else if (textField == txtConfirmPwd) {
            if (checkValid()) {
                doUploadDetail()
            }
        }
        
        textField.resignFirstResponder()
        return false
    }
}
