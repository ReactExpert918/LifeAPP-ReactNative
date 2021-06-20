//
//  String+Extension.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import CryptoSwift
extension String {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func decryptedFloat() -> Float {

        let bytes:[UInt8] = Array(self.utf8)
        //let s = String(format: "%.2f", value)
        if let aes = try? AES(key: LIFE_CRYPT.key, iv: LIFE_CRYPT.iv),
           let aesD = try? aes.decrypt(bytes) {
            
            guard let balanceDecrypted = String(bytes: aesD, encoding: .utf8) else {
                return 0
            }
           
            return (balanceDecrypted as NSString).floatValue
        }
        return 0
    }

    
}
