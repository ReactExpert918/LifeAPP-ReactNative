//
//  AddPictureViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/29.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import JGProgressHUD

class AddPictureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var avatarCovered : Bool = false
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var avata: UIImageView!
    @IBOutlet weak var publicName: UITextField!
    let hud = JGProgressHUD(style: .light)
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.isHidden = true
        // Do any additional setup after loading the view.
    }
    @IBAction func onCameraTapped(_ sender: Any) {
        openCamera()
    }
    
    func openCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        avata.image = image
        cameraView.isHidden = false
        avatarCovered = true
        // print out the image size as a test
        print(image.size)
    }
    @IBAction func onBottomCameraTapped(_ sender: Any) {
        openCamera()
    }
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onNextTapped(_ sender: Any) {
        if !avatarCovered{
            Util.showAlert(vc: self, "Attention" , "Please take profile photo first.")
            return
        }else if publicName.text == ""{
            Util.showAlert(vc: self, "Attention" , "Please enter public name first.")
            return
        }
        if let uid = UserDefaults.standard.string(forKey: "uid"){
            DispatchQueue.main.async {
                self.hud.textLabel.text = "Uploading..."
                self.hud.show(in: self.view, animated: true)
            }
            let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(uid).png")
            profileImgReference.putData((avata.image?.pngData())!, metadata: nil){ (metadata, error) in
                if error != nil{
                    self.hud.dismiss(afterDelay: 1.0, animated: true)
                    Util.showAlert(vc: self, error!.localizedDescription , "")
                    return
                }
                profileImgReference.downloadURL(completion: {(url, error) in
                    if let url = url{
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = self.publicName.text!
                        changeRequest?.photoURL = url
                        changeRequest?.commitChanges { (error) in
                            self.hud.dismiss(afterDelay: 1.0, animated: true)
                            if error != nil{
                                Util.showAlert(vc: self, error!.localizedDescription, "")
                            }
                            let vc =  self.storyboard?.instantiateViewController(identifier: "successVC") as! SuccessViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else{
                        self.hud.dismiss(afterDelay: 1.0, animated: true)
                        Util.showAlert(vc: self, "Attention" , "Please take profile photo and try again.")
                        return
                    }
                })
            }
        }
        
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
