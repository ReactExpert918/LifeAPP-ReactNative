//
//  ChatViewController+ImagePicker.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

extension ChatViewController: ImagePickerSheetViewControllerDelegate {

    func selectImage(image: UIImage?) {
        if let image = image {
            let photoConfirView =  self.storyboard?.instantiateViewController(identifier: "PhotoSelectionView") as! PhotoSelectionView

            photoConfirView.image = image
            photoConfirView.delegate = self

            //present(photoConfirView, animated: true)
            self.navigationController?.pushViewController(photoConfirView, animated: false)
        }
    }

    func showAlbum() {
        ImagePicker.photoLibrary(target: self, edit: false)
    }

    func showCamera() {
        ImagePicker.cameraMulti(target: self, edit: false)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //let video = info[.mediaURL] as? URL
        if let photo = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true)
            let photoConfirView =  self.storyboard?.instantiateViewController(identifier: "PhotoSelectionView") as! PhotoSelectionView

            photoConfirView.image = photo
            photoConfirView.delegate = self

            //present(photoConfirView, animated: true)
            self.navigationController?.pushViewController(photoConfirView, animated: false)

            return
        }

        let video = info[.mediaURL] as? URL

        messageSend(text: nil, photo: nil, video: video, audio: nil)
        picker.dismiss(animated: true)
    }
}
