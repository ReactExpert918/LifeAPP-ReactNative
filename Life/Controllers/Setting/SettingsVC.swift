//
//  SettingsVC.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift
import FittedSheets

class SettingsVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    let sections = [NSLocalizedString("General Settings", comment: "General Settings")]
    
    let items = [
        NSLocalizedString("Zed Pay", comment: "Zed Pay"),
        NSLocalizedString("Account Settings", comment: "Account Settings"),
        NSLocalizedString("Privacy Policy", comment: "Privacy Policy"),
        NSLocalizedString("EULA", comment: "EULA")
    ]
    
    let icons = [
        UIImage(named: "ic_zed_pay"),
        UIImage(named: "setting_account"),
        UIImage(named: "setting_privacy"),
        UIImage(named: "setting_about")
    ]
    
    private var stripeCustomers = realm.objects(StripeCustomer.self).filter(falsepredicate)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SettingCellHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: SettingCellHeader.reuseIdentifier)
        //tableView.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onSignoutTapped(_ sender: Any) {
        showAlert(R.titleNotice, message: "Are you sure to sign out?", positive: R.btnYes, negative: R.btnNo, positiveAction: { (_) in
            DispatchQueue.main.async {
                Persons.update(lastTerminate: Date().timestamp())
                Persons.update(oneSignalId: "")
                AuthUser.signOut { (error) in
                    if error != nil {
                        return
                    }
                    PrefsManager.setEmail("")
                    self.gotoWelcomeViewController()
                }
            }
        }, negativeAction: nil, completion: nil)
    }
    
    func gotoWelcomeViewController() {
        let vc = AppBoards.login.initialViewController
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
        cell.selectionStyle = .none
        cell.title.text = items[indexPath.row]
        cell.profile.image = icons[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // zed pay
            let predicate = NSPredicate(format: "userId == %@ AND status == %@", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
            stripeCustomers = realm.objects(StripeCustomer.self).filter(predicate)
            let stripeCustomer = stripeCustomers.first
            if(stripeCustomer == nil){
                let vc =  self.storyboard?.instantiateViewController(identifier: "CreateCustomerVC") as! CreateCustomerVC
                let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360)])
                self.present(sheetController, animated: false, completion: nil)
            } else {
                if let vc = storyboard?.instantiateViewController(identifier: "ZedPaySettingsVC") as? ZedPaySettingsVC {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        case 1: // account settings
            if let viewController = storyboard?.instantiateViewController(identifier: "AccountSettingsVC") as? AccountSettingsVC {
                navigationController?.pushViewController(viewController, animated: true)
            }
        case 2: // privacy policy
            if let vc = storyboard?.instantiateViewController(identifier: "PrivacyEulaVC") as? PrivacyEulaVC {
                vc.privacy = true
                navigationController?.pushViewController(vc, animated: true)
            }
        case 3: // eula
            if let vc = storyboard?.instantiateViewController(identifier: "PrivacyEulaVC") as? PrivacyEulaVC {
                vc.privacy = false
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            self.showToast("Coming soon")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SettingCellHeader") as! SettingCellHeader

        headerView.headerTitle.text = sections[section]

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
}
