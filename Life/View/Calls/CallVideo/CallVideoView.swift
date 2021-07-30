

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
	@IBOutlet var viewButtons1: UIView!
	@IBOutlet var viewButtons2: UIView!
    @IBOutlet var viewButtons3: UIView!
	//@IBOutlet var buttonMute: UIButton!
	//@IBOutlet var buttonSwitch: UIButton!
	@IBOutlet var viewEnded: UIView!

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
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    var videoStatusHandle: UInt?
    
    var agoraKit: AgoraRtcEngineKit!
    var localVideo: AgoraRtcVideoCanvas?
    var remoteVideo: AgoraRtcVideoCanvas?
    var roomID: String = ""
    var receiver: String = ""
    var isRemoteVideoRender: Bool = true {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    remoteContainer.isHidden = !isRemoteVideoRender
                } else if view.superview == remoteContainer {
                }
            }
        }
    }
    
    var isLocalVideoRender: Bool = false {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    //localVideoMutedIndicator.isHidden = isLocalVideoRender
                } else if view.superview == remoteContainer {
                   // remoteVideoMutedIndicator.isHidden = isLocalVideoRender
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
        print(callString)
        
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

        
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConstant.agoraAppID, delegate: self)
        setupVideo()
        
		micButton.setImage(UIImage(named: "callvideo_mute1"), for: .normal)
        micButton.setImage(UIImage(named: "callvideo_mute1"), for: .highlighted)

		cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
        cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)

        if (incoming) { updateDetails2() }
        if (outgoing) { updateDetails1() }
        
        
        
	}
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let videoStatusHandle = videoStatusHandle{
            FirebaseAPI.removeVideoCallListnerObserver(self.roomID, videoStatusHandle)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    func videoCallStatusListner(_ roomId : String)  {
        self.videoStatusHandle = FirebaseAPI.setVideoCallAddListener(roomId){ [self] (statusModel) in
            print(statusModel)
        }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.joinAction()
                }
                
                break
            case 5:
                break
            case 6:
                break
                
            default:
                print("default")
            }
        }
    }
    
    func joinAction() {
        
        self.localContainer.isHidden = false
        self.remoteContainer.isHidden = false
        self.viewEnded.isHidden = true
        setupLocalVideo()
        joinChannel()
        self.viewDetails.isHidden = true
        self.viewButtons1.isHidden = true
        self.viewButtons2.isHidden = false
        self.viewButtons3.isHidden = false
    }
    
    //******************************* Agora module start *****************************//
    
    func setupVideo() {
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
        agoraKit.setupLocalVideo(localVideo)
    }
    
    func joinChannel() {
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

    func leaveChannel() {
        // leave channel and end chat
        agoraKit.leaveChannel(nil)
        isRemoteVideoRender = false
        isLocalVideoRender = false
        isStartCalling = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func actionHangup(_ sender: Any) {
        ref.child("video_call").child(self.roomID).removeValue()
        self.leaveChannel()
        self.dismiss(animated: true, completion: nil)
        //call?.hangup()
        
    }
    
    @IBAction func actionMute(_ sender: Any) {
        let sender = sender as! UIButton
        sender.isSelected.toggle()
        // mute local audio
        agoraKit.muteLocalAudioStream(sender.isSelected)
/*
        if (muted) {
            muted = false
            buttonMute.setImage(UIImage(named: "callvideo_mute1"), for: .normal)
            buttonMute.setImage(UIImage(named: "callvideo_mute1"), for: .highlighted)
            audioController?.unmute()
        } else {
            muted = true
            buttonMute.setImage(UIImage(named: "callvideo_mute2"), for: .normal)
            buttonMute.setImage(UIImage(named: "callvideo_mute2"), for: .highlighted)
            audioController?.mute()
        }
*/
    }
    
    @IBAction func actionSwitch(_ sender: Any) {
        let sender = sender as! UIButton
        sender.isSelected.toggle()
        agoraKit.switchCamera()
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
/*
		if let remoteUserId = call?.remoteUserId {
			person = realm.object(ofType: Person.self, forPrimaryKey: remoteUserId)

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
		}*/
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

		viewButtons2.isHidden = !viewButtons2.isHidden
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
	
	func updateDetails1() {

		//videoController?.remoteView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
		//videoController?.localView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)

		viewDetails.isHidden = false

        labelStatus.text = "Calling..."

		viewButtons1.isHidden = outgoing
		viewButtons2.isHidden = incoming

		viewEnded.isHidden = true
        localContainer.isHidden = true
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.outgoing.rawValue
        
        FirebaseAPI.sendVideoCallStatus(status, self.roomID) { (isSuccess, data) in
            
        }
	}

	
	func updateDetails2() {

		//videoController?.remoteView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
		//videoController?.localView().frame = CGRect(x: 20, y: 20, width: 70, height: 100)

		viewDetails.isHidden = false

		labelStatus.text = "Incomming..."
        localContainer.isHidden = true
		viewButtons1.isHidden = false // answer , hangout
		viewButtons2.isHidden = true // mute, switch
        viewButtons3.isHidden = true //one call hangout

		viewEnded.isHidden = true
	}

	
	func updateDetails3() {

		viewDetails.isHidden = false

        labelStatus.text = "Ended"

		viewEnded.isHidden = false
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
        
		updateDetails2()
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
        if state.rawValue == 0{
            self.leaveChannel()
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
//            let toVC = storyBoard.instantiateViewController( withIdentifier: VCs.MESSAGESENDNAV)
//            toVC.modalPresentationStyle = .fullScreen
//            self.present(toVC, animated: false, completion: nil)
        }
    }
    
    /*func rtcEngineVideoDidStop(_ engine: AgoraRtcEngineKit) {
        print("rtcEngineVideoDidStop")
    }
    
    func rtcEngineTranscodingUpdated(_ engine: AgoraRtcEngineKit) {
        print("rtcEngineTranscodingUpdated")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        print("reportRtcStats")
    }
    
    func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        print("rtcEngineConnectionDidLost")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        print("didLeaveChannelWith")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        print("remoteVideoStats")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didReceive event: AgoraChannelMediaRelayEvent) {
        print("didReceive event")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionStateType, reason: AgoraConnectionChangedReason) {
        print("connectionChangedTo state")
    }*/
    
    /// Callback to handle the event when the first frame of a remote video stream is decoded on the device.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - uid: user id
    ///   - size: the height and width of the video frame
    ///   - elapsed: Time elapsed (ms) from the local user calling JoinChannel method until the SDK triggers this callback.
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        isRemoteVideoRender = true
        
        var parent: UIView = remoteContainer
        if let it = localVideo, let view = it.view {
            if view.superview == parent {
                parent = localContainer
            }
        }
        
        // Only one remote video view is available for this
        // tutorial. Here we check if there exists a surface
        // view tagged as this uid.
        if remoteVideo != nil {
            return
        }
        
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: parent.frame.size))
        remoteVideo = AgoraRtcVideoCanvas()
        remoteVideo!.view = view
        remoteVideo!.renderMode = .hidden
        remoteVideo!.uid = uid
        parent.addSubview(remoteVideo!.view!)
        agoraKit.setupRemoteVideo(remoteVideo!)
    }
    
    /// Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - uid: ID of the user or host who leaves a channel or goes offline.
    ///   - reason: Reason why the user goes offline
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        isRemoteVideoRender = false
        if let it = remoteVideo, it.uid == uid {
            removeFromParent(it)
            remoteVideo = nil
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
