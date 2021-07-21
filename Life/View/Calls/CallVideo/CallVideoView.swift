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
import SwiftyAvatar
//-------------------------------------------------------------------------------------------------------------------------------------------------
class CallVideoView: UIViewController {

	@IBOutlet var viewBackground: UIView!
	@IBOutlet var viewDetails: UIView!
	@IBOutlet var imageUser: SwiftyAvatar!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStatus: UILabel!
	@IBOutlet var viewButtons1: UIView!
	@IBOutlet var viewButtons2: UIView!
	@IBOutlet var buttonMute: UIButton!
	@IBOutlet var buttonSwitch: UIButton!
	@IBOutlet var viewEnded: UIView!

	private var person: Person!

	private var incoming = false
	private var outgoing = false
	private var muted = false
	private var switched = false

<<<<<<< HEAD
	private var call: SINCall?
	private var audioController: SINAudioController?
	private var videoController: SINVideoController?
    private var personsFullName:String?
    private var callString = ""
    private var type = 0
    private var group: Group?
	//---------------------------------------------------------------------------------------------------------------------------------------------
=======
	//private var call: SINCall?
	//private var audioController: SINAudioController?
	//private var videoController: SINVideoController?

	/*
>>>>>>> master
	init(call: SINCall?) {

		super.init(nibName: nil, bundle: nil)

		self.isModalInPresentation = true
		self.modalPresentationStyle = .fullScreen

		let app = UIApplication.shared.delegate as? AppDelegate

		self.call = call
		call?.delegate = self

		audioController = app?.client?.audioController()
		videoController = app?.client?.videoController()
<<<<<<< HEAD
        incoming = true
        
        callString = (self.call?.headers["name"])! as! String
	}
=======
	}*/
>>>>>>> master

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(userId: String) {
        
		super.init(nibName: nil, bundle: nil)
        let recipentUser = realm.object(ofType: Person.self, forPrimaryKey: userId)
        callString = recipentUser!.fullname
		self.isModalInPresentation = true
		self.modalPresentationStyle = .fullScreen

		let app = UIApplication.shared.delegate as? AppDelegate
<<<<<<< HEAD

        personsFullName = Persons.fullname()
        app?.callKitProvider?.setGroupCall(false)
        //DispatchQueue.main.asyncAfter(deadline: .now()+1) {
        self.call = app?.client?.call().callUserVideo(withId: userId, headers: ["name": Persons.fullname()])
            self.call?.delegate = self

            self.audioController = app?.client?.audioController()
            self.videoController = app?.client?.videoController()
        //}
        outgoing = true
		
=======
/*
		call = app?.client?.call().callUserVideo(withId: userId, headers: ["name": Persons.fullname()])
		call?.delegate = self

		audioController = app?.client?.audioController()
		videoController = app?.client?.videoController()*/
>>>>>>> master
	}
    init(group: Group, persons: [String]) {
        
        super.init(nibName: nil, bundle: nil)
        type = 1
        self.group = group
        callString = group.name
        print(callString)
        outgoing = true
        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen

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
        self.videoController = app?.client?.videoController()
        
    }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
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
		videoController?.remoteView().addGestureRecognizer(gestureRecognizer)
		gestureRecognizer.cancelsTouchesInView = false
*/
		buttonMute.setImage(UIImage(named: "callvideo_mute1"), for: .normal)
		buttonMute.setImage(UIImage(named: "callvideo_mute1"), for: .highlighted)

		buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
		buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)

<<<<<<< HEAD
        if (incoming) { updateDetails2() }
        if (outgoing) { updateDetails1() }
=======
		//incoming = (call?.direction == .incoming)
		//outgoing = (call?.direction == .outgoing)
>>>>>>> master
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

        if(type == 0){
            loadPerson()
        }else{
            loadGroup(self.group!)
        }

		
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

<<<<<<< HEAD
			labelName.text = callString
		}
=======
			labelName.text = person.fullname
		}*/
>>>>>>> master
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
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionTap() {

		viewButtons2.isHidden = !viewButtons2.isHidden
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionMute(_ sender: Any) {
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

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHangup(_ sender: Any) {
<<<<<<< HEAD
        
        call?.hangup()
        
=======

		//call?.hangup()
>>>>>>> master
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionAnswer(_ sender: Any) {

		//call?.answer()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionSwitch(_ sender: Any) {

		if (switched) {
			switched = false
			buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
			buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)
			//videoController?.captureDevicePosition = .front
		} else {
			switched = true
			buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
			buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)
			//videoController?.captureDevicePosition = .back
		}
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails1() {

		let screenWidth = UIScreen.main.bounds.size.width
		let screenHeight = UIScreen.main.bounds.size.height

		//videoController?.remoteView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
		//videoController?.localView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)

		viewDetails.isHidden = false

        labelStatus.text = "Calling...".localized

		viewButtons1.isHidden = outgoing
		viewButtons2.isHidden = incoming

		viewEnded.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails2() {

		let screenWidth = UIScreen.main.bounds.size.width
		let screenHeight = UIScreen.main.bounds.size.height

		//videoController?.remoteView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
		//videoController?.localView().frame = CGRect(x: 20, y: 20, width: 70, height: 100)

		viewDetails.isHidden = true

		labelStatus.text = nil

		viewButtons1.isHidden = true
		viewButtons2.isHidden = false

		viewEnded.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails3() {

		viewDetails.isHidden = false

        labelStatus.text = "Ended".localized

		viewEnded.isHidden = false
	}
}

// MARK: - SINCallDelegate
/*
extension CallVideoView: SINCallDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidProgress(_ call: SINCall?) {
        self.call = call
		audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidEstablish(_ call: SINCall?) {
        self.imageUser.isHidden = true
    
        self.labelName.isHidden = true
		audioController?.stopPlayingSoundFile()
		audioController?.enableSpeaker()
        
		updateDetails2()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
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
