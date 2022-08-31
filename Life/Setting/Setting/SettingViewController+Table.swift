//
//  SettingViewController+Table.swift
//  Life
//
//  Created by Escape on 09/06/1401 AP.
//  Copyright © 1401 AP Zed. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets

fileprivate extension SettingViewController {
    
    func gotoWalkthrough() {
        let viewModel = WalkthroughViewModel(fromSetting: true)
        let walkthroughViewController = WalkthroughViewController.instantiate()
        walkthroughViewController.model = viewModel
        navigationController?.pushViewController(walkthroughViewController, animated: true)
    }
    
    func gotoAccount() {
        if let viewController = storyboard?.instantiateViewController(identifier: "accountSettingsVC") as? AccountSettingsViewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func gotoZedPay() {
        var stripeCustomers = realm.objects(StripeCustomer.self).filter(falsepredicate)
        let predicate = NSPredicate(format: "userId == %@ AND status == %@", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
        stripeCustomers = realm.objects(StripeCustomer.self).filter(predicate)
        let stripeCustomer = stripeCustomers.first
        if(stripeCustomer == nil){
            let vc =  self.storyboard?.instantiateViewController(identifier: "createCustomerVC") as! CreateCustomerViewController
            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360)])
            self.present(sheetController, animated: false, completion: nil)
        }
        else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "zedPaySettingsVC") as! ZEDPaySettingsViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    func gotoPrivacy() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyEulaVC") as! PrivacyEulaVC
        vc.privacy = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoEula() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyEulaVC") as! PrivacyEulaVC
        vc.privacy = false
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            gotoAccount()
        case 1:
            gotoZedPay()
        case 2:
            gotoPrivacy()
        case 3:
            gotoEula()
        case 4:
            gotoWalkthrough()
        default:
            break
        }
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingCell
        cell.selectionStyle = .none
        cell.title.text = items[indexPath.row]
        cell.profile.image = icons[indexPath.row]
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
}
