//
//  BasicDetailInsertViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/29.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import JGProgressHUD
import RealmSwift

class BasicDetailInsertViewController: UIViewController, UITextFieldDelegate{
    
    var password_eye_off = true
    var confirmPassword_eye_off = true
    let hud = JGProgressHUD(style: .light)

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var passwordEye: UIButton!
    @IBOutlet weak var confirmPasswordEye: UIButton!
    
    private var person: Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userName.delegate = self
        password.delegate = self
        confirmPassword.delegate = self
        // load Person
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())

    }
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func submitTapped(_ sender: Any) {
        if userName.text == ""{
            Util.showAlert(vc: self, "Attention" , "Please enter email first.")
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
        
        Firestore.firestore().collection("Person").document(person.objectId).setData(["about": person.about, "country": person.country, "createdAt": person.createdAt, "email": person.email, "firstName": person.firstname, "fullName": person.fullname, "isDeleted": person.isDeleted, "keepMedia": person.keepMedia, "lastActive": person.lastActive, "lastTerminate": person.lastTerminate, "lastname": person.lastname, "location": person.location, "loginMethod": person.loginMethod, "networkAudio": person.networkAudio, "networkPhoto": person.networkPhoto, "networkVideo": person.networkVideo, "objectId": person.objectId, "oneSignalId": person.oneSignalId, "phone": person.phone, "pictureAt": person.pictureAt, "status" : person.status, "updatedAt": person.updatedAt, "wallpaper": person.wallpaper]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
            }
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
                // Save Email
                let realm = try! Realm()
                try! realm.safeWrite {
                    self.person.email = self.userName.text!
                    self.person.syncRequired = true
                    self.person.updatedAt = Date().timestamp()
                }
                // Save to the UserDefaults
                PrefsManager.setEmail(val: self.userName?.text ?? "")
                PrefsManager.setPassword(val: self.password?.text ?? "")
                
                let vc =  self.storyboard?.instantiateViewController(identifier: "addPictureVC") as! AddPictureViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        
        }
    }
    
    @IBAction func passwordEyeTapped(_ sender: Any) {
        if password_eye_off {
            password.isSecureTextEntry = false
            passwordEye.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            password.isSecureTextEntry = true
            passwordEye.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }

        password_eye_off = !password_eye_off
    }
    
    @IBAction func confirmPasswordEyeTapped(_ sender: Any) {
        if confirmPassword_eye_off {
            confirmPassword.isSecureTextEntry = false
            confirmPasswordEye.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            confirmPassword.isSecureTextEntry = true
            confirmPasswordEye.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }

        confirmPassword_eye_off = !confirmPassword_eye_off
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.viewWithTag(nextTag) as UIResponder?

        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }

        return false
    }

}
