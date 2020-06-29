//
//  ChatViewController.swift
//  Life
//
//  Created by XianHuang on 6/26/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import InputBarAccessoryView
class ChatViewController: UIViewController {

    private var messages = realm.objects(Message.self).filter(falsepredicate)
    
    @IBOutlet weak var tableView: UITableView!
    
    var messageInputBar = InputBarAccessoryView()
    private var keyboardManager = KeyboardManager()
    
    private var heightKeyboard: CGFloat = 0
    private var keyboardWillShow = false
    
    private var messageToDisplay: Int = 12
    
//    private var rcmessages: [String: RCMessage] = [:]
    private var rcmessages: [RCMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

        tableView.delegate = self
        tableView.dataSource = self
        //tableView.tableHeaderView = viewLoadEarlier
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
        configureMessageInputBar()
        
        let message1 = RCMessage()
        message1.type = MESSAGE_TYPE.MESSAGE_TEXT
        message1.text = "Hello World"
        rcmessages.append(message1)
        
        let message2 = RCMessage()
        message2.type = MESSAGE_TYPE.MESSAGE_TEXT
        message2.text = "Hello World"
        rcmessages.append(message2)
        
        let message3 = RCMessage()
        message3.type = MESSAGE_TYPE.MESSAGE_TEXT
        message3.text = "Hello This is my test message"
        message3.incoming = true
        message3.outgoing = false
        rcmessages.append(message3)
        
        let message4 = RCMessage()
        message4.type = MESSAGE_TYPE.MESSAGE_TEXT
        message4.text = "Hello World"
        rcmessages.append(message4)

        let message5 = RCMessage()
        message5.type = MESSAGE_TYPE.MESSAGE_TEXT
        message5.text = "Hello World"
        rcmessages.append(message5)
        
        tableView.reloadData()

    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        //layoutTableView()
    }

    // MARK: - Message methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func messageTotalCount() -> Int {

        return messages.count
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func messageLoadedCount() -> Int {

        return min(messageToDisplay, messageTotalCount())
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func messageAt(_ indexPath: IndexPath) -> Message {

        let offset = messageTotalCount() - messageLoadedCount()
        let index = indexPath.section + offset

        return messages[index]
    }
    // MARK: - Message methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func rcmessageAt(_ indexPath: IndexPath) -> RCMessage {
        return rcmessages[indexPath.row]
/*
        let message = messageAt(indexPath)
        if let rcmessage = rcmessages[message.objectId] {
            rcmessage.update(message)
            loadMedia(rcmessage)
            return rcmessage
        }

        let rcmessage = RCMessage(message: message)
        rcmessages[message.objectId] = rcmessage
        loadMedia(rcmessage)
        return rcmessage
 */
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadMedia(_ rcmessage: RCMessage) {

        if (rcmessage.mediaStatus != MediaStatus.MEDIASTATUS_UNKNOWN)     { return }
        if (rcmessage.incoming) && (rcmessage.isMediaQueued) { return }
        if (rcmessage.incoming) && (rcmessage.isMediaFailed) { return }

        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { RCPhotoLoader.start(rcmessage, in: tableView)        }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { RCVideoLoader.start(rcmessage, in: tableView)        }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { RCAudioLoader.start(rcmessage, in: tableView)        }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_LOCATION)    { RCLocationLoader.start(rcmessage, in: tableView)    }
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
    func textFooterLower(_ indexPath: IndexPath) -> String? {

        return nil
    }
    // MARK: - Menu controller methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func menuItems(_ indexPath: IndexPath) -> [RCMenuItem]? {

        return nil
    }

    // MARK: - User actions (bubble tap)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionTapBubble(_ indexPath: IndexPath) {

    }

    // MARK: - User actions (avatar tap)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionTapAvatar(_ indexPath: IndexPath) {

    }
    // MARK: - User actions (input panel)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionAttachMessage() {

    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionSendMessage(_ text: String) {

    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func typingIndicatorUpdate() {

    }
    // MARK: - Helper methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func layoutTableView() {

        let widthView    = view.frame.size.width
        let heightView    = view.frame.size.height

        let leftSafe    = view.safeAreaInsets.left
        let rightSafe    = view.safeAreaInsets.right

        let heightInput = messageInputBar.bounds.height

        let widthTable = widthView - leftSafe - rightSafe
        let heightTable = heightView - heightInput - heightKeyboard

        tableView.frame = CGRect(x: leftSafe, y: 0, width: widthTable, height: heightTable)
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func scrollToBottom(animated: Bool) {

        if (tableView.numberOfSections > 0) {
//            let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
//            tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
    // MARK: - Keyboard methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func keyboardWillShow(_ notification: Notification?) {

        if (heightKeyboard != 0) { return }

        keyboardWillShow = true

        if let info = notification?.userInfo {
            if let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                if let keyboard = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration)  {
                        if (self.keyboardWillShow) {
                            self.heightKeyboard = keyboard.size.height
                            self.layoutTableView()
                            self.scrollToBottom(animated: true)
                        }
                    }
                }
            }
        }

        UIMenuController.shared.menuItems = nil
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func keyboardWillHide(_ notification: Notification?) {

        heightKeyboard = 0
        keyboardWillShow = false

        layoutTableView()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func dismissKeyboard() {

        messageInputBar.inputTextView.resignFirstResponder()
    }
    func configureMessageInputBar() {

        view.addSubview(messageInputBar)

        keyboardManager.bind(inputAccessoryView: messageInputBar)
        keyboardManager.bind(to: tableView)

        messageInputBar.delegate = self

        let button = InputBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.setSize(CGSize(width: 36, height: 36), animated: false)

        button.onKeyboardSwipeGesture { item, gesture in
            if (gesture.direction == .left)     { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)        }
            if (gesture.direction == .right) { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)    }
        }

        button.onTouchUpInside { item in
            self.actionAttachMessage()
        }

        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)

        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill")
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)

        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)

        messageInputBar.inputTextView.isImagePasteEnabled = false
    }
    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatViewController: UITableViewDataSource {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 5
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
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
extension ChatViewController: UITableViewDelegate {

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
extension ChatViewController: InputBarAccessoryViewDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {

        if (text != "") {
            typingIndicatorUpdate()
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom(animated: true)
        }
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
