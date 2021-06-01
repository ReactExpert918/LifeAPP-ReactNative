//
//  AddFriendsViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/24.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FittedSheets
import FirebaseFirestore
import Contacts
import ContactsUI

class AddFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    //Popup for sending Friend Request
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupProfileImageView: UIImageView!
    @IBOutlet weak var popupNameLabel: UILabel!
    @IBOutlet weak var popupPhoneNumberLabel: UILabel!
    @IBOutlet weak var popupStatusLabel: UILabel!
    //Popup to confirm Friend Request
    @IBOutlet weak var confirmPopupView: UIView!
    @IBOutlet weak var confirmPopupProfileImage: UIImageView!
    @IBOutlet weak var confirmPopupLabel: UILabel!
    
    let sections = ["New Friend Requests", "Friend Recommendations"]
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    private var pendingFriends = realm.objects(Person.self).filter(falsepredicate)
    var personList = [Person]()
    
    var contacts = [FetchedContact]()
    var contactImageAvailability: Bool?
    
    var selectedPerson : Person!
    var sectionCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "AddFriendSection", bundle: nil), forHeaderFooterViewReuseIdentifier: AddFriendSection.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        loadFriendsRecommend()
        loadPendingFriends()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onStartChatTapped(_ sender: Any) {
        popupView.isHidden = true
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onPopupCloseTapped(_ sender: Any) {
        popupView.isHidden = true
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
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true){
        }
    }
    
    @IBAction func qrcodeTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "qrcodeVC") as! QrCodeViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func searchFriendsTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "searchFriendsVC") as! SearchFriendsViewController
        //vc.modalPresentationStyle = .fullScreen
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func loadFriendsRecommend(){
        CNContactStore().requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                
            }
            
        }
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                let keys = [CNContactFamilyNameKey, CNContactGivenNameKey,  CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactPostalAddressesKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                var countryCode = NSLocale.current.regionCode
                if countryCode == nil{
                    countryCode = ""
                }
                let phoneCode = Util.getCountryPhonceCode(countryCode: countryCode!)
                
                do {
                    try store.enumerateContacts(with: request, usingBlock: {
                        (contact : CNContact, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
                        
                        let person = Person()
                        person.firstname = contact.givenName
                        person.lastname = contact.familyName
                        person.fullname = person.firstname+" "+person.lastname
                        person.objectId = AuthUser.userId()
                        for phone in contact.phoneNumbers {
                            
                            var label = "未知标签"
                            if phone.label != nil {
                                label = CNLabeledValue<NSString>.localizedString(forLabel:
                                    phone.label!)
                                
                                if(label == "mobile"){
                                    let phoneStr = phone.value.stringValue
                                    var trim = phoneStr.trimmingCharacters(in: .whitespaces)
                                    if(trim.prefix(1) != "+"){
                                        trim = phoneCode+trim
                                    }
                                    person.phone = trim
                                }
                            }
                        }
                        self.personList.append(person)
                         
                    })
                } catch {
                    print(error)
                }
                self.searchPersonsByPhoneNumber()

            } else {
                print("access denied")
            }
        }
    }
    
    func searchPersonsByPhoneNumber(text: String = "") {
        let predicate1 = NSPredicate(format: "objectId != %@", AuthUser.userId())
        let predicate2 = (text != "") ? NSPredicate(format: "phone CONTAINS[c] %@", text) : NSPredicate(value: true)
        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "phone")
        personList.append(contentsOf: persons)
    }
    
    func loadPendingFriends(){
        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Friends.friendPendingIds(), Blockeds.blockerIds())
        pendingFriends = realm.objects(Person.self).filter(predicate1).sorted(byKeyPath: "fullname")
        refreshTableView()
    }
    
    func refreshTableView(){
        if pendingFriends.count > 0 && personList.count > 0{
            sectionCount = 2
        }else if pendingFriends.count > 0{
            sectionCount = 1
        }else if personList.count > 0{
            sectionCount = 1
        }else{
            sectionCount = 0
        }
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if pendingFriends.count > 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendConfirmCell", for: indexPath) as! AddFriendConfirmCell
                let person = pendingFriends[indexPath.row]
                cell.index = indexPath.row
                cell.bindData(person: person)
                cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
                cell.selectionStyle = .none
                cell.callbackAddFriendConfirm = { (index) in
                    let person = self.pendingFriends[index]
                    self.selectedPerson = person
                    // Display info on popupview
                    self.confirmPopupLabel.text = "Do you want to add \(person.fullname) your friend list?"
                    self.loadRequestedFriendImage(person: person)

                    self.confirmPopupView.isHidden = false
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendCell
                let person = personList[indexPath.row]
                cell.index = indexPath.row
                cell.bindData(person: person)
                cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
                cell.selectionStyle = .none
                cell.callbackAddFriend = { (index) in
                    let person = self.personList[index]
                    // Display info on popupview
                    self.popupNameLabel.text = person.fullname
                    self.popupPhoneNumberLabel.text = person.phone
                    self.loadImage(person: person)
                    
                    self.popupView.isHidden = false
                    if (Friends.isFriend(person.objectId)) {
                        self.popupStatusLabel.text = "Already existing in your friend list."
                    } else {
                        Friends.create(person.objectId)
                        self.popupStatusLabel.text = "Successfully added to your friend list."
                    }
                }
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendCell
            let person = personList[indexPath.row]
            cell.index = indexPath.row
            cell.bindData(person: person)
            cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
            cell.selectionStyle = .none
            cell.callbackAddFriend = { (index) in
                let person = self.personList[index]
                // Display info on popupview
                self.popupNameLabel.text = person.fullname
                self.popupPhoneNumberLabel.text = person.phone
                self.loadImage(person: person)
                
                self.popupView.isHidden = false
                if (Friends.isFriend(person.objectId)) {
                    self.popupStatusLabel.text = "Already existing in your friend list."
                } else {
                    Friends.create(person.objectId)
                    self.popupStatusLabel.text = "Successfully added to your friend list."
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if pendingFriends.count > 0{
                return pendingFriends.count
            }else{
                return personList.count
            }
        }
        else{
            return personList.count
        }
    }
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddFriendSection") as! AddFriendSection
            if pendingFriends.count > 0{
                headerView.headerTitle.text = sections[section] + " " + String(pendingFriends.count)
            }else{
                headerView.headerTitle.text = sections[section + 1] + " " + String(personList.count)
            }
            return headerView
        }
        else{
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddFriendSection") as! AddFriendSection
            headerView.headerTitle.text = sections[section] + " " + String(personList.count)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func loadImage(person: Person) {
        if let path = MediaDownload.pathUser(person.objectId) {
            popupProfileImageView.image = UIImage.image(path, size: 40)
            //labelInitials.text = nil
        } else {
            popupProfileImageView.image = nil
            //labelInitials.text = person.initials()
            downloadImage(person: person)
        }
        popupProfileImageView.makeRounded()
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
    
    func downloadImage(person: Person) {
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.popupProfileImageView.image = image
                self.popupProfileImageView.makeRounded()
            }
            else{
                self.popupProfileImageView.image = UIImage(named: "ic_default_profile")
            }
        }
    }
    

}
