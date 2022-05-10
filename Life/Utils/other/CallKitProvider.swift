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

import CallKit
import UIKit
import FirebaseDatabase
//-------------------------------------------------------------------------------------------------------------------------------------------------
class CallKitProvider: NSObject {
    
	private var cxprovider: CXProvider!
    private var call: Call?
    
    var videoStatusRemoveHandle: UInt?
    var voiceStatusRemoveHandle: UInt?
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		let configuration = CXProviderConfiguration(localizedName: "LIFE")
		configuration.supportsVideo = true
		configuration.maximumCallGroups = 1
		configuration.maximumCallsPerCallGroup = 50
		configuration.includesCallsInRecents = true
        configuration.supportedHandleTypes = [.generic]
		cxprovider = CXProvider(configuration: configuration)
		cxprovider.setDelegate(self, queue: nil)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didReceivePush(withPayload payload: [AnyHashable: Any]?) {
        guard let payload = payload else {
            return
        }
        if let data = payload["custom"] as? [String: Any], let values = data["a"] as? [String: Any]  {
            guard let chatId = values["chatId"] as? String else {
                return
            }
            
            
            
            let name = values["name"] as? String
            let recipientId = values["recipientId"] as? String
            let hasVideo = values["hasVideo"] as? Int
            let uuid = UUID()
            
            if (self.call != nil) {
                Database.database().reference().child(hasVideo == 1 ? "video_call" : "voice_call").child(chatId).removeValue()
                return
            }
            
            
            self.call = Call(name: name ?? "Life App", chatId: chatId, recipientId: recipientId ?? "", isVideo: hasVideo == 1, uuID: uuid)
            
            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .generic, value: name ?? "Life App")
            update.hasVideo = hasVideo == 1
            self.cxprovider.reportNewIncomingCall(with: uuid, update: update, completion: { error in })
            
            if (hasVideo == 0) {
                self.voiceStatusRemoveHandle = FirebaseAPI.setVoiceCallRemoveListener(chatId){ [self] (receiverid) in
                    self.removeStateListner()
                    self.removeCall()
                }
            } else {
                self.videoStatusRemoveHandle = FirebaseAPI.setVideoCallRemoveListener(chatId){ [self] (receiverid) in
                    self.removeStateListner()
                    self.removeCall()
                }
            }
        }
	}
    
    func removeCall() {
        self.call = nil
    }
    
    func removeReport() {
        if let call = self.call {
            self.cxprovider.reportCall(with: call.uuID, endedAt: Date(), reason: .answeredElsewhere)
        }
    }
    
    func removeStateListner() {
        if let voiceStatusRemoveHandle = voiceStatusRemoveHandle, let call = self.call {
            FirebaseAPI.removeVoiceCallRemoveListnerObserver(call.chatId, voiceStatusRemoveHandle)
            self.voiceStatusRemoveHandle = nil
        }
        if let videoStatusRemoveHandle = videoStatusRemoveHandle, let call = self.call {
            FirebaseAPI.removeVoiceCallRemoveListnerObserver(call.chatId, videoStatusRemoveHandle)
            self.videoStatusRemoveHandle = nil
        }
    }
    

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func topViewController() -> UIViewController? {

		let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
		var viewController = keyWindow?.rootViewController

		while (viewController?.presentedViewController != nil) {
			viewController = viewController?.presentedViewController
		}
		return viewController
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
extension CallKitProvider: CXProviderDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func providerDidBegin(_ provider: CXProvider) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func providerDidReset(_ provider: CXProvider) {

	}


	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        
        //provider.reportCall(with: action.callUUID, endedAt: Date(), reason: .answeredElsewhere)
        
        guard let topViewController = topViewController() else {

            let app = UIApplication.shared.delegate as? AppDelegate
            app?.pendingVideoCall = true
            return
        }
        
        if topViewController.nibName != "life app" {
            let app = UIApplication.shared.delegate as? AppDelegate
            app?.pendingVideoCall = true
            NotificationCenter.default.post(name: NSNotification.Name(NotificationStatus.NOTIFICATION_RECEIVE_CALL), object: nil)
            return
        }
        
        self.openCallView(topController: topViewController)
		
	}
    
    func openCallView(topController: UIViewController) {
        guard let call = self.call else { return }
        
        if (call.isVideo) {
            let callVideoView = CallVideoView(userId: call.recipientId)
            callVideoView.roomID = call.chatId
            callVideoView.receiver = call.recipientId
            callVideoView.name = topController.description
            callVideoView.outgoing = false
            callVideoView.incoming = true
            topController.present(callVideoView, animated: true)
            var status = [String: Any]()
            status["receiver"]   = call.recipientId
            status["status"]   = Status.accept.rawValue
            
            FirebaseAPI.sendVideoCallStatus(status, call.chatId) { (isSuccess, data) in
                
            }
        } else {
            let callAudioView = CallAudioView(userId: call.recipientId)
            callAudioView.roomID = call.chatId
            callAudioView.receiver = call.recipientId
            callAudioView.outgoing = false
            callAudioView.incoming = true
            topController.present(callAudioView, animated: false)
            
            var status = [String: Any]()
            status["receiver"]   = call.recipientId
            status["status"]   = Status.accept.rawValue
            
            FirebaseAPI.sendVoiceCallStatus(status, call.chatId) { (isSuccess, data) in
                
            }
        }
    }

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
		action.fulfill()
        if let call = self.call {
            Database.database().reference().child(call.isVideo ? "video_call" : "voice_call").child(call.chatId).removeValue()
        }        
	}
}

struct Call {
    let name: String
    let chatId: String
    let recipientId: String
    let isVideo: Bool
    let uuID: UUID
}
