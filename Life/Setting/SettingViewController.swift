//
//  SettingViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    let sections = [NSLocalizedString("General Settings", comment: "General Settings")]
     
    let items = [[NSLocalizedString("Mirai AI", comment: "Mirai AI"), NSLocalizedString("Zed Pay", comment: "Zed Pay"), NSLocalizedString("Account Settings", comment: "Account Settings"), NSLocalizedString("Privacy Policy", comment: "Privacy Policy"), NSLocalizedString("About Us", comment: "About Us")]]
    let icons = [[UIImage(named: "ic_setting_mirai"), UIImage(named: "ic_zed_pay"), UIImage(named: "setting_account"), UIImage(named: "setting_privacy"), UIImage(named: "setting_about")]]
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
        let refreshAlert = UIAlertController(title: "Are you sure to sign out?", message: "", preferredStyle: .alert)

        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            AuthUser.signOut { (error) in
                if let error = error {
                    
                }
                PrefsManager.setEmail(val: "")
                self.gotoWelcomeViewController()
            }
            
        }))

        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func gotoWelcomeViewController() {
        let mainstoryboard = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "rootNavigationViewController")
        UIApplication.shared.windows.first?.rootViewController = vc
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingCell
        cell.selectionStyle = .none
        cell.title.text = items[indexPath.section][indexPath.row]
        cell.profile.image = icons[indexPath.section][indexPath.row]
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SettingCellHeader") as! SettingCellHeader

        headerView.headerTitle.text = sections[section]

        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2{
            if let viewController = storyboard?.instantiateViewController(identifier: "accountSettingsVC") as? AccountSettingsViewController {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

}
