//
//  MD5.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

class MD5 {
    
    private func prepareMD5Data(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                
                return 0
            }
        }
        
        return digestData
    }
    
    func getHex(string: String) -> String {
        let md5Data = self.prepareMD5Data(string: string)
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        
        return md5Hex
    }
    
    func getBase64(string: String) -> String {
        let md5Data = self.prepareMD5Data(string: string)
        let md5Base64 = md5Data.base64EncodedString()
        
        return md5Base64
    }
}
