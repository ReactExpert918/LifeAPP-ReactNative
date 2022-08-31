//
//  SettingViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift
import JamitFoundation

class SettingViewController: UIViewController{
    private enum Constants {
        static let adUnitId: String = "ca-app-pub-9167808110872900/4939430243"
    }
    
    private lazy var adView: AdView = .instantiate()
    
    @IBOutlet weak var adViewContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let sections = [NSLocalizedString("General Settings", comment: "General Settings")]
    
    let items = [
        NSLocalizedString("Account Settings", comment: "Account Settings"),
        NSLocalizedString("Zed Pay", comment: "Zed Pay"),
        NSLocalizedString("Privacy Policy", comment: "Privacy Policy"),
        NSLocalizedString("EULA", comment: "EULA"),
        NSLocalizedString("How to use Life app", comment: "How to use Life app")
    ]
    
    let icons = [
        UIImage(named: "setting_account"),
        UIImage(named: "ic_zed_pay"),
        UIImage(named: "setting_privacy"),
        UIImage(named: "setting_about"),
        UIImage()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SettingCellHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: SettingCellHeader.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adView.frame = adViewContainer.bounds
        adViewContainer.addSubview(adView)
        
        adView.model = AdViewModel(
            unitId: Constants.adUnitId,
            adSize: CGSize(width: 300, height: 250),
            rootViewController: self
        )
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onSignoutTapped(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Sign Out".localized, message: "Are you sure you want to sign out?".localized, preferredStyle: .alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes".localized, style: .default, handler: { (action: UIAlertAction!) in
            
            DispatchQueue.main.async {
                Persons.update(lastTerminate: Date().timestamp())
                Persons.update(oneSignalId: "")
                AuthUser.signOut { (error) in
                    if error != nil {
                        return
                    }
                    PrefsManager.setEmail(val: "")
                    self.gotoWelcomeViewController()
                }
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No".localized, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func gotoWelcomeViewController() {
        let mainstoryboard = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "rootNavigationViewController")
        UIApplication.shared.windows.first?.rootViewController = vc
    }
}
