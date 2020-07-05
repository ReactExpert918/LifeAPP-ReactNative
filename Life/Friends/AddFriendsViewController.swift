//
//  AddFriendsViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/24.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FittedSheets
class AddFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let sections = ["", "Official Account Recommendations", "Friend Recommendations"]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return 2
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendHeaderCell", for: indexPath) as! AddFriendHeaderCell
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendCell
            cell.selectionStyle = .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }else{
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddFriendSection") as! AddFriendSection

            headerView.headerTitle.text = sections[section]
            if section == 1{
                headerView.seeAll.isHidden = false
            }else{
                headerView.seeAll.isHidden = true
            }

            return headerView
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else{
            return 48
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 154
        }else{
            return 64
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AddFriendSection", bundle: nil), forHeaderFooterViewReuseIdentifier: AddFriendSection.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true){
            
        }
    }
    
    @IBAction func qrcodeTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "qrcodeVC") as! QrCodeViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func searchFriendsTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "searchFriendsVC") as! SearchFriendsViewController
        //vc.modalPresentationStyle = .fullScreen
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
