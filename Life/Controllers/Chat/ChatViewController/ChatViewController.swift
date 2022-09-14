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
import FirebaseDatabase
import Photos
import CallKit
import JamitFoundation

class User {
    let name: String
    let image: UIImage
    init(name: String, image: UIImage) {
        self.image = image
        self.name = name
    }
}

enum ButtonType { case audio, video}

class ChatViewController: UIViewController {

    var chatId = ""
    var recipientId = ""
    var fromNoti = false
    var ref = Database.database().reference()
    var detail: Detail?
    var details = realm.objects(Detail.self).filter(falsepredicate)
    var messages = realm.objects(Message.self).filter(falsepredicate)
    var tokenDetails: NotificationToken? = nil
    var tokenMessages: NotificationToken? = nil
    var telegramVideoView: TelegramRecordView?
    var recordingView: SKRecordView!
    var refreshControl = UIRefreshControl()
    var isTyping = false
    var messageInputBar = TouchPassingInputBarAccessoryView()
    var heightKeyboard: CGFloat = 0
    var keyboardWillShow = false
    var rcmessages: [String: RCMessage] = [:]
    var messageToDisplay: Int = 12
    var typingCounter: Timer = Timer()
    var indexForward: IndexPath?
    var tokenPersons: NotificationToken? = nil
    var persons = realm.objects(Person.self).filter(falsepredicate)
    var tokenMembers: NotificationToken? = nil
    var members = realm.objects(Member.self).filter(falsepredicate)
    var users:[User] = []
    var playingIndex: IndexPath?
    let app = UIApplication.shared.delegate as? AppDelegate
    var hybridButton: InputBarButtonItem!
    private let callController = CXCallController()
    private var textTitle: String?
    private var keyboardManager = KeyboardManager()
    private var avatarImages: [String: UIImage] = [:]
    private var currentButton: ButtonType = .audio
    private var lastRead: Int64 = 0
    private var isShowingToolbar = false
    lazy var trashButton: UIButton = .init(frame: .zero)

    @IBOutlet weak var videoCallView: UIView!
    @IBOutlet weak var voiceCallView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var callToolbarView: UIView!
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var statusbarView: UIView!
    @IBOutlet weak var topbarView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupUserName: UILabel!
    @IBOutlet weak var popupPhoneNumber: UILabel!
    @IBOutlet weak var popupUserAvatar: UIImageView!
    @IBOutlet weak var popupCheckmark: UIImageView!
    @IBOutlet weak var zedPayButton: UIView!

    private var audioController: RCAudioController?
    var voiceRecord: VoiceRecord? = nil
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.messageInputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        manager.maxSpaceCountDuringCompletion = 1
        return manager
    }()


    @IBAction func onBackPressed(_ sender: Any) {
        if let audiocontroller = audioController{
            audiocontroller.stopAudio()
        }
        if fromNoti{
            let home = AppBoards.main.initialViewController
            let vc = AppBoards.main.viewController(withIdentifier: "mainTabViewController") as! MainTabViewController
            vc.modalPresentationStyle = .fullScreen
            let window = UIApplication.shared.keyWindow
            window?.rootViewController = home
            window?.makeKeyAndVisible()
            home.present(vc, animated: false, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func actionPlusButton(_ sender: Any) {
        isShowingToolbar = !isShowingToolbar
        showCallToolbar(value: isShowingToolbar)
    }

    // MARK: - ZED PAY
    @IBAction func actionZedPay(_ sender: Any) {
        if(recipientId == ""){
            return
        } else {
            isShowingToolbar = false
            showCallToolbar(value: isShowingToolbar)
            showZedPay()
        }
    }

    @IBAction func actionAudioCall(_ sender: Any) {
        showCallToolbar(value: false)
        if(recipientId != ""){
            let callAdudioView = CallAudioView(userId: self.recipientId)
            callAdudioView.roomID = self.chatId
            callAdudioView.receiver = recipientId
            callAdudioView.sender = AuthUser.userId()
            callAdudioView.outgoing = true
            callAdudioView.incoming = false

            let realm = try! Realm()

            let recipient = realm.object(ofType: Person.self, forPrimaryKey: recipientId)
            let sender = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
            callAdudioView.name = recipient?.getFullName() ?? ""
            if let pictureAt = sender?.pictureAt {
                callAdudioView.pictureAt = pictureAt
            }
            present(callAdudioView, animated: true)

            let uuid = UUID().uuidString
            PushNotification.sendCall(name: recipient?.getFullName() ?? "", chatId: self.chatId, recipientId: self.recipientId, pictureAt: recipient?.pictureAt ?? 0, senderId: AuthUser.userId(), hasVideo: 0, uuid: uuid)
            if let recipient = recipient {
                startCall(handle: recipient.getFullName(), videoEnabled: false, uuid: uuid)
            }
        } else {
            var personsId: [String] = []
            for person in persons{
                personsId.append(person.objectId)
            }
            if let group=realm.object(ofType: Group.self, forPrimaryKey: chatId){
                let callAudioView = CallAudioView(group: group, persons: personsId)
                callAudioView.roomID = self.chatId
                present(callAudioView, animated: true)

                startCall(handle: "Unknown", videoEnabled: false, uuid: UUID().uuidString)
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
            let realm = try! Realm()

            let sender = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())

            let uuid = UUID()

            PushNotification.sendCall(name: sender?.getFullName() ?? "", chatId: self.chatId, recipientId: self.recipientId, pictureAt: sender?.pictureAt ?? 0, senderId: AuthUser.userId(), hasVideo: 1, uuid: uuid.uuidString)

            if let sender = sender {
                startCall(handle: sender.fullname, videoEnabled: true, uuid: uuid.uuidString)
            }

        } else {
            var personsId: [String] = []
            for person in persons {
                personsId.append(person.objectId)
            }

            if let _ = realm.object(ofType: Group.self, forPrimaryKey: chatId){
                let callVideoView = self.storyboard?.instantiateViewController(withIdentifier: "GroupVideoCallViewController") as! GroupVideoCallViewController
                callVideoView.modalPresentationStyle = .fullScreen
                callVideoView.roomName = self.chatId
                startCall(handle: "Unknown", videoEnabled: true, uuid: UUID().uuidString)
                present(callVideoView, animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        popupView.isHidden = true

        configureSearchBar()
        configureTableView()

        refreshControl.addTarget(self, action: #selector(actionLoadEarlier), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)

        configureMessageInputBar()
        
        loadDetail()
        loadDetails()
        loadMessages()
        
        ///zed pay button
        if(recipientId == ""){
            zedPayButton.isUserInteractionEnabled = false
            zedPayButton.isHidden = true
        }else{
            zedPayButton.isUserInteractionEnabled = true
            zedPayButton.isHidden = false
        }
        audioController = RCAudioController(self)
        
        self.ref.child("Typing").child(self.chatId).observe(.childChanged) { snapshot in
            if snapshot.key == self.recipientId {
                self.isTyping = snapshot.value as? Bool ?? false
                self.refreshTableView()
                self.scrollToBottom()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        updateTitleDetails()
        showCallToolbar(value: false)
        if(recipientId == ""){
            loadMembers()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if (isMovingFromParent) {
            actionCleanup()
        }
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTableView()
    }

    @objc func actionLoadEarlier() {
        messageToDisplay += 12
        refreshLoadEarlier()
        refreshTableView()
        refreshControl.endRefreshing()
    }

    func actionCleanup() {

        tokenDetails?.invalidate()
        tokenMessages?.invalidate()

        detail?.update(typing: false)
    }

    func showCallToolbar(value: Bool) {
        callToolbarView.isHidden = !value
        isShowingToolbar = value
        if value == true {
            plusButton.setImage(UIImage(named: "cancel"), for: .normal)
        }
        else{
            plusButton.setImage(UIImage(named: "ic_plus"), for: .normal)
        }
    }

    func showZedPay() {
        let recipient = realm.object(ofType: Person.self, forPrimaryKey: recipientId)
        let zedStoryboard = UIStoryboard.init(name: "ZedPay", bundle: nil)
        let vc =  zedStoryboard.instantiateViewController(identifier: "payBottomSheetVC") as! PayBottomSheetViewController
        vc.person = recipient
        vc.chatId = self.chatId
        vc.recipientId = self.recipientId
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(470)])
        self.present(sheetController, animated: true, completion: nil)
    }
    
    // MARK: - Audio and video call
    private func startCall(handle: String, videoEnabled: Bool, uuid: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            let handle = CXHandle(type: .generic, value: handle)
            let uuid = UUID(uuidString: uuid)
            let startCallAction = CXStartCallAction(call: uuid ?? UUID(), handle: handle)
            startCallAction.isVideo = videoEnabled
            let transaction = CXTransaction(action: startCallAction)
            if let app = self.app {
                app.callKitProvider?.outgoingUUID = uuid
                let realm = try! Realm()
                let sender = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
                app.callKitProvider?.call = Call(name: sender?.getFullName() ?? "", chatId: self.chatId, recipientId: self.recipientId, isVideo: false, uuID: uuid ?? UUID(), senderId: AuthUser.userId(), pictureAt: sender?.pictureAt ?? 0)
            }
            self.requestTransaction(transaction)
        }
    }

    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }

    // MARK: - Title details methods
    func updateTitleDetails() {
        if let person = realm.object(ofType: Person.self, forPrimaryKey: recipientId) {
            participantNameLabel.text = person.getFullName()
        } else if let group = realm.object(ofType: Group.self, forPrimaryKey: chatId) {
            participantNameLabel.text = group.name
        } else {
            participantNameLabel.text = ""
        }
    }

    func setParticipant(chatId: String, recipientId: String) {
        self.chatId = chatId
        self.recipientId = recipientId
    }

    // MARK: - Refresh methods
    func refreshLoadEarlier() {
        loadEarlierShow(messageToDisplay < messages.count)
    }

    func playIncoming() {

        if let message = messages.last {
            if (message.userId != AuthUser.userId()) {
                Audio.playMessageIncoming()
            }
        }
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
    }

    // MARK: - Load earlier methods
    func loadEarlierShow(_ show: Bool) {
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
        
        if (indexPath.section < messageLoadedCount()) {
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
        } else {
            let message = Message()
            
            message.chatId = chatId
            message.userId = recipientId
            
            let rcmessage = RCMessage(message: message)
            rcmessage.type = MESSAGE_TYPE.MESSAGE_ISTYPING
            rcmessages[message.objectId] = rcmessage
            //loadMedia(rcmessage)
            return rcmessage
        }
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
        var imageAvatar = avatarImages[rcmessage.userId]
        if (imageAvatar == nil) {
            MediaDownload.startUser(rcmessage.userId, pictureAt: rcmessage.userPictureAt) { image, error in
                if (error == nil) {
                    self.avatarImages[rcmessage.userId] = image
                }
                else{
                    self.avatarImages[rcmessage.userId] = UIImage(named: "ic_default_profile")
                }
            }
            imageAvatar = UIImage(named: "ic_default_profile")
        }
        return imageAvatar
    }

    // MARK: - Header, Footer methods
    func textHeaderUpper(_ indexPath: IndexPath) -> String? {
        let rcmessage = rcmessageAt(indexPath)
        var previousDate = ""
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
            if (message.syncRequired)    { return nil }
            if (message.isMediaQueued)    { return nil }
            if (message.isMediaFailed)    { return nil }
            return (message.createdAt > lastRead) ? nil : UIImage(named: "ic_tick")
        }
        return nil
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - User actions (bubble tap)
    func pauseVideoOnTapBubble(_ indexPath: IndexPath) {
        if playingIndex == indexPath {
            playingIndex = nil
            tableView.reloadRows(at: [indexPath], with: .top)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
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
                var reloadingIndices: [IndexPath] = [indexPath]
                if let currentPlayingIndex = playingIndex {
                    reloadingIndices.append(currentPlayingIndex)
                }
                playingIndex = indexPath
                tableView.reloadRows(at: reloadingIndices, with: .top)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO) {
                audioController?.toggleAudio(indexPath)
            }
        }
    }
    
    @IBAction func actionTapClose(_ sender: Any) {
        self.popupView.isHidden = true
    }

    // MARK: - UISaveVideoAtPathToSavedPhotosAlbum
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
    }

    @objc func video(_ videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
    }
    
    func actionOpenCamera() {
        ImagePicker.cameraMulti(target: self, edit: false)
    }
    
    func actionOpenGallery() {
        let imagePickerSheet =  self.storyboard?.instantiateViewController(identifier: "ImagePickerSheet") as! ImagePickerSheetViewController
        imagePickerSheet.delegate = self
        imagePickerSheet.modalPresentationStyle = .overCurrentContext
        present(imagePickerSheet, animated: true, completion: nil)
    }
    
    func configureMessageInputBar() {

        messageInputBar.backgroundColor = .clear
        messageInputBar.backgroundView.backgroundColor = .clear

        view.addSubview(messageInputBar)
        callToolbarView.layer.zPosition = 1
        keyboardManager.bind(inputAccessoryView: messageInputBar)
        messageInputBar.delegate = self

        hybridButton = InputBarButtonItem()
        hybridButton.setImage(UIImage(named: "ic_record")?.resize(width: 20, height: 20), for: .normal)
        hybridButton.imageEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        hybridButton.tintColor = UIColor(named: "PrimaryColor")
        hybridButton.setSize(CGSize(width: 50, height: 50), animated: false)
        hybridButton.layer.cornerRadius = 25
        hybridButton.contentMode = .center
        hybridButton.onTouchUpInside { item in
            if self.recordingView.state == .locked {
                self.stopVoiceRecord()
                self.recordingView.finishLockMode()
            } else {
                self.changeButton()
            }
        }
        let cameraButton = InputBarButtonItem()
        cameraButton.image = UIImage(named: "ic_camera")
        cameraButton.setSize(CGSize(width: 30, height: 50), animated: false)
        cameraButton.contentMode = .scaleAspectFit
        cameraButton.onTouchUpInside { item in
            self.actionOpenCamera()
        }
        let galleryButton = InputBarButtonItem()
        galleryButton.image = UIImage(named: "ic_attach")
        galleryButton.setSize(CGSize(width: 50, height: 50), animated: false)
        galleryButton.contentMode = .scaleAspectFit
        galleryButton.onTouchUpInside { item in
            self.actionOpenGallery()
        }
        
        messageInputBar.setStackViewItems([galleryButton, cameraButton], forStack: .left, animated: false)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = false
        messageInputBar.leftStackView.spacing = 6
        
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(named: "ic_send")
        messageInputBar.sendButton.setSize(CGSize(width: 42, height: 42), animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 80, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 40, animated: false)
        
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 5)
        messageInputBar.inputTextView.font = RCDefaults.textFont
        messageInputBar.inputTextView.placeholder = "Enter a message".localized
        messageInputBar.inputTextView.backgroundColor = COLORS.BACKGROUND
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.inputTextView.keyboardType = .twitter

        recordingView = SKRecordView(recordBtn: hybridButton, vc: self)
        recordingView.delegate = self
        recordingView.normalImage = UIImage(named: "ic_record.png")!
        view.addSubview(recordingView)
        messageInputBar.addSubview(recordingView)
        NSLayoutConstraint.activate([
            recordingView.widthAnchor.constraint(equalToConstant: messageInputBar.frame.width),
            recordingView.heightAnchor.constraint(equalToConstant: messageInputBar.frame.height),
            recordingView.leadingAnchor.constraint(equalTo: self.messageInputBar.leadingAnchor),
            recordingView.bottomAnchor.constraint(equalTo: self.messageInputBar.bottomAnchor)
        ])
        recordingView.isHidden = true

        messageInputBar.setStackViewItems([recordingView.recordButton], forStack: .right, animated: false)
        recordingView.setupRecorder()
        if(recipientId == "") {
            autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body),
                                                             .foregroundColor: UIColor.systemBlue,
                                                             .backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1)])
        }

        addVoiceRecord()
        view.bringSubviewToFront(messageInputBar)

        trashButton.setTitle("", for: .normal)
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        trashButton.addTarget(self, action: #selector(trashDidTap), for: .touchUpInside)
        view.addSubview(trashButton)
        NSLayoutConstraint.activate([
            trashButton.trailingAnchor.constraint(equalTo: voiceRecord!.trashButton.trailingAnchor),
            trashButton.topAnchor.constraint(equalTo: voiceRecord!.trashButton.topAnchor),
            trashButton.leadingAnchor.constraint(equalTo: voiceRecord!.trashButton.leadingAnchor),
            trashButton.bottomAnchor.constraint(equalTo: voiceRecord!.trashButton.bottomAnchor)
        ])
    }

    @objc
    func trashDidTap() {
        voiceRecord?.lockTrashDidTap()
    }

    func addVoiceRecord() {

        if voiceRecord == nil {
            voiceRecord = .instantiate()
            voiceRecord?.model = .init()
            voiceRecord?.delegate = self
        }
        stopVoiceRecord()
        voiceRecord?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(voiceRecord!)
        NSLayoutConstraint.activate([
            voiceRecord!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            voiceRecord!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            voiceRecord!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        voiceRecord?.layoutIfNeeded()
        view.bringSubviewToFront(voiceRecord!)
    }

    func changeButton() {
        currentButton = currentButton == .audio ? .video : .audio
        recordingView.isVideo = currentButton == .audio ? false : true
        UIView.transition(with: self.hybridButton, duration: 0.07, options: .transitionCrossDissolve, animations: {
            self.hybridButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5);
            self.hybridButton.image = UIImage(named: self.currentButton == .audio ? "ic_record" : "ic_video_clip")
        }) { _ in
            UIView.animate(withDuration: 0.07, delay: 0, options: .transitionCrossDissolve) {
                self.hybridButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }

    func startVoiceRecord() {
        voiceRecord?.recordConfiguration()
        messageInputBar.separatorLine.height = 0
        hybridButton.backgroundColor = .clear
        trashButton.isEnabled = false
        trashButton.isHidden = true
    }

    func stopVoiceRecord() {
        voiceRecord?.defaultConfiguration()
        messageInputBar.separatorLine.height = 1
        hybridButton.backgroundColor = .clear
        trashButton.isEnabled = false
        trashButton.isHidden = true
    }

    func lockVoiceRecord() {
        voiceRecord?.lockConfiguration()
        messageInputBar.separatorLine.height = 0
        hybridButton.backgroundColor = COLORS.MSG_OUTGOING
        trashButton.isEnabled = true
        trashButton.isHidden = false
    }
}
