//
//  OSLogManager.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 28.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let сordialSDKDemo = OSLog(subsystem: subsystem, category: "CordialSDKDemo")
        
    func loging(row: String) {
        let folderName = "logs"
        let fileName = "\(OSLog.subsystem).log"
        
        let folderURL = self.getDocumentsDirectory().appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            
            let fileURL = folderURL.appendingPathComponent(fileName)
            
            let fileUpdater = try FileHandle(forUpdating: fileURL)
            
            fileUpdater.seekToEndOfFile()
            fileUpdater.write(row.data(using: .utf8)!)
            fileUpdater.closeFile()
            
        } catch let error {
            os_log("Error: [%{public}@]", log: .сordialSDKDemo, type: .error, error.localizedDescription)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
}
