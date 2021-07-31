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

//import Sinch
import MediaPlayer
import SwiftyAvatar
import UIKit
import AgoraRtcKit
import FirebaseDatabase
import FirebaseFirestore

//----
class CallAudioView: UIViewController {
    let ref = Database.database().reference()
    
    @IBOutlet var imageUser: UIImageView!
    @IBOutlet var labelInitials: UILabel!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelStatus: UILabel!
    @IBOutlet var uiv_mutespeaker: UIView!
    @IBOutlet var buttonMute: UIButton!
    @IBOutlet var buttonSpeaker: UIButton!
    @IBOutlet var buttonVideo: UIButton!
    @IBOutlet var uiv_answerdecline: UIView!
    @IBOutlet var uiv_power: UIView!
    
    @IBOutlet weak var uiv_requst: UIView!
    @IBOutlet weak var dottedProgressView: UIView!
    
    private var dottedProgressBar:DottedProgressBar?
    
    private var person: Person!
    private var timer: Timer?

    var incoming = false
    var outgoing = false
    private var muted = false
    private var speaker = false

    //private var call: SINCall?
    //private var audioController: SINAudioController?
    private var personsFullName:String?
    private var type = 0
    private var group:Group?
    private var callString = ""
    
    var roomID = ""
    var receiver: String = ""
    var agoraKit: AgoraRtcEngineKit?
    
    var voiceStatusHandle: UInt?
    var voiceStatusRemoveHandle: UInt?
    
    /*
    init(call: SINCall?) {

        super.init(nibName: nil, bundle: nil)

        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen

        let app = UIApplication.shared.delegate as? AppDelegate

        self.call = call
        self.call?.delegate = self
        incoming = true
        audioController = app?.client?.audioController()
        callString = (self.call?.headers["name"])! as! String
    }*/


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let voiceStatusHandle = voiceStatusHandle{
            FirebaseAPI.removeVoiceCallListnerObserver(self.roomID, voiceStatusHandle)
        }
        if let voiceStatusRemoveHandle = voiceStatusRemoveHandle{
            FirebaseAPI.removeVoiceCallRemoveListnerObserver(self.roomID, voiceStatusRemoveHandle)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    func voiceCallStatusListner(_ roomId : String)  {
        self.voiceStatusHandle = FirebaseAPI.setVoiceCallChangeListener(roomId){ [self] (status) in
            
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
        
        self.voiceStatusRemoveHandle = FirebaseAPI.setVoiceCallRemoveListener(roomId){ [self] (receiverid) in
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
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        let recipentUser = realm.object(ofType: Person.self, forPrimaryKey: userId)
        callString = recipentUser!.fullname
        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen

        _ = UIApplication.shared.delegate as? AppDelegate
        
        /*
        app?.callKitProvider?.setGroupCall(false)
        //DispatchQueue.main.asyncAfter(deadline: .now()+1) {
        self.call = app?.client?.call().callUser(withId: userId, headers: ["name": Persons.fullname()])
            self.call?.delegate = self
            
            self.audioController = app?.client?.audioController()*/
    }
    init(group: Group, persons: [String]) {
        
        super.init(nibName: nil, bundle: nil)
        type = 1
        self.group = group
        callString = group.name
        outgoing = true
        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen

        _ = UIApplication.shared.delegate as? AppDelegate
        /*
        app?.callKitProvider?.setGroupCall(true)
        for person in persons {
            if(person == AuthUser.userId()){
                continue
            }
            let call = app?.client?.call().callUser(withId: person, headers: ["name": callString])
            call?.delegate = self
            
            app?.callKitProvider?.insertCall(call: call!)
        }
        
       
        self.audioController = app?.client?.audioController()*/
        
    }

    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {

        super.viewDidLoad()

        //audioController?.unmute()
        //audioController?.disableSpeaker()

        buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .normal)
        buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .highlighted)

        buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .normal)
        buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .highlighted)

        buttonVideo.setImage(UIImage(named: "callaudio_video1"), for: .normal)
        buttonVideo.setImage(UIImage(named: "callaudio_video1"), for: .highlighted)

        
        if (incoming) { setIncomingUI() }
        if (outgoing) { setOutgoingUI() }
        // dotted progressview
        dottedProgressBar = DottedProgressBar()
        dottedProgressBar?.progressAppearance = DottedProgressBar.DottedProgressAppearance(dotRadius: 6.0, dotsColor: UIColor(hexString: "#33000000")!, dotsProgressColor: UIColor(hexString: "#00406E")!, backColor: UIColor.clear)
        dottedProgressBar?.frame = CGRect(x: 0, y: 0, width: 100, height: 24)
        dottedProgressView.addSubview(dottedProgressBar!)
        dottedProgressBar?.setNumberOfDots(6)
        
        // get audio volume
        let audioSession = AVAudioSession.sharedInstance()
        /*
        do{
            try! audioSession.setActive(true)
        }catch {
            print(error)
        }
 */
        /// Volume View
        let volumeView = MPVolumeView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        volumeView.isHidden = false
        volumeView.alpha = 0.01
        view.addSubview(volumeView)
        /// Notification Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        //audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
        let progress = audioSession.outputVolume / 1.0 * 6
        dottedProgressBar?.setProgress(value: Int(progress))
        
        
    }
    
    func joinAction() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConstant.agoraAppID, delegate: self)
        // Allows a user to join a channel.
        if let agoraKit = self.agoraKit{
            agoraKit.joinChannel(byToken: "", channelId: roomID, info:nil, uid:0) {[unowned self] (sid, uid, elapsed) -> Void in
                // Joined channel "demoChannel"
                agoraKit.setEnableSpeakerphone(false)
                UIApplication.shared.isIdleTimerDisabled = true
            }
            self.setConnectedUI()
        }
    }
    
    @objc func volumeDidChange(notification: NSNotification) {
        //// print("VOLUME CHANGING", AVAudioSession.sharedInstance().outputVolume)

        let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
        let progress = volume / 1.0 * 6
        dottedProgressBar?.setProgress(value: Int(progress))
        // print("Device Volume:\(volume)")
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        
        if(type==0){
            loadPerson()
        }else{
            loadGroup(self.group!)
        }
        labelName.text = callString
        self.voiceCallStatusListner(self.roomID)
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
                    
                }
                else {
                    self.imageUser.image = UIImage(named: "ic_default_profile")
                }
            }
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

        
        
    }

    // MARK: - Timer methods
    /*
    func timerStart(_ call: SINCall?) {

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.updateStatus(call)
        }
    }*/

    
    func timerStop() {

        timer?.invalidate()
        timer = nil
    }

    /*
    func updateStatus(_ call:SINCall?) {
        if(call == nil){
            labelStatus.isHidden = true
            return
        }
        if let date = call?.details.establishedTime {
            let interval = Date().timeIntervalSince(date)
            let seconds = Int(interval) % 60
            let minutes = Int(interval) / 60
            labelStatus.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }*/

    // MARK: - User actions
    
    @IBAction func actionMute(_ sender: Any) {
        //let sender = sender as! UIButton
        if (muted) {
            muted = false
            buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .normal)
            buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .highlighted)
            //audioController?.unmute()
        } else {
            muted = true
            buttonMute.setImage(UIImage(named: "callaudio_mute3"), for: .normal)
            buttonMute.setImage(UIImage(named: "callaudio_mute3"), for: .highlighted)
            //audioController?.mute()
        }
        
        //sender.isSelected = !sender.isSelected
        // Stops/Resumes sending the local audio stream.
        if let agoraKit = self.agoraKit{
            agoraKit.muteLocalAudioStream(muted)
        }
    }

    
    @IBAction func actionSpeaker(_ sender: Any) {
        //let sender = sender as! UIButton
        if (speaker) {
            speaker = false
            buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .normal)
            buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .highlighted)
            //audioController?.disableSpeaker()
        } else {
            speaker = true
            buttonSpeaker.setImage(UIImage(named: "callaudio_speaker3"), for: .normal)
            buttonSpeaker.setImage(UIImage(named: "callaudio_speaker3"), for: .highlighted)
            //audioController?.enableSpeaker()
        }
        
        //sender.isSelected = !sender.isSelected
        if let agoraKit = self.agoraKit{
            agoraKit.setEnableSpeakerphone(speaker)
        }
    }


    func leaveChannel() {
        if let agoraKit = self.agoraKit{
            agoraKit.leaveChannel(nil)
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    
    @IBAction func actionHangup(_ sender: Any) {
        self.leaveChannel()
        ref.child("voice_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionRequestHangup(_ sender: Any) {
        ref.child("voice_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDecline(_ sender: Any) {
        ref.child("voice_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func actionAnswer(_ sender: Any) {
        self.joinAction()
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.accept.rawValue
        
        FirebaseAPI.sendVoiceCallStatus(status, self.roomID) { (isSuccess, data) in
            
        }
        self.joinAction()
        //call?.answer()
    }

    // MARK: - Helper methods
    
    func setOutgoingUI() {
        labelStatus.text = "Calling..."
        labelStatus.textColor = .white
        uiv_mutespeaker.isHidden = true
        uiv_answerdecline.isHidden = true
        uiv_power.isHidden = true
        uiv_requst.isHidden = false
        //viewEnded.isHidden = true
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.outgoing.rawValue
        FirebaseAPI.sendVoiceCallStatus(status, self.roomID) { (isSuccess, data) in
        }
    }

    
    func setIncomingUI() {
        labelStatus.text = "Incoming..."
        labelStatus.textColor = .white
        uiv_mutespeaker.isHidden = true
        uiv_answerdecline.isHidden = false
        uiv_power.isHidden = true
        uiv_requst.isHidden = true
        //viewEnded.isHidden = true
    }
    
    func setConnectedUI() {
        labelStatus.text = "Connected"
        labelStatus.textColor = .green
        uiv_mutespeaker.isHidden = false
        uiv_answerdecline.isHidden = true
        uiv_power.isHidden = false
        uiv_requst.isHidden = true
    }

    
    func setEndUI() {
        labelStatus.text = "Ended"
        labelStatus.textColor = .white
        uiv_mutespeaker.isHidden = true
        uiv_answerdecline.isHidden = true
        uiv_power.isHidden = false
        uiv_requst.isHidden = true
        //viewEnded.isHidden = false
    }
}

/*
// MARK: - SINCallDelegate
extension CallAudioView: SINCallDelegate {

    
    func callDidProgress(_ call: SINCall?) {
        self.call = call
        audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
    }

    
    func callDidEstablish(_ call: SINCall?) {

        timerStart(call)
        audioController?.stopPlayingSoundFile()
        setIncomingUI()
    }

    
    func callDidEnd(_ call: SINCall?) {

        timerStop()
        audioController?.stopPlayingSoundFile()
        updateDetails3()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismiss(animated: true)
        }
    }
}
*/

extension CallAudioView: AgoraRtcEngineDelegate{
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteStateReason, elapsed: Int) {
        print("this is remoteaudiostatechage=====>",state.rawValue)
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStateChange state: AgoraAudioLocalState, error: AgoraAudioLocalError) {
        print("this is localaudiostatechage=====>",state.rawValue)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("offline")
        self.leaveChannel()
        setEndUI()
    }
}
