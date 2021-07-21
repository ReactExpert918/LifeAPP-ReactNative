//
//

import UIKit

class ThemeTextField: UITextField {
    override func didMoveToWindow() {
        
        self.font = UIFont.init(name: MyFont.MontserratRegular, size: 16)
        
        /*
        //took off the shadow
        self.layer.shadowColor = UIColor.systemGray3.cgColor
        self.layer.shadowOpacity = 1

        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 3
        
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
         */
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

class RectangleTextField: UITextField {
    override func didMoveToWindow() {
        
        self.font = UIFont.init(name: MyFont.MontserratRegular, size: 16)
        
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.systemGray2.cgColor
        
        self.layer.shadowColor = UIColor.systemGray3.cgColor
        self.layer.shadowOpacity = 1

        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 3
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

class RectangleTextView: UITextView {
    override func didMoveToWindow() {
        
        self.font = UIFont.init(name: MyFont.MontserratRegular, size: 16)
        
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.systemGray2.cgColor
        //took off the shadow
        self.layer.shadowColor = UIColor.systemGray3.cgColor
        self.layer.shadowOpacity = 1

        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 3
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
