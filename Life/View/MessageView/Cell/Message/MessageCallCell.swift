//
//  RCMMessageCallCell.swift
//  Life
//
//  Created by top Dev on 17.08.2021.
//  Copyright © 2021 Zed. All rights reserved.
//


import UIKit

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MessageCallCell: UITableViewCell {

    private var imvCall: UIImageView!
    private var labelContent: UILabel!
    var indexPath: IndexPath!
    var messagesView: ChatViewController!

    var viewBubble: UIView!
    private var objectionableMark: UIImageView!
    private var imageAvatar: UIImageView!
    private var labelTimeText: UILabel!
    private var viewStatus: UIView!
    func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {
        
        self.indexPath = indexPath
        self.messagesView = messagesView
        let rcmessage = messagesView.rcmessageAt(indexPath)
        backgroundColor = UIColor.clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionContentView))
        contentView.addGestureRecognizer(tapGesture)
        
        
        if (viewBubble == nil) {
            viewBubble = UIView()
            viewBubble.layer.cornerRadius = 20
            viewBubble.layer.shadowColor = UIColor.black.cgColor
            viewBubble.layer.shadowOffset = CGSize(width: 0, height: 1)
            viewBubble.layer.shadowOpacity = 0.2
            viewBubble.layer.shadowRadius = 2.0
            
            contentView.addSubview(viewBubble)
            bubbleGestureRecognizer()
        }
        
        viewBubble.backgroundColor = UIColor.white

        if (imageAvatar == nil) {
            imageAvatar = UIImageView()
            imageAvatar.layer.masksToBounds = true
            imageAvatar.layer.cornerRadius = 23
            imageAvatar.backgroundColor = RCDefaults.avatarBackColor
            imageAvatar.isUserInteractionEnabled = true
            contentView.addSubview(imageAvatar)
            avatarGestureRecognizer()
        }
        
        imageAvatar.image = messagesView.avatarImage(indexPath)
        
        if (viewStatus == nil) {
            viewStatus = UIView()
            viewStatus.layer.cornerRadius = 6
            viewStatus.layer.borderWidth = 2
            viewStatus.layer.borderColor = UIColor.white.cgColor
            viewStatus.backgroundColor = UIColor(hexString: "#6cc93e")
            contentView.addSubview(viewStatus)
        }
        
        if (labelTimeText == nil) {
            labelTimeText = UILabel()
            labelTimeText.font = RCDefaults.headerLowerFont
            labelTimeText.textColor = RCDefaults.headerLowerColor
            viewBubble.addSubview(labelTimeText)
        }

        labelTimeText.textAlignment = rcmessage.incoming ? .left : .right
        if rcmessage.callStatus == .OUTGOING_CALL {
            var durationMessage = ""
            if let duration = Int(rcmessage.text) {
                let mins = duration / 60
                let seconds = duration % 60
                if mins > 0 {
                    durationMessage = "\(mins) min"
                } else {
                    durationMessage = "\(seconds) sec"
                }
            }
            labelTimeText.text = (messagesView.textHeaderLower(indexPath) ?? "") + ", " + durationMessage
        } else {
            labelTimeText.text = messagesView.textHeaderLower(indexPath)
        }
        
        
        if (imvCall == nil) {
            imvCall = UIImageView()
            viewBubble.addSubview(imvCall)
        }

        if (labelContent == nil) {
            labelContent = UILabel()
            labelContent.font = RCDefaults.audioFont
            labelContent.textAlignment = .right
            viewBubble.addSubview(labelContent)
        }
        
        if (rcmessage.callStatus == .MISSED_CALL || rcmessage.callStatus == .CANCELLED_CALL) {
            imvCall.image = RCDefaults.callMissed
            labelContent.textColor = RCDefaults.callIncomingMissed
            labelContent.text = rcmessage.text
        } else {
            imvCall.image = RCDefaults.callOutGoing
            labelContent.text = rcmessage.incoming ? "Incoming Call" : "Outgoing Call"
            labelContent.textColor = RCDefaults.callOutGoingNormal
        }


//        labelContent.textColor = RCDefaults.callIncomingMissed
//        labelContent.text = rcmessage.incoming ? "Cancelled call".localized : "Missed call".localized
//        labelContent.text = rcmessage.incoming ? "Cancelled call".localized : "Missed call".localized
//        labelContent.text = rcmessage.text
        labelContent.textAlignment = rcmessage.incoming ? .left : .right
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rcmessage = messagesView.rcmessageAt(indexPath)
        let widthTable = messagesView.tableView.frame.size.width
        
        let diameter: CGFloat = 46
        
        let xBubble = rcmessage.incoming ? diameter - 20 : (widthTable - diameter + 20 - RCDefaults.callBubbleWidht)
        
        
        
        viewBubble.frame = CGRect(x: xBubble, y: RCDefaults.callBubbleMarginTop, width: RCDefaults.callBubbleWidht, height: RCDefaults.callBubbleHeight)
        
        
        let xAvatar = rcmessage.incoming ? RCDefaults.avatarMarginLeft : (widthTable - RCDefaults.avatarMarginRight - diameter)
        
        imageAvatar.frame = CGRect(x: xAvatar, y: 0, width: diameter, height: diameter)
        viewStatus.frame = CGRect(x: xAvatar + 33, y: 0, width: 12, height: 12)
        
        let xCall = rcmessage.outgoing ? 20 : RCDefaults.callBubbleWidht - RCDefaults.callBubbleImageWidth - 20
        
        imvCall.frame = CGRect(x: xCall, y: 7, width: RCDefaults.callBubbleImageWidth, height: RCDefaults.callBubbleImageHeight)
        
        let xLabel = rcmessage.outgoing ? RCDefaults.callBubbleWidht - 130 : 40
        
        labelContent.frame = CGRect(x: xLabel, y: 5, width: 90, height: 20)
        
        let time_width = CGFloat(120)
        let time_height = (labelTimeText.text != nil) ? RCDefaults.headerLowerHeight : 0
        let xTime = rcmessage.outgoing ? RCDefaults.callBubbleWidht - 160: 40
        
        labelTimeText.frame = CGRect(x: xTime, y: RCDefaults.callBubbleHeight - time_height , width: time_width, height: time_height)
    }
    
    // MARK: - Gesture recognizer methods
    func bubbleGestureRecognizer() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapBubble))
        viewBubble.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongBubble(_:)))
        viewBubble.addGestureRecognizer(longGesture)
    }

    func avatarGestureRecognizer() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapAvatar))
        imageAvatar.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
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
            menuController.showMenu(from: contentView, rect: viewBubble.frame)
        } else {
            messagesView.messageInputBar.inputTextView.resignFirstResponder()
        }
    }
}

