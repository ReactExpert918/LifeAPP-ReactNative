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

//import OneSignal
import Foundation

class PushNotification: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
<<<<<<< HEAD
    class func oneSignalId() -> String{
        guard let status = OneSignal.getDeviceState() else{
            return ""
        }
        if (status.pushToken != nil) {
           if let userId = status.userId {
                return userId
           }
       }

        return ""
    }

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func send(message: Message, recipientId:String) {

=======
    
	class func oneSignalId() -> String {
/*
		if let status = OneSignal.getDeviceState() {
            let subcribed = status.isSubscribed
            if subcribed {
                if let uid = status.userId {
                    return uid
                }
            }
		}*/
        
		return ""
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func send(message: Message) {
/*
>>>>>>> master
		let type = message.type
		var en_text = message.userFullname
        var ja_text = message.userFullname

<<<<<<< HEAD
        if (type == MESSAGE_TYPE.MESSAGE_TEXT)		{
            ja_text = ja_text + " "+"sent you a text message.".localized
            en_text = en_text + " "+"sent you a text message."
            
        }
		if (type == MESSAGE_TYPE.MESSAGE_EMOJI)		{
            ja_text = ja_text + " " + "sent you an emoji.".localized
            en_text = en_text + " " + "sent you an emoji."
            
        }
		if (type == MESSAGE_TYPE.MESSAGE_PHOTO)		{
            ja_text = ja_text + " " + "sent you a photo.".localized
            en_text = en_text + " " + "sent you a photo."
            
        }
		if (type == MESSAGE_TYPE.MESSAGE_VIDEO)		{
            ja_text = ja_text + " " + "sent you a video.".localized
            en_text = en_text + " " + "sent you a video."
            
        }
        if (type == MESSAGE_TYPE.MESSAGE_MONEY && !message.isMediaFailed)        {
            ja_text = ja_text + " " + "sent you money.".localized
            en_text = en_text + " " + "sent you money."
            
        }
        /*
		if (type == MESSAGE_TYPE.MESSAGE_AUDIO) 		{
            ja_text = ja_text + (" sent you an audio.")
            
        }
		if (type == MESSAGE_TYPE.MESSAGE_LOCATION)	{
            text = text + (" sent you a location.")
            
        }*/
=======
		if (type == MESSAGE_TYPE.MESSAGE_TEXT)		{ text = text + (" sent you a text message.")	}
		if (type == MESSAGE_TYPE.MESSAGE_EMOJI)		{ text = text + (" sent you an emoji.")			}
		if (type == MESSAGE_TYPE.MESSAGE_PHOTO)		{ text = text + (" sent you a photo.")			}
		if (type == MESSAGE_TYPE.MESSAGE_VIDEO)		{ text = text + (" sent you a video.")			}
		if (type == MESSAGE_TYPE.MESSAGE_AUDIO) 	{ text = text + (" sent you an audio.")			}
		if (type == MESSAGE_TYPE.MESSAGE_LOCATION)	{ text = text + (" sent you a location.")		}
>>>>>>> master

		let chatId = message.chatId
		var userIds = Members.userIds(chatId: chatId)

		let predicate = NSPredicate(format: "chatId == %@", chatId)
		for detail in realm.objects(Detail.self).filter(predicate) {
			if (detail.mutedUntil > Date().timestamp()) {
				//userIds.removeObject(detail.userId)
                userIds.removeAll(where: { $0 == detail.userId})
			}
		}
        userIds.removeAll(where: { $0 == AuthUser.userId()})
//		userIds.removeObject(AuthUser.userId())
<<<<<<< HEAD
        //print(AuthUser.userId())
        //print(userIds)
        send(userIds: userIds, en_text: en_text, ja_text: ja_text, chatId: message.chatId, recipientId: recipientId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
    private class func send(userIds: [String], en_text: String, ja_text: String, chatId: String, recipientId:String) {

		let predicate = NSPredicate(format: "objectId IN %@ AND isDeleted == NO", userIds)
=======

		send(userIds: userIds, text: text)*/
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func send(userIds: [String], text: String) {
/*
		let predicate = NSPredicate(format: "objectId IN %@", userIds)
>>>>>>> master
		let persons = realm.objects(Person.self).filter(predicate).sorted(byKeyPath: "fullname")

		var oneSignalIds: [String] = []
        
        let predicateMine = NSPredicate(format: "objectId == %@ AND isDeleted == NO", AuthUser.userId())
        guard let personMine = realm.objects(Person.self).filter(predicateMine).first else{
            return
        }
        
		for person in persons {
            if (person.oneSignalId.count != 0 && person.oneSignalId != personMine.oneSignalId && person.lastTerminate > person.lastActive ) {
				oneSignalIds.append(person.oneSignalId)
			}
		}
<<<<<<< HEAD
        
        OneSignal.postNotification(["contents": ["en": en_text, "ja":ja_text], "include_player_ids": oneSignalIds,
            "data": ["chatId": chatId, "recipientId": recipientId]])
=======

		OneSignal.postNotification(["contents": ["en": text], "include_player_ids": oneSignalIds])*/
>>>>>>> master
	}
}
