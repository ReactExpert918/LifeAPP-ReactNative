//
//  Transactions.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//
import RealmSwift
class Transactions: NSObject {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func create(fromUserId: String, toUserId: String, quantity: Float ) {


        let transaction = Transaction()
        
        transaction.objectId = transaction.objectId.crc32().uppercased()
        transaction.fromUserId = fromUserId
        transaction.toUserId = toUserId
        transaction.quantity = quantity.encryptedString()
        let realm = try! Realm()
        try! realm.safeWrite {
            realm.add(transaction, update: .modified)
        }
        return
        
    }

    // MARK: -
    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func update(_ transactionId: String, status: Int) {

        if let transaction = realm.object(ofType: Transaction.self, forPrimaryKey: transactionId) {
            transaction.update(status: status)
        }
    }
    class func update(_ transactionId: String, fromUserId: String) {

        if let transaction = realm.object(ofType: Transaction.self, forPrimaryKey: transactionId) {
            transaction.update(fromUserId: fromUserId)
        }
    }
    
    class func update(_ transactionId: String, toUserId: String) {

        if let transaction = realm.object(ofType: Transaction.self, forPrimaryKey: transactionId) {
            transaction.update(toUserId: toUserId)
        }
    }
    
    class func update(_ transactionId: String, quantity: Float) {

        if let transaction = realm.object(ofType: Transaction.self, forPrimaryKey: transactionId) {
            transaction.update(quantity: quantity)
        }
    }
}
