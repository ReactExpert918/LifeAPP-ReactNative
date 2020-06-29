//
//  AddPictureViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/29.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class AddPictureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var avatarCovered : Bool = false
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var avata: UIImageView!
    @IBOutlet weak var publicName: UITextField!
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
        let vc =  self.storyboard?.instantiateViewController(identifier: "successVC") as! SuccessViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
