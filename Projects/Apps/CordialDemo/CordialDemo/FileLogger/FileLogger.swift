//
//  FileLogger.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 06.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class FileLogger {
    
    func loging(row: String) {
        let folderName = "logs"
        let fileName = "\(Bundle.main.bundleIdentifier!).log"
        
        let folderURL = self.getDocumentsDirectory().appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            
            let fileURL = folderURL.appendingPathComponent(fileName)
            
            let fileUpdater = try FileHandle(forUpdating: fileURL)
            
            fileUpdater.seekToEndOfFile()
            fileUpdater.write(row.data(using: .utf8)!)
            fileUpdater.closeFile()
            
        } catch let error {
            LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKDemo")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
}
