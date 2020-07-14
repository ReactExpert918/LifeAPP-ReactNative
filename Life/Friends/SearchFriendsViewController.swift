//
//  SearchFriendsViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import BEMCheckBox
class SearchFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTxt: UILabel!
    @IBOutlet weak var searchResultBk: UIImageView!
    @IBOutlet weak var showingResult: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var radioGroup : BEMCheckBoxGroup!
    @IBOutlet weak var radioUsername: BEMCheckBox!
    @IBOutlet weak var radioPhoneNumber: BEMCheckBox!
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupProfileImageView: UIImageView!
    @IBOutlet weak var popupNameLabel: UILabel!
    @IBOutlet weak var popupPhoneNumberLabel: UILabel!
    @IBOutlet weak var popupStatusLabel: UILabel!
    
    @IBOutlet weak var resultPictureHeight: NSLayoutConstraint!
    @IBOutlet weak var resultViewBottomConstraint: NSLayoutConstraint!
    
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        showingResult.isHidden = true
        radioGroup = BEMCheckBoxGroup(checkBoxes: [radioUsername, radioPhoneNumber])
        radioGroup.mustHaveSelection = true
        radioGroup.selectedCheckBox = radioUsername
        // Initialize search bar
        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor(hexString: "#999999")
        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "Search friends"
        searchBar.set(textColor: UIColor(hexString: "#333333")!)
        searchBar.setPlaceholder(textColor: UIColor(hexString: "#999999")!)
        searchBar.setSearchImage(color: UIColor(hexString: "#999999")!)
//        searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        searchBar.tintColor = UIColor(hexString: "#333333")
        // Subscribe Keyboard Popup
        subscribeToShowKeyboardNotifications()
    }
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            resultViewBottomConstraint.constant = keyboardHeight
            resultPictureHeight.constant = 100
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            resultViewBottomConstraint.constant = 0
            resultPictureHeight.constant = 200
        }
    }
    @IBAction func backTapped(_ sender: Any) {
        //dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPopupClosePreseed(_ sender: Any) {
        popupView.isHidden = true
    }
    
    @IBAction func onStartChatPressed(_ sender: Any) {
        popupView.isHidden = true
        self.dismiss(animated: true) {
            
        }        
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
    //---------------------------------------------------------------------------------------------------------------------------------------------
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
    // MARK: - Refresh methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTableView() {
        tableView.reloadData()
    }
    // MARK: - Backend methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchPersonsByUserName(text: String = "") {
        if text.count < 4 {
            return
        }
        let predicate1 = NSPredicate(format: "objectId != %@ AND isDeleted == NO", AuthUser.userId())
        let predicate2 = (text != "") ? NSPredicate(format: "fullname CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")
        
        if persons.count > 0 {
            tableView.isHidden = false
            refreshTableView()
        }
        else{
            tableView.isHidden = true
        }
    }
    
    func searchPersonsByPhoneNumber(text: String = "") {
        if text.count < 9 {
            return
        }
        let predicate1 = NSPredicate(format: "objectId != %@ AND isDeleted == NO", AuthUser.userId())
        let predicate2 = (text != "") ? NSPredicate(format: "phone CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")
        if persons.count > 0 {
            tableView.isHidden = false
            refreshTableView()
        }
        else{
            tableView.isHidden = true
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchFriendCell", for: indexPath) as! SearchFriendCell
        let person = persons[indexPath.row]
        cell.index = indexPath.row
        cell.bindData(person: person)
        cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
        cell.selectionStyle = .none
        
        cell.callbackAddFriend = { (index) in
            let person = self.persons[index]
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultBk.image = UIImage(named: "no_available_bk")
        if radioGroup.selectedCheckBox == radioUsername{
            searchResultTxt.text = "No user is available by that username"
        }else{
            searchResultTxt.text = "No user is available by that phone number"
        }
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
        //loadPersons()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar_.text
        if searchText?.isEmpty == true {
            return
        }
        if radioGroup.selectedCheckBox == radioUsername{
            searchPersonsByUserName(text: searchText ?? "")
        }else{
            searchPersonsByPhoneNumber(text: searchText ?? "")
        }
    }

}
