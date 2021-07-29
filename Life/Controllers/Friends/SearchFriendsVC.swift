//
//  SearchFriendsVC.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import BEMCheckBox
import FittedSheets

class SearchFriendsVC: BaseVC {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTxt: UILabel!
    @IBOutlet weak var searchResultBk: UIImageView!
    @IBOutlet weak var showingResult: UILabel!
    @IBOutlet weak var tblSearchFriends: UITableView!
    var radioGroup : BEMCheckBoxGroup!
    @IBOutlet weak var radioEmail: BEMCheckBox!
    @IBOutlet weak var radioPhoneNumber: BEMCheckBox!
    /*
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupProfileImageView: UIImageView!
    @IBOutlet weak var popupNameLabel: UILabel!
    @IBOutlet weak var popupPhoneNumberLabel: UILabel!
    @IBOutlet weak var popupStatusLabel: UILabel!*/
    
    @IBOutlet weak var resultPictureHeight: NSLayoutConstraint!
    @IBOutlet weak var resultViewBottomConstraint: NSLayoutConstraint!
    
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblSearchFriends.isHidden = true
        tblSearchFriends.delegate = self
        tblSearchFriends.dataSource = self
        
        showingResult.isHidden = true
        radioGroup = BEMCheckBoxGroup(checkBoxes: [radioEmail, radioPhoneNumber])
        radioGroup.mustHaveSelection = true
        radioGroup.selectedCheckBox = radioEmail
        
        searchBar.tintColor = .primaryColor
        let attributes:[NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.primaryColor,
            .font: UIFont(name: MyFont.MontserratRegular, size: 16)!
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        /*
        // Initialize search bar
//        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
//        searchBar.barTintColor = UIColor(hexString: "#999999")
//        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "Search friends"
        searchBar.set(textColor: UIColor(hexString: "#333333")!)
//        searchBar.setPlaceholder(textColor: UIColor(hexString: "#999999")!)
//        searchBar.setSearchImage(color: UIColor(hexString: "#999999")!)
//        searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        
 */
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
            let _ = keyboardRectangle.height
            resultViewBottomConstraint.constant = 0
            resultPictureHeight.constant = 200
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SearchFriendsVC: UISearchBarDelegate, UISearchDisplayDelegate {
    // MARK: - Backend methods
    func searchPersonsByEmail(text: String = "") {
        
        if !Utils.shared.isValidEmail(text) {
            showToast(R.msgInvalidEmail)
            return
        }
        
        let predicate1 = NSPredicate(format: "objectId != %@ AND isDeleted == NO", AuthUser.userId())
        let predicate2 = (text != "") ? NSPredicate(format: "email CONTAINS[c] %@", text) : NSPredicate(value: true)

//        persons = realm.objects(Person.self).filter(predicate2).sorted(byKeyPath: "fullname")
        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")
        
        if persons.count > 0 {
            tblSearchFriends.isHidden = false
            tblSearchFriends.reloadData()
        } else {
            tblSearchFriends.isHidden = true
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
            tblSearchFriends.isHidden = false
            tblSearchFriends.reloadData()
        } else {
            tblSearchFriends.isHidden = true
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar_.text
        if searchText?.isEmpty == true {
            return
        }
        
        if radioGroup.selectedCheckBox == radioEmail {
            searchPersonsByEmail(text: searchText ?? "")
        } else {
            searchPersonsByPhoneNumber(text: searchText ?? "")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultBk.image = UIImage(named: "no_available_bk")
        if radioGroup.selectedCheckBox == radioEmail {
            searchResultTxt.text = "No user is available by that username"
        } else {
            searchResultTxt.text = "No user is available by that phone number"
        }
    }
}

extension SearchFriendsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFriendCell", for: indexPath) as! SearchFriendCell
        let person = persons[indexPath.row]
        cell.index = indexPath.row
        cell.bindData(person: person)
        cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
        cell.selectionStyle = .none
        
        cell.callbackAddFriend = { (index) in
            let person = self.persons[index]
            
            let vc = self.storyboard?.instantiateViewController(identifier: "StartChatVC") as! StartChatVC
            vc.person = person
            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360)])
            
            self.present(sheetController, animated: true, completion: nil)
        }
        
        return cell
    }
}
