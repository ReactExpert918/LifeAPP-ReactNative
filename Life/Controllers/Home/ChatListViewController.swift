//
//  ChatListViewController.swift
//  Life
//
//  Created by XianHuang on 6/25/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var chatsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       searchBar.backgroundImage = UIImage()
       searchBar.barStyle = .default
       searchBar.barTintColor = UIColor(hexString: "#16406F")
       searchBar.layer.cornerRadius = 8
       searchBar.placeholder = "Search"
//     searchBar.backgroundColor = UIColor(hexString: "165c90")
       searchBar.set(textColor: UIColor(hexString: "#96B4D2")!)
       searchBar.setPlaceholder(textColor: UIColor(hexString: "#96B4D2")!)
       searchBar.setSearchImage(color: UIColor(hexString: "#96B4D2")!)
//     searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        
        // Init Chat List TableView
        chatsTableView.dataSource = self
        chatsTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatHistoryCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

}
