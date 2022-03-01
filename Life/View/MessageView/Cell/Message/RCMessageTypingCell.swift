//
//  RCMessageTypingCell.swift
//  Life
//
//  Created by Yansong Wang on 2022/2/23.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import Kingfisher

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCMessageTypingCell: UITableViewCell {

    var indexPath: IndexPath!
    var messagesView: ChatViewController!

    private var imageAvatar: UIImageView!
    private var imageTyping: AnimatedImageView!
    private var viewStatus: UIView!

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {
        self.messagesView = messagesView
        self.indexPath = indexPath
        if (self.imageTyping == nil) {
            self.imageTyping = AnimatedImageView()
            self.contentView.addSubview(self.imageTyping)
            let path = Bundle.main.url(forResource: "ic_istyping", withExtension: "gif")
            self.imageTyping.kf.setImage(with: path)
        }
        
        if (imageAvatar == nil) {
            imageAvatar = UIImageView()
            imageAvatar.layer.masksToBounds = true
            imageAvatar.layer.cornerRadius = 23
            imageAvatar.backgroundColor = UIColor.clear
            imageAvatar.isUserInteractionEnabled = true
            contentView.addSubview(imageAvatar)
            avatarGestureRecognizer()
            imageAvatar.image = self.messagesView.avatarImage(indexPath)
        }
        
        if (viewStatus == nil) {
            viewStatus = UIView()
            viewStatus.layer.cornerRadius = 6
            viewStatus.layer.borderWidth = 2
            viewStatus.layer.borderColor = UIColor.white.cgColor
            viewStatus.backgroundColor = UIColor(hexString: "#6cc93e")
            contentView.addSubview(viewStatus)
        }
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    override func layoutSubviews() {
        
        let diameter = 46
        let xAvatar = 12
        imageAvatar.frame = CGRect(x: xAvatar, y: 0, width: diameter, height: diameter)
        
        viewStatus.frame = CGRect(x: 45, y: 0, width: 12, height: 12)
        
        self.imageTyping.frame = CGRect(x: 2 * xAvatar + diameter, y: 8, width: 70, height: 30)
    }
    
    func avatarGestureRecognizer() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapAvatar))
        imageAvatar.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    @objc func actionTapAvatar() {

        messagesView.dismissKeyboard()
        messagesView.actionTapAvatar(indexPath)
    }
}
