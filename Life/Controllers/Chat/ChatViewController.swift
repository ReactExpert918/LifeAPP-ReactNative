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

class ChatViewController: RCMessagesView {

    private var chatId = ""
    private var recipientId = ""
    
    private var detail: Detail?
    private var details = realm.objects(Detail.self).filter(falsepredicate)
    private var messages = realm.objects(Message.self).filter(falsepredicate)
    
    private var tokenDetails: NotificationToken? = nil
    private var tokenMessages: NotificationToken? = nil


    private var isShowingToolbar = false
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var callToolbarView: UIView!
    
    
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var statusbarView: UIView!
    @IBOutlet weak var topbarView: UIView!

    @IBOutlet weak var searchBar: UISearchBar!
       
    private var textTitle: String?
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

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
        showCallToolbar(value: false)

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
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        layoutTableView()

    }
    // MARK: - User actions (load earlier)
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func actionLoadEarlier() {

        messageToDisplay += 12
        refreshLoadEarlier()
        refreshTableView()
        refreshControl.endRefreshing()
    }
    func showCallToolbar(value: Bool) {
        callToolbarView.isHidden = !value
        //callToolbarView.layer.zPosition = 1
        self.view.bringSubviewToFront(callToolbarView)
        isShowingToolbar = value
        if value == true {
            plusButton.setImage(UIImage(named: "cancel"), for: .normal)
        }
        else{
            plusButton.setImage(UIImage(named: "ic_plus"), for: .normal)
        }
        
    }
    @IBAction func actionPlusButton(_ sender: Any) {
        if isShowingToolbar == false {
            isShowingToolbar = true
        }
        else{
            isShowingToolbar = false
        }
        showCallToolbar(value: isShowingToolbar)
    }
    
    @IBAction func actionZedPay(_ sender: Any) {
        showCallToolbar(value: false)
    }
    @IBAction func actionAudioCall(_ sender: Any) {
        showCallToolbar(value: false)
        let callAudioView = CallAudioView(userId: self.recipientId)
        present(callAudioView, animated: true)
    }
    
    @IBAction func actionVideoCall(_ sender: Any) {
        showCallToolbar(value: false)
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
    override func rcmessageAt(_ indexPath: IndexPath) -> RCMessage {
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
    override func avatarInitials(_ indexPath: IndexPath) -> String {

        let rcmessage = rcmessageAt(indexPath)
        return rcmessage.userInitials
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func avatarImage(_ indexPath: IndexPath) -> UIImage? {

        let rcmessage = rcmessageAt(indexPath)
        var imageAvatar = avatarImages[rcmessage.userId]
/*
        if (imageAvatar == nil) {
            if let path = MediaDownload.pathUser(rcmessage.userId) {
                imageAvatar = UIImage.image(path, size: 30)
                avatarImages[rcmessage.userId] = imageAvatar
            }
        }
*/
        if (imageAvatar == nil) {
            MediaDownload.startUser(rcmessage.userId, pictureAt: rcmessage.userPictureAt) { image, error in
                if (error == nil) {
                    imageAvatar = image
                    self.avatarImages[rcmessage.userId] = imageAvatar
                    //self.refreshTableView()
                }
                else{
                    self.avatarImages[rcmessage.userId] = UIImage(named: "ic_default_profile")
                }
            }
        }

        return imageAvatar
    }

    // MARK: - Header, Footer methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func textHeaderUpper(_ indexPath: IndexPath) -> String? {

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
    override func textHeaderLower(_ indexPath: IndexPath) -> String? {
        let rcmessage = rcmessageAt(indexPath)
        return Convert.timestampToDayTime(rcmessage.createdAt)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func textFooterUpper(_ indexPath: IndexPath) -> String? {

        return nil
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func textFooterLower(_ indexPath: IndexPath) -> UIImage? {

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
    override func menuItems(_ indexPath: IndexPath) -> [RCMenuItem]? {

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
    override func actionTapBubble(_ indexPath: IndexPath) {
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
    override func actionTapAvatar(_ indexPath: IndexPath) {

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
    
    override func actionOpenCamera() {
        ImagePicker.cameraMulti(target: self, edit: true)
    }
    
    override func actionOpenGallery() {
        ImagePicker.photoLibrary(target: self, edit: true)
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func actionSendMessage(_ text: String) {
        messageSend(text: text, photo: nil, video: nil, audio: nil)
    }
    // MARK: - Helper methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func layoutTableView() {

        let heightInput = messageInputBar.bounds.height

        let widthView    = view.frame.size.width
        let heightView    = view.frame.size.height

        let leftSafe    = view.safeAreaInsets.left
        let rightSafe    = view.safeAreaInsets.right

        let tableviewtoppos = statusbarView.frame.height + topbarView.frame.height

        let widthTable = widthView - leftSafe - rightSafe
        let heightTable = heightView -/* heightInput - heightKeyboard - */tableviewtoppos

        tableView.frame = CGRect(x: leftSafe, y: tableviewtoppos, width: widthTable, height: heightTable)

        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: heightInput + heightKeyboard, right: 0)

        tableView.contentInset = edgeInset        
        tableView.scrollIndicatorInsets = edgeInset
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func scrollToBottom(animated: Bool) {

        if (tableView.numberOfSections > 0) {
            let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }


    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func typingIndicatorUpdate() {
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
    override func numberOfSections(in tableView: UITableView) -> Int {

        return messageLoadedCount()
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

    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let video = info[.mediaURL] as? URL
        let photo = info[.originalImage] as? UIImage

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
