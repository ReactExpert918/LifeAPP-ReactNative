//
//  AccountSettingsTVC.swift
//  Life
//
//  Created by Good Developer on 7/29/21.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class AccountSettingsTVC: BaseTVC {

    @IBOutlet weak var lblNameValue: Regular15Label!
    @IBOutlet weak var lblPasswordValue: Regular15Label!
    @IBOutlet weak var lblPhoneValue: Regular15Label!
    @IBOutlet weak var lblEmailValue: Regular15Label!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initUI()
    }
    
    fileprivate func initUI() {
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: // name
            break
        case 1: // password
            break
        case 2: // phone number
            break
        case 3: // email
            break
        default: // delete
            break
        }
    }

    
}
