//
//  ZedHistoryViewController.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import CryptoSwift
import RealmSwift

class ZedHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    

    var person:Person?
    private var tokenTransactions: NotificationToken? = nil
    private var transactions = realm.objects(ZEDPay.self).filter(falsepredicate)
    
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
        Persons.update(isBalanceRead: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTransactions()
    }
    
    // MARK: - load transactions
    
    func loadTransactions(){
        let predicate1 = NSPredicate(format: "fromUserId == %@ OR toUserId == %@", AuthUser.userId(), AuthUser.userId())
        //let predicate2 = NSPredicate(format: "NOT status IN %@", [TRANSACTION_STATUS.PENDING] )
        /// fix replace this
        //let predicate2 = NSPredicate(format: "status IN %@", [TRANSACTION_STATUS.SUCCESS] )
        
        //transactions = realm.objects(ZEDPay.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "updatedAt", ascending: false)
        transactions = realm.objects(ZEDPay.self).filter(predicate1).sorted(byKeyPath: "updatedAt", ascending: false)
        tokenTransactions?.invalidate()
        transactions.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenTransactions = token
        })
        
    }
    
    func refreshTableView(){
        self.tableView.reloadData()
    }
    // MARK: - table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count > 0 ? transactions.count : 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(transactions.count > 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.GetCellReuseIdentifier(), for: indexPath) as! TransactionCell
            cell.selectionStyle = .none
            cell.bindData(transaction: transactions[indexPath.row], tableView: tableView, indexPath: indexPath)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "noRecord", for: indexPath) as! NoRecordCell
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(transactions.count == 0){
            return
        }
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "detailVC") as! TransactionDetailViewController
        vc.transaction = transactions[indexPath.row]
        self.present(vc, animated: true, completion: nil)

    }

    // MARK: - Cacel Tap
    @IBAction func actionTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Add money tap
    @IBAction func actionTapAddMoney(_ sender: Any) {
        /// just for test
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "payQrcodeVC") as! PayQRCodeViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
