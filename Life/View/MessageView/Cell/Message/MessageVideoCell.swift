//
//  MessageVideoCell.swift
//  Life
//
//  Created by top Dev on 30.08.2021.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MessageVideoCell: UITableViewCell {
    @IBOutlet weak var uivContent: UIView!
    @IBOutlet weak var uivYou: UIView!
    @IBOutlet weak var uivMe: UIView!
    
    @IBOutlet weak var imvPartner: UIImageView!
    @IBOutlet weak var imvMe: UIImageView!
    
    @IBOutlet weak var uivYouTxt: UIView!
    @IBOutlet weak var uivMeTxt: UIView!
    
    @IBOutlet weak var lblYouTime: UILabel!
    @IBOutlet weak var lblMeTime: UILabel!
    
    @IBOutlet weak var imvMeTick: UIImageView!
    
    @IBOutlet weak var uivYouStatus: UIView!
    @IBOutlet weak var uivMeStatus: UIView!

    @IBOutlet weak var videoViewMe: UIView!
    @IBOutlet weak var videoViewYou: UIView!

    @IBOutlet weak var videoContainer: UIView!
    
    var indexPath: IndexPath!
    var messagesView: ChatViewController!
    var type = 0
    var searchString = ""
    var videoView: VideoView!
    
    func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath, isPlaying: Bool) {
        
        self.indexPath = indexPath
        self.messagesView = messagesView
        let rcmessage = messagesView.rcmessageAt(indexPath)
        
        let bubbleGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapBubble))
        rcmessage.incoming ? uivYouTxt.addGestureRecognizer(bubbleGesture) : uivMeTxt.addGestureRecognizer(bubbleGesture)
        bubbleGesture.cancelsTouchesInView = false
        
        let url = URL(fileURLWithPath: rcmessage.videoPath)

        if isPlaying {

            videoContainer.isHidden = false
            uivYou.isHidden = true
            uivMe.isHidden = true
            
            videoContainer.layer.cornerRadius = videoContainer.bounds.width / 2
            videoContainer.clipsToBounds = true

            setupPlaying(videoUrl: url, containerView: videoContainer, mute: false, customActionDone: playerDone)
            
        } else if rcmessage.incoming {
            
            videoContainer.isHidden = true
            uivYou.isHidden = false
            uivMe.isHidden = true
            
            uivYouStatus.layer.cornerRadius = 6
            uivYouStatus.layer.borderWidth = 2
            uivYouStatus.layer.borderColor = UIColor.white.cgColor
            
            videoViewYou.layer.cornerRadius = 80
            videoViewYou.layer.borderWidth = 1
            videoViewYou.layer.borderColor = COLORS.PRIMARY?.cgColor
            videoViewYou.clipsToBounds = true
            
            imvPartner.image = messagesView.avatarImage(indexPath)
            
            lblYouTime.textAlignment = .left
            lblYouTime.text = messagesView.textHeaderLower(indexPath)
            
            setupPlaying(videoUrl: url, containerView: videoViewYou, mute: true, customActionDone: resetPlayer)
            
            addGestures(incoming: rcmessage.incoming)

        } else {
            
            videoContainer.isHidden = true
            uivYou.isHidden = true
            uivMe.isHidden = false
            
            uivMeStatus.layer.cornerRadius = 6
            uivMeStatus.layer.borderWidth = 2
            uivMeStatus.layer.borderColor = UIColor.white.cgColor
            
            videoViewMe.layer.cornerRadius = 80
            videoViewMe.layer.borderWidth = 1
            videoViewMe.layer.borderColor = COLORS.PRIMARY?.cgColor
            videoViewMe.clipsToBounds = true
            
            imvMe.image = messagesView.avatarImage(indexPath)
            
            lblMeTime.textAlignment = .left
            lblMeTime.text = messagesView.textHeaderLower(indexPath)
            
            setupPlaying(videoUrl: url, containerView: videoViewMe, mute: true, customActionDone: resetPlayer)
            
            if let image = messagesView.textFooterLower(indexPath){
                imvMeTick.isHidden = false
                imvMeTick.image = image
            } else {
                imvMeTick.isHidden = true
                imvMeTick.image = nil
            }
            
            addGestures(incoming: rcmessage.incoming)
        }

    }
    
    private func addGestures(incoming: Bool) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionContentView))
        uivContent.addGestureRecognizer(tapGesture)
        
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongBubble(_:)))
        incoming ? uivYouTxt.addGestureRecognizer(longGesture) : uivMeTxt.addGestureRecognizer(longGesture)
    }
    // MARK: - User actions
    @objc func actionTapBubble() {
        messagesView.dismissKeyboard()
        messagesView.actionTapBubble(indexPath)
    }
    
    @objc func actionContentView() {
        messagesView.dismissKeyboard()
        //messagesView.actionTapBubble(indexPath)
    }
    
    @objc func actionTapAvatar() {
        messagesView.dismissKeyboard()
        messagesView.actionTapAvatar(indexPath)
    }
    
    @objc func actionLongBubble(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            actionMenu()
            break
        case .changed:
            break
        case .ended:
            break
        case .possible:
            break
        case .cancelled:
            break
        case .failed:
            break
        default:
            break
        }
    }
    
    func actionMenu() {
        if (messagesView.messageInputBar.inputTextView.isFirstResponder == false) {
            let menuController = UIMenuController.shared
            menuController.menuItems = messagesView.menuItems(indexPath)
            menuController.showMenu(from: contentView, rect: uivMeTxt.frame)
        } else {
            messagesView.messageInputBar.inputTextView.resignFirstResponder()
        }
    }
    
    private func setupPlaying(videoUrl: URL,
                              containerView: UIView,
                              mute: Bool,
                              customActionDone: (() -> ())? = nil) {
        closePlayer()
        videoView = VideoView(url: videoUrl, showsPlaybackControls: false, mute: mute)
        guard let videoUIView = videoView.view else { return }
        
        videoView.customActionDone = customActionDone
        
        messagesView.addChild(videoView)
        containerView.addSubview(videoUIView)
        
        videoView.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraint(NSLayoutConstraint(item: videoUIView,
                                                       attribute: .leading,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .leading,
                                                       multiplier: 1.0,
                                                       constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: videoUIView,
                                                       attribute: .trailing,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .trailing,
                                                       multiplier: 1.0,
                                                       constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: videoUIView,
                                                       attribute: .top,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .top,
                                                       multiplier: 1.0,
                                                       constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: videoUIView,
                                                       attribute: .bottom,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .bottom,
                                                       multiplier: 1.0,
                                                       constant: 0.0))
        
        videoView.didMove(toParent: messagesView)
        videoView.view.layoutIfNeeded()
    }
    
    private func closePlayer() {
        guard let videoView = videoView else { return }
        videoView.didMove(toParent: nil)
        videoView.view.removeFromSuperview()
        videoView.removeFromParent()
        self.videoView = nil
    }
    private func playerDone() {
        closePlayer()
        messagesView.pauseVideoOnTapBubble(indexPath)
    }
    private func resetPlayer() {
        videoView.resetPlayer()
    }
}

