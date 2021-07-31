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
import FittedSheets

class User {
    
    let name: String
    let image: UIImage
    init(name: String, image: UIImage) {
        self.image = image
        self.name = name
    }
    
}

class ChatViewController: UIViewController {

    var chatId = ""
    var recipientId = ""
    
    private var detail: Detail?
    private var details = realm.objects(Detail.self).filter(falsepredicate)
    private var messages = realm.objects(Message.self).filter(falsepredicate)
    
    private var tokenDetails: NotificationToken? = nil
    private var tokenMessages: NotificationToken? = nil

    @IBOutlet weak var zedPayButton: UIView!
    @IBOutlet weak var videoCallView: UIView!
    @IBOutlet weak var voiceCallView: UIView!
    
    @IBOutlet weak var callToolbarView: UIView!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIBarButtonItem!
    
    private var isShowingToolbar = true
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
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupUserName: UILabel!
    @IBOutlet weak var popupPhoneNumber: UILabel!
    @IBOutlet weak var popupUserAvatar: UIImageView!
    @IBOutlet weak var popupCheckmark: UIImageView!
    
    var videoStatusHandle: UInt?
    var audioStatusHandle: UInt?
    
    private var tokenPersons: NotificationToken? = nil
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    
    private var tokenMembers: NotificationToken? = nil
    private var members = realm.objects(Member.self).filter(falsepredicate)
    private var users:[User] = []
    
    var imagePicker: ImagePicker!
    
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.messageInputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        manager.maxSpaceCountDuringCompletion = 1
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popupView.isHidden = true
        
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
        
        //searchView.isHidden = true
        MoneyTableViewCell.Register(withTableView: self.tableView)
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
        tableView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        //tableView.tableHeaderView = viewLoadEarlier
        
        refreshControl.addTarget(self, action: #selector(actionLoadEarlier), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        configureMessageInputBar()
        
        loadDetail()
        loadDetails()
        loadMessages()
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        
        ///zed pay button
        if(recipientId == ""){
            zedPayButton.isUserInteractionEnabled = false
        }else{
            zedPayButton.isUserInteractionEnabled = true
        }

        imagePicker = ImagePicker(self, delegate: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
     
        navigationController?.isNavigationBarHidden = false
        
        updateTitleDetails()
        showCallToolbar(value: false)
        if(recipientId == ""){
            loadMembers()
        }
        self.videoAudioCallStatusListner(self.chatId)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (isMovingFromParent) {
            actionCleanup()
        }
        
        if let videoStatusHandle = videoStatusHandle{
            FirebaseAPI.removeVideoCallListnerObserver(self.chatId, videoStatusHandle)
        }
        if let audioStatusHandle = audioStatusHandle{
            FirebaseAPI.removeVoiceCallListnerObserver(self.chatId, audioStatusHandle)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTableView()
    }
    
    
    func videoAudioCallStatusListner(_ roomId : String)  {
        self.videoStatusHandle = FirebaseAPI.setVideoCallAddListener(roomId){ [self] (receiverid) in
            if !receiverid.isEmpty{
                print("this is receiverid==>",receiverid)
                print("this is userid==>",AuthUser.userId())
                if receiverid == AuthUser.userId(){
                    let callVideoView = CallVideoView(userId: self.recipientId)
                    callVideoView.roomID = self.chatId
                    callVideoView.receiver = recipientId
                    callVideoView.outgoing = false
                    callVideoView.incoming = true
                    present(callVideoView, animated: true)
                }
            }
        }
        self.audioStatusHandle = FirebaseAPI.setVoiceCallListener(roomId){ [self] (receiverid) in
            print(receiverid)
            if !receiverid.isEmpty{
                print("this is receiverid==>",receiverid)
                print("this is userid==>",AuthUser.userId())
                if receiverid == AuthUser.userId(){
                    let callAudioView = CallAudioView(userId: self.recipientId)
                    callAudioView.roomID = self.chatId
                    callAudioView.receiver = recipientId
                    callAudioView.outgoing = false
                    callAudioView.incoming = true
                    present(callAudioView, animated: true)
                }
            }
        }
    }
    

    func loadMembers() {

        let predicate = NSPredicate(format: "chatId == %@ AND isActive == YES", self.chatId)
        members = realm.objects(Member.self).filter(predicate)
        
        
        tokenMembers?.invalidate()
        members.safeObserve({ changes in
            self.loadPersons()
        }, completion: { token in
            self.tokenMembers = token
        })
    }
    
    func loadPersons() {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Members.userIds(chatId: self.chatId), Blockeds.blockerIds())
        
        persons = realm.objects(Person.self).filter(predicate1)
        
        tokenPersons?.invalidate()
        persons.safeObserve({ changes in
            self.refreshUsers()
        }, completion: { token in
            self.tokenPersons = token
        })
    }
    
    
    func refreshUsers(){
        for person in persons {
            if(person.objectId == AuthUser.userId()){
                continue
            }
            MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
                if (error == nil && image != nil) {
                    self.users.append(User(name:person.fullname, image: image!))
                } else{
                    self.users.append(User(name:person.fullname, image: UIImage(named: "ic_default_profile")!))
                }
            }
        }
        
    }
    
    // MARK: - User actions (load earlier)
    @objc func actionLoadEarlier() {

        messageToDisplay += 12
        refreshLoadEarlier()
        refreshTableView()
        refreshControl.endRefreshing()
    }
    
    func showCallToolbar(value: Bool) {
        callToolbarView.isHidden = !value
        isShowingToolbar = value
        if value == true {
            //plusButton.setImage(UIImage(named: "cancel"), for: .normal)
            plusButton.image = UIImage(named: "cancel")
        } else {
            //plusButton.setImage(UIImage(named: "ic_plus"), for: .normal)
            plusButton.image = UIImage(named: "ic_plus")
        }
    }
    
    @IBAction func actionPlusButton(_ sender: Any) {
        isShowingToolbar = !isShowingToolbar
        showCallToolbar(value: isShowingToolbar)
    }
    
    // MARK: - ZED PAY
    @IBAction func actionZedPay(_ sender: Any) {
        //showCallToolbar(value: false)
        if(recipientId == ""){
            return
        }else{
            isShowingToolbar = false
            
            showCallToolbar(value: isShowingToolbar)
            
            let recipient = realm.object(ofType: Person.self, forPrimaryKey: recipientId)
            let zedStoryboard = UIStoryboard.init(name: "ZedPay", bundle: nil)
            let vc =  zedStoryboard.instantiateViewController(identifier: "PayBottomSheetVC") as! PayBottomSheetVC
            vc.person = recipient
            vc.chatId = self.chatId
            vc.recipientId = self.recipientId
            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(470)])
            self.present(sheetController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Audio and video call
    @IBAction func actionAudioCall(_ sender: Any) {
        showCallToolbar(value: false)
        if(recipientId != ""){
//            let callAudioView = CallAudioView(userId: self.recipientId)
//            present(callAudioView, animated: true)
            let callAdudioView = CallAudioView(userId: self.recipientId)
            callAdudioView.roomID = self.chatId
            callAdudioView.receiver = recipientId
            callAdudioView.outgoing = true
            callAdudioView.incoming = false
            present(callAdudioView, animated: true)
        }else{
            var personsId: [String] = []
            for person in persons{
                personsId.append(person.objectId)
            }
            if let group=realm.object(ofType: Group.self, forPrimaryKey: chatId){
                let callAudioView = CallAudioView(group: group, persons: personsId)
                present(callAudioView, animated: true)
            }
        }
    }
    
    @IBAction func actionVideoCall(_ sender: Any) {
        showCallToolbar(value: false)
        
        if (recipientId != "") {
            let callVideoView = CallVideoView(userId: self.recipientId)
            callVideoView.roomID = self.chatId
            callVideoView.receiver = recipientId
            callVideoView.outgoing = true
            callVideoView.incoming = false
            present(callVideoView, animated: true)
            
        } else {
            var personsId: [String] = []
            for person in persons {
                personsId.append(person.objectId)
            }
            
            if let group = realm.object(ofType: Group.self, forPrimaryKey: chatId){
                let callVideoView = CallVideoView(group: group, persons: personsId)
                present(callVideoView, animated: true)
            }
        }
    }
    
    // MARK: - Title details methods
    func updateTitleDetails() {
        if let person = realm.object(ofType: Person.self, forPrimaryKey: recipientId) {
//            participantNameLabel.text = person.fullname
            self.title = person.fullname
        } else if let group = realm.object(ofType: Group.self, forPrimaryKey: chatId) {
//            participantNameLabel.text = group.name
            self.title = group.name
        } else {
//            participantNameLabel.text = ""
        }
    }
    // MARK: - Cleanup methods
    
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
    
    func loadDetail() {

        let predicate = NSPredicate(format: "chatId == %@ AND userId == %@", chatId, AuthUser.userId())
        detail = realm.objects(Detail.self).filter(predicate).first
    }

    
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
                    print("messages update")
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
    func refreshLoadEarlier() {
        loadEarlierShow(messageToDisplay < messages.count)
    }

    func refreshTableView() {
        print("refresh table view")
        tableView.reloadData()
    }

    func scrollToBottom() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom(animated: false)
        }
        detail?.update(lastRead: Date().timestamp())
    }

    func playIncoming() {

        if let message = messages.last {
            if (message.userId != AuthUser.userId()) {
                Audio.playMessageIncoming()
            }
        }
    }

    func refreshTyping() {

        var typing = false
        for detail in details {
            if (detail.typing) {
                typing = true
            }
        }
        self.typingIndicatorShow(typing)
    }

    func refreshLastRead() {

        for detail in details {
            if (detail.lastRead > lastRead) {
                lastRead = detail.lastRead
            }
        }
        refreshTableView()
    }
    
    // MARK: - Message send methods
    func messageSend(text: String?, photo: UIImage?, video: URL?, audio: String?) {

        Messages.send(chatId: chatId, recipientId: recipientId, text: text, photo: photo, video: video, audio: audio)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom(animated: true)
        }
        //Shortcut.update(userId: recipientId)
        
    }
    
    // MARK: - Load earlier methods
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
    func messageTotalCount() -> Int {

        return messages.count
    }

    func messageLoadedCount() -> Int {
        return min(messageToDisplay, messageTotalCount())
    }
    
    func messageAt(_ indexPath: IndexPath) -> Message {

        let offset = messageTotalCount() - messageLoadedCount()
        let index = indexPath.section + offset

        return messages[index]
    }
    
    // MARK: - Message methods
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
    func avatarInitials(_ indexPath: IndexPath) -> String {

        let rcmessage = rcmessageAt(indexPath)
        return rcmessage.userInitials
    }

    func avatarImage(_ indexPath: IndexPath) -> UIImage? {

        let rcmessage = rcmessageAt(indexPath)
        let imageAvatar = avatarImages[rcmessage.userId]
        // print(rcmessage.userId)
        //print(rcmessage.userPictureAt)
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
                // print(error)
                if (error == nil) {
                    //imageAvatar = image
                    self.avatarImages[rcmessage.userId] = image
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
    func textHeaderUpper(_ indexPath: IndexPath) -> String? {

        let rcmessage = rcmessageAt(indexPath)
        var previousDate = ""
        //// print("row: \(indexPath.row), section:\(indexPath.section)")
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
    
    func textHeaderLower(_ indexPath: IndexPath) -> String? {
        let rcmessage = rcmessageAt(indexPath)
        return Convert.timestampToDayTime(rcmessage.createdAt)
    }

    func textFooterUpper(_ indexPath: IndexPath) -> String? {

        return nil
    }

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
    func menuItems(_ indexPath: IndexPath) -> [RCMenuItem]? {

        let menuItemCopy = RCMenuItem(title: "Copy", action: #selector(actionMenuCopy(_:)))
        let menuItemSave = RCMenuItem(title: "Save", action: #selector(actionMenuSave(_:)))
        let menuItemDelete = RCMenuItem(title: "Delete", action: #selector(actionMenuDelete(_:)))
        let menuItemMark = RCMenuItem(title: "Objectionable", action: #selector(actionMenuMark(_:)))

        menuItemCopy.indexPath = indexPath
        menuItemSave.indexPath = indexPath
        menuItemDelete.indexPath = indexPath
        menuItemMark.indexPath = indexPath
        //menuItemForward.indexPath = indexPath

        let rcmessage = rcmessageAt(indexPath)

        var array: [RCMenuItem] = []

        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_TEXT)        { array.append(menuItemCopy) }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_EMOJI)    { array.append(menuItemCopy) }

        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { array.append(menuItemSave) }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { array.append(menuItemSave) }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { array.append(menuItemSave) }

        array.append(menuItemDelete)
        array.append(menuItemMark)
        //array.append(menuItemForward)

        return array
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (action == #selector(actionMenuCopy(_:)))    { return true }
        if (action == #selector(actionMenuSave(_:)))    { return true }
        if (action == #selector(actionMenuDelete(_:)))    { return true }
        if (action == #selector(actionMenuMark(_:)))    { return true }
        return false
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - User actions (bubble tap)
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
    
    @IBAction func actionTapClose(_ sender: Any) {
        self.popupView.isHidden = true
    }
    // MARK: - User actions (avatar tap)
    
    func actionTapAvatar(_ indexPath: IndexPath) {
        let rcmessage = rcmessageAt(indexPath)
        if(rcmessage.userId == AuthUser.userId()){
            return
        }
        guard let person = Persons.getById(rcmessage.userId) else {
            return
        }
        
        self.popupUserName.text = person.fullname
        self.popupPhoneNumber.text = person.phone
        self.popupCheckmark.isHidden = true
        if let path = MediaDownload.pathUser(person.objectId) {
            self.popupUserAvatar.image = UIImage.image(path, size: 40)
            self.popupCheckmark.isHidden = false
        } else {
            self.popupUserAvatar.image = nil
            //labelInitials.text = person.initials()
            MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
                if (error == nil) {
                    self.popupUserAvatar.image = image
                    self.popupUserAvatar.makeRounded()
                }
                else{
                    self.popupUserAvatar.image = UIImage(named: "ic_default_profile")
                }
                self.popupCheckmark.isHidden = false
            }
        }
        self.popupUserAvatar.makeRounded()

                    
        self.popupView.isHidden = false
    }
    // MARK: - User actions (menu)
    
    @objc func actionMenuCopy(_ sender: Any?) {

        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            let rcmessage = rcmessageAt(indexPath)
            UIPasteboard.general.string = rcmessage.text
        }
    }

    
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

    
    @objc func actionMenuDelete(_ sender: Any?) {

        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            let message = messageAt(indexPath)
            message.update(isDeleted: true)
        }
    }
    
    @objc func actionMenuMark(_ sender: Any?) {

        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            let message = messageAt(indexPath)
            message.update(isObjectionable: true)
        }
    }

    
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
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

        if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
    }

    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

        if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
    }
    // MARK: - User actions (input panel)
    
    func actionAttachMessage() {

    }
    
    func actionOpenCamera() {
        //ImagePicker.cameraMulti(target: self, edit: false)
    }
    
    func actionOpenGallery() {
        //ImagePicker.photoLibrary(target: self, edit: false)
    }
    
    func actionSendMessage(_ text: String) {
        messageSend(text: text, photo: nil, video: nil, audio: nil)
    }
    // MARK: - Helper methods
    
    func layoutTableView() {
        // print("layoutTableView")
        let heightInput = messageInputBar.bounds.height
        
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: heightInput + heightKeyboard, right: 0)

        tableView.contentInset = edgeInset
        tableView.scrollIndicatorInsets = edgeInset
        
    }
    
    func scrollToBottom(animated: Bool) {

        if (tableView.numberOfSections > 0) {
            let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
    // MARK: - Typing indicator methods
    
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

    
    func typingIndicatorUpdate() {
        typingCounter += 1
        detail?.update(typing: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.typingIndicatorStop()
        }
    }
    
    func typingIndicatorStop() {

        typingCounter -= 1
        if (typingCounter == 0) {
            detail?.update(typing: false)
        }
    }
    // MARK: - Keyboard methods
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.popupView.isHidden = true
        showCallToolbar(value: false)
        if (heightKeyboard != 0) { return }
        // print("keyboardwillshow")
        keyboardWillShow = true
        
        if let info = notification.userInfo {
            if let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                if let keyboard = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration)  {
                        if (self.keyboardWillShow) {
                            self.heightKeyboard = keyboard.size.height
                            self.layoutTableView()
                            self.scrollToBottom()
                        }
                    }
                }
            }
        }

        UIMenuController.shared.menuItems = nil
    }

    
    @objc func keyboardWillHide(_ notification: Notification?) {

        heightKeyboard = 0
        keyboardWillShow = false

        layoutTableView()
    }

    
    func dismissKeyboard() {
        if(keyboardWillShow){
            messageInputBar.inputTextView.resignFirstResponder()
        }
    }
    func configureMessageInputBar() {

        view.addSubview(messageInputBar)
        callToolbarView.layer.zPosition = 1

        keyboardManager.bind(inputAccessoryView: messageInputBar)
        //keyboardManager.bind(to: tableView)

        messageInputBar.delegate = self

        let cameraButton = InputBarButtonItem()
        cameraButton.image = UIImage(named: "ic_camera")
        cameraButton.setSize(CGSize(width: 30, height: 40), animated: false)
        
        cameraButton.onTouchUpInside { item in
            self.actionOpenCamera()
        }

        let galleryButton = InputBarButtonItem()
        galleryButton.image = UIImage(named: "ic_gallery")
        galleryButton.setSize(CGSize(width: 25, height: 40), animated: false)
        
        galleryButton.onTouchUpInside { item in
            self.actionOpenGallery()
        }
        
        messageInputBar.setStackViewItems([cameraButton, galleryButton], forStack: .left, animated: false)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = false
        messageInputBar.leftStackView.spacing = 8
        
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(named: "ic_send")
        messageInputBar.sendButton.setSize(CGSize(width: 27, height: 40), animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 62, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 28, animated: false)
        
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 5)
        messageInputBar.inputTextView.font = RCDefaults.textFont
        messageInputBar.inputTextView.placeholder = "Enter a message"
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 11.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.inputTextView.keyboardType = .twitter
        if(recipientId == ""){
            autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body),.foregroundColor: UIColor.systemBlue,.backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1)])
        }
        
    }
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messageLoadedCount()
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if (indexPath.row == 0) {
            let rcmessage = rcmessageAt(indexPath)
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_TEXT)        { return cellForMessageText(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_EMOJI)    { return cellForMessageEmoji(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { return cellForMessagePhoto(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { return cellForMessageVideo(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { return cellForMessageAudio(tableView, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_LOCATION)    { return cellForMessageLocation(tableView, at: indexPath)    }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_MONEY)    { return cellForMessageMoney(tableView, at: indexPath)    }
        }
        return UITableViewCell()
    }

    
    func cellForHeaderUpper(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCHeaderUpperCell", for: indexPath) as! RCHeaderUpperCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    
    func cellForHeaderLower(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCHeaderLowerCell", for: indexPath) as! RCHeaderLowerCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    
    func cellForMessageText(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageTextCell", for: indexPath) as! RCMessageTextCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    
    func cellForMessageEmoji(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageEmojiCell", for: indexPath) as! RCMessageEmojiCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    
    func cellForMessagePhoto(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessagePhotoCell", for: indexPath) as! RCMessagePhotoCell
        cell.bindData(self, at: indexPath)
        return cell
    }
    
    
    func cellForMessageMoney(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: MoneyTableViewCell.GetCellReuseIdentifier(), for: indexPath) as! MoneyTableViewCell
        
        cell.bindData(messageAt(indexPath), messageView: self)
        return cell
    }

    func goPayDetail(_ zedPay: ZEDPay){
        let mainstoryboard = UIStoryboard.init(name: "ZedPay", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "TransactionDetailVC") as! TransactionDetailVC
        vc.transaction = zedPay
        self.present(vc, animated: true, completion: nil)
    }
    
    func cellForMessageVideo(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageVideoCell", for: indexPath) as! RCMessageVideoCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    
    func cellForMessageAudio(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageAudioCell", for: indexPath) as! RCMessageAudioCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    
    func cellForMessageLocation(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageLocationCell", for: indexPath) as! RCMessageLocationCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    
    func cellForFooterUpper(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCFooterUpperCell", for: indexPath) as! RCFooterUpperCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    
    func cellForFooterLower(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RCFooterLowerCell", for: indexPath) as! RCFooterLowerCell
        cell.bindData(self, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        view.tintColor = UIColor.clear
    }

    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {

        view.tintColor = UIColor.clear
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        
        if (indexPath.row == 0) {
            let rcmessage = rcmessageAt(indexPath)
            
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_TEXT)        { return RCMessageTextCell.height(self, at: indexPath)        }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_EMOJI)    { return RCMessageEmojiCell.height(self, at: indexPath)         }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { return RCMessagePhotoCell.height(self, at: indexPath)     }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { return RCMessageVideoCell.height(self, at: indexPath)      }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { return RCMessageAudioCell.height(self, at: indexPath)         }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_LOCATION)    { return RCMessageLocationCell.height(self, at: indexPath)   }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_MONEY)    { return 143   }
        }
        return 0
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let offset = messageTotalCount() - messageLoadedCount()
        let message = messages[section + offset]
        var prevUserId = ""
        if(section > 0){
            prevUserId = messages[section + offset - 1].userId
        }
        var offsetHeight = CGFloat(3)
        if (prevUserId != message.userId){
            offsetHeight = RCDefaults.sectionHeaderMargin
            prevUserId = message.userId
        }
        return offsetHeight
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        return RCDefaults.sectionFooterMargin
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate {

    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {

        if (text != "") {
            typingIndicatorUpdate()
        }
    }

    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        
        
        
        
    }

    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                self.messageInputBar.sendButton.startAnimating()
                actionSendMessage(text)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.messageInputBar.sendButton.stopAnimating()
                }
                //self.messageInputBar.sendButton.stopAnimating()
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let video = info[.mediaURL] as? URL
        let photo = info[.originalImage] as? UIImage

        messageSend(text: nil, photo: photo, video: video, audio: nil)

        picker.dismiss(animated: true)
    }
}

// MARK: - AudioDelegate
extension ChatViewController: AudioDelegate {

    
    func didRecordAudio(path: String) {

        messageSend(text: nil, photo: nil, video: nil, audio: path)
    }
}

// MARK: - StickersDelegate
extension ChatViewController: StickersDelegate {

    
    func didSelectSticker(sticker: UIImage) {

        messageSend(text: nil, photo: sticker, video: nil, audio: nil)
    }
}

// MARK: - SelectUsersDelegate
extension ChatViewController: SelectUsersDelegate {

    
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
extension ChatViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }

    func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {

        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar_.resignFirstResponder()
        
        tableView.reloadData()
    }
}

extension ChatViewController: AutocompleteManagerDelegate, AutocompleteManagerDataSource {

    // MARK: - AutocompleteManagerDataSource
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {

        if prefix == "@" {
            
            var autoList:[AutocompleteCompletion] = []
            for user in users {
                autoList.append(AutocompleteCompletion(text: user.name))
            }
            return autoList
        } else {
            return ["InputBarAccessoryView", "iOS"].map { AutocompleteCompletion(text: $0) }
        }
    }

    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else {
            fatalError("Oops, some unknown error occurred")
        }
        if session.prefix == "@" {
            let user = users[indexPath.row]
            cell.imageView?.image = user.image
            cell.imageViewEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            cell.imageView?.layer.cornerRadius = 8
            cell.imageView?.layer.borderWidth = 1
            cell.imageView?.layer.borderColor = UIColor.systemBlue.cgColor
            cell.imageView?.layer.masksToBounds = true
        }
        cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15, keepPrefix: session.prefix == "#" )
        return cell
    }

    // MARK: - AutocompleteManagerDelegate

    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }

    // MARK: - AutocompleteManagerDelegate Helper

    func setAutocompleteManager(active: Bool) {
        let topStackView = self.messageInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        self.messageInputBar.invalidateIntrinsicContentSize()
    }
}

// MARK: - ImagePickerDelegate
extension ChatViewController: ImagePickerDelegate {
    
    func didSelect(_ image: UIImage?) {
//        guard let image = image else {
//            return
//        }
        
    }
}
