//
//  RCMesssageView.swift
//  Life
//
//  Created by Jaelhorton on 7/15/20.
//  Copyright © 2020 Zed. All rights reserved.
//

import UIKit
import InputBarAccessoryView

class RCMessagesView: UIViewController {

    var refreshControl = UIRefreshControl()
    var tableView = UITableView()
    var messageInputBar = InputBarAccessoryView()

    private var keyboardManager = KeyboardManager()

    private var isTyping = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(RCHeaderUpperCell.self, forCellReuseIdentifier: "RCHeaderUpperCell")
        tableView.register(RCHeaderLowerCell.self, forCellReuseIdentifier: "RCHeaderLowerCell")

        tableView.register(RCMessageTextCell.self, forCellReuseIdentifier: "RCMessageTextCell")
        tableView.register(RCMessageEmojiCell.self, forCellReuseIdentifier: "RCMessageEmojiCell")
        tableView.register(RCMessagePhotoCell.self, forCellReuseIdentifier: "RCMessagePhotoCell")
        tableView.register(RCMessageVideoCell.self, forCellReuseIdentifier: "RCMessageVideoCell")
        tableView.register(RCMessageAudioCell.self, forCellReuseIdentifier: "RCMessageAudioCell")
        tableView.register(RCMessageLocationCell.self, forCellReuseIdentifier: "RCMessageLocationCell")

        tableView.register(RCFooterUpperCell.self, forCellReuseIdentifier: "RCFooterUpperCell")
        tableView.register(RCFooterLowerCell.self, forCellReuseIdentifier: "RCFooterLowerCell")

        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.tableHeaderView = viewLoadEarlier
        
        refreshControl.addTarget(self, action: #selector(actionLoadEarlier), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        self.view.addSubview(tableView)
        configureMessageInputBar()
        
    }
    func configureMessageInputBar() {

        view.addSubview(messageInputBar)
        keyboardManager.bind(inputAccessoryView: messageInputBar)
        keyboardManager.bind(to: tableView)

        messageInputBar.delegate = self
        
        /*
        let button = InputBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.setSize(CGSize(width: 36, height: 36), animated: false)

        button.onKeyboardSwipeGesture { item, gesture in
            if (gesture.direction == .left)     { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)        }
            if (gesture.direction == .right) { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)    }
        }
         */
        let cameraButton = InputBarButtonItem()
        cameraButton.image = UIImage(named: "ic_camera")
        cameraButton.setSize(CGSize(width: 34, height: 36), animated: false)
        //cameraButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        cameraButton.onKeyboardSwipeGesture { item, gesture in
            if (gesture.direction == .left)     { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)        }
            if (gesture.direction == .right) { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)    }
        }

        cameraButton.onTouchUpInside { item in
            self.actionOpenCamera()
        }

        let galleryButton = InputBarButtonItem()
        galleryButton.image = UIImage(named: "ic_gallery")
        galleryButton.setSize(CGSize(width: 30, height: 36), animated: false)
        //galleryButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        galleryButton.onKeyboardSwipeGesture { item, gesture in
            if (gesture.direction == .left)     { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)        }
            if (gesture.direction == .right) { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)    }
        }

        galleryButton.onTouchUpInside { item in
            self.actionOpenGallery()
        }

        messageInputBar.setStackViewItems([cameraButton, galleryButton], forStack: .left, animated: false)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = false
        messageInputBar.leftStackView.spacing = 8

        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(named: "ic_send")
        messageInputBar.sendButton.setSize(CGSize(width: 32, height: 36), animated: false)

        messageInputBar.setLeftStackViewWidthConstant(to: 72, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)

        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 5)
        messageInputBar.inputTextView.placeholder = "Enter a message"
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.isImagePasteEnabled = false
    }
    func dismissKeyboard() {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func actionTapBubble(_ indexPath: IndexPath) {

    }
    // MARK: - User actions (avatar tap)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionTapAvatar(_ indexPath: IndexPath) {

    }
    
    // MARK: - Menu controller methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func menuItems(_ indexPath: IndexPath) -> [RCMenuItem]? {

        return nil
    }
    // MARK: - User actions (load earlier)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionLoadEarlier() {
        
    }
    // MARK: - Message methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func rcmessageAt(_ indexPath: IndexPath) -> RCMessage {

        return RCMessage()
    }
    // MARK: - Avatar methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func avatarInitials(_ indexPath: IndexPath) -> String {

        return ""
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func avatarImage(_ indexPath: IndexPath) -> UIImage? {

        return nil
    }

    // MARK: - Header, Footer methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func textHeaderUpper(_ indexPath: IndexPath) -> String? {

        return nil
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func textHeaderLower(_ indexPath: IndexPath) -> String? {

        return nil
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func textFooterUpper(_ indexPath: IndexPath) -> String? {

        return nil
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func textFooterLower(_ indexPath: IndexPath) -> UIImage? {

        return nil
    }
    // MARK: - Typing indicator methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func typingIndicatorShow(_ typing: Bool, text: String = "typing...") {

        if (typing == true) && (isTyping == false) {
//            textTitle = typingLabel?.text
//            typingLabel?.text = text
        }
        if (typing == false) && (isTyping == true) {
//            typingLabel?.text = textTitle
        }
        isTyping = typing
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func typingIndicatorUpdate() {

    }
    
    func actionOpenCamera() {
        
    }
    
    func actionOpenGallery() {
        
    }
    func actionSendMessage(_ text: String) {

    }
}


// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView: UITableViewDataSource {
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 5
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {

        return 0        
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.row == 0)                        { return cellForHeaderUpper(tableView, at: indexPath)        }
        if (indexPath.row == 1)                        { return cellForHeaderLower(tableView, at: indexPath)        }

        if (indexPath.row == 2) {
            let rcmessage = rcmessageAt(indexPath)
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_TEXT)        { return cellForMessageText(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_EMOJI)    { return cellForMessageEmoji(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { return cellForMessagePhoto(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { return cellForMessageVideo(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { return cellForMessageAudio(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_LOCATION)    { return cellForMessageLocation(tableView, at: indexPath)    }
        }

        if (indexPath.row == 3)                        { return cellForFooterUpper(tableView, at: indexPath)        }
        if (indexPath.row == 4)                        { return cellForFooterLower(tableView, at: indexPath)        }

        return UITableViewCell()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForHeaderUpper(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCHeaderUpperCell", for: indexPath) as! RCHeaderUpperCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForHeaderLower(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCHeaderLowerCell", for: indexPath) as! RCHeaderLowerCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForMessageText(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageTextCell", for: indexPath) as! RCMessageTextCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForMessageEmoji(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageEmojiCell", for: indexPath) as! RCMessageEmojiCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForMessagePhoto(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessagePhotoCell", for: indexPath) as! RCMessagePhotoCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForMessageVideo(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageVideoCell", for: indexPath) as! RCMessageVideoCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForMessageAudio(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageAudioCell", for: indexPath) as! RCMessageAudioCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForMessageLocation(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageLocationCell", for: indexPath) as! RCMessageLocationCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForFooterUpper(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCFooterUpperCell", for: indexPath) as! RCFooterUpperCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func cellForFooterLower(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCFooterLowerCell", for: indexPath) as! RCFooterLowerCell
        cell.bindData(self, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView: UITableViewDelegate {
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        view.tintColor = UIColor.clear
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {

        view.tintColor = UIColor.clear
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if (indexPath.row == 0)                        { return RCHeaderUpperCell.height(self, at: indexPath)        }
        if (indexPath.row == 1)                        { return RCHeaderLowerCell.height(self, at: indexPath)        }

        if (indexPath.row == 2) {
            let rcmessage = rcmessageAt(indexPath)
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_TEXT)        { return RCMessageTextCell.height(self, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_EMOJI)    { return RCMessageEmojiCell.height(self, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { return RCMessagePhotoCell.height(self, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { return RCMessageVideoCell.height(self, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { return RCMessageAudioCell.height(self, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_LOCATION)    { return RCMessageLocationCell.height(self, at: indexPath)    }
        }

        if (indexPath.row == 3)                        { return RCFooterUpperCell.height(self, at: indexPath)        }
        if (indexPath.row == 4)                        { return RCFooterLowerCell.height(self, at: indexPath)        }

        return 0
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return RCDefaults.sectionHeaderMargin
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        return RCDefaults.sectionFooterMargin
    }
}
extension RCMessagesView: InputBarAccessoryViewDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {

        if (text != "") {
            typingIndicatorUpdate()
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom(animated: true)
        }
        */
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                actionSendMessage(text)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}

