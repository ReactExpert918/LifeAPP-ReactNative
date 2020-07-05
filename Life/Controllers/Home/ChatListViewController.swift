//
//  ChatListViewController.swift
//  Life
//
//  Created by XianHuang on 6/25/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var chatsTableView: UITableView!
    
    private var tokenMembers: NotificationToken? = nil
    private var tokenChats: NotificationToken? = nil

    private var members    = realm.objects(Member.self).filter(falsepredicate)
    private var chats    = realm.objects(Chat.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor(hexString: "#16406F")
        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "Search"
//      searchBar.backgroundColor = UIColor(hexString: "165c90")
        searchBar.set(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setPlaceholder(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setSearchImage(color: UIColor(hexString: "#96B4D2")!)
//      searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        searchBar.delegate = self
        // Init Chat List TableView
        ChatHistoryCell.Register(withTableView: chatsTableView)
        chatsTableView.dataSource = self
        chatsTableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMembers), name: NSNotification.Name(rawValue: NotificationStatus.NOTIFICATION_USER_LOGGED_IN), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(actionCleanup), name: NSNotification.Name(rawValue: NotificationStatus.NOTIFICATION_USER_LOGGED_OUT), object: nil)
        
        if (AuthUser.userId() != "") {
            loadMembers()
        }
    }
    // MARK: - Realm methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func loadMembers() {

        let predicate = NSPredicate(format: "userId == %@ AND isActive == YES", AuthUser.userId())
        members = realm.objects(Member.self).filter(predicate)

        tokenMembers?.invalidate()
        members.safeObserve({ changes in
            self.loadChats()
        }, completion: { token in
            self.tokenMembers = token
        })
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadChats(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND lastMessageAt != 0", Members.chatIds())
        let predicate2 = NSPredicate(format: "isDeleted == NO AND isArchived == NO AND isGroupDeleted == NO")
        let predicate3 = (text != "") ? NSPredicate(format: "details CONTAINS[c] %@", text) : NSPredicate(value: true)

        let predicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2, predicate3])
        chats = realm.objects(Chat.self).filter(predicate).sorted(byKeyPath: "lastMessageAt", ascending: false)

        tokenChats?.invalidate()
        chats.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenChats = token
        })
    }
    // MARK: - Refresh methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTableView() {

        chatsTableView.reloadData()
        self.refreshTabCounter()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTabCounter() {

        var total: Int = 0

        for chat in chats {
            total += chat.unreadCount
        }

        let item = tabBarController?.tabBar.items?[1]
        item?.badgeValue = (total != 0) ? "\(total)" : nil

        UIApplication.shared.applicationIconBadgeNumber = total
    }
    // MARK: - Cleanup methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionCleanup() {

        tokenMembers?.invalidate()
        tokenChats?.invalidate()

        members    = realm.objects(Member.self).filter(falsepredicate)
        chats    = realm.objects(Chat.self).filter(falsepredicate)

        refreshTableView()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chat = chats[indexPath.row]
        if (chat.isGroup){
            
        }
        else if (chat.isPrivate) {
            let isRecipient = (chat.userId1 != AuthUser.userId())
            let userId = isRecipient ? chat.userId1 : chat.userId2
            
            let vc =  self.storyboard?.instantiateViewController(identifier: "chatViewController") as! ChatViewController
            //vc.modalPresentationStyle = .fullScreen
            //self.present(vc, animated: true, completion: nil)
            vc.hidesBottomBarWhenPushed = true
            vc.setParticipant(chatId: chat.objectId, recipientId: userId)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatHistoryCell.GetCellReuseIdentifier(), for: indexPath) as! ChatHistoryCell
        let chat = chats[indexPath.row]
        cell.bindData(chat: chat)
        cell.loadImage(chat: chat, tableView: tableView, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

}

// MARK: - UISearchBarDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatListViewController: UISearchBarDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(true, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(false, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {

        searchBar.text = ""
        searchBar.resignFirstResponder()
        
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {

        searchBar.resignFirstResponder()
    }
}
