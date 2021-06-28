//
//  StripeSettingsViewController.swift
//  Life
//
//  Created by mac on 2021/6/27.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import JGProgressHUD
import FittedSheets
protocol UpdatePayDelegateProtocol {
    func updatePasscode(result: Bool)
    func updateCard(result: Bool)
    
}
class ZEDPaySettingsViewController: UIViewController {

    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var imgPopup: UIImageView!
    @IBOutlet weak var resultView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resultView.isHidden = true
    }
    

    @IBAction func actionTapClosed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionTapAddCard(_ sender: Any) {
    }
    @IBAction func actionTapPasscode(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "updatePasscodeVC") as! UpdatePasscodeViewController
        vc.delegate = self
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360)])
        self.present(sheetController, animated: false, completion: nil)
    }
    
}

extension ZEDPaySettingsViewController: UpdatePayDelegateProtocol{
    func updatePasscode(result: Bool) {
        if result==false {
            self.imgPopup.image = UIImage(named: "ic_pay_fail")
            self.labelResult.text = "Update passcode failed".localized
        }else{
            
            self.imgPopup.image = UIImage(named: "ic_checkmark_success")
            self.labelResult.text = "Successfully updated the passcode".localized
        }
       
        
        self.resultView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.resultView.isHidden = true
        }
    }
    
    func updateCard(result: Bool) {
        return
    }
    
    
}
