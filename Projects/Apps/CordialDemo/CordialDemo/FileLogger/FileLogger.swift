//
//  FileLogger.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 06.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class FileLogger: LoggerDelegate {
    
    static let shared = FileLogger()
    
    private init() {}
    
    @available(iOS 13.4, *)
    func reading() -> String {
        var logs = String()
        
        if let fileURL = self.getFileURL() {
            do {
                let fileUpdater = try FileHandle(forReadingFrom: fileURL)
                
                if let logsData = try fileUpdater.readToEnd(),
                   let logsDataDecoding  = String(data: logsData, encoding: .utf8) {
                    
                    logs = logsDataDecoding
                }
                
                fileUpdater.closeFile()
                
            } catch let error {
                LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKDemo")
            }
        }
        
        return logs
    }
    
    private func getDirectoryURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    private func getFileURL() -> URL? {
        let folderName = "logs"
        let fileName = "\(Bundle.main.bundleIdentifier!).log"
        
        let folderURL = self.getDirectoryURL().appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            
            let fileURL = folderURL.appendingPathComponent(fileName)
            
            return fileURL
            
        } catch let error {
            LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKDemo")
        }
        
        return nil
    }
    
    private func loging(_ row: String) {
        guard let fileURL = self.getFileURL(), let rowData = "\(row)\n\n".data(using: .utf8) else { return }
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let fileUpdater = try FileHandle(forWritingTo: fileURL)
                
                fileUpdater.seekToEndOfFile()
                fileUpdater.write(rowData)
                fileUpdater.closeFile()
            } else {
                try rowData.write(to: fileURL)
            }
        } catch let error {
            LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKDemo")
        }
    }
    
    // MARK: - LoggerDelegate
    
    func log(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.loging("\(timestamp) [\(category)]: \(message)")
    }
    
    func info(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.loging("\(timestamp) [\(category)]: \(message)")
    }
    
    func debug(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.loging("\(timestamp) [\(category)]: \(message)")
    }
    
    func error(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.loging("\(timestamp) [\(category)]: \(message)")
    }
    
    func fault(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.loging("\(timestamp) [\(category)]: \(message)")
    }
}
