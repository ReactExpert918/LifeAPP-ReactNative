//
//  CreateGroupVC.swift
//  Life
//
//  Created by Yun Li on 2020/7/8.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import JGProgressHUD
import SwiftyAvatar

var selectedPersonsForGroup : [Person] = []

class CreateGroupVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var groupImageView: SwiftyAvatar!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedUsers: [String] = []
    private var groupPicture: UIImage? = nil
    

    var delegate: CreateGroupDelegate? = nil
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPersonsForGroup.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addMemberCell", for: indexPath) as! AddMemberCell
            cell.circleView.cornerRadius = (UIScreen.main.bounds.width - 80) / 8
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addedMemberCell", for: indexPath) as! AddedMemberCell
            let person = selectedPersonsForGroup[indexPath.row - 1]
            cell.index = indexPath.row
            cell.bindData(person: person)
            cell.loadImage(person: person, collectionView: collectionView
                , indexPath: indexPath)
            cell.callbackCancelTapped = {(index) in
                selectedPersonsForGroup.remove(at: index - 1)
                self.refreshCollectionView()
            }
            return cell
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedPersonsForGroup = []
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.refreshCollectionView()
    }
    @objc func refreshCollectionView(){
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 80) / 4
        let height = width + 40
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if let viewController = storyboard?.instantiateViewController(identifier: "addParticipantVC") as? AddParticipantsVC {
                viewController.ownerVC = self
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
            print("No image found")
            return
        }
        let data = image.jpegData(compressionQuality: 1.0)
        groupPicture = UIImage(data: data! as Data)
        DispatchQueue.main.async{
            self.groupImageView.image = self.groupPicture
            self.cameraButton.setImage(nil, for: .normal)
        }
        // print out the image size as a test
        // print(correct_image?.size)
        //uploadPicture(image: correct_image!)
    }

    @IBAction func onSaveTapped(_ sender: Any) {
        
        let name = groupNameTextField.text ?? ""
        if name.count == 0 {
            //Util.showAlert(vc: self, "Please enter the name", "")
            return
        }
        if selectedPersonsForGroup.count == 0 {
            //Util.showAlert(vc: self, "Please select users", "")
            return
        }
        // Append user id
        self.selectedUsers.removeAll()
        for item in selectedPersonsForGroup {
            if self.selectedUsers.contains(item.objectId) == false{
                self.selectedUsers.append(item.objectId)
            }
        }
        self.selectedUsers.append(AuthUser.userId())
        let group = Groups.create(name, userIds: self.selectedUsers)
        
        if self.groupPicture != nil {
            // upload picture
            if let data = groupPicture?.jpegData(compressionQuality: 0.6) {
                //self.hud.textLabel.text = "Creating new group..."
                //self.hud.show(in: self.view, animated: true)
                MediaUpload.group(group.objectId, data: data, completion: { error in
                    if (error == nil) {
                        MediaDownload.saveGroup(group.objectId, data: data)
                        group.update(pictureAt: Date().timestamp())
                        //self.hud.dismiss()
                        self.dismiss(animated: true) {
                            self.delegate?.onGroupCreated(group: group)
                        }
                    } else {
                        DispatchQueue.main.async {
                            //self.hud.textLabel.text = "Picture upload error."
                            //self.hud.show(in: self.view, animated: true)
                        }
                        //self.hud.dismiss(afterDelay: 1.0, animated: true)
                    }
                })
            }
        }
        else{
            self.dismiss(animated: true) {
                self.delegate?.onGroupCreated(group: group)
            }
        }
    }
    
}
