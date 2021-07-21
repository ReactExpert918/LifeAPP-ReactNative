//
//  ImagePicker.swift
//

import UIKit

//MARK: - @Protocol ImagePickerDelegate
public protocol ImagePickerDelegate: class {
    func didSelect(_ image: UIImage?)
}

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(_ presentationViewController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController =  presentationViewController
       
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = false
        self.pickerController.mediaTypes = ["public.image"]
                
        self.delegate = delegate
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            
            DispatchQueue.main.async {
                // make sure to call this present explicitly on the main thread
                self.presentationController?.present(self.pickerController, animated: true)
            }
            
        }
    }
        
    public func present(from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.setTintColor(.black)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        /*
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }*/
        
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //alertController.setTintColor(.myThemeColor)

        self.presentationController?.present(alertController, animated: true)
    }
        
    fileprivate func pickerController(_ controller: UIImagePickerController, image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image)
    }
}

// MARK: - ImagePickerControllerDelegate
extension ImagePicker: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, image: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // use this to get the edited image
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, image: nil)
        }
        
        self.pickerController(picker, image: image)
    }
}

// MARK: - UINavigationControllerDelegate
extension ImagePicker: UINavigationControllerDelegate {
}
