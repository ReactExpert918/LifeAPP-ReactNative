//
//  AddPictureVC.swift
//  Life
//
//  Created by Yun Li on 2020/6/29.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import RealmSwift

class AddPictureVC: BaseVC {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var txtPublicName: UITextField!
    
    private var person: Person!
    
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = ImagePicker(self, delegate: self)
        cameraView.isHidden = true
        
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCameraTapped(_ sender: Any) {
        if imvProfile.image?.pngData() == nil {
            print("No image yet")
            self.imagePicker.present(from: self.view)
        } else {
            if let img = imvProfile.image {
                openEditPhoto(img)
            }
            print("Image chosen")
        }
    }
    
    @IBAction func onSmallCameraTapped(_ sender: Any) {
        self.imagePicker.present(from: self.view)
    }
    
    
    @IBAction func onNextTapped(_ sender: Any) {
        if checkValid() {
            uploadPicture()
        }
    }
    
    fileprivate func checkValid() -> Bool {
        if imvProfile.image == nil {
            showAlert(R.msgTakePhoto)
            return false
        }
        
        if txtPublicName.text!.trim().isEmpty {
            showAlert(R.msgEnterPublicName)
            return false
        }
        
        return true
    }
    
    func uploadPicture() {
        showProgress()
        
        if let image = imvProfile.image {
            let temp = image.square(to: 300)
            if let data = temp.jpegData(compressionQuality: 0.6) {
                MediaUpload.user(AuthUser.userId(), data: data, completion: { error in
                    self.hideProgress()
                    if (error == nil) {
                        MediaDownload.saveUser(AuthUser.userId(), data: data)
                        self.person.update(pictureAt: Date().timestamp())
                        self.updateUser()
                    } else {
                        self.showToast(R.errFailedUploadPhoto)
                    }
                })
            }
        }
    }
    
    fileprivate func updateUser() {
        let realm = try! Realm()
        try! realm.safeWrite {
            person.fullname    = txtPublicName.text!
            person.syncRequired = true
            person.updatedAt = Date().timestamp()
        }
        
        gotoNext()
    }
    
    fileprivate func gotoNext() {
        let vc =  self.storyboard?.instantiateViewController(identifier: "successVC") as! SuccessVC
        self.navigationController?.pushViewController(vc, animated: true)
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
extension AddPictureVC: ImagePickerDelegate {
    
    func didSelect(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        
        openEditPhoto(image)
    }
}

extension AddPictureVC: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        imvProfile.image = cropped
        imvProfile.borderWidth = 3
        imvProfile.borderColor = .gray
        cameraView.isHidden = false
    }

    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) { }

    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) { }

    func cropViewControllerWillDismiss(_ cropViewController: CropViewController) { }
}


