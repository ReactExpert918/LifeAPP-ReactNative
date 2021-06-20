//
//  ZedHistoryViewController.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class ZedHistoryViewController: UIViewController {

    var person:Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    // MARK: - Cacel Tap
    @IBAction func actionTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
