//
//  PhotoSelectionView.swift
//  Life
//
//  Created by Yansong Wang on 2022/3/12.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import RSKImageCropper

protocol PhotoSelectionViewDelegate {
    func didSelectPhoto(image: UIImage?)
}

class PhotoSelectionView: UIViewController {
    var image: UIImage?
    var delegate: PhotoSelectionViewDelegate?
    
    @IBOutlet weak var buttonDone: UIButton!
    
    @IBOutlet weak var buttonCrop: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonCrop.setTitle("", for: .normal)
        self.buttonDone.setTitle("", for: .normal)
        
        if let image = image {
            self.imageView.image = image
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override var prefersStatusBarHidden: Bool {

        return false
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override var preferredStatusBarStyle: UIStatusBarStyle {

        return .lightContent
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionDone(_ sender: Any) {
        if let delegate = delegate {
            delegate.didSelectPhoto(image: self.imageView.image)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionCrop(_ sender: Any) {
        if let image = self.image {
            
            let imageCropVC = RSKImageCropViewController(image: image, cropMode: .square)
            imageCropVC.delegate = self
            self.navigationController?.pushViewController(imageCropVC, animated: true)
        }
        
    }
    
}

extension PhotoSelectionView: RSKImageCropViewControllerDelegate {
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        print("Canceled")
        self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.imageView.image = croppedImage
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
