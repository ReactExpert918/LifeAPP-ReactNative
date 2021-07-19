//
//

import Foundation
import UIKit

// MARK: - UIApplication Extension
extension UIApplication {
    
    var keyWindow: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        }
    }
    
    class func safeAreaBottom() -> CGFloat {
        let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
        let bottomPadding: CGFloat
        if #available(iOS 11.0, *) {
            bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
        } else {
            bottomPadding = 0.0
        }
        return bottomPadding
    }

    class func safeAreaTop() -> CGFloat {
        let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
        let topPadding: CGFloat
        if #available(iOS 11.0, *) {
            topPadding = window?.safeAreaInsets.top ?? 0.0
        } else {
            topPadding = 0.0
        }
        return topPadding
    }
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }

        return viewController
    }
}
