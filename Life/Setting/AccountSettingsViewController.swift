//
//  AccountSettingsViewController.swift
//  Life
//
//  Created by Yun Li on 2020/7/3.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SwiftyAvatar
import JGProgressHUD
import FittedSheets
import FirebaseAuth
import FirebaseStorage
import RealmSwift
import FirebaseFirestore
import OneSignal

protocol UpdateDataDelegateProtocol {
    func updateUserName(name: String)
    func updatePassword(password: String)
}

class AccountSettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UpdateDataDelegateProtocol {
    
    private var person: Person! 

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var profileImageView: SwiftyAvatar!
    
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteRight: UIImageView!
    @IBOutlet weak var emailRight: UIImageView!
    @IBOutlet weak var phoneRight: UIImageView!
    
    
    let hud = JGProgressHUD(style: .light)
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberButton.isHidden = true
        emailButton.isHidden = true
        emailRight.isHidden = true
        phoneRight.isHidden = true
        deleteRight.isHidden = true
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        if (AuthUser.userId() != "") {
            loadPerson()
        }
    }
    @IBAction func onBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func updateUserName(name: String) {
        self.person.update(fullname: name)
        loadPerson()
        Util.showSuccessAlert(vc: self, "Successfully updated the name.".localized, "")
    }
    
    func updatePassword(password: String) {
        DispatchQueue.main.async {
            self.hud.show(in: self.view, animated: true)
        }
        AuthUser.updatePassword(password: password) { (error) in
            self.hud.dismiss()
            if let error = error {
                Util.showAlert(vc: self, error.localizedDescription , "")
                return
            }
            Util.showSuccessAlert(vc: self, "Successfully updated the password.".localized, "")
        }
    }
    
    @IBAction func onNameChangeTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "updateNameVC") as! UpdateNameViewController
        vc.setName(withName: person.fullname)
        vc.delegate = self

        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(290)])
        
        //sheetController.blurBottomSafeArea = false
        //sheetController.adjustForBottomSafeArea = false

        // Make corners more round
        //sheetController.topCornersRadius = 15
        

        // It is important to set animated to false or it behaves weird currently
        self.present(sheetController, animated: false, completion: nil)
    }
    @IBAction func onPasswordChangeTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "updatePasswordVC") as! UpdatePasswordViewController
        vc.delegate = self
        
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(350)])
        //sheetController.blurBottomSafeArea = false
        //sheetController.adjustForBottomSafeArea = false

        // Make corners more round
        //sheetController.topCornersRadius = 15

        // It is important to set animated to false or it behaves weird currently
        self.present(sheetController, animated: false, completion: nil)
    }
    @IBAction func onPhoneNumberChangeTapped(_ sender: Any) {
    }
    @IBAction func onEmailChangeTapped(_ sender: Any) {
    }
    @IBAction func onDeleteAccountTapped(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Are you sure to delete your account?".localized, message: "", preferredStyle: .alert)

        refreshAlert.addAction(UIAlertAction(title: "Yes".localized, style: .default, handler: { (action: UIAlertAction!) in
            DispatchQueue.main.async {
                self.hud.show(in: self.view, animated: true)
            }
            AuthUser.deleteAccount { (error) in
                self.hud.dismiss()
                if let error = error {
                    Util.showAlert(vc: self, error.localizedDescription, "")
                    return
                }
                self.person.update(isDeleted: true)
                PrefsManager.setEmail(val: "")
                self.gotoWelcomeViewController()
            }
            
        }))

        refreshAlert.addAction(UIAlertAction(title: "No".localized, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    func gotoWelcomeViewController() {
        let mainstoryboard = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "rootNavigationViewController")
        UIApplication.shared.windows.first?.rootViewController = vc
    }
    
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profileImageView.image = image
            }
            else {
                self.profileImageView.image = UIImage(named: "ic_default_profile")
            }
        }
        name.text = person.fullname
        password.text = person.fullname
        phoneNumber.text = person.phone
        emailAddress.text = person.email
    }
    
    @IBAction func onCameraTapped(_ sender: Any) {
        
        let confirmationAlert = UIAlertController(title: "Please select source type to set profile image.".localized, message: "", preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "Camera".localized, style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.openCamera()
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Gallery".localized, style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.openGallery()
        }))

        confirmationAlert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    func openCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func openGallery(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            // print("No image found")
            return
        }
        let data = image.jpegData(compressionQuality: 1.0)
        let correct_image = UIImage(data: data! as Data)
        DispatchQueue.main.async{
            self.profileImageView.image = correct_image
        }
        // print out the image size as a test
        // print(correct_image?.size)
        uploadPicture(image: correct_image!)
    }
    func uploadPicture(image: UIImage) {
        // print("uploadPicture")
        if let data = image.jpegData(compressionQuality: 0.6) {
            MediaUpload.user(AuthUser.userId(), data: data, completion: { error in
                if (error == nil) {
                    MediaDownload.saveUser(AuthUser.userId(), data: data)
                    self.person.update(pictureAt: Date().timestamp())
                } else {
                    DispatchQueue.main.async {
                        self.hud.textLabel.text = "Picture upload error.".localized
                        self.hud.show(in: self.view, animated: true)
                    }
                    self.hud.dismiss(afterDelay: 1.0, animated: true)
                }
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
}
