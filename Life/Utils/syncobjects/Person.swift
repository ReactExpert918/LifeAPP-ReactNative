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

import RealmSwift
import CryptoSwift
//----
class Person: SyncObject {

    @objc dynamic var email = ""
    @objc dynamic var phone = ""

    @objc dynamic var firstname = ""
    @objc dynamic var lastname = ""
    @objc dynamic var fullname = ""
    @objc dynamic var country = ""
    @objc dynamic var location = ""
    @objc dynamic var pictureAt: Int64 = 0

    @objc dynamic var status = "Available"
    @objc dynamic var about = "I am using Life App."

    @objc dynamic var keepMedia: Int32 = Int32(KEEPMEDIA_PERIOD.KEEPMEDIA_FOREVER)
    @objc dynamic var networkPhoto: Int32 = Int32(NETWORK_MODE.NETWORK_ALL)
    @objc dynamic var networkVideo: Int32 = Int32(NETWORK_MODE.NETWORK_ALL)
    @objc dynamic var networkAudio: Int32 = Int32(NETWORK_MODE.NETWORK_ALL)

    @objc dynamic var wallpaper = ""
    @objc dynamic var loginMethod = ""
    @objc dynamic var oneSignalId = ""

    @objc dynamic var lastActive: Int64 = 0
    @objc dynamic var lastTerminate: Int64 = 0
    @objc dynamic var isDeleted = false
    
    /// schema2 for ZED pay
    @objc dynamic var balance: String = ""
    @objc dynamic var isBalanceRead = true
    @objc dynamic var payInfo1: String = ""
    @objc dynamic var payInfo2: String = ""
    @objc dynamic var payInfo3: String = ""
    
    class func lastUpdatedAt() -> Int64 {

        let realm = try! Realm()
        let predicate = NSPredicate(format: "objectId != %@", AuthUser.userId())
        let object = realm.objects(Person.self).filter(predicate).sorted(byKeyPath: "updatedAt").last
        return object?.updatedAt ?? 0
    }

    // MARK: -
    
    func initials() -> String {

        let initial1 = (firstname.count != 0) ? firstname.prefix(1) : ""
        let initial2 = (lastname.count != 0) ? lastname.prefix(1) : ""

        return "\(initial1)\(initial2)"
    }

    
    func lastActiveText() -> String {

        if (Blockeds.isBlocker(objectId)) {
            return ""
        }

        if (lastActive < lastTerminate) {
            let elapsed = Convert.timestampToElapsed(lastTerminate)
            return "last active: \(elapsed)"
        }

        return "online now"
    }

    // MARK: -
    
    func update(fullname value: String) {

        if (fullname == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            fullname = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
    
    func update(email value: String) {

        if (email == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            email = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
    // MARK: -
    
    func update(pictureAt value: Int64) {

        if (pictureAt == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            pictureAt = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }

    
    func update(status value: String) {

        if (status == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            status = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }

    
    func update(keepMedia value: Int32) {

        if (keepMedia == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            keepMedia = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }

    
    func update(networkPhoto value: Int32) {

        if (networkPhoto == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            networkPhoto = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }

    
    func update(networkVideo value: Int32) {

        if (networkVideo == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            networkVideo = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }

    
    func update(networkAudio value: Int32) {

        if (networkAudio == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            networkAudio = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }

    
    func update(wallpaper value: String) {

        if (wallpaper == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            wallpaper = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }

    
    func update(oneSignalId value: String) {

        if (oneSignalId == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            oneSignalId = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }

    
    func update(lastActive value: Int64) {

        if (lastActive == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            lastActive = value
            syncRequired = true
            updatedAt = Date().timestamp()
            print("lastActivate")
            print(value)
        }
    }

    
    func update(lastTerminate value: Int64) {

        if (lastTerminate == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            lastTerminate = value
            syncRequired = true
            updatedAt = Date().timestamp()
            print("lastTerminate")
            print(value)
        }
    }


    func update(isDeleted value: Bool) {

        if (isDeleted == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            isDeleted = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
    
    func update(balance value: Float) {
        
        let encryptedValue = value.encryptedString()
        if (balance == encryptedValue) {
            return
        }

        let realm = try! Realm()
        try! realm.safeWrite {
            if(encryptedValue > balance){
                isBalanceRead = false
            }
            balance = encryptedValue
            //syncRequired = true
            updatedAt = Date().timestamp()
            
        }
        
    }
    
    func getBalance() -> Float {
        return balance.decryptedFloat()
        
    }
    
    func update(isBalanceRead value: Bool){
        if(isBalanceRead == value){return}
        let realm = try! Realm()
        try! realm.safeWrite {
            isBalanceRead = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
}
