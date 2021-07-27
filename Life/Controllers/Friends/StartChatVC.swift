//
//  StartChatVC.swift
//  Life
//
//  Created by Good Developer on 7/26/21.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit


class StartChatVC: BaseVC {

    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneNum: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    var person = Person()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    fileprivate func initUI() {
        
        if let path = MediaDownload.pathUser(person.objectId) {
            imvProfile.image = UIImage.image(path, size: 40)
        } else {
            imvProfile.image = nil
            downloadImage()
        }
        
        lblName.text = person.fullname
        lblPhoneNum.text = person.phone
        
        if (Friends.isFriend(person.objectId)) {
            lblStatus.text = "Already existing in your friend list."
        } else {
            Friends.create(person.objectId)
            lblStatus.text = "Successfully added to your friend list."
        }
    }
    
    @IBAction func onStartChatTapped(_ sender: Any) {
        PushNotification.send(token: person.oneSignalId, title: "Want to be your friend", body: "I'd like to be your friend. Please accept my request.")
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func downloadImage() {
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.imvProfile.image = image
            } else {
                self.imvProfile.image = UIImage(named: "ic_default_profile")
            }
        }
    }
}
