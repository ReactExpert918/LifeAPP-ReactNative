//
//

import UIKit

class ThemeButton: UIButton {
    override func didMoveToWindow() {
        
        self.backgroundColor = .primaryColor
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont(name: MyFont.MontserratSemiBold, size: 16)
        
        /*
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.primaryColor.cgColor
        
        self.layer.shadowColor = UIColor.systemGray3.cgColor
        self.layer.shadowOpacity = 1

        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 3
        */
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

class WhiteButton: UIButton {
    override func didMoveToWindow() {
        
        self.backgroundColor = .white
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.setTitleColor(.primaryColor, for: .normal)
        self.titleLabel?.font = UIFont(name: MyFont.MontserratSemiBold, size: 16)
        
        //took off border and shadow
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.primaryColor.cgColor
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

