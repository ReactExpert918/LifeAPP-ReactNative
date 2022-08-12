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
import RealmSwift

//-------------------------------------------------------------------------------------------------------------------------------------------------
class CallKitProvider: NSObject {
    
	private var cxprovider: CXProvider!
     var call: Call?

    var outgoingUUID: UUID?
    
    var videoStatusRemoveHandle: UInt?
    var voiceStatusRemoveHandle: UInt?

    private let callController = CXCallController()

    private let app = UIApplication.shared.delegate as? AppDelegate
 
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

    private func startCall(handle: String, videoEnabled: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            guard let call = self.call else { return }
            let handle = CXHandle(type: .generic, value: handle)
            let uuid = UUID()
          let startCallAction = CXStartCallAction(call: uuid, handle: handle)
          startCallAction.isVideo = videoEnabled
          let transaction = CXTransaction(action: startCallAction)
            if let app = self.app {
                let realm = try! Realm()
                let sender = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
                app.callKitProvider?.call = Call(name: sender?.getFullName() ?? "", chatId: call.chatId, recipientId: call.recipientId, isVideo: false, uuID: uuid, senderId: AuthUser.userId())
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
            let senderId = values["senderId"] as? String
            let hasVideo = values["hasVideo"] as? Int
            let uuid = UUID()
            
            if (self.call != nil) {
                Database.database().reference().child(hasVideo == 1 ? "video_call" : "voice_call").child(chatId).removeValue()
                return
            }
            
            
            self.call = Call(name: name ?? "Life App", chatId: chatId, recipientId: recipientId ?? "", isVideo: hasVideo == 1, uuID: uuid, senderId: senderId ?? "")
            
            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .generic, value: name ?? "Life App")
            update.hasVideo = hasVideo == 1
            self.cxprovider.reportNewIncomingCall(with: uuid, update: update, completion: {[weak self] error in
                guard let self = self else { return }
                if error != nil {
                self.cxprovider.reportCall(with: uuid, endedAt: nil, reason: .failed)
                }
            })
            
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

    func endReport() {
        if let call = self.call {
            self.cxprovider.reportCall(with: call.uuID, endedAt: Date(), reason: .remoteEnded)
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
    
    func openCallView(topController: UIViewController, outgoing: Bool = false, comingFromForeground: Bool = false) {
        guard let call = self.call else { return }
        if let _ = topController as? CallAudioView {
            return
        }
        if let _ = topController as? CallVideoView {
            return
        }

        if (call.isVideo) {
            let callVideoView = CallVideoView(userId: call.recipientId)
            callVideoView.comingFromForeground = comingFromForeground
            callVideoView.roomID = call.chatId
            callVideoView.receiver = call.recipientId
            callVideoView.name = topController.description
            callVideoView.outgoing = outgoing
            callVideoView.incoming = !outgoing
            topController.present(callVideoView, animated: true)
            var status = [String: Any]()
            status["receiver"]   = call.recipientId
            status["status"]   = Status.accept.rawValue
            if !comingFromForeground {
                let realm = try! Realm()
                let sender = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
                startCall(handle: sender?.getFullName() ?? "", videoEnabled: false)
            }
            FirebaseAPI.sendVideoCallStatus(status, call.chatId) { (isSuccess, data) in
                
            }
        } else {
            let callAudioView = CallAudioView(userId: call.recipientId)
            callAudioView.comingFromForeground = comingFromForeground
            callAudioView.roomID = call.chatId
            callAudioView.receiver = call.recipientId
            callAudioView.sender = call.senderId
            callAudioView.outgoing = outgoing
            callAudioView.incoming = !outgoing
            topController.present(callAudioView, animated: false)
            
            var status = [String: Any]()
            status["receiver"]   = call.recipientId
            status["status"]   = Status.accept.rawValue
            if !comingFromForeground {
                let realm = try! Realm()
                let sender = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
                startCall(handle: sender?.getFullName() ?? "", videoEnabled: false)
            FirebaseAPI.sendVoiceCallStatus(status, call.chatId) { (isSuccess, data) in
                
            }
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
    let senderId: String
}
