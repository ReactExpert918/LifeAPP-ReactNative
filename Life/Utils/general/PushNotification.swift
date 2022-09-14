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

import Foundation
//----
class PushNotification: NSObject {
    
    class func send(token: String, title: String, body: String, type: NotiType, chatId: String?, soundName: String?) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let serverKey = "AAAAa2uhe4c:APA91bEnMUCK-H2Bf3gM3o4Zo8TbDi_5oK41qzWcpOdf4JE4xHVOkwVrjrhBIJDd2JqTWTwo34LZBCmz2NARPLxOOLbxpAwloXAd5RLfQYPSQSenTf7Lz8kDXnWzNZB0IvhsQ8PH8Uwr"
        
        let userId = AuthUser.userId()
        let paramString: [String : Any] = [
            "to" : token,
            "notification" :
                [
                    "title" : title,
                    "body" : body,
                    "sound": soundName ?? "default",
                ],
            "data" : ["userId" : userId,
                      "chatId" : chatId ?? "",
                      "noti_type": type.rawValue]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    class func sendCall(name: String, chatId: String, recipientId: String, pictureAt: Int64, senderId: String, hasVideo: Int, uuid: String) {
        let urlString = "https://onesignal.com/api/v1/notifications"
        let url = NSURL(string: urlString)!
        
        let paramString: [String : Any] = [
            "app_id": "370c64b9-c575-4b29-bc5a-5940efcbd0c9",
            "apns_push_type_override": "voip",
            "contents": [
                "en": "Life App Calling"
            ],
            "data": [
                "name": name,
                "chatId": chatId,
                "recipientId": recipientId,
                "senderId": senderId,
                "hasVideo": hasVideo,
                "pictureAt": pictureAt,
                "uuid": uuid
            ],
            "priority": 10,
            "ttl": 30 ,
            "include_external_user_ids": [
                recipientId
            ]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic NzU1MDhiYjEtNmQxZi00MTY5LWJjNzEtMDBiZGM3NzAyMDZm", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    class func registerDeviceId(deviceId: String) {
        let urlString = "https://onesignal.com/api/v1/players"
        let url = NSURL(string: urlString)!
        
        let userId = AuthUser.userId()
        
        if userId == "" {
            UserDefaults.standard.set(deviceId, forKey: ONESIGNAL.DEVICE_TOKEN)
            return
        }
        
        let paramString: [String : Any] = [
            "app_id": "370c64b9-c575-4b29-bc5a-5940efcbd0c9",
            "identifier": deviceId,
            "device_type": 0,
            "external_id": userId
        ]
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
