//
//  ReqestAcceptedAlertViewController.swift
//  Life
//
//  Created by Yun Li on 2020/7/16.
//  Copyright © 2020 Zed. All rights reserved.
//

import UIKit

class ReqestAcceptedAlertViewController: UIViewController {
    
    var person : Person!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var profile: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        name.text = person.fullname
        phoneNumber.text = person.phone

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profile.image = image
            }
            else {
                self.profile.image = UIImage(named: "ic_default_profile")
            }
            self.profile.makeRounded()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        Friends.update(person.objectId, isCallbacked: true)
    }
    @IBAction func onStartChatTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
