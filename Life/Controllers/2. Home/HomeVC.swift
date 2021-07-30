//
//  HomeVC.swift
//  Life
//
//  Created by XianHuang on 6/25/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift
import JGProgressHUD
import FittedSheets

protocol CreateGroupDelegate {
    func onGroupCreated(group: Group)
}

protocol ChatViewControllerProtocol {
    func singleChatView(_ indexPath: IndexPath)
    func groupChatView(_ indexPath: IndexPath)
    func removeFriend(_ indexPath: IndexPath)
    func groupInfo(_ group: Group)
}

class HomeVC: BaseVC, CreateGroupDelegate, ChatViewControllerProtocol {

    private var person: Person!

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var homeTableView: UITableView!
    
    @IBOutlet weak var redCircle: UIImageView!
    @IBOutlet weak var imageReceivedUnRead: UIImageView!
    
    var headerSections =  [HeaderSection(name: "My Status", collapsed: false), HeaderSection(name: "Groups"+" 0", collapsed: false), HeaderSection(name: "Friends"+" 0", collapsed: false)]

    private var tokenFriends: NotificationToken? = nil
    private var tokenPersons: NotificationToken? = nil
    private var tokenGroups: NotificationToken? = nil
    private var tokenMembers: NotificationToken? = nil
    
    private var friends = realm.objects(Friend.self).filter(falsepredicate)
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    private var groups  = realm.objects(Group.self).filter(falsepredicate)
    private var members = realm.objects(Group.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        if (Friends.friendPendingIds().count > 0){
            redCircle.isHidden = false
        } else {
            redCircle.isHidden = true
        }
        
        if (AuthUser.userId() != "") {
            loadPerson()
            loadMembers()
            loadFriends()
        }
    }
    
    fileprivate func initUI() {
        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = .primaryColor
        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "Search"
        searchBar.set(textColor: .lightPrimaryColor)
        searchBar.setPlaceholder(textColor: .lightPrimaryColor)
        searchBar.setSearchImage(color: .lightPrimaryColor)
        searchBar.tintColor = .white
        searchBar.delegate = self
        
        ExpandableHeaderCell.RegisterAsAHeader(withTableView: self.homeTableView)
        //UserStatusCell.Register(withTableView: self.homeTableView)
        //FriendCell.Register(withTableView: self.homeTableView)
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        
        updateFcmToken()
    }
    
    // MARK: - Realm methods
    @objc func loadFriends() {

        let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO  AND isAccepted == YES", AuthUser.userId())
        friends = realm.objects(Friend.self).filter(predicate)

        tokenFriends?.invalidate()
        friends.safeObserve({ changes in
            self.loadPersons()
        }, completion: { token in
            self.tokenFriends = token
        })
    }
    
    func loadPersons(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Friends.friendAcceptedIds(), Blockeds.blockerIds())
        let predicate2 = (text != "") ? NSPredicate(format: "fullname CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")

        tokenPersons?.invalidate()
        persons.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenPersons = token
        })
    }
    
    func loadGroups(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND isDeleted == NO", Members.chatIds())
        let predicate2 = (text != "") ? NSPredicate(format: "name CONTAINS[c] %@", text) : NSPredicate(value: true)

        groups = realm.objects(Group.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "name")

        tokenGroups?.invalidate()
        groups.safeObserve({ changes in
            
            self.refreshTableView()
            self.hideProgress()
        }, completion: { token in
            self.tokenGroups = token
        })
    }
    
    func loadMembers(text: String = "") {

        let predicate = NSPredicate(format: "userId == %@ AND isActive == YES", AuthUser.userId())
        let members = realm.objects(Member.self).filter(predicate)

        tokenMembers?.invalidate()
        members.safeObserve({ changes in
            self.loadGroups()
        }, completion: { token in
            self.tokenMembers = token
        })
    }
    
    func onGroupCreated(group: Group) {
        showAlert("\(group.name) " + "has been created successfully.")
    }

    // MARK: - Refresh methods
    @objc func refreshTableView() {
        headerSections[1].name = "Groups"+" \(groups.count)"
        headerSections[2].name = "Friends"+" \(persons.count)"
        homeTableView.reloadData()
    }
    
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        if(person.isBalanceRead == false){
            imageReceivedUnRead.isHidden = false
        }else{
            imageReceivedUnRead.isHidden = true
        }
        
        
    }
    
    // MARK: - bar button items
    @IBAction func onSettingPressed(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "Setting", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "settingNav") as! UINavigationController
//        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onZedPay(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "ZedPay", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "ZedHistoryVC") as! ZedHistoryVC
        vc.person = self.person
        
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(400), .fullscreen])
        self.present(sheetController, animated: true, completion: nil)
    }
    
    @IBAction func onAddFriendPressed(_ sender: Any) {
        let vc = AppBoards.friend.initialViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func openPrivateChat(chatId: String, recipientId: String) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        vc.setParticipant(chatId: chatId, recipientId: recipientId)
        vc.modalPresentationStyle = .fullScreen
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func createGroupView(){
        let mainstoryboard = UIStoryboard.init(name: "Group", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "CreateGroupVC") as! CreateGroupVC
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func singleChatView(_ indexPath: IndexPath){
        let friend = persons[indexPath.row]
        let chatId = Singles.create(friend.objectId)
        openPrivateChat(chatId: chatId, recipientId: friend.objectId)
        
    }
    
    func groupChatView(_ indexPath: IndexPath){
        
        let chatId = groups[indexPath.row-1].chatId
        openPrivateChat(chatId: chatId, recipientId: "")
        
    }
    
    func removeFriend(_ indexPath: IndexPath) {
        let friend = persons[indexPath.row]
        let confirmationAlert = UIAlertController(title: "Remove Friend", message: "Are you sure remove " + friend.fullname, preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                (action: UIAlertAction!) in
                confirmationAlert.dismiss(animated: true, completion: nil)
                Friends.removeFriend(friend.objectId){
                    self.loadFriends()
                }
            
            })
        )
        
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
       
    }
    
    func groupInfo(_ group: Group){
        let mainstoryboard = UIStoryboard.init(name: "Group", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "ConfigGroupVC") as! ConfigGroupVC
        vc.group = group
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    // MARK: - upload fcm token
    fileprivate func updateFcmToken() {
        let token = PrefsManager.getFCMToken()
        Persons.update(oneSignalId: token)
    }
    
    
}

// MARK: - Table delegate
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // headerSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return headerSections[section].collapsed ? 0 : groups.count + 1
        case 2:
            return headerSections[section].collapsed ? 0 : persons.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
            if person != nil{
                cell.setCell(person)
            }
            return cell
        case 1: // group
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CreateGroupCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
                cell.setGroup(groups[indexPath.row-1])
                return cell
            }
        default: // friends
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
            cell.setFriend(persons[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandableHeaderCell.GetReuseIdentifier()) as! ExpandableHeaderCell
        header.titleLabel.text = headerSections[section].name
        header.setCollapsed(collapsed: headerSections[section].collapsed)
        header.section = section
        header.delegate = self
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 1: // group
            if indexPath.row == 0 { // create a group
                let vc = AppBoards.group.viewController(withIdentifier: "CreateGroupVC") as! CreateGroupVC
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            } else {
                let chatId = groups[indexPath.row-1].chatId
                openPrivateChat(chatId: chatId, recipientId: "")
            }
        case 2: // friend
            let friend = persons[indexPath.row]
            let chatId = Singles.create(friend.objectId)
            openPrivateChat(chatId: chatId, recipientId: friend.objectId)
        default: // user cell
            break
        }
    }
    
}


// MARK: - UISearchBarDelegate
extension HomeVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }

    func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadGroups()
        loadPersons()
    }

    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar_.text
        
        loadGroups(text: searchText ?? "")
        loadPersons(text: searchText ?? "")
    }
}

extension HomeVC: CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ header: ExpandableHeaderCell, section: Int) {
        let collapsed = !headerSections[section].collapsed
            
        // Toggle collapse
        headerSections[section].collapsed = collapsed
        header.setCollapsed(collapsed: collapsed)

        // Reload the whole section
        homeTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
}

struct HeaderSection {
    var name: String
    var collapsed: Bool

    init(name: String, collapsed: Bool = false) {
        self.name = name
        self.collapsed = collapsed
    }
}
    


