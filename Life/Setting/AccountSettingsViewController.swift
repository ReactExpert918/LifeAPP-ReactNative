//
//  AccountSettingsViewController.swift
//  Life
//
//  Created by Yun Li on 2020/7/3.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class AccountSettingsViewController: UIViewController {
    private var person: Person! 

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        if (AuthUser.userId() != "") {
            loadPerson()
        }
    }
    @IBAction func onBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onNameChangeTapped(_ sender: Any) {
    }
    @IBAction func onUsernameChangeTapped(_ sender: Any) {
    }
    @IBAction func onPasswordChangeTapped(_ sender: Any) {
    }
    @IBAction func onPhoneNumberChangeTapped(_ sender: Any) {
    }
    @IBAction func onEmailChangeTapped(_ sender: Any) {
    }
    @IBAction func onDeleteAccountTapped(_ sender: Any) {
    }
    
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        name.text = person.fullname
        userName.text = person.fullname
        password.text = person.fullname
        phoneNumber.text = person.phone
        emailAddress.text = person.email
    }
    
}
