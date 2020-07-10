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
class AccountSettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private var person: Person! 

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var profileImageView: SwiftyAvatar!
    let hud = JGProgressHUD(style: .light)
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func onNameChangeTapped(_ sender: Any) {
    }
    @IBAction func onUsernameChangeTapped(_ sender: Any) {
    }
    @IBAction func onPasswordChangeTapped(_ sender: Any) {
    }
    @IBAction func onPhoneNumberChangeTapped(_ sender: Any) {
    }
    @IBAction func onEmailChangeTapped(_ sender: Any) {
    }
    @IBAction func onDeleteAccountTapped(_ sender: Any) {
    }
    
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profileImageView.image = image
            }
        }
        name.text = person.fullname
        userName.text = person.fullname
        password.text = person.fullname
        phoneNumber.text = person.phone
        emailAddress.text = person.email
    }
    @IBAction func onCameraTapped(_ sender: Any) {
        
        let confirmationAlert = UIAlertController(title: "please select source type to set profile image.", message: "", preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.openCamera()
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.openGallery()
        }))

        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    func openCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func openGallery(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        DispatchQueue.main.async{
            self.profileImageView.image = image
        }
        // print out the image size as a test
        print(image.size)
        uploadPicture(image: image)
    }
    func uploadPicture(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.6) {
            MediaUpload.user(AuthUser.userId(), data: data, completion: { error in
                if (error == nil) {
                    MediaDownload.saveUser(AuthUser.userId(), data: data)
                    self.person.update(pictureAt: Date().timestamp())
                } else {
                    DispatchQueue.main.async {
                        self.hud.textLabel.text = "Picture upload error."
                        self.hud.show(in: self.view, animated: true)
                    }
                    self.hud.dismiss(afterDelay: 1.0, animated: true)
                }
            })
        }
    }
}
