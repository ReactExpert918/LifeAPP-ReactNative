//
//  ViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/24.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func addFriendTapped(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Friend", bundle: nil)
        let addFriendsViewController: AddFriendsViewController = mainStoryboard.instantiateViewController(withIdentifier: "addFriendsVC") as! AddFriendsViewController
        addFriendsViewController.modalPresentationStyle = .fullScreen
        self.present(addFriendsViewController, animated: true, completion: nil)
    }
    

}

