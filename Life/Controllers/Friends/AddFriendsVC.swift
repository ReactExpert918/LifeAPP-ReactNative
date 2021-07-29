//
//  AddFriendsVC.swift
//  Life
//
//  Created by Yun Li on 2020/6/24.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FittedSheets
import Contacts

class AddFriendsVC: BaseVC {
    
    @IBOutlet weak var tblFriends: UITableView!
    //Popup to confirm Friend Request
    @IBOutlet weak var confirmPopupView: UIView!
    @IBOutlet weak var confirmPopupProfileImage: UIImageView!
    @IBOutlet weak var confirmPopupLabel: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    let sections = ["New Friend Requests", "Friend Recommendations"]
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    private var pendingFriends = realm.objects(Person.self).filter(falsepredicate)
    var personList = [Person]()
    var selectedPerson : Person!
    var sectionCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblFriends.register(UINib(nibName: "AddFriendSection", bundle: nil), forHeaderFooterViewReuseIdentifier: AddFriendSection.reuseIdentifier)
        tblFriends.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFriendsRecommend()
        loadPendingFriends()
    }
    
    func loadFriendsRecommend(){
        //var contacts = [CNContact]()
        let keys = [CNContactPhoneNumbersKey as NSString]
        let contactStore = CNContactStore()
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Check if the phone number is available for the given contact
                if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
                    for item in contact.phoneNumbers{
                        self.searchPersonsByPhoneNumber(text: item.value.stringValue.replacingOccurrences(of: " ", with: ""))
                    }
                }
            }
            refreshTableView()
        }
        catch {
            print("unable to fetch contacts")
        }
    }
    
    func loadPendingFriends(){
        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Friends.friendPendingIds(), Blockeds.blockerIds())
        pendingFriends = realm.objects(Person.self).filter(predicate1).sorted(byKeyPath: "fullname")
        refreshTableView()
    }
    
    func refreshTableView(){
        
        if pendingFriends.count > 0 && personList.count > 0 {
            sectionCount = 2
        } else if pendingFriends.count > 0 {
            sectionCount = 1
        } else if personList.count > 0 {
            sectionCount = 1
        } else {
            sectionCount = 0
        }
        tblFriends.reloadData()
    }
    
    func searchPersonsByPhoneNumber(text: String = "") {
        let predicate1 = NSPredicate(format: "objectId != %@", AuthUser.userId())
        let predicate2 = (text != "") ? NSPredicate(format: "phone CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")
        personList.append(contentsOf: persons)
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func qrcodeTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "QRCodeVC") as! QRCodeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func searchFriendsTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "SearchFriendsVC") as! SearchFriendsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onDeclineTapped(_ sender: Any) {
        confirmPopupView.isHidden = true
        Friends.update(selectedPerson.objectId, isAccepted: false)
        loadPendingFriends()
    }
    
    @IBAction func onAcceptTapped(_ sender: Any) {
        confirmPopupView.isHidden = true
        Friends.update(selectedPerson.objectId, isAccepted: true)
        loadPendingFriends()
    }
    
    func loadRequestedFriendImage(person: Person) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.confirmPopupProfileImage.image = image
                self.confirmPopupProfileImage.makeRounded()
            }
            else{
                self.confirmPopupProfileImage.image = UIImage(named: "ic_default_profile")
            }
        }
    }
}

extension AddFriendsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if pendingFriends.count > 0 {
                return pendingFriends.count
            } else {
                return personList.count
            }
        } else {
            return personList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if pendingFriends.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendConfirmCell", for: indexPath) as! AddFriendConfirmCell
                let person = pendingFriends[indexPath.row]
                cell.index = indexPath.row
                cell.bindData(person: person)
                cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
                cell.selectionStyle = .none
                cell.callbackAddFriendConfirm = { (index) in
                    let person = self.pendingFriends[index]
                    self.selectedPerson = person
                    // Display info on popupview
                    self.confirmPopupLabel.text = "Do you want to add \(person.fullname) to your friend list?"
                    self.loadRequestedFriendImage(person: person)

                    self.confirmPopupView.isHidden = false
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as! AddFriendCell
                let person = personList[indexPath.row]
                cell.index = indexPath.row
                cell.bindData(person: person)
                cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
                cell.selectionStyle = .none
                cell.callbackAddFriend = { (index) in
                    let person = self.personList[index]
                    let vc = self.storyboard?.instantiateViewController(identifier: "StartChatVC") as! StartChatVC
                    vc.person = person
                    print("Selcted Person TOKEN: ", person.oneSignalId)
                    let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360)])
                    
                    self.present(sheetController, animated: true, completion: nil)
                }
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as! AddFriendCell
            let person = personList[indexPath.row]
            cell.index = indexPath.row
            cell.bindData(person: person)
            cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
            cell.selectionStyle = .none
            cell.callbackAddFriend = { (index) in
                let person = self.personList[index]
                let vc = self.storyboard?.instantiateViewController(identifier: "StartChatVC") as! StartChatVC
                vc.person = person
                print("Selcted Person TOKEN ============= ", person.oneSignalId)
                let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360)])
                
                self.present(sheetController, animated: true, completion: nil)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddFriendSection") as! AddFriendSection
            if pendingFriends.count > 0 {
                headerView.headerTitle.text = sections[section] + " " + "\(pendingFriends.count)"
            } else {
                headerView.headerTitle.text = sections[section + 1] + " " + "\(personList.count)"
            }
            return headerView
        } else {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddFriendSection") as! AddFriendSection
            headerView.headerTitle.text = sections[section] + " " + "\(personList.count)"
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}
