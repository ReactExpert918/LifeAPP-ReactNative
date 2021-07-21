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
