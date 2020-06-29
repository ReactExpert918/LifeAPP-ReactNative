//
//  HomeViewController.swift
//  Life
//
//  Created by XianHuang on 6/25/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    var headerSections =  [HeaderSection(name: "Groups 2", collapsed: false), HeaderSection(name: "Friends 5", collapsed: false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor(hexString: "#16406F")
        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "Search"
//        searchBar.backgroundColor = UIColor(hexString: "165c90")
        searchBar.set(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setPlaceholder(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setSearchImage(color: UIColor(hexString: "#96B4D2")!)
//        searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        
        // Init TableView
        ExpandableHeaderCell.RegisterAsAHeader(withTableView: self.homeTableView)
        FriendCell.Register(withTableView: self.homeTableView)
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onAddFriendPressed(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "Friend", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "addFriendsVC")
        //self.navigationController?.pushViewController(vc, animated: true)
        
        //vc.modalPresentationStyle = .fullScreen
        //self.present(vc, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerSections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc =  self.storyboard?.instantiateViewController(identifier: "chatViewController") as! ChatViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandableHeaderCell.GetReuseIdentifier()) as! ExpandableHeaderCell
        header.titleLabel.text = headerSections[section].name
        header.setCollapsed(collapsed: headerSections[section].collapsed)
        header.section = section
        header.delegate = self
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.00
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headerSections[section].collapsed ? 0 : 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "createGroupCell", for: indexPath)
                return cell;
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.GetCellReuseIdentifier(), for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}

extension HomeViewController: CollapsibleTableViewHeaderDelegate {
  func toggleSection(_ header: ExpandableHeaderCell, section: Int) {
    let collapsed = !headerSections[section].collapsed
        
    // Toggle collapse
    headerSections[section].collapsed = collapsed
    header.setCollapsed(collapsed: collapsed)
    
    // Reload the whole section
    homeTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
  }
}

struct HeaderSection {
  var name: String
  var collapsed: Bool
    
  init(name: String, collapsed: Bool = false) {
    self.name = name
    self.collapsed = collapsed
  }
}
    
