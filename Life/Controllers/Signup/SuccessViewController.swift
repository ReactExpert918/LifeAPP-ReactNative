//
//  SuccessViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/30.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func onStartTapped(_ sender: Any) {
        AuthUser.logOut()
        let vc =  self.storyboard?.instantiateViewController(identifier: "signinVC") as! SignInViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
