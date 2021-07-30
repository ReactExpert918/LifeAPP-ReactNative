//
//  BuyPointsTVC.swift
//  Life
//
//  Created by Good Developer on 7/30/21.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import StoreKit

class BuyPointsTVC: BaseTVC {

    var defaultQueue = SKPaymentQueue()
    var product      = SKProduct()
    fileprivate var productRequest: SKProductsRequest!
    fileprivate var availableProducts = [SKProduct]()
    fileprivate var invalidProductIdentifiers = [String]()
    fileprivate var purchased = [SKPaymentTransaction]()
    fileprivate var restored  = [SKPaymentTransaction]()
    
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    fileprivate var hasRestorablePurchases = false
    
    let iapItemNames = [
        "Buy 5 Points",
        "Buy 10 Points",
        "Buy 50 Points",
        "Buy 100 Points"
    ]
    
    let iapItemIDs = [
        "com.life.iap.buy5points", // reference name: LifeBuy5Points
        "com.life.iap.buy10points",
        "com.life.iap.buy50points",
        "com.life.iap.buy100points"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buy Points"
        tableView.tableFooterView = UIView()
        
        defaultQueue = SKPaymentQueue.default()
        defaultQueue.add(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAuthorizedForPayments {
            fetchProducts()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        defaultQueue.remove(self)
    }
    
    fileprivate func fetchProducts() {
        // Create a set for the product identifiers.
        let productIdentifiers = Set(iapItemIDs)
        
        // Initialize the product request with the above identifiers.
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        
        // Send the request to the App Store.
        productRequest.start()
    }
    
    // MARK: - In-app purchase
    func callInAppPurchase(_ index: Int) {
        defaultQueue = SKPaymentQueue.default()
        defaultQueue.add(self)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return iapItemNames.count//availableProducts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuyCell", for: indexPath)

        cell.textLabel?.text = iapItemNames[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        callInAppPurchase(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    

}

// MARK: - In-app purchase delegate
extension BuyPointsTVC: SKProductsRequestDelegate {
    // delegate method to check product availibilty with identifier
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // products contains products whose identifiers have been recognized by the App Store. As such, they can be purchased.
        if !response.products.isEmpty {
            availableProducts = response.products
            self.tableView.reloadData()
        }
        
        // invalidProductIdentifiers contains all product identifiers not recognized by the App Store.
        if !response.invalidProductIdentifiers.isEmpty {
            invalidProductIdentifiers = response.invalidProductIdentifiers
        }
    }

}

extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

extension BuyPointsTVC: SKPaymentTransactionObserver {
    // delegate method to get transaction status of payment
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: break
            // Do not block the UI. Allow the user to continue using the app.
            case .deferred: print("Allow the user to continue using your app.")
            // The purchase was successful.
            case .purchased: handlePurchased(transaction)
            // The transaction failed.
            case .failed: handleFailed(transaction)
            // There're restored products.
            case .restored: handleRestored(transaction)
            @unknown default: fatalError("Unknown payment transaction case.")
            }
        }
    }

    fileprivate func handlePurchased(_ transaction: SKPaymentTransaction) {
        purchased.append(transaction)
        // Finish the successful transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func handleFailed(_ transaction: SKPaymentTransaction) {
        var message = "Purchase of \(transaction.payment.productIdentifier) failed"
        
        if let error = transaction.error {
            message += "\nError: \(error.localizedDescription)"
            print("Error:  \(error.localizedDescription)")
        }
        
        // Do not send any notifications when the user cancels the purchase.
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            // show alert
            self.showAlert(message)
        }
        // Finish the failed transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// Handles restored purchase transactions.
    fileprivate func handleRestored(_ transaction: SKPaymentTransaction) {
        hasRestorablePurchases = true
        restored.append(transaction)
        
        // Finishes the restored transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
