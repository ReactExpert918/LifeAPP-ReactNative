//
//  UIImageView+Extension.swift
//

import AVFoundation
import UIKit
import Kingfisher

typealias ImageViewActivityIndicator = Kingfisher.IndicatorType

extension UIImageView {
    
    var activityIndicator: ImageViewActivityIndicator {
        get {
            return self.kf.indicatorType
        }
        set {
            self.kf.indicatorType = newValue
        }
    }
    
    var activityIndicatorColor: UIColor? {
        get {
            return (self.kf.indicator?.view as? UIActivityIndicatorView)?.color
        }
        set {
            (self.kf.indicator?.view as? UIActivityIndicatorView)?.color = newValue
        }
    }
    
    func loadImageFromUrl(_ url: String) {
        if url.isEmpty {
            self.kf.setImage(with: URL(string: ""), placeholder: UIImage(systemName: "photo"))
        } else {
            self.kf.setImage(with: URL(string: url), placeholder: UIImage(systemName: "photo"))
        }
    }
    
    func loadImageWithURL(withURL url: String, cacheKey key: String? = nil, placeholder: String, completion: ((UIImage?) -> Void)? = nil) {
        let url = URL(string: url)
        let provider = LocalFileImageDataProvider(fileURL: url!, cacheKey: key)
        
        if completion == nil {
            self.kf.setImage(with: provider, placeholder: UIImage(named: placeholder))
            
        } else {
            self.kf.setImage(with: provider, placeholder: UIImage(named: placeholder)) { result in
                switch result {
                case .success(let value):
                    // From where the image was retrieved:
                    // - .none - Just downloaded.
                    // - .memory - Got from memory cache.
                    // - .disk - Got from disk cache.
//                    print(value.cacheType)
                    completion?(value.image)
                    return
                    
                case .failure(let error):
                    print(error)
                    completion?(nil)
                    return
                }
            }
        }
        
    }
}
