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

import Sinch
import MediaPlayer

//-------------------------------------------------------------------------------------------------------------------------------------------------
class CallAudioView: UIViewController {

	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStatus: UILabel!
	@IBOutlet var viewButtons: UIView!
	@IBOutlet var buttonMute: UIButton!
	@IBOutlet var buttonSpeaker: UIButton!
	@IBOutlet var buttonVideo: UIButton!
	@IBOutlet var viewButtons1: UIView!
	@IBOutlet var viewButtons2: UIView!
	@IBOutlet var viewEnded: UIView!
    @IBOutlet weak var dottedProgressView: UIView!
    
    private var dottedProgressBar:DottedProgressBar?
    
	private var person: Person!
	private var timer: Timer?

	private var incoming = false
	private var outgoing = false
	private var muted = false
	private var speaker = false

	private var call: SINCall?
	private var audioController: SINAudioController?
    private var personsFullName:String?
    private var type = 0
    private var group:Group?
    private var callString = ""
	//---------------------------------------------------------------------------------------------------------------------------------------------
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
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(userId: String) {
		super.init(nibName: nil, bundle: nil)
        let recipentUser = realm.object(ofType: Person.self, forPrimaryKey: userId)
        callString = recipentUser!.fullname
		self.isModalInPresentation = true
		self.modalPresentationStyle = .fullScreen

		let app = UIApplication.shared.delegate as? AppDelegate
        
        
        app?.callKitProvider?.setGroupCall(false)
        //DispatchQueue.main.asyncAfter(deadline: .now()+1) {
        self.call = app?.client?.call().callUser(withId: userId, headers: ["name": Persons.fullname()])
            self.call?.delegate = self
            
            self.audioController = app?.client?.audioController()
        outgoing = true
        
	}
    init(group: Group, persons: [String]) {
        
        super.init(nibName: nil, bundle: nil)
        type = 1
        self.group = group
        callString = group.name
        outgoing = true
        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen

        let app = UIApplication.shared.delegate as? AppDelegate
        app?.callKitProvider?.setGroupCall(true)
        for person in persons {
            if(person == AuthUser.userId()){
                continue
            }
            let call = app?.client?.call().callUser(withId: person, headers: ["name": callString])
            call?.delegate = self
            
            app?.callKitProvider?.insertCall(call: call!)
        }
        
       
        self.audioController = app?.client?.audioController()
        
    }

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		audioController?.unmute()
		audioController?.disableSpeaker()

		buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .normal)
		buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .highlighted)

		buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .normal)
		buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .highlighted)

		buttonVideo.setImage(UIImage(named: "callaudio_video1"), for: .normal)
		buttonVideo.setImage(UIImage(named: "callaudio_video1"), for: .highlighted)

		
        if (incoming) { updateDetails2() }
        if (outgoing) { updateDetails1() }
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
    @objc func volumeDidChange(notification: NSNotification) {
        //// print("VOLUME CHANGING", AVAudioSession.sharedInstance().outputVolume)

        let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
        let progress = volume / 1.0 * 6
        dottedProgressBar?.setProgress(value: Int(progress))
        // print("Device Volume:\(volume)")
    }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		
        if(type==0){
            loadPerson()
        }else{
            loadGroup(self.group!)
        }
        labelName.text = callString
        
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

		return .portrait
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {

		return .portrait
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var shouldAutorotate: Bool {

		return false
	}

	// MARK: - Realm methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadPerson() {

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

	// MARK: - Timer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
    func timerStart(_ call: SINCall?) {

		timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
			self.updateStatus(call)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func timerStop() {

		timer?.invalidate()
		timer = nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
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
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionMute(_ sender: Any) {

		if (muted) {
			muted = false
			buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .normal)
			buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .highlighted)
			audioController?.unmute()
		} else {
			muted = true
			buttonMute.setImage(UIImage(named: "callaudio_mute3"), for: .normal)
			buttonMute.setImage(UIImage(named: "callaudio_mute3"), for: .highlighted)
			audioController?.mute()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionSpeaker(_ sender: Any) {

		if (speaker) {
			speaker = false
			buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .normal)
			buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .highlighted)
			audioController?.disableSpeaker()
		} else {
			speaker = true
			buttonSpeaker.setImage(UIImage(named: "callaudio_speaker3"), for: .normal)
			buttonSpeaker.setImage(UIImage(named: "callaudio_speaker3"), for: .highlighted)
			audioController?.enableSpeaker()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionVideo(_ sender: Any) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHangup(_ sender: Any) {

		call?.hangup()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionAnswer(_ sender: Any) {

		call?.answer()
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails1() {

        labelStatus.text = "Calling...".localized

		viewButtons.isHidden = incoming
		viewButtons1.isHidden = outgoing
		viewButtons2.isHidden = incoming

		viewEnded.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails2() {

		labelStatus.text = "00:00"

		viewButtons.isHidden = false
		viewButtons1.isHidden = true
		viewButtons2.isHidden = false

		viewEnded.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails3() {

        labelStatus.text = "Ended".localized

		viewEnded.isHidden = false
	}
}

// MARK: - SINCallDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension CallAudioView: SINCallDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidProgress(_ call: SINCall?) {

		audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidEstablish(_ call: SINCall?) {

		timerStart(call)
		audioController?.stopPlayingSoundFile()
		updateDetails2()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidEnd(_ call: SINCall?) {

		timerStop()
		audioController?.stopPlayingSoundFile()
		updateDetails3()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {            
			self.dismiss(animated: true)
		}
	}
}
