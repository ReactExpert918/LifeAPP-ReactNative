//
//  HomeViewController.swift
//  Life
//
//  Created by XianHuang on 6/25/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
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
        
        // Do any additional setup after loading the view.
    }
    

 

}
