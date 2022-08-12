//
// Copyright (c) 2020 Related Code
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import MediaPlayer
import SwiftyAvatar
import UIKit
import AgoraRtcKit
import FirebaseDatabase
import FirebaseFirestore
import Sinch
import JamitFoundation
import CallKit


//----
class CallAudioView: UIViewController {

    private enum Constants {
        static let adUnitId: String = "ca-app-pub-9167808110872900/4939430243"
    }


    
    @IBOutlet var imageUser: UIImageView!
    @IBOutlet var labelInitials: UILabel!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelStatus: UILabel!
    @IBOutlet var uiv_mutespeaker: UIView!
    
    @IBOutlet weak var adViewContainer: UIView!
    @IBOutlet var buttonMute: UIButton!
    @IBOutlet var buttonVideo: UIButton!
    @IBOutlet weak var buttonSpeaker: UIImageView!
    
    @IBOutlet weak var buttonBack: UIButton!
    
    
    @IBOutlet var uiv_answerdecline: UIView!
    @IBOutlet var uiv_power: UIView!
    
    @IBOutlet weak var uiv_requst: UIView!
    @IBOutlet weak var dottedProgressView: UIView!

    private let callController = CXCallController()
    
    let ref = Database.database().reference()
    private var dottedProgressBar:DottedProgressBar?
    
    private var person: Person!
    private var timer: Timer?

    var incoming = false
    var outgoing = false
    private var muted = false
    private var speaker = false

    private var personsFullName:String?
    private var type = 0
    private var group:Group?
    private var callString = ""

    var comingFromForeground: Bool = false

    var roomID = ""
    var receiver: String = ""
    var sender: String = ""
    var agoraKit: AgoraRtcEngineKit?
    
    var voiceStatusHandle: UInt?
    var voiceStatusRemoveHandle: UInt?
    
    private var audioController: SINAudioController?
    let app = UIApplication.shared.delegate as? AppDelegate
    
    private var stopSelf = false
    private var joined = false
    private var callingStart: Date?

    private lazy var adView: AdView = .instantiate()
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        let recipentUser = realm.object(ofType: Person.self, forPrimaryKey: userId)
        callString = recipentUser!.getFullName()

        let app = UIApplication.shared.delegate as? AppDelegate
        audioController = app?.client?.audioController()

        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen
    }

    init(group: Group, persons: [String]) {
        
        super.init(nibName: nil, bundle: nil)
        type = 1
        self.group = group
        callString = group.name
        
        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen

        _ = UIApplication.shared.delegate as? AppDelegate
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Timer methods
    
    func timerStart(_ now: Date) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.updateStatus(now)
        }
    }

    
    func timerStop() {
        timer?.invalidate()
        timer = nil
    }

    func updateStatus(_ now: Date) {
        
        let interval = Date().timeIntervalSince(now)
        let seconds = Int(interval) % 60
        let minutes = Int(interval) / 60
        labelStatus.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        buttonMute.setImage(UIImage(named: "ic_voice_off"), for: .normal)
        buttonMute.setImage(UIImage(named: "ic_voice_off"), for: .highlighted)

        buttonSpeaker.image = UIImage(named: "ic_audio_off")

        buttonVideo.setImage(UIImage(named: "ic_video_off"), for: .normal)
        buttonVideo.setImage(UIImage(named: "ic_video_off"), for: .highlighted)
        
        
        self.buttonBack.setTitle("", for: .normal)
        self.buttonBack.setImage(UIImage(named: "ic_arrow_back")?.resize(width: 17, height: 30).withRenderingMode(.alwaysTemplate), for: .normal)
        
        if (incoming && !comingFromForeground) { setIncomingUI() }
        if (outgoing && !comingFromForeground) { setOutgoingUI() }
        // dotted progressview
        dottedProgressBar = DottedProgressBar()
        dottedProgressBar?.progressAppearance = DottedProgressBar.DottedProgressAppearance(dotRadius: 6.0, dotsColor: UIColor(hexString: "#33000000")!, dotsProgressColor: UIColor(hexString: "#00406E")!, backColor: UIColor.clear)
        dottedProgressBar?.frame = CGRect(x: 0, y: 0, width: dottedProgressView.frame.width, height: dottedProgressView.frame.height)
        dottedProgressView.addSubview(dottedProgressBar!)
        dottedProgressBar?.setNumberOfDots(6)
        dottedProgressBar?.stopAnimate()
        
        // get audio volume
        let audioSession = AVAudioSession.sharedInstance()
        
        /// Volume View
        let volumeView = MPVolumeView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        volumeView.isHidden = false
        volumeView.alpha = 0.01
        view.addSubview(volumeView)
        /// Notification Observer
        if #available(iOS 15.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(self.volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "SystemVolumeDidChange"), object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_AudioVolumeNotificationParameter"), object: nil)
        }
        
        
        
        let progress = Int(audioSession.outputVolume / 1.0 * 6)
        dottedProgressBar?.setProgress(value: progress)
        if type == 1 && !comingFromForeground{
            self.joinAction()
        }

        if comingFromForeground {
            setConnectedUI()
        }
    }
    
    // ------ call accept status listener
    func voiceCallStatusListner(_ roomId : String)  {
        self.voiceStatusHandle = FirebaseAPI.setVoiceCallChangeListener(roomId){ [self] (status) in
            if status == Status.accept.rawValue{
                self.joinAction()
            }
        }
        
        self.voiceStatusRemoveHandle = FirebaseAPI.setVoiceCallRemoveListener(roomId){ [self] (receiverid) in
            self.audioController?.stopPlayingSoundFile()
            if outgoing {
                if let callingStart = callingStart {
                    timerStop()
                    var interval = 0
                    interval = Int(Date().timeIntervalSince(callingStart))
                    Messages.sendCalling(chatId: self.roomID, recipientId: self.receiver, duration: "\(interval)")
                    self.leaveChannel()
                    self.dismiss(animated: true, completion: nil)
                    
                    return
                }
                
                self.labelStatus.text = "Declined"
                self.labelStatus.textColor = .red
                if self.stopSelf {
                    Messages.sendCalling(chatId: self.roomID, recipientId: self.receiver, type: .CANCELLED_CALL)
                } else {
                    Messages.sendCalling(chatId: self.roomID, recipientId: self.receiver, type: .MISSED_CALL)
                }
            }else{
                self.leaveChannel()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func joinAction() {
        //------ agora setup and join action
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConstant.agoraAppID, delegate: self)
        self.joined = true
        // Allows a user to join a channel.
        if let agoraKit = self.agoraKit{
            agoraKit.joinChannel(byToken: "", channelId: roomID, info:nil, uid:0) {(sid, uid, elapsed) -> Void in
                // Joined channel "demoChannel"
                agoraKit.setEnableSpeakerphone(false)
                UIApplication.shared.isIdleTimerDisabled = true
            }
            self.setConnectedUI()
        }
    }
    
    @objc func volumeDidChange(notification: NSNotification) {
        let audioSession = AVAudioSession.sharedInstance()
        
        let progress = Int(audioSession.outputVolume / 1.0 * 6)
        
        if let currentVolume = self.dottedProgressBar?.currentProgress {
            if currentVolume != progress {
                DispatchQueue.main.async { [self] in
                    dottedProgressBar?.setProgress(value: progress)
                }
            }            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        if !comingFromForeground {
        if let callKit = app?.callKitProvider {
            callKit.removeStateListner()
            callKit.removeReport()
        }
        }
        if(type==0){
            loadPerson()
        }else{
            loadGroup(self.group!)
        }

        if  let recipentUser = realm.object(ofType: Person.self, forPrimaryKey: sender) {
        callString = recipentUser.getFullName()
        }
        labelName.text = callString

        if !comingFromForeground {
        self.voiceCallStatusListner(self.roomID)
        }

        adView.frame = adViewContainer.bounds
        adViewContainer.addSubview(adView)

        adView.model = AdViewModel(
            unitId: Constants.adUnitId,
            adSize: CGSize(width: 300, height: 250),
            rootViewController: self
        )
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
        let primaryKey = outgoing ? receiver : sender
        person = realm.object(ofType: Person.self, forPrimaryKey: primaryKey)
        labelInitials.text = nil
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.imageUser.image = image
            }
            else {
                self.imageUser.image = UIImage(named: "ic_default_profile")
            }
        }
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
    }
    
    // MARK: - User actions
    
    @IBAction func actionMute(_ sender: Any) {
        if (muted) {
            muted = false
            buttonMute.setImage(UIImage(named: "ic_voice_off"), for: .normal)
            buttonMute.setImage(UIImage(named: "ic_voice_off"), for: .highlighted)
        } else {
            muted = true
            buttonMute.setImage(UIImage(named: "ic_voice_on"), for: .normal)
            buttonMute.setImage(UIImage(named: "ic_voice_on"), for: .highlighted)
        }
        if let agoraKit = self.agoraKit{
            agoraKit.muteLocalAudioStream(muted)
        }
    }

    
    @IBAction func actionSpeaker(_ sender: Any) {
        if (speaker) {
            speaker = false
            buttonSpeaker.image = UIImage(named: "ic_audio_off")
        } else {
            speaker = true
            buttonSpeaker.image = UIImage(named: "ic_audio_on")
        }
        if let agoraKit = self.agoraKit{
            agoraKit.setEnableSpeakerphone(speaker)
        }
    }


    func leaveChannel() {
        if let agoraKit = self.agoraKit{
            agoraKit.leaveChannel(nil)
            UIApplication.shared.isIdleTimerDisabled = false
            UIDevice.current.isProximityMonitoringEnabled = false
        }
    }
    
    
    @IBAction func actionHangup(_ sender: Any) {
        self.leaveChannel()
        ref.child("voice_call").child(self.roomID).removeValue()
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if let callKit = self.app?.callKitProvider {
                callKit.removeStateListner()
                callKit.removeCall()
            }
            if let voiceStatusHandle = self.voiceStatusHandle {
                FirebaseAPI.removeVoiceCallListnerObserver(self.roomID, voiceStatusHandle)
            }
            if let voiceStatusRemoveHandle = self.voiceStatusRemoveHandle{
                FirebaseAPI.removeVoiceCallRemoveListnerObserver(self.roomID, voiceStatusRemoveHandle)
            }

            self.app?.callKitProvider?.endReport()
            NotificationCenter.default.removeObserver(self)

            if let app = self.app {
                if let callKitProvider = app.callKitProvider {
                    self.end(uuid: callKitProvider.outgoingUUID ?? UUID())
                }
            }

        }
    }

    func end(uuid: UUID) {
      let endCallAction = CXEndCallAction(call: uuid)
      let transaction = CXTransaction(action: endCallAction)

      requestTransaction(transaction)
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

    
    @IBAction func actionRequestHangup(_ sender: Any) {
        if let button = sender as? UIButton, button == self.buttonBack, self.joined {
            return
        }
        self.stopSelf = true
        
        DispatchQueue.main.async {
            self.audioController?.stopPlayingSoundFile()
        }
        ref.child("voice_call").child(self.roomID).removeValue()
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if let callKit = self.app?.callKitProvider {
                callKit.removeStateListner()
                callKit.removeCall()
            }
            if let voiceStatusHandle = self.voiceStatusHandle{
                FirebaseAPI.removeVoiceCallListnerObserver(self.roomID, voiceStatusHandle)
            }
            if let voiceStatusRemoveHandle = self.voiceStatusRemoveHandle{
                FirebaseAPI.removeVoiceCallRemoveListnerObserver(self.roomID, voiceStatusRemoveHandle)
            }
            NotificationCenter.default.removeObserver(self)
            self.app?.callKitProvider?.endReport()

            if let app = self.app {
                if let callKitProvider = app.callKitProvider {
                    self.end(uuid: callKitProvider.outgoingUUID ?? UUID())
                }
            }
        }
    }
    
    @IBAction func actionDecline(_ sender: Any) {
        DispatchQueue.main.async {
            self.audioController?.stopPlayingSoundFile()
        }
        ref.child("voice_call").child(self.roomID).removeValue()
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if let callKit = self.app?.callKitProvider {
                callKit.removeStateListner()
                callKit.removeCall()
            }
            if let voiceStatusHandle = self.voiceStatusHandle{
                FirebaseAPI.removeVoiceCallListnerObserver(self.roomID, voiceStatusHandle)
            }
            if let voiceStatusRemoveHandle = self.voiceStatusRemoveHandle{
                FirebaseAPI.removeVoiceCallRemoveListnerObserver(self.roomID, voiceStatusRemoveHandle)
            }
            NotificationCenter.default.removeObserver(self)
        }
    }

    @IBAction func pressedBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func actionAnswer(_ sender: Any) {
        self.joinAction()
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.accept.rawValue
        FirebaseAPI.sendVoiceCallStatus(status, self.roomID) { (isSuccess, data) in
        }

        //self.joinAction()
    }


    // MARK: - Helper methods
    
    func setOutgoingUI() {
        labelStatus.text = "Calling..."
        labelStatus.textColor = .lightGray
        uiv_mutespeaker.isHidden = true
        uiv_answerdecline.isHidden = true
        uiv_power.isHidden = true
        uiv_requst.isHidden = false
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.outgoing.rawValue
        FirebaseAPI.sendVoiceCallStatus(status, self.roomID) { (isSuccess, data) in
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.audioController?.enableSpeaker()
            self.audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
        }
    }
    
    func setIncomingUI() {
        labelStatus.text = "Incoming..."
        labelStatus.textColor = .lightGray
        uiv_mutespeaker.isHidden = true
        uiv_answerdecline.isHidden = false
        uiv_power.isHidden = true
        uiv_requst.isHidden = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.audioController?.enableSpeaker()
//            self.audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
//        }
        joinAction()
        self.joinAction()
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.accept.rawValue
        FirebaseAPI.sendVoiceCallStatus(status, self.roomID) { (isSuccess, data) in
        }
    }
    
    func setConnectedUI() {
        DispatchQueue.main.async {
            self.audioController?.stopPlayingSoundFile()
        }
        
        self.callingStart = Date()
        timerStart(Date())
        //labelStatus.text = "Connected"
        //labelStatus.textColor = .green
        uiv_mutespeaker.isHidden = false
        uiv_answerdecline.isHidden = true
        uiv_power.isHidden = false
        uiv_requst.isHidden = true
        UIDevice.current.isProximityMonitoringEnabled = true
    }

    
    func setEndUI() {
        labelStatus.text = "Ended"
        labelStatus.textColor = .lightGray
        uiv_mutespeaker.isHidden = true
        uiv_answerdecline.isHidden = true
        uiv_power.isHidden = false
        uiv_requst.isHidden = true
    }
}

extension CallAudioView: AgoraRtcEngineDelegate{
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteStateReason, elapsed: Int) {
        print("this is remoteaudiostatechage=====>",state.rawValue)
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStateChange state: AgoraAudioLocalState, error: AgoraAudioLocalError) {
        print("this is localaudiostatechage=====>",state.rawValue)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        self.leaveChannel()
        setEndUI()
    }
}

