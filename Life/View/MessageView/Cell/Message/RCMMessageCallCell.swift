//
//  RCMMessageCallCell.swift
//  Life
//
//  Created by top Dev on 17.08.2021.
//  Copyright © 2021 Zed. All rights reserved.
//


import UIKit

//-------------------------------------------------------------------------------------------------------------------------------------------------
class RCMMessageCallCell: UITableViewCell {

    private var imvCall: UIImageView!
    private var labelContent: UILabel!
    var indexPath: IndexPath!
    var messagesView: ChatViewController!

    var viewBubble: UIView!
    private var objectionableMark: UIImageView!
    private var imageAvatar: UIImageView!
    private var labelTimeText: UILabel!
    private var viewStatus: UIView!
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {
        
        self.indexPath = indexPath
        self.messagesView = messagesView
        let rcmessage = messagesView.rcmessageAt(indexPath)
        backgroundColor = UIColor.clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionContentView))
        contentView.addGestureRecognizer(tapGesture)
        
        
        if (viewBubble == nil) {
            viewBubble = UIView()
            //viewBubble.layer.cornerRadius = RCDefaults.bubbleRadius
            contentView.addSubview(viewBubble)
            bubbleGestureRecognizer()
        }
        
        viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.callBubbleColorIncoming : RCDefaults.callBubbleColorOutgoing

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
            contentView.addSubview(labelTimeText)
        }

        labelTimeText.textAlignment = rcmessage.incoming ? .left : .right
        labelTimeText.text = messagesView.textHeaderLower(indexPath)
        
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
        
        print("Call statues", rcmessage.callStatus)

        if (rcmessage.callStatus == .MISSED_CALL) { imvCall.image = RCDefaults.callMissed        }
        if (rcmessage.callStatus == .CANCELLED_CALL) { imvCall.image = RCDefaults.callCancelled    }

        labelContent.textColor = rcmessage.incoming ? RCDefaults.audioTextColorIncoming : RCDefaults.audioTextColorOutgoing
//        labelContent.text = rcmessage.incoming ? "Cancelled call".localized : "Missed call".localized
        labelContent.text = rcmessage.text
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rcmessage = messagesView.rcmessageAt(indexPath)
        let widthTable = messagesView.tableView.frame.size.width
        
        let diameter: CGFloat = 46
        
        let xBubble = rcmessage.incoming ? diameter + 20 : (widthTable - diameter - 20 - RCDefaults.callBubbleWidht)
        
        
        
        viewBubble.frame = CGRect(x: xBubble, y: RCDefaults.viewBubbleMarginTop, width: RCDefaults.callBubbleWidht, height: RCDefaults.callBubbleHeight-RCDefaults.viewBubbleMarginTop)
        let xMark = rcmessage.incoming ? RCDefaults.bubbleMarginLeft + RCDefaults.callBubbleWidht + 10 : (widthTable - RCDefaults.bubbleMarginRight - RCDefaults.callBubbleWidht - 20 - 10)
        if(objectionableMark != nil){
            print("display mark")
            objectionableMark.frame = CGRect(x: xMark, y:RCDefaults.viewBubbleMarginTop + 5, width: 18, height: 18 )
        }
        
        
        
        let xAvatar = rcmessage.incoming ? RCDefaults.avatarMarginLeft : (widthTable - RCDefaults.avatarMarginRight - diameter)
        
        imageAvatar.frame = CGRect(x: xAvatar, y: 0, width: diameter, height: diameter)
        viewStatus.frame = CGRect(x: xAvatar + 33, y: 0, width: 12, height: 12)
        
        imvCall.frame = CGRect(x: 10, y: 5, width: 20, height: 20)
        labelContent.frame = CGRect(x: 40, y: 5, width: 90, height: 20)
        
        let time_width = CGFloat(60)
        let time_height = (labelTimeText.text != nil) ? RCDefaults.headerLowerHeight : 0
        let xTime = rcmessage.incoming ? xBubble + RCDefaults.callBubbleWidht + 10 : xBubble - time_width-10
        
        labelTimeText.frame = CGRect(x: xTime, y: RCDefaults.callBubbleHeight - time_height , width: time_width, height: time_height)
        
        let imageName = rcmessage.incoming ? "chat_incoming_mask" : "chat_outgoing_mask"
        guard let image = UIImage(named: imageName) else { return }
        let maskView = UIImageView()
        maskView.image = image.resizableImage(withCapInsets:UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),resizingMode: .stretch)
        maskView.frame = CGRect(x: 0, y: 0, width: viewBubble.frame.size.width, height: viewBubble.frame.size.height)
        //contentView.addSubview(maskView)
        viewBubble.mask = maskView
    }
    
    // MARK: - Gesture recognizer methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func bubbleGestureRecognizer() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapBubble))
        viewBubble.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongBubble(_:)))
        viewBubble.addGestureRecognizer(longGesture)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func avatarGestureRecognizer() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapAvatar))
        imageAvatar.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }

    // MARK: - User actions
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionTapBubble() {

        messagesView.dismissKeyboard()
        messagesView.actionTapBubble(indexPath)
    }
    
    @objc func actionContentView() {

        messagesView.dismissKeyboard()
        //messagesView.actionTapBubble(indexPath)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionTapAvatar() {

        messagesView.dismissKeyboard()
        messagesView.actionTapAvatar(indexPath)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
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

    //---------------------------------------------------------------------------------------------------------------------------------------------
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

