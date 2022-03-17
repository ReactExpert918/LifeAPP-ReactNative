//
//  ImagePickerSheetViewController.swift
//  Life
//
//  Created by Yansong Wang on 2022/3/15.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import Photos

protocol ImagePickerSheetViewControllerDelegate {
    func selectImage(image: UIImage?)
    func showAlbum()
    func showCamera()
}

class ImagePickerSheetViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var allPhotos = PHFetchResult<PHAsset>()
    @IBOutlet weak var buttonCancel: UIButton!
    var delegate: ImagePickerSheetViewControllerDelegate?
    let imageManger = PHImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonCancel.setTitle("", for: .normal)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.getPermission { result in
            if result {
                let options = PHFetchOptions()
                options.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                options.fetchLimit = 10
                
                self.allPhotos = PHAsset.fetchAssets(with: options)
                self.collectionView?.reloadData()
            }
        }
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionAlbum(_ sender: Any) {
        if let delegate = delegate {
            delegate.showAlbum()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func getPermission(completionHanlder: @escaping (_ result: Bool) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completionHanlder(true)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            completionHanlder(status == .authorized)
        }
    }    
}

extension ImagePickerSheetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.contentView.backgroundColor = UIColor.clear
        cell.contentView.removeAllSubViews()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        
        cell.contentView.addSubview(imageView)
        
        if indexPath.row == 0 {
            imageView.image = UIImage(named: "ic_photo_background")
            let iconView = UIImageView(image: UIImage(named: "ic_photo_icon"))
            iconView.center = CGPoint(x: 50, y: 50)
            
            cell.contentView.addSubview(iconView)
        } else {
            let asset = self.allPhotos.object(at: indexPath.row - 1)
            
            self.imageManger.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil) { image, _ in
                imageView.image = image
            }
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allPhotos.count + 1
    }
}

extension ImagePickerSheetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //self.collectionView.deselectItem(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            if let delegate = delegate {
                delegate.showCamera()
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            let asset = self.allPhotos.object(at: indexPath.row - 1)
            
            if let delegate = delegate {
                var first = false
                let option = PHImageRequestOptions()
                option.deliveryMode = .highQualityFormat
                option.resizeMode = .exact
                
                self.imageManger.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { image, _ in
                    if first {
                        return
                    }
                    first = true
                    self.dismiss(animated: true, completion: nil)
                    delegate.selectImage(image: image)                    
                }                
            }
        }
    }
}
