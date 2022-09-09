//
//  ChatViewController+RealmLoad.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

extension ChatViewController {

    func refreshUsers(){
        for person in persons {
            if(person.objectId == AuthUser.userId()){
                continue
            }
            MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
                if (error == nil && image != nil) {
                    self.users.append(User(name:person.getFullName(), image: image!))
                } else{
                    self.users.append(User(name:person.getFullName(), image: UIImage(named: "ic_default_profile")!))
                }
            }
        }
    }

    func loadMembers() {
        let predicate = NSPredicate(format: "chatId == %@ AND isActive == YES", self.chatId)
        members = realm.objects(Member.self).filter(predicate)
        tokenMembers?.invalidate()
        members.safeObserve({ changes in
            self.loadPersons()
        }, completion: { token in
            self.tokenMembers = token
        })
    }

    func loadPersons() {
        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Members.userIds(chatId: self.chatId), Blockeds.blockerIds())
        persons = realm.objects(Person.self).filter(predicate1)
        tokenPersons?.invalidate()
        persons.safeObserve({ changes in
            self.refreshUsers()
        }, completion: { token in
            self.tokenPersons = token
        })
    }

    func loadDetail() {
        let predicate = NSPredicate(format: "chatId == %@ AND userId == %@", chatId, AuthUser.userId())
        detail = realm.objects(Detail.self).filter(predicate).first
    }

    func loadDetails() {
        let predicate = NSPredicate(format: "chatId == %@ AND userId != %@", chatId, AuthUser.userId())
        details = realm.objects(Detail.self).filter(predicate)
        details.safeObserve({ changes in
            self.refreshLastRead()
        }, completion: { token in
            self.tokenDetails = token
        })
    }

    func loadMessages() {
        if chatId.isEmpty == false {
            let predicate = NSPredicate(format: "chatId == %@ AND isDeleted == NO", chatId)
            messages = realm.objects(Message.self).filter(predicate).sorted(byKeyPath: "createdAt")

            print("Chats ids", chatId);

            messages.safeObserve({ changes in
                switch changes {
                case .initial:
                    self.refreshLoadEarlier()
                    self.refreshTableView()
                    self.scrollToBottom()
                case .update(_, let delete, let insert, _):
                    print("messages update")
                    self.messageToDisplay -= delete.count
                    self.messageToDisplay += insert.count
                    self.refreshTableView()
                    if (insert.count != 0) {
                        self.scrollToBottom()
                        self.playIncoming()
                    }
                default: break
                }
            }, completion: { token in
                self.tokenMessages = token
            })
        }
    }
}
