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
    func read() -> String {
        var logs = String()
        
        if let fileURL = self.getFileURL(),
           FileManager.default.fileExists(atPath: fileURL.path) {
            
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
    
    func deleteAll() {
        guard let fileURL = self.getFileURL() else { return }
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch let error {
            LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKDemo")
        }
    }

    @available(iOS 13.4, *)
    func removeTo(log: String) {
        let logs = self.read()
        
        guard let index = self.findIndex(of: log, in: logs) else { return }
        guard let data = logs[logs.index(logs.startIndex, offsetBy: index)...].data(using: .utf8) else { return }
        
        self.update(data: data)
    }
    
    @available(iOS 13.4, *)
    private func update(data: Data) {
        guard let fileURL = self.getFileURL() else { return }
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let fileUpdater = try FileHandle(forWritingTo: fileURL)
                
                try fileUpdater.truncate(atOffset: 0)
                fileUpdater.write(data)
                fileUpdater.closeFile()
            }
        } catch let error {
            LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKDemo")
        }
    }
    
    private func findIndex(of string: String, in str: String) -> Int? {
        for (index, _) in str.enumerated() {
            var found = true
            for (offset, char) in string.enumerated() {
                if str[str.index(str.startIndex, offsetBy: index + offset)] != char {
                    found = false
                    break
                }
            }
            if found {
                return index + string.count
            }
        }
        
        return nil
    }
        
    private func write(_ row: String) {
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
            
            NotificationCenter.default.post(name: .cordialDemoNewLogMessageDelivered, object: nil)
        } catch let error {
            LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKDemo")
        }
    }
    
    private func getDirectoryURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    private func getFileURL() -> URL? {
        let folderName = "logs"
        let fileName = "\(Bundle.main.bundleIdentifier!).log"
        
        let folderURL = self.getDirectoryURL().deletingPathExtension().appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            
            let fileURL = folderURL.deletingPathExtension().appendingPathComponent(fileName)
            
            return fileURL
            
        } catch let error {
            LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKDemo")
        }
        
        return nil
    }
    
    // MARK: - LoggerDelegate
    
    func log(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.write("\(timestamp) [\(category)]: \(message)")
    }
    
    func info(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.write("\(timestamp) [\(category)]: \(message)")
    }
    
    func debug(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.write("\(timestamp) [\(category)]: \(message)")
    }
    
    func error(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.write("\(timestamp) [\(category)]: \(message)")
    }
    
    func fault(message: String, category: String) {
        let timestamp = AppDateFormatter().getTimestampFromDate(date: Date())
        self.write("\(timestamp) [\(category)]: \(message)")
    }
}
