
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class FirebaseAPI {
    
    static let ref = Database.database().reference()
    
    static let VIDEO_CALL = "video_call"
    static let VOICE_CALL = "voice_call"
    
    
     //MARK: - Set/remove Add/change observer
    static func setVideoCallAddListener(_ roomId: String, handler:@escaping (_ msg: String)->()) -> UInt {
        return ref.child(VIDEO_CALL).child(roomId).observe(.childAdded) { (snapshot, error) in

            let childref = snapshot.value as? String
            //print(childref)
            if let childRef = childref {
                //let msg = parseStatus(childRef)
                handler(childRef)
            }
        }
    }
    
    static func setVideoCallChangeListener(_ roomId: String, handler:@escaping (_ msg: Int)->()) -> UInt {
        return ref.child(VIDEO_CALL).child(roomId).observe(.childChanged) { (snapshot, error) in

            if let childref = snapshot.value as? Int{
                handler(childref)
            }
        }
    }
    
    static func setVideoCallRemoveListener(_ roomId: String, handler:@escaping (_ msg: String)->()) -> UInt {
        return ref.child(VIDEO_CALL).child(roomId).observe(.childRemoved) { (snapshot, error) in

            if let childref = snapshot.value as? String{
                handler(childref)
            }
        }
    }
    
    static func setVoiceCallChangeListener(_ roomId: String, handler:@escaping (_ msg: Int)->()) -> UInt {
        return ref.child(VOICE_CALL).child(roomId).observe(.childChanged) { (snapshot, error) in

            if let childref = snapshot.value as? Int{
                handler(childref)
            }
        }
    }
    
    static func setVoiceCallRemoveListener(_ roomId: String, handler:@escaping (_ msg: String)->()) -> UInt {
        return ref.child(VOICE_CALL).child(roomId).observe(.childRemoved) { (snapshot, error) in

            if let childref = snapshot.value as? String{
                handler(childref)
            }
        }
    }
    
    static func setVoiceCallListener(_ roomId: String, handler:@escaping (_ msg: String)->()) -> UInt {
        return ref.child(VOICE_CALL).child(roomId).observe(.childAdded) { (snapshot, error) in

            let childref = snapshot.value as? String
            //print(childref)
            if let childRef = childref {
                //let msg = parseStatus(childRef)
                handler(childRef)
            }
        }
    }
    
    static func removeVideoCallListnerObserver(_ roomId: String, _ handle : UInt) {
        ref.child(VIDEO_CALL).child(roomId).removeObserver(withHandle: handle)
    }
    
    static func removeVideoCallRemoveListnerObserver(_ roomId: String, _ handle : UInt) {
        ref.child(VIDEO_CALL).child(roomId).removeObserver(withHandle: handle)
    }
    
    static func removeVoiceCallListnerObserver(_ roomId: String, _ handle : UInt) {
        ref.child(VOICE_CALL).child(roomId).removeObserver(withHandle: handle)
    }
    
    static func removeVoiceCallRemoveListnerObserver(_ roomId: String, _ handle : UInt) {
        ref.child(VOICE_CALL).child(roomId).removeObserver(withHandle: handle)
    }
    
    
    static func parseStatus(_ snapshot: NSDictionary) -> StatusModel {
        let statusModel = StatusModel()
        //print(snapshot)
        
        if let receiver = snapshot["receiver"] as? String{
            statusModel.receiver = receiver
        }
        if let status = snapshot["status"] as? Int{
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
                statusModel.status = .outgoing
            case 2:
                statusModel.status = .incoming
            case 3:
                statusModel.status = .end
            case 4:
                statusModel.status = .accept
            case 5:
                statusModel.status = .reject
            case 6:
                statusModel.status = .null
            default:
                statusModel.status = .null
            }
        }
        return statusModel
    }
    
    // MARK: - send Statusmodel
    static func sendVoiceCallStatus(_ voiceCallStatus:[String:Any], _ roomId: String, completion: @escaping (_ status: Bool, _ message: String) -> ()) {
        ref.child(VOICE_CALL).child(roomId).setValue(voiceCallStatus) { (error, dataRef) in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                print(dataRef)
                let totalPath: String = "\(dataRef)"
//                let totalPathArr = totalPath.split(separator: "/")
//                print(totalPathArr.first)
//                print(totalPathArr.last)
                completion(true, totalPath)
            }
        }
    }
    
    static func sendVideoCallStatus(_ videoCallStatus:[String:Any], _ roomId: String, completion: @escaping (_ status: Bool, _ message: String) -> ()) {
        ref.child(VIDEO_CALL).child(roomId).setValue(videoCallStatus) { (error, dataRef) in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                print(dataRef)
                let totalPath: String = "\(dataRef)"
//                let totalPathArr = totalPath.split(separator: "/")
//                print(totalPathArr.first)
//                print(totalPathArr.last)
                completion(true, totalPath)
            }
        }
    }
}

class StatusModel {
    
    var receiver: String = ""
    var status:Status = .null
    
    init() {
        
        self.receiver = ""
        self.status = .null
    }
    
    init(receiver: String, status: Status) {
        
        self.receiver = receiver
        self.status = status
    }
}

enum Status: Int {
    case outgoing = 1
    case incoming = 2
    case end = 3
    case accept = 4
    case reject = 5
    case null = 6
}
