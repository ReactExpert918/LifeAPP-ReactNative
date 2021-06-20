//
//  ZedHistoryViewController.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class ZedHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    

    var person:Person?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelBalance: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        labelBalance.text = person?.getBalance().moneyString()
        TransactionCell.Register(withTableView: self.tableView)
        self.tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // MARK: - table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row < 5){
            let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.GetCellReuseIdentifier(), for: indexPath) as! TransactionCell
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row < 5){
            return 140
        }
        else{
            return 0
        }
    }

    // MARK: - Cacel Tap
    @IBAction func actionTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Add money tap
    @IBAction func actionTapAddMoney(_ sender: Any) {
    }
}
