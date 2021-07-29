//
//  UILabel+Ex.swift
//

import UIKit

class ThemeLabel: UILabel {
    override func didMoveToWindow() {
        
        self.font = UIFont.init(name: MyFont.MontserratRegular, size: 17)
        self.textAlignment = .left
    }
}

class TitleLabel: UILabel {
    override func didMoveToWindow() {
        
        self.font = UIFont(name: MyFont.MontserratBold, size: 20)
        self.textAlignment = .left
    }
}

class Regular15Label: UILabel {
    override func didMoveToWindow() {
        self.font = UIFont(name: MyFont.MontserratRegular, size: 15)
        self.textAlignment = .left
    }
}
