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
    
    let sections = ["New Friend Requests".localized, "New Friend Pendings".localized, "Friend Recommendations".localized]
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    private var pendingFriends = realm.objects(Person.self).filter(falsepredicate)
    private var requestFriends = realm.objects(Person.self).filter(falsepredicate)
    var personList = [Person]()
    
    var contacts = [FetchedContact]()
    var contactImageAvailability: Bool?
    
    var selectedPerson : Person!
    var sectionCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "AddFriendSection", bundle: nil), forHeaderFooterViewReuseIdentifier: AddFriendSection.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        
        //refreshView()
        // Do any additional setup after loading the view.
    }
    
    func refreshView(){
        
        persons = realm.objects(Person.self).filter(falsepredicate)
        pendingFriends = realm.objects(Person.self).filter(falsepredicate)
        requestFriends = realm.objects(Person.self).filter(falsepredicate)
        personList.removeAll()
        loadFriendsRecommend()
        loadPendingFriends()
        loadRequestFriends()
        refreshTableView()
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
        refreshView()
    }
    
    @IBAction func onAcceptTapped(_ sender: Any) {
        confirmPopupView.isHidden = true
        Friends.update(selectedPerson.objectId, isAccepted: true)
        refreshView()
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
                // print("failed to request access", error)
                return
            }
            if granted {
                
            }
            
        }
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                // print("failed to request access", error)
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
                        
                        
                        for phone in contact.phoneNumbers {
                            
                            var label = "unknown"
                            if phone.label != nil {
                                label = CNLabeledValue<NSString>.localizedString(forLabel:
                                    phone.label!)
                                
                                if(label == "mobile"){
                                    let phoneStr = phone.value.stringValue
                                    var trim = phoneStr.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: "")
                                    if(trim.prefix(1) != "+"){
                                        trim = phoneCode+trim
                                    }
                                    
                                    self.searchPersonsByPhoneNumber(text:trim)
                                }
                            }
                        }
                        
                         
                    })
                } catch {
                    //print(error)
                }
                

            } else {
                // print("access denied")
            }
        }
        
        // print("recommend")
        //print(personList.count)
    }
    
    func searchPersonsByPhoneNumber(text: String = "") {
        //print(text)
        let predicate1 = NSPredicate(format: "objectId != %@ AND NOT objectId IN %@", AuthUser.userId(), Friends.friendIds())
        let predicate2 = (text != "") ? NSPredicate(format: "phone == %@", text) : NSPredicate(value: true)
        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "phone")
        //persons = realm.objects(Person.self)
        personList.append(contentsOf: persons)
    }
    
    func loadPendingFriends(){
        // print("pending")
        // print(Friends.friendPendingIds())
        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Friends.friendPendingIds(), Blockeds.blockerIds())
        pendingFriends = realm.objects(Person.self).filter(predicate1).sorted(byKeyPath: "fullname")
        // print(pendingFriends.count)
    }
    func loadRequestFriends(){
        // print("request")
        // print(Friends.friendRequestIds())
        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Friends.friendRequestIds(), Blockeds.blockerIds())
        requestFriends = realm.objects(Person.self).filter(predicate1).sorted(byKeyPath: "fullname")
        // print(requestFriends.count)
    }
    
    func refreshTableView(){
        sectionCount = 0
        if pendingFriends.count > 0 {
            sectionCount += 1
        }
        if requestFriends.count > 0{
            sectionCount += 1
        }
        
        if personList.count > 0 {
            sectionCount += 1
        }
        
       
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func addPendingCell(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
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
        
    }
    func addRequestCell(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendPendingCell", for: indexPath) as! AddFriendPendingCell
        let person = requestFriends[indexPath.row]
        
        cell.bindData(person: person)
        cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
        cell.selectionStyle = .none
        
        return cell
        
    }
    func addPersonCell(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
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
                self.popupStatusLabel.text = "Already existing in your friend list.".localized
            } else {
                Friends.create(person.objectId)
                self.popupStatusLabel.text = "Successfully added to your friend list.".localized
                self.refreshView()
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if pendingFriends.count > 0{
                return addPendingCell(tableView, cellForRowAt: indexPath)
            }else if requestFriends.count > 0{
                return addRequestCell(tableView, cellForRowAt: indexPath)
            }
            else{
                return addPersonCell(tableView, cellForRowAt: indexPath)
            }
        }
        else if indexPath.section == 1{
            if pendingFriends.count > 0 && requestFriends.count > 0{
                return addRequestCell(tableView, cellForRowAt: indexPath)
            }else{
                return addPersonCell(tableView, cellForRowAt: indexPath)
            }
        }
        else{
            return addPersonCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if pendingFriends.count > 0{
                return pendingFriends.count
            }else if requestFriends.count > 0{
                return requestFriends.count
            }
            else{
                return personList.count
            }
        }
        else if section == 1{
            if pendingFriends.count > 0 && requestFriends.count > 0{
                return requestFriends.count
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
            }else if requestFriends.count > 0{
                headerView.headerTitle.text = sections[1] + " " + String(requestFriends.count)
            }
            else{
                headerView.headerTitle.text = sections[2] + " " + String(personList.count)
            }
            return headerView
        }
        else if section == 1{
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddFriendSection") as! AddFriendSection
            if pendingFriends.count>0 && requestFriends.count > 0{
                headerView.headerTitle.text = sections[1] + " " + String(requestFriends.count)
            }
            else{
                headerView.headerTitle.text = sections[2] + " " + String(personList.count)
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
    
    override func viewDidAppear(_ animated: Bool) {
        refreshView()
    }
    

}
