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

import AVKit

//-------------------------------------------------------------------------------------------------------------------------------------------------
class VideoView: UIViewController {
    
    var url: URL!
    private var controller: AVPlayerViewController?
    
    var customActionDone: (() -> ())? = nil
    var showsPlaybackControls: Bool = true
    var mute: Bool = false
    
    init(url: URL, showsPlaybackControls: Bool = true, mute: Bool = true) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.url = url
        self.showsPlaybackControls = showsPlaybackControls
        self.mute = mute
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        let notification = NSNotification.Name.AVPlayerItemDidPlayToEndTime
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(actionDone),
//                                               name: NSNotification.Name(rawValue: notification.rawValue),
//                                               object: controller?.player)
        //	}
        //
        //	//---------------------------------------------------------------------------------------------------------------------------------------------
        //	override func viewWillAppear(_ animated: Bool) {
        //
        //		super.viewWillAppear(animated)
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: .defaultToSpeaker)
        
        controller = AVPlayerViewController()
        controller?.player = AVPlayer(url: url)
        controller?.player?.play()
        
        if (controller != nil) {
            addChild(controller!)
            view.addSubview(controller!.view)
            controller!.view.frame = view.frame
            controller!.showsPlaybackControls = showsPlaybackControls
            controller!.player?.isMuted = mute
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: controller?.player?.currentItem,
                                               queue: .main,
                                               using: {[weak self] (notification) in
            guard let self = self else { return }
            if let item = notification.object as? AVPlayerItem,
               self.controller?.player?.currentItem == item {
                self.actionDone()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func resetPlayer() {
        controller?.player?.seek(to: .zero)
        controller?.player?.play()
    }
    
    // MARK: - User actions
    func actionDone() {
        if let customActionDone = customActionDone {
            customActionDone()
        } else {
            dismiss(animated: true)
        }
    }
}
