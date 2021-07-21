//
//  UpdateNameVC.swift
//  Life
//
//  Created by XianHuang on 7/10/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class UpdateNameVC: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    var name: String? = nil
    var delegate: UpdateDataDelegateProtocol? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.nameTextField.text = self.name
        nameTextField.becomeFirstResponder()
    }
    
    func setName(withName name: String) {
        self.name = name
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func onSubmitTapped(_ sender: Any) {
        let updatedName = self.nameTextField.text
        if updatedName?.isEmpty == true {
            return
        }
        self.dismiss(animated: true) {
            self.delegate?.updateUserName(name: updatedName!)
        }
    }
    
}
