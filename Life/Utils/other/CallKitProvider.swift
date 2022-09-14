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
import AgoraRtcKit
//-------------------------------------------------------------------------------------------------------------------------------------------------
class CallKitProvider: NSObject {
    
    private var cxprovider: CXProvider!
    var call: Call?

    var outgoingUUID: UUID?
    
    var videoStatusRemoveHandle: UInt?
    var voiceStatusRemoveHandle: UInt?

    var agoraKit: AgoraRtcEngineKit?

    private let callController = CXCallController()

    private let app = UIApplication.shared.delegate as? AppDelegate

    private var callAudioView: CallAudioView? = nil

    private var callVideoView: CallVideoView? = nil

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
                let sender = realm.object(ofType: Person.self, forPrimaryKey: call.recipientId)
                app.callKitProvider?.call = Call(name: sender?.getFullName() ?? "", chatId: call.chatId, recipientId: call.recipientId, isVideo: false, uuID: uuid, senderId: AuthUser.userId(), pictureAt: sender?.pictureAt ?? 0)
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
            let pictureAt = values["pictureAt"] as? Int64
            let hasVideo = values["hasVideo"] as? Int
            let uuid = values["uuid"] as? String
            
            if (self.call != nil) {
                Database.database().reference().child(hasVideo == 1 ? "video_call" : "voice_call").child(chatId).removeValue()
                return
            }
            

            self.call = Call(name: name ?? "Life App", chatId: chatId, recipientId: recipientId ?? "", isVideo: hasVideo == 1, uuID: UUID(uuidString: uuid ?? "") ?? UUID() , senderId: senderId ?? "", pictureAt: pictureAt ?? 0)
            
            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .generic, value: name ?? "Life App")
            update.hasVideo = hasVideo == 1
            self.cxprovider.reportNewIncomingCall(with: UUID(uuidString: uuid ?? "") ?? UUID() , update: update, completion: {[weak self] error in
                guard let self = self else { return }
                if error != nil {
                    self.cxprovider.reportCall(with: UUID(uuidString: uuid ?? "") ?? UUID() , endedAt: nil, reason: .failed)
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
        self.outgoingUUID = nil
        self.callAudioView = nil
        self.callVideoView = nil
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

    func providerDidBegin(_ provider: CXProvider) {

    }

    func providerDidReset(_ provider: CXProvider) {

    }


    // MARK: -
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {


        
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {

        //provider.reportCall(with: action.callUUID, endedAt: Date(), reason: .answeredElsewhere)
        
        //        openCallView(topController: topViewController() ?? UIViewController())
        let state = UIApplication.shared.applicationState
        if state == .inactive || state == .background {

            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConstant.agoraAppID, delegate: self)
            // Allows a user to join a channel.
            if let agoraKit = self.agoraKit {
                if let call = call {
                    var status = [String: Any]()
                    status["receiver"]   = call.recipientId
                    status ["sender"] = call.senderId
                    status["status"]   = Status.accept.rawValue
                    agoraKit.joinChannel(byToken: "", channelId: call.chatId , info: nil, uid:0) {(sid, uid, elapsed) -> Void in
                        // Joined channel "demoChannel"
                        agoraKit.setEnableSpeakerphone(false)
                        UIApplication.shared.isIdleTimerDisabled = true
                        if call.isVideo {
                            FirebaseAPI.sendVideoCallStatus(status, call.chatId) { (isSuccess, data) in
                                if isSuccess {
                                    action.fulfill()
                                } else {
                                    action.fail()
                                }
                            }
                        } else {
                            FirebaseAPI.sendVoiceCallStatus(status, call.chatId) { (isSuccess, data) in
                                if isSuccess {
                                    action.fulfill()
                                } else {
                                    action.fail()
                                }
                            }
                        }

                    }
                }else{
                    action.fail()
                }
            }else {
                action.fail()
            }
        } else {
            if let _ = self.call {
                if outgoingUUID == nil {
            openCallView(topController: topViewController() ?? UIViewController())
                }
            action.fulfill()
            }else{
                action.fail()
            }
        }


    }

    func leaveChannel() {
        if let agoraKit = self.agoraKit{
            agoraKit.leaveChannel(nil)
            UIApplication.shared.isIdleTimerDisabled = false
            UIDevice.current.isProximityMonitoringEnabled = false
        }

        outgoingUUID = nil 
    }

    func presentView() {
        guard let call =  call else { return }
        if call.isVideo {
            guard let callVideoView = callVideoView else { return }
            topViewController()?.present(callVideoView, animated: true)
        } else {
            guard let callAudioView = callAudioView else { return }
            topViewController()?.present(callAudioView, animated: true)
        }
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
            if callVideoView == nil {
                callVideoView = CallVideoView(userId: call.recipientId)
                callVideoView?.comingFromForeground = comingFromForeground
                callVideoView?.roomID = call.chatId
                callVideoView?.receiver = call.recipientId
                callVideoView?.name = call.name
                callVideoView?.outgoing = outgoing
                callVideoView?.incoming = !outgoing
                if let callVideoView = callVideoView {
                    topController.present(callVideoView, animated: true)
                }
                var status = [String: Any]()
                status["receiver"]   = call.recipientId
                status ["sender"] = call.senderId
                status["status"]   = Status.accept.rawValue
                if !comingFromForeground {
                    let realm = try! Realm()
                    let primaryKey = outgoing ? call.recipientId : call.senderId
                    let sender = realm.object(ofType: Person.self, forPrimaryKey: primaryKey)
                }
                FirebaseAPI.sendVideoCallStatus(status, call.chatId) { (isSuccess, data) in

                }
            }
        } else {
            if callAudioView == nil {
                callAudioView = CallAudioView(userId: call.recipientId)
                callAudioView?.comingFromForeground = comingFromForeground
                callAudioView?.roomID = call.chatId
                callAudioView?.receiver = call.recipientId
                callAudioView?.sender = call.senderId
                callAudioView?.outgoing = outgoing
                callAudioView?.incoming = !outgoing
                callAudioView?.pictureAt = call.pictureAt

                var status = [String: Any]()
                status["receiver"]   = call.recipientId
                status["sender"] = call.senderId
                status["status"]   = Status.accept.rawValue

                if !comingFromForeground {
                    let realm = try! Realm()
                    let primaryKey = outgoing ? call.recipientId : call.senderId
                    let sender = realm.object(ofType: Person.self, forPrimaryKey: primaryKey)
                    callAudioView?.pictureAt = sender?.pictureAt ?? 0
                    callAudioView?.name = sender?.getFullName() ?? ""
                    if let app = app {
                        if let callKitProvider = app.callKitProvider {

                        }
                    }
                } else {
                    guard let callAudioView = callAudioView else { return }
                    topController.present(callAudioView, animated: false)
                }
            }
        }
    }

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
    let pictureAt: Int64
}


extension CallKitProvider: AgoraRtcEngineDelegate{
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteStateReason, elapsed: Int) {
        print("this is remoteaudiostatechage=====>",state.rawValue)

    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStateChange state: AgoraAudioLocalState, error: AgoraAudioLocalError) {
        print("this is localaudiostatechage=====>",state.rawValue)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        self.leaveChannel()
    }
}
