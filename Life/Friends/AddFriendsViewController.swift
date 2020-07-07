//
//  AddFriendsViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/24.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FittedSheets
import Contacts
class AddFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let sections = ["", "Friend Recommendations"]
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    var personList = [Person]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AddFriendSection", bundle: nil), forHeaderFooterViewReuseIdentifier: AddFriendSection.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        loadFriendsRecommend()
        // Do any additional setup after loading the view.
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
                if contact.isKeyAvailable(CNContactPhoneNumbersKey){
                    for item in contact.phoneNumbers{
                        self.searchPersonsByPhoneNumber(text: item.value.stringValue)
                    }
                }
            }
            tableView.reloadData()
        }
        catch {
            print("unable to fetch contacts")
        }
    }
    
    func searchPersonsByPhoneNumber(text: String = "") {
        let predicate1 = NSPredicate(format: "objectId != %@", AuthUser.userId())
        let predicate2 = (text != "") ? NSPredicate(format: "phone CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")
        personList.append(contentsOf: persons)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return personList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendHeaderCell", for: indexPath) as! AddFriendHeaderCell
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendCell
            let person = personList[indexPath.row]
            cell.index = indexPath.row
            cell.bindData(person: person)
            cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
            cell.selectionStyle = .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }else{
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddFriendSection") as! AddFriendSection

            headerView.headerTitle.text = sections[section] + " " + String(personList.count)

            return headerView
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else{
            return 48
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if personList.count == 0{
            return 1
        }else{
            return 2
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 77
        }else{
            return 64
        }
    }
    
}
