//
//  AddFriendBottomSheetViewController.swift
//  Life
//
//  Created by Yun Li on 2020/7/2.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SwiftyAvatar
class AddFriendBottomSheetViewController: UIViewController {

    var isFriend : Bool = false
    private var person: Person!
    var qrCode : String!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var profile: SwiftyAvatar!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addFriendButton: RoundButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        checkMark.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        loadPerson()
        
    }
    @IBAction func onCancelTapped(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }
    
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: qrCode)
        if let person = person{
            name.text = person.fullname
            phoneNumber.text = person.phone
        }
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profile.image = image?.square(to: 100)
            }
        }
    }
    @IBAction func onAddFriendTapped(_ sender: Any) {
        if isFriend == false{
            if (Friends.isFriend(person.objectId)) {
                self.statusLabel.text = "Already existing in your friend list."
            } else {
                Friends.create(person.objectId)
                self.statusLabel.text = "Successfully added to your friend list."
                isFriend = true
                addFriendButton.backgroundColor = UIColor(hexString: "#00406E")
                addFriendButton.setTitleColor(UIColor.white, for: .normal)
                checkMark.isHidden = false
            }
        }
        else{
            dismiss(animated: true, completion: nil)
        }
    }
    

}
