//
//  HomeViewController.swift
//  Life
//
//  Created by XianHuang on 6/25/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var person: Person!    

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var aboutUserLabel: UILabel!
    
    var headerSections =  [HeaderSection(name: "Groups 2", collapsed: false), HeaderSection(name: "Friends 5", collapsed: false)]

    private var tokenFriends: NotificationToken? = nil
    private var tokenPersons: NotificationToken? = nil
    
    private var friends = realm.objects(Friend.self).filter(falsepredicate)
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor(hexString: "#16406F")
        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "Search"
//        searchBar.backgroundColor = UIColor(hexString: "165c90")
        searchBar.set(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setPlaceholder(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setSearchImage(color: UIColor(hexString: "#96B4D2")!)
//        searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        searchBar.delegate = self        
        // Init TableView
        ExpandableHeaderCell.RegisterAsAHeader(withTableView: self.homeTableView)
        FriendCell.Register(withTableView: self.homeTableView)
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        if (AuthUser.userId() != "") {
            loadPerson()
            loadFriends()
        }
    }
    // MARK: - Realm methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func loadFriends() {

        let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO", AuthUser.userId())
        friends = realm.objects(Friend.self).filter(predicate)

        tokenFriends?.invalidate()
        friends.safeObserve({ changes in
            self.loadPersons()
        }, completion: { token in
            self.tokenFriends = token
        })
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadPersons(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@", Friends.friendIds(), Blockeds.blockerIds())
        let predicate2 = (text != "") ? NSPredicate(format: "fullname CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")

        tokenPersons?.invalidate()
        persons.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenPersons = token
        })
    }
    // MARK: - Refresh methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func refreshTableView() {
        headerSections[1].name = "Friends \(persons.count)"
        homeTableView.reloadData()

    }
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())

        //labelInitials.text = person.initials()
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profileImageView.image = image?.square(to: 70)
                self.profileImageView.makeRounded()
            }
        }
        userNameLabel.text = person.fullname
        aboutUserLabel.text = person.about
    }
    @IBAction func onSettingPressed(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "Setting", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "settingNav") as! UINavigationController
//        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func onAddFriendPressed(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "Friend", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "addFriendRootVC")
//        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func openPrivateChat(chatId: String, recipientId: String) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "chatViewController") as! ChatViewController
        vc.setParticipant(chatId: chatId, recipientId: recipientId)
        vc.modalPresentationStyle = .fullScreen
        vc.hidesBottomBarWhenPushed = true
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerSections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let friend = persons[indexPath.row]
            let chatId = Singles.create(friend.objectId)
            openPrivateChat(chatId: chatId, recipientId: friend.objectId)
        }
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
        return 40.00
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return headerSections[section].collapsed ? 0 : 2
        }
        else if section == 1{
            return headerSections[section].collapsed ? 0 : persons.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "createGroupCell", for: indexPath)
                return cell;
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.GetCellReuseIdentifier(), for: indexPath) as! FriendCell
        cell.selectionStyle = .none
        if( indexPath.section == 1) {
            let person = persons[indexPath.row]
            cell.bindData(person: person)
            cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}

// MARK: - UISearchBarDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension HomeViewController: UISearchBarDelegate {

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

extension HomeViewController: CollapsibleTableViewHeaderDelegate {
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
    
