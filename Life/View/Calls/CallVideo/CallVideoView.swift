

import SwiftyAvatar
import UIKit
import AgoraRtcKit
import FirebaseDatabase
import FirebaseFirestore

class CallVideoView: BaseVC {

    let ref = Database.database().reference()
    
	@IBOutlet var viewBackground: UIView!
	@IBOutlet var viewDetails: UIView!
	@IBOutlet var imageUser: SwiftyAvatar!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStatus: UILabel!
	@IBOutlet var uiv_anwserhangup: UIView!
	@IBOutlet var uiv_muteswitch: UIView!
    @IBOutlet var uiv_power: UIView!
    @IBOutlet weak var uiv_request: UIView!
    
	private var person: Person!

	 var incoming = false
	 var outgoing = false
	private var muted = false
	private var switched = false

	//private var call: SINCall?
	//private var audioController: SINAudioController?
	//private var videoController: SINVideoController?
    private var personsFullName:String?
    private var callString = ""
    private var type = 0
    private var group: Group?
    
    // agora module
    @IBOutlet weak var localContainer: UIView!
    @IBOutlet weak var remoteContainer: UIView!
    
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIView!
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    var videoStatusHandle: UInt?
    var videoStatusRemoveHandle: UInt?
    
    var agoraKit: AgoraRtcEngineKit?
    var localVideo: AgoraRtcVideoCanvas?
    var remoteVideo: AgoraRtcVideoCanvas?
    var roomID: String = ""
    var receiver: String = ""
    var isRemoteVideoRender: Bool = true {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    remoteVideoMutedIndicator.isHidden = isRemoteVideoRender
                    remoteContainer.isHidden = !isRemoteVideoRender
                } else if view.superview == remoteContainer {
                    localVideoMutedIndicator.isHidden = isRemoteVideoRender
                }
            }
        }
    }
    
    var isLocalVideoRender: Bool = false {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    localVideoMutedIndicator.isHidden = isLocalVideoRender
                } else if view.superview == remoteContainer {
                    remoteVideoMutedIndicator.isHidden = isLocalVideoRender
                }
            }
        }
    }
    
    var isStartCalling: Bool = true {
        didSet {
            if isStartCalling {
                micButton.isSelected = false
            }
            micButton.isHidden = !isStartCalling
            cameraButton.isHidden = !isStartCalling
        }
    }
    
    
	
    /*
	init(call: SINCall?) {

		super.init(nibName: nil, bundle: nil)

		self.isModalInPresentation = true
		self.modalPresentationStyle = .fullScreen

		let app = UIApplication.shared.delegate as? AppDelegate

		self.call = call
		call?.delegate = self

		audioController = app?.client?.audioController()
		videoController = app?.client?.videoController()
        incoming = true
        
        callString = (self.call?.headers["name"])! as! String
	}*/

	
	init(userId: String) {
        
		super.init(nibName: nil, bundle: nil)
        let recipentUser = realm.object(ofType: Person.self, forPrimaryKey: userId)
        callString = recipentUser!.fullname
        print(callString)
		self.isModalInPresentation = true
		self.modalPresentationStyle = .fullScreen

        _ = UIApplication.shared.delegate as? AppDelegate
        print("=================>",Persons.fullname())
/*
        personsFullName = Persons.fullname()
        app?.callKitProvider?.setGroupCall(false)
        //DispatchQueue.main.asyncAfter(deadline: .now()+1) {
        self.call = app?.client?.call().callUserVideo(withId: userId, headers: ["name": Persons.fullname()])
            self.call?.delegate = self

            self.audioController = app?.client?.audioController()
            self.videoController = app?.client?.videoController()
        //}*/
        outgoing = true
		
	}
    
    init(group: Group, persons: [String]) {
        
        super.init(nibName: nil, bundle: nil)
        type = 1
        self.group = group
        callString = group.name
        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen
/*
        let app = UIApplication.shared.delegate as? AppDelegate
        app?.callKitProvider?.setGroupCall(true)
        for person in persons {
            if(person == AuthUser.userId()){
                continue
            }
            let call = app?.client?.call().callUserVideo(withId: person, headers: ["name": callString])
            call?.delegate = self
            
            app?.callKitProvider?.insertCall(call: call!)
        }
        
        self.audioController = app?.client?.audioController()
        self.videoController = app?.client?.videoController()*/
        
    }
	
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	
	override func viewDidLoad() {

		super.viewDidLoad()
/*
		audioController?.unmute()
		audioController?.disableSpeaker()

		videoController?.captureDevicePosition = .front

		if let remoteView = videoController?.remoteView() {
			viewBackground.addSubview(remoteView)
		}
		if let localView = videoController?.localView() {
			viewBackground.addSubview(localView)
		}

		videoController?.localView().contentMode = .scaleAspectFill
		videoController?.remoteView().contentMode = .scaleAspectFill

		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionTap))
		videoController?.remoteView().addGestureRecognizer(gestureRecognizer)*/
//		gestureRecognizer.cancelsTouchesInView = false

        
		micButton.setImage(UIImage(named: "callvideo_mute1"), for: .normal)
        micButton.setImage(UIImage(named: "callvideo_mute1"), for: .highlighted)

		cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
        cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)

        if (incoming) { setIncomingUI() }
        if (outgoing) { setOutGoingUI() }
        
        
        
	}
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let videoStatusHandle = videoStatusHandle{
            FirebaseAPI.removeVideoCallListnerObserver(self.roomID, videoStatusHandle)
        }
        if let videoStatusRemoveHandle = videoStatusRemoveHandle{
            FirebaseAPI.removeVideoCallRemoveListnerObserver(self.roomID, videoStatusRemoveHandle)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    func videoCallStatusListner(_ roomId : String)  {
        self.videoStatusHandle = FirebaseAPI.setVideoCallChangeListener(roomId){ [self] (status) in
            
            switch status {
            /*
             case outgoing = 1
             case incoming = 2
             case end = 3
             case accept = 4
             case reject = 5
             case null = 6
             */
            case 1:
                break
            case 2:
                // show
                break
            case 3:
                break
            case 4:// accept acction and start calling
                self.joinAction()
                break
            case 5:
                break
            case 6:
                break
            default:
                print("default")
            }
        }
        
        self.videoStatusRemoveHandle = FirebaseAPI.setVideoCallRemoveListener(roomId){ [self] (receiverid) in
            if receiverid == AuthUser.userId(){
                self.leaveChannel()
                self.dismiss(animated: true, completion: nil)
            }else{
                if outgoing{
                    self.labelStatus.text = "Declined"
                    self.labelStatus.textColor = .red
                }else{
                    self.leaveChannel()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func joinAction() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConstant.agoraAppID, delegate: self)
        setupVideo()
        self.viewDetails.isHidden = true
        self.uiv_anwserhangup.isHidden = true
        self.uiv_muteswitch.isHidden = false
        self.uiv_power.isHidden = false
        self.uiv_request.isHidden = false
        self.localContainer.isHidden = false
        self.remoteContainer.isHidden = false
        //self.viewEnded.isHidden = true
        setupLocalVideo()
        joinChannel()
    }
    
    //******************************* Agora module start *****************************//
    
    func setupVideo() {
        if let agoraKit = self.agoraKit{
            // In simple use cases, we only need to enable video capturing
            // and rendering once at the initialization step.
            // Note: audio recording and playing is enabled by default.
            agoraKit.enableVideo()
            
            // Set video configuration
            // Please go to this page for detailed explanation
            // https://docs.agora.io/cn/Voice/API%20Reference/java/classio_1_1agora_1_1rtc_1_1_rtc_engine.html#af5f4de754e2c1f493096641c5c5c1d8f
            agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
                                                                                 frameRate: .fps15,
                                                                                 bitrate: AgoraVideoBitrateStandard,
                                                                                 orientationMode: .adaptative))
        }
    }
    
    func setupLocalVideo() {
        // This is used to set a local preview.
        // The steps setting local and remote view are very similar.
        // But note that if the local user do not have a uid or do
        // not care what the uid is, he can set his uid as ZERO.
        // Our server will assign one and return the uid via the block
        // callback (joinSuccessBlock) after
        // joining the channel successfully.
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: localContainer.frame.size))
        localVideo = AgoraRtcVideoCanvas()
        localVideo!.view = view
        localVideo!.renderMode = .hidden
        localVideo!.uid = 0
        localContainer.addSubview(localVideo!.view!)
        if let agoraKit = self.agoraKit{
            agoraKit.setupLocalVideo(localVideo)
        }
        
    }
    
    func joinChannel() {
        if let agoraKit = self.agoraKit{
            // Set audio route to speaker
            agoraKit.setDefaultAudioRouteToSpeakerphone(true)
            
            // 1. Users can only see each other after they join the
            // same channel successfully using the same app id.
            // 2. One token is only valid for the channel name that
            // you use to generate this token.
            agoraKit.joinChannel(byToken: "", channelId: self.roomID, info: nil, uid: 0) { [unowned self] (channel, uid, elapsed) -> Void in
                // Did join channel "demoChannel1"
                self.isLocalVideoRender = true
            }
            isStartCalling = true
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    func leaveChannel() {
        if let agoraKit = self.agoraKit{
            // leave channel and end chat
            agoraKit.leaveChannel(nil)
            isRemoteVideoRender = false
            isLocalVideoRender = false
            isStartCalling = false
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    @IBAction func actionHangup(_ sender: Any) {
        ref.child("video_call").child(self.roomID).removeValue()
        self.leaveChannel()
        self.dismiss(animated: true, completion: nil)
        //call?.hangup()
    }
    
    @IBAction func actionRequestHangup(_ sender: Any) {
        ref.child("video_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func decline(_ sender: Any) {
        ref.child("video_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
        //call?.hangup()
        
    }
    
    @IBAction func actionMute(_ sender: Any) {
        let sender = sender as! UIButton
        sender.isSelected.toggle()
        // mute local audio
        if let agoraKit = self.agoraKit{
            agoraKit.muteLocalAudioStream(sender.isSelected)
        }
        

        if (muted) {
            muted = false
            micButton.setImage(UIImage(named: "callvideo_mute1"), for: .normal)
            micButton.setImage(UIImage(named: "callvideo_mute1"), for: .highlighted)
            //audioController?.unmute()
        } else {
            muted = true
            micButton.setImage(UIImage(named: "callvideo_mute2"), for: .normal)
            micButton.setImage(UIImage(named: "callvideo_mute2"), for: .highlighted)
            //audioController?.mute()
        }

    }
    
    @IBAction func actionSwitch(_ sender: Any) {
        let sender = sender as! UIButton
        sender.isSelected.toggle()
        if let agoraKit = self.agoraKit{
            agoraKit.switchCamera()
        }
        
        if (switched) {
            switched = false
            cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
            cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)
            //videoController?.captureDevicePosition = .front
        } else {
            switched = true
            cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
            cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)
            //videoController?.captureDevicePosition = .back
        }
    }
    
    @IBAction func didClickLocalContainer(_ sender: Any) {
        switchView(localVideo)
        switchView(remoteVideo)
    }
    
    func removeFromParent(_ canvas: AgoraRtcVideoCanvas?) -> UIView? {
        if let it = canvas, let view = it.view {
            let parent = view.superview
            if parent != nil {
                view.removeFromSuperview()
                return parent
            }
        }
        return nil
    }
    
    func switchView(_ canvas: AgoraRtcVideoCanvas?) {
        let parent = removeFromParent(canvas)
        if parent == localContainer {
            canvas!.view!.frame.size = remoteContainer.frame.size
            remoteContainer.addSubview(canvas!.view!)
        } else if parent == remoteContainer {
            canvas!.view!.frame.size = localContainer.frame.size
            localContainer.addSubview(canvas!.view!)
        }
    }
    
    //******************************* Agora module end *****************************//
    
	
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

        self.videoCallStatusListner(self.roomID)
        
        if(type == 0){
            loadPerson()
        }else{
            loadGroup(self.group!)
        }
	}

	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

		return .portrait
	}

	
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {

		return .portrait
	}

	
	override var shouldAutorotate: Bool {

		return false
	}

	// MARK: - Realm methods
	
	func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: self.receiver)

        labelInitials.text = nil
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.imageUser.image = image
                self.labelInitials.text = nil
            }
            else {
                self.imageUser.image = UIImage(named: "ic_default_profile")
            }
        }

        labelName.text = callString
	}
    
    func loadGroup(_ group:Group) {

        self.labelInitials.text = nil
        MediaDownload.startGroup(group.objectId, pictureAt: group.pictureAt) { image, error in
            if (error == nil) {
                self.imageUser.image = image
                
            }
            else {
                self.imageUser.image = UIImage(named: "ic_default_profile")
            }
        }
        labelName.text = callString
        
        
    }
	// MARK: - User actions
	
	@objc func actionTap() {
		uiv_muteswitch.isHidden = !uiv_muteswitch.isHidden
	}

	
	@IBAction func actionAnswer(_ sender: Any) {
        self.joinAction()
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.accept.rawValue
        
        FirebaseAPI.sendVideoCallStatus(status, self.roomID) { (isSuccess, data) in
            
        }
		//call?.answer()
	}

	// MARK: - Helper methods
	
	func setOutGoingUI() {

		//videoController?.remoteView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
		//videoController?.localView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)

		viewDetails.isHidden = false

        labelStatus.text = "Calling..."
        labelStatus.textColor = .white
		uiv_anwserhangup.isHidden = true
		uiv_muteswitch.isHidden = true
        uiv_power.isHidden = true
        uiv_request.isHidden = false

		//viewEnded.isHidden = true
        localContainer.isHidden = true
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.outgoing.rawValue
        FirebaseAPI.sendVideoCallStatus(status, self.roomID) { (isSuccess, data) in
        }
	}

	
	func setIncomingUI() {

		//videoController?.remoteView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
		//videoController?.localView().frame = CGRect(x: 20, y: 20, width: 70, height: 100)

		viewDetails.isHidden = false

		labelStatus.text = "Incomming..."
        labelStatus.textColor = .white
        localContainer.isHidden = true
		uiv_anwserhangup.isHidden = false // answer , hangout
		uiv_muteswitch.isHidden = true // mute, switch
        uiv_power.isHidden = true //one call hangout
        uiv_request.isHidden = true
		//viewEnded.isHidden = true
	}

    
    func updateEnd() {
        self.viewDetails.isHidden = false
        self.labelStatus.text = "End"
        labelStatus.textColor = .white
        self.uiv_muteswitch.isHidden = true
        self.uiv_anwserhangup.isHidden = true
        self.uiv_power.isHidden = false
        self.uiv_request.isHidden = true
        self.remoteContainer.isHidden = true
        self.remoteVideoMutedIndicator.isHidden = true
        self.localVideoMutedIndicator.isHidden = true
        self.localContainer.isHidden = true
    }
}

// MARK: - SINCallDelegate
/*
extension CallVideoView: SINCallDelegate {

	
	func callDidProgress(_ call: SINCall?) {
        self.call = call
		audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
	}

	
	func callDidEstablish(_ call: SINCall?) {
        self.imageUser.isHidden = true
    
        self.labelName.isHidden = true
		audioController?.stopPlayingSoundFile()
		audioController?.enableSpeaker()
        
		setIncomingUI()
	}

	
	func callDidEnd(_ call: SINCall?) {

		audioController?.stopPlayingSoundFile()
		audioController?.disableSpeaker()

		updateDetails3()

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {  
			self.dismiss(animated: true)
		}
	}
}
*/


extension CallVideoView: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteStateReason, elapsed: Int) {
        print("remotestatechagne==>",state.rawValue)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let parent: UIView = remoteContainer
        if remoteVideo != nil {
            return
        }

        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: parent.frame.size))
        remoteVideo = AgoraRtcVideoCanvas()
        remoteVideo!.view = view
        remoteVideo!.renderMode = .hidden
        remoteVideo!.uid = uid
        parent.addSubview(remoteVideo!.view!)
        if let agoraKit = self.agoraKit{
            agoraKit.setupRemoteVideo(remoteVideo!)
        }
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        isRemoteVideoRender = true
        
        var parent: UIView = remoteContainer
        if let it = localVideo, let view = it.view {
            if view.superview == parent {
                parent = localContainer
            }
        }
        if remoteVideo != nil {
            return
        }
        
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: parent.frame.size))
        remoteVideo = AgoraRtcVideoCanvas()
        remoteVideo!.view = view
        remoteVideo!.renderMode = .hidden
        remoteVideo!.uid = uid
        parent.addSubview(remoteVideo!.view!)
        if let agoraKit = self.agoraKit{
            agoraKit.setupRemoteVideo(remoteVideo!)
        }
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        isRemoteVideoRender = false
        if let it = remoteVideo, it.uid == uid {
            removeFromParent(it)
            remoteVideo = nil
        }
        // dismisss action
        print("offline")
        DispatchQueue.main.async {
            self.updateEnd()
        }
    }
    
    /// Occurs when a remote user’s video stream playback pauses/resumes.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - muted: YES for paused, NO for resumed.
    ///   - byUid: User ID of the remote user.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
        isRemoteVideoRender = !muted
    }
    
    /// Reports a warning during SDK runtime.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - warningCode: Warning code
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        //logVC?.log(type: .warning, content: "did occur warning, code: \(warningCode.rawValue)")
    }
    
    /// Reports an error during SDK runtime.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - errorCode: Error code
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        //logVC?.log(type: .error, content: "did occur error, code: \(errorCode.rawValue)")
    }
}
