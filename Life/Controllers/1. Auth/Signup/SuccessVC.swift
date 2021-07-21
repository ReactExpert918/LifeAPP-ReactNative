//
//  SuccessVC.swift
//  Life
//
//  Created by Yun Li on 2020/6/30.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class SuccessVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onStartTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .loggedIn, object: nil)
        /*
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        UIApplication.shared.windows.first?.rootViewController = vc
        */
        let vc = AppBoards.main.initialViewController
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

}
