//
//  ChatViewController.swift
//  Life
//
//  Created by XianHuang on 6/26/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift
import ProgressHUD
import InputBarAccessoryView
import IQKeyboardManagerSwift

class ChatViewController: UIViewController {

    private var chatId = ""
    private var recipientId = ""
    
    private var detail: Detail?
    private var details = realm.objects(Detail.self).filter(falsepredicate)
    private var messages = realm.objects(Message.self).filter(falsepredicate)
    
    private var tokenDetails: NotificationToken? = nil
    private var tokenMessages: NotificationToken? = nil


    
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var statusbarView: UIView!
    @IBOutlet weak var topbarView: UIView!

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
        
    var refreshControl = UIRefreshControl()
    
    private var isTyping = false
    private var textTitle: String?
    
    var messageInputBar = InputBarAccessoryView()
    private var keyboardManager = KeyboardManager()
    
    private var heightKeyboard: CGFloat = 0
    private var keyboardWillShow = false
        
    private var rcmessages: [String: RCMessage] = [:]
    private var avatarImages: [String: UIImage] = [:]
    
    private var messageToDisplay: Int = 12

    private var typingCounter: Int = 0
    private var lastRead: Int64 = 0

    private var indexForward: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor(hexString: "#16406F")
        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "Search"
//        searchBar.backgroundColor = UIColor(hexString: "165c90")
        searchBar.set(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setPlaceholder(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setSearchImage(color: UIColor(hexString: "#96B4D2")!)
//        searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        searchBar.tintColor = UIColor(hexString: "#FFFFFF")
        searchBar.delegate = self
        
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
        
        refreshControl.addTarget(self, action: #selector(actionLoadEarlier), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
        configureMessageInputBar()
        
        loadDetail()
        loadDetails()
        loadMessages()
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false

    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        updateTitleDetails()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)

        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        
        if (isMovingFromParent) {
            actionCleanup()
        }
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        layoutTableView()
    }
    // MARK: - User actions (load earlier)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionLoadEarlier() {

        messageToDisplay += 12
        refreshLoadEarlier()
        refreshTableView()
        refreshControl.endRefreshing()
    }
    @IBAction func actionAudioCall(_ sender: Any) {
        let callAudioView = CallAudioView(userId: self.recipientId)
        present(callAudioView, animated: true)
    }
    
    @IBAction func actionVideoCall(_ sender: Any) {
        let callVideoView = CallVideoView(userId: self.recipientId)
        present(callVideoView, animated: true)
    }
    
    // MARK: - Title details methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func updateTitleDetails() {

        if let person = realm.object(ofType: Person.self, forPrimaryKey: recipientId) {
            participantNameLabel.text = person.fullname
//            labelTitle2.text = person.lastActiveText()
        }
    }
    // MARK: - Cleanup methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionCleanup() {

        tokenDetails?.invalidate()
        tokenMessages?.invalidate()

        detail?.update(typing: false)
    }
    func setParticipant(chatId: String, recipientId: String) {
        self.chatId = chatId
        self.recipientId = recipientId
    }
    // MARK: - Realm methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadDetail() {

        let predicate = NSPredicate(format: "chatId == %@ AND userId == %@", chatId, AuthUser.userId())
        detail = realm.objects(Detail.self).filter(predicate).first
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadDetails() {

        let predicate = NSPredicate(format: "chatId == %@ AND userId != %@", chatId, AuthUser.userId())
        details = realm.objects(Detail.self).filter(predicate)

        details.safeObserve({ changes in
            self.refreshTyping()
            self.refreshLastRead()
        }, completion: { token in
            self.tokenDetails = token
        })
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadMessages() {

        let predicate = NSPredicate(format: "chatId == %@ AND isDeleted == NO", chatId)
        messages = realm.objects(Message.self).filter(predicate).sorted(byKeyPath: "createdAt")

        messages.safeObserve({ changes in
            switch changes {
                case .initial:
                    self.refreshLoadEarlier()
                    self.refreshTableView()
                    self.scrollToBottom()
                case .update(_, let delete, let insert, _):
                    self.messageToDisplay -= delete.count
                    self.messageToDisplay += insert.count
                    self.refreshTableView()
                    if (insert.count != 0) {
                        self.scrollToBottom()
                        self.playIncoming()
                    }
                default: break
            }
        }, completion: { token in
            self.tokenMessages = token
        })
    }
    // MARK: - Refresh methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshLoadEarlier() {
        loadEarlierShow(messageToDisplay < messages.count)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTableView() {

        tableView.reloadData()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func scrollToBottom() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom(animated: false)
        }
        detail?.update(lastRead: Date().timestamp())
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func playIncoming() {

        if let message = messages.last {
            if (message.userId != AuthUser.userId()) {
                Audio.playMessageIncoming()
            }
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTyping() {

        var typing = false
        for detail in details {
            if (detail.typing) {
                typing = true
            }
        }
        self.typingIndicatorShow(typing)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshLastRead() {

        for detail in details {
            if (detail.lastRead > lastRead) {
                lastRead = detail.lastRead
            }
        }
        refreshTableView()
    }
    // MARK: - Message send methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func messageSend(text: String?, photo: UIImage?, video: URL?, audio: String?) {

        Messages.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio)

        //Shortcut.update(userId: recipientId)
    }
    // MARK: - Load earlier methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadEarlierShow(_ show: Bool) {
/*
        viewLoadEarlier.isHidden = !show
        var frame: CGRect = viewLoadEarlier.frame
        frame.size.height = show ? 50 : 0
        viewLoadEarlier.frame = frame
*/
        tableView.reloadData()
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

        let rcmessage = rcmessageAt(indexPath)
        return rcmessage.userInitials
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func avatarImage(_ indexPath: IndexPath) -> UIImage? {

        let rcmessage = rcmessageAt(indexPath)
        var imageAvatar = avatarImages[rcmessage.userId]

        if (imageAvatar == nil) {
            if let path = MediaDownload.pathUser(rcmessage.userId) {
                imageAvatar = UIImage.image(path, size: 30)
                avatarImages[rcmessage.userId] = imageAvatar
            }
        }

        if (imageAvatar == nil) {
            MediaDownload.startUser(rcmessage.userId, pictureAt: rcmessage.userPictureAt) { image, error in
                if (error == nil) {
                    self.refreshTableView()
                }
            }
        }

        return imageAvatar
    }

    // MARK: - Header, Footer methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func textHeaderUpper(_ indexPath: IndexPath) -> String? {

        let rcmessage = rcmessageAt(indexPath)
        var previousDate = ""
        //print("row: \(indexPath.row), section:\(indexPath.section)")
        if indexPath.section != 0 {
            let previousIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            let previousrcmMessage = rcmessageAt(previousIndexPath)
            previousDate = Convert.timestampToDayMonth(previousrcmMessage.createdAt)
        }
        let date = Convert.timestampToDayMonth(rcmessage.createdAt)
        if date == previousDate {
            return nil
        }
        return date
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func textHeaderLower(_ indexPath: IndexPath) -> String? {
        let rcmessage = rcmessageAt(indexPath)
        return Convert.timestampToDayTime(rcmessage.createdAt)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func textFooterUpper(_ indexPath: IndexPath) -> String? {

        return nil
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func textFooterLower(_ indexPath: IndexPath) -> UIImage? {

        let rcmessage = rcmessageAt(indexPath)
        if (rcmessage.outgoing) {
            let message = messageAt(indexPath)
            if (message.syncRequired)    { return UIImage(named: "sent") }
            if (message.isMediaQueued)    { return UIImage(named: "sent") }
            if (message.isMediaFailed)    { return UIImage(named: "sent") }
            return (message.createdAt > lastRead) ? UIImage(named: "delivered") : UIImage(named: "read")
        }
        return nil
    }
    // MARK: - Menu controller methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func menuItems(_ indexPath: IndexPath) -> [RCMenuItem]? {

        let menuItemCopy = RCMenuItem(title: "Copy", action: #selector(actionMenuCopy(_:)))
        let menuItemSave = RCMenuItem(title: "Save", action: #selector(actionMenuSave(_:)))
        let menuItemDelete = RCMenuItem(title: "Delete", action: #selector(actionMenuDelete(_:)))
        let menuItemForward = RCMenuItem(title: "Forward", action: #selector(actionMenuForward(_:)))

        menuItemCopy.indexPath = indexPath
        menuItemSave.indexPath = indexPath
        menuItemDelete.indexPath = indexPath
        menuItemForward.indexPath = indexPath

        let rcmessage = rcmessageAt(indexPath)

        var array: [RCMenuItem] = []

        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_TEXT)        { array.append(menuItemCopy) }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_EMOJI)    { array.append(menuItemCopy) }

        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { array.append(menuItemSave) }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { array.append(menuItemSave) }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { array.append(menuItemSave) }

        array.append(menuItemDelete)
        array.append(menuItemForward)

        return array
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (action == #selector(actionMenuCopy(_:)))    { return true }
        if (action == #selector(actionMenuSave(_:)))    { return true }
        if (action == #selector(actionMenuDelete(_:)))    { return true }
        if (action == #selector(actionMenuForward(_:)))    { return true }
        return false
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override var canBecomeFirstResponder: Bool {

        return true
    }
    // MARK: - User actions (bubble tap)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionTapBubble(_ indexPath: IndexPath) {
        let rcmessage = rcmessageAt(indexPath)

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_MANUAL) {
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO) { RCPhotoLoader.manual(rcmessage, in: tableView) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO) { RCVideoLoader.manual(rcmessage, in: tableView) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO) { RCAudioLoader.manual(rcmessage, in: tableView) }
        }

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO) {
                let pictureView = PictureView(chatId: chatId, messageId: rcmessage.messageId)
                present(pictureView, animated: true)
            }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO) {
                let url = URL(fileURLWithPath: rcmessage.videoPath)
                let videoView = VideoView(url: url)
                present(videoView, animated: true)
            }
            /*
            if (rcmessage.type == MediaStatus.MESSAGE_AUDIO) {
                if (rcmessage.audioStatus == AUDIOSTATUS_STOPPED) {
                    if let sound = Sound(contentsOfFile: rcmessage.audioPath) {
                        sound.completionHandler = { didFinish in
                            rcmessage.audioStatus = AUDIOSTATUS_STOPPED
                            self.refreshTableView()
                        }
                        SoundManager.shared().playSound(sound)
                        rcmessage.audioStatus = AUDIOSTATUS_PLAYING
                        refreshTableView()
                    }
                } else if (rcmessage.audioStatus == AUDIOSTATUS_PLAYING) {
                    SoundManager.shared().stopAllSounds(false)
                    rcmessage.audioStatus = AUDIOSTATUS_STOPPED
                    refreshTableView()
                }
            }
            if (rcmessage.type == MediaStatus.MESSAGE_LOCATION) {
                let mapView = MapView(latitude: rcmessage.latitude, longitude: rcmessage.longitude)
                let navController = NavigationController(rootViewController: mapView)
                present(navController, animated: true)
            }
 */
        }
    }

    // MARK: - User actions (avatar tap)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionTapAvatar(_ indexPath: IndexPath) {

    }
    // MARK: - User actions (menu)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionMenuCopy(_ sender: Any?) {

        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            let rcmessage = rcmessageAt(indexPath)
            UIPasteboard.general.string = rcmessage.text
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionMenuSave(_ sender: Any?) {

        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            let rcmessage = rcmessageAt(indexPath)

            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO) {
                if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
                    if let image = rcmessage.photoImage {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
            }

            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO) {
                if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
                    UISaveVideoAtPathToSavedPhotosAlbum(rcmessage.videoPath, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }

            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO) {
                if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
                    let path = File.temp(ext: "mp4")
                    File.copy(src: rcmessage.audioPath, dest: path, overwrite: true)
                    UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionMenuDelete(_ sender: Any?) {

        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            let message = messageAt(indexPath)
            message.update(isDeleted: true)
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionMenuForward(_ sender: Any?) {

        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            indexForward = indexPath

            let selectUsersView = SelectUsersView()
            selectUsersView.delegate = self
            //let navController = NavigationController(rootViewController: selectUsersView)
            //present(navController, animated: true)
        }
    }

    // MARK: - UISaveVideoAtPathToSavedPhotosAlbum
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

        if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func video(_ videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

        if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
    }
    // MARK: - User actions (input panel)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionAttachMessage() {

    }
    
    func actionOpenCamera() {
        ImagePicker.cameraMulti(target: self, edit: true)
    }
    
    func actionOpenGallery() {
        ImagePicker.photoLibrary(target: self, edit: true)
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionSendMessage(_ text: String) {
        messageSend(text: text, photo: nil, video: nil, audio: nil)
    }
    // MARK: - Helper methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func layoutTableView() {

        let widthView    = view.frame.size.width
        let heightView    = view.frame.size.height

        let leftSafe    = view.safeAreaInsets.left
        let rightSafe    = view.safeAreaInsets.right

        let heightInput = messageInputBar.bounds.height

        let tableviewtoppos = statusbarView.frame.height + topbarView.frame.height
        
        let widthTable = widthView - leftSafe - rightSafe
        let heightTable = heightView - heightInput - heightKeyboard - tableviewtoppos

        tableView.frame = CGRect(x: leftSafe, y: tableviewtoppos, width: widthTable, height: heightTable)
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func scrollToBottom(animated: Bool) {

        if (tableView.numberOfSections > 0) {
            let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
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
        typingCounter += 1
        detail?.update(typing: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.typingIndicatorStop()
        }
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func typingIndicatorStop() {

        typingCounter -= 1
        if (typingCounter == 0) {
            detail?.update(typing: false)
        }
    }
    // MARK: - Keyboard methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func keyboardWillShow(_ notification: Notification) {

        if (heightKeyboard != 0) { return }

        keyboardWillShow = true
        /*
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.heightKeyboard = keyboardRectangle.height
            self.layoutTableView()
            self.scrollToBottom(animated: true)

        }
 */
        if let info = notification.userInfo {
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
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill")
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)

        messageInputBar.setLeftStackViewWidthConstant(to: 72, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)

        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 5)
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
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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

        return messageLoadedCount()
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

// MARK: - UIImagePickerControllerDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let video = info[.mediaURL] as? URL
        let photo = info[.editedImage] as? UIImage

        messageSend(text: nil, photo: photo, video: video, audio: nil)

        picker.dismiss(animated: true)
    }
}

// MARK: - AudioDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatViewController: AudioDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func didRecordAudio(path: String) {

        messageSend(text: nil, photo: nil, video: nil, audio: path)
    }
}

// MARK: - StickersDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatViewController: StickersDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func didSelectSticker(sticker: UIImage) {

        messageSend(text: nil, photo: sticker, video: nil, audio: nil)
    }
}

// MARK: - SelectUsersDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatViewController: SelectUsersDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func didSelectUsers(userIds: [String]) {

        if let indexPath = indexForward {
            let message = messageAt(indexPath)

            for userId in userIds {
                let chatId = Singles.create(userId)
                Messages.forward(chatId: chatId, message: message)
            }

            indexForward = nil
        }
    }
}

// MARK: - UISearchBarDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatViewController: UISearchBarDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(true, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(false, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {

        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar_.text
        if searchText?.isEmpty == true {
            return
        }
        
    }
}
