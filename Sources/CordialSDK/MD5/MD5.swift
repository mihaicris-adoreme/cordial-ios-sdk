//
//  MD5.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

class MD5 {
    
    @available(iOS 13.0, *)
    private func prepareMD5DataCryptoKit(string: String) -> Insecure.MD5.Digest {
        let messageData = string.data(using: .utf8)!
        let digestData = Insecure.MD5.hash (data: messageData)
        
        return digestData
    }
    
    private func prepareMD5DataCommonCrypto(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using: .utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    if #available(iOS 13.0, *) {
                        LoggerManager.shared.error(message: "The CC_MD5 function is cryptographically broken", category: "CordialSDKError")
                    } else {
                        CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                    }
                }
                
                return 0
            }
        }
        
        return digestData
    }
    
    @available(iOS 13.0, *)
    func getHexCryptoKit(string: String) -> String {
        let md5Data = self.prepareMD5DataCryptoKit(string: string)
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        
        return md5Hex
    }
    
    func getHexCommonCrypto(string: String) -> String {
        let md5Data = self.prepareMD5DataCommonCrypto(string: string)
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        
        return md5Hex
    }
}
