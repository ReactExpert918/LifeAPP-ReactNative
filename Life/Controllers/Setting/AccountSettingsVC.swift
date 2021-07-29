//
//  AccountSettingsVC.swift
//  Life
//
//  Created by Yun Li on 2020/7/3.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SwiftyAvatar
import FittedSheets
import FirebaseAuth
import FirebaseStorage
import RealmSwift
import FirebaseFirestore

protocol UpdateDataDelegateProtocol {
    func updateUserName(name: String)
    func updatePassword(password: String)
    func deleteAccount()
    func updateEmail(email: String)
}

class AccountSettingsVC: BaseVC, UIImagePickerControllerDelegate, UpdateDataDelegateProtocol {
    
    @IBOutlet weak var imvProfile: SwiftyAvatar!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblPhoneNum: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    var imagePicker: ImagePicker!
    private var person: Person!
    private var tokenPerson: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = ImagePicker(self, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        showSuccessAlert("Successfully updated the name.")
    }
    
    func updatePassword(password: String) {
        showProgress()
        AuthUser.updatePassword(password: password) { (error) in
            self.hideProgress()
            if let _ = error {
                self.showFailedAlert("Failed to update password")
            }else{
                self.showSuccessAlert("Successfully updated the password.")
            }
        }
    }
    
    func updateEmail(email: String) {
        showProgress()
        AuthUser.updateEmail(email: email){ (error) in
            self.hideProgress()
            if let _ = error {
                self.showFailedAlert("Failed to update email")
            }else{
                self.person.update(email: email)
                self.showSuccessAlert("Successfully updated the password.")
            }
           
        }
    }
    
    func deleteAccount(){
        showProgress()
        AuthUser.deleteAccount { (error) in
            self.hideProgress()
            if let _ = error {
                self.showFailedAlert("Failed to delete account.")
            }else{
                self.person.update(isDeleted: true)
                self.showSuccessAlert("Successfully deleted your account.")
            }
            
            DispatchQueue.main.async() {
                PrefsManager.setEmail("")
                self.gotoWelcomeVC()
            }
        }
    }
    
    @IBAction func onNameChangeTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "updateNameVC") as! UpdateNameVC
        vc.setName(withName: person.fullname)
        vc.delegate = self

        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(290)])
        
        self.present(sheetController, animated: false, completion: nil)
    }
    
    @IBAction func onPasswordChangeTapped(_ sender: Any) {
        showProgress()
        PhoneAuthProvider.provider().verifyPhoneNumber(self.person.phone, uiDelegate: nil) { (verificationID, error) in
            self.hideProgress()
            if error != nil {
                self.showAlert("Verification code send failed")
                return
            }
            // Save Verification ID
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            let vc =  self.storyboard?.instantiateViewController(identifier: "UpdateOPTVC") as! UpdateOPTVC
            vc.delegate = self
            vc.updateType = UPDATE_ACCOUNT.PASSWORD
            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(300)])
            
            self.present(sheetController, animated: false, completion: nil)
        }
    }
    
    @IBAction func onEmailChangeTapped(_ sender: Any) {
        showProgress()
        PhoneAuthProvider.provider().verifyPhoneNumber(self.person.phone, uiDelegate: nil) { (verificationID, error) in
            self.hideProgress()
            if error != nil {
                self.showAlert("Verification code send failed")
                return
            }
            // Save Verification ID
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            let vc =  self.storyboard?.instantiateViewController(identifier: "UpdateOPTVC") as! UpdateOPTVC
            vc.delegate = self
            vc.updateType = UPDATE_ACCOUNT.EMAIL
            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(300)])
            
            self.present(sheetController, animated: false, completion: nil)
        }
    }
    
    @IBAction func onDeleteAccountTapped(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Are you sure to delete your account?", message: "", preferredStyle: .alert)

        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.showProgress()
            
            PhoneAuthProvider.provider().verifyPhoneNumber(self.person.phone, uiDelegate: nil) { (verificationID, error) in
                self.hideProgress()
                if error != nil {
                    self.showAlert("Verification code send failed")
                    return
                }
                // Save Verification ID
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                let vc =  self.storyboard?.instantiateViewController(identifier: "UpdateOPTVC") as! UpdateOPTVC
                vc.delegate = self
                vc.updateType = UPDATE_ACCOUNT.DELETE
                let sheetController = SheetViewController(controller: vc, sizes: [.fixed(300)])
                
                self.present(sheetController, animated: false, completion: nil)
            }
        }))

        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func gotoWelcomeVC() {
        let vc = AppBoards.login.initialViewController
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    func loadPerson() {
        let predicate = NSPredicate(format: "objectId == %@", AuthUser.userId())
        let persons = realm.objects(Person.self).filter(predicate)
        
        
        tokenPerson?.invalidate()
        persons.safeObserve({ changes in
            self.person = persons.first!
            self.refreshAccountInfo()
        }, completion: { token in
            self.tokenPerson = token
        })
        
    }
    
    func refreshAccountInfo(){
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.imvProfile.image = image
            } else {
                self.imvProfile.image = UIImage(named: "ic_default_profile")
            }
        }
        lblName.text     = person.fullname
        txtPassword.text = person.fullname
        lblPhoneNum.text = person.phone
        lblEmail.text    = person.email
    }
    
    @IBAction func onCameraTapped(_ sender: Any) {
        self.imagePicker.present(from: self.view)
    }
    
    func uploadPicture() {
        if let image = imvProfile.image {
            if let data = image.jpegData(compressionQuality: 0.6) {
                showProgress()
                MediaUpload.user(AuthUser.userId(), data: data, completion: { error in
                    self.hideProgress()
                    if (error == nil) {
                        MediaDownload.saveUser(AuthUser.userId(), data: data)
                        self.person.update(pictureAt: Date().timestamp())
                        self.showToast("Picture changed successfully")
                    } else {
                        self.showAlert("Picture upload error.")
                    }
                })
            }
        }
    }
    
    fileprivate func openEditPhoto(_ image: UIImage) {
        
        var config = CropConfig()
        // Do any additional customization here
        config.showRatioButton = true
        config.cropShapeType = .rect
        config.ratioOptions = .square
        
        let cropViewController = CropViewController(image: image, config: config)
        let cropNav = UINavigationController(rootViewController: cropViewController)
        // set present style with fullScreen mode
        cropNav.modalPresentationStyle = .fullScreen
        
        // set delegate and title
        cropViewController.delegate = self
        cropViewController.navigationItem.title = "Edit Photo"
        
        present(cropNav, animated: true)
    }
    
}

// MARK: - ImagePickerDelegate
extension AccountSettingsVC: ImagePickerDelegate {
    
    func didSelect(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        
        openEditPhoto(image)
    }
}

extension AccountSettingsVC: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        imvProfile.image = cropped
        
        uploadPicture()
    }

    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) { }

    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) { }

    func cropViewControllerWillDismiss(_ cropViewController: CropViewController) { }
}
