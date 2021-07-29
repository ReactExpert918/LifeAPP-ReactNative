//
//  BaseVC.swift
//
//

import UIKit
import ProgressHUD
import JGProgressHUD

var _currentVC : UIViewController?

class BaseVC: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        _currentVC = self
        
        self.isModalInPresentation = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationController?.isNavigationBarHidden = true
    }
    
    func setTitle(_ title: String) {
        self.navigationItem.title = title
    }
}



extension UIViewController {
    /// show progress/loading view
    func showProgress(_ status: String? = nil) {
        DispatchQueue.main.async {
            ProgressHUD.show(status)
        }
    }
    
    /// hide progress view
    func hideProgress() {
        ProgressHUD.dismiss()
    }
    
    func showToast(_ message: String) {
        UIView.hr_setToastFontName(fontName: MyFont.MontserratRegular)
        UIView.hr_setToastFontColor(color: .white)
        UIView.hr_setToastThemeColor(color: .primaryColor)
        UIApplication.shared.keyWindow!.makeToast(message: message, duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
    }
    
    func showLoading(_ str: String? = nil) {
        UIView.hr_setToastThemeColor(color: .lightGray)
        UIApplication.shared.keyWindow?.makeToastActivity(message: str ?? "")
    }
    
    func hideLoading() {
        UIApplication.shared.keyWindow!.hideToastActivity()
    }
    
    // show alert
    func showAlert(_ title: String!, message: String!, positive: String?, negative: String?, positiveAction: ((_ positiveAciton: UIAlertAction) -> Void)?, negativeAction: ((_ negativeAction: UIAlertAction) -> Void)?, completion:(() -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (negative != nil) {
            alert.addAction(UIAlertAction(title: negative, style: .cancel, handler: negativeAction))
        }
        
        if (positive != nil) {
            alert.addAction(UIAlertAction(title: positive, style: .default, handler: positiveAction))
        }
        
        alert.setTintColor(.black)
        alert.setTitle(UIFont(name: MyFont.MontserratBold, size: 16), color: .black)
        alert.setMessage(UIFont(name: MyFont.MontserratRegular, size: 14), color: .black)
        
        self.present(alert, animated: true, completion: completion)
    }
    
    func showAlert(_ title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (positive != nil) {
            alert.addAction(UIAlertAction(title: positive, style: .default, handler: nil))
        }
        
        if (negative != nil) {
            alert.addAction(UIAlertAction(title: negative, style: .default, handler: nil))
        }
        
        alert.setTintColor(.black)
        alert.setTitle(UIFont(name: MyFont.MontserratMedium, size: 16), color: .black)
        alert.setMessage(UIFont(name: MyFont.MontserratRegular, size: 14), color: .black)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(_ message: String!) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        alert.setTintColor(.black)
        alert.setTitle(UIFont(name: MyFont.MontserratMedium, size: 16), color: .black)
        alert.setMessage(UIFont(name: MyFont.MontserratRegular, size: 14), color: .black)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // show warning for empty data entry
    func showSuccessAlert(_ message: String) {
        
        let alt = SCLAlertView(appearance: Const.shared.alertAppearance)
        
        alt.addButton(R.btnOk, backgroundColor: UIColor.white, textColor: UIColor.primaryColor) {
            // no action
        }
        
        alt.showSuccess(message)
    }
    
    func showFailedAlert(_ message: String) {
        
        let alt = SCLAlertView(appearance: Const.shared.alertAppearance)
        
        alt.addButton(R.btnOk, backgroundColor: UIColor.white, textColor: UIColor.primaryColor) {
            // no action
        }
        
        alt.showError(message)
    }
}

// MARK: - UIAlertViewController+Extension
extension UIAlertController {
    
    /// Set background color
    func setBackgroundColor(_ color: UIColor) {
        guard let bgView = self.view.subviews.first,
            let groupView = bgView.subviews.first,
            let contentView = groupView.subviews.first else {
                return
        }
        
        contentView.backgroundColor = color
    }
    
    /// Set title font and color
    func setTitle(_ font: UIFont? = nil, color: UIColor? = nil) {
        guard let title = self.title else { return }
        
        let attributedString = NSMutableAttributedString(string: title)
        
        if let titleFont = font {
            attributedString.addAttributes([NSAttributedString.Key.font : titleFont], range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor], range: NSMakeRange(0, title.utf8.count))
        }
        
        self.setValue(attributedString, forKey: "attributedTitle")
    }
    
    /// Set message font and color
    func setMessage(_ font: UIFont? = nil, color: UIColor? = nil) {
        guard let message = self.message else { return }
        
        let attributedString = NSMutableAttributedString(string: message)
        
        if let titleFont = font {
            attributedString.addAttributes([NSAttributedString.Key.font : titleFont], range: NSMakeRange(0, message.utf8.count))
        }
        
        if let titleColor = color {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor], range: NSMakeRange(0, message.utf8.count))
        }
        
        self.setValue(attributedString, forKey: "attributedMessage")
    }
    
    /// Set tint color of UIAlertViewController
    func setTintColor(_ color: UIColor) {
        self.view.tintColor = color
    }
    
    
}
