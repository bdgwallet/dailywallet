//
//  BackupManager.swift
//  dailywallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import Foundation
import CryptoKit
import KeychainAccess

public class BackupManager: ObservableObject {
    // Public variables
    @Published public var backupInfo: BackupInfo?
    
    // Private variables
    private let keychain: Keychain
    private let symmetricKey: SymmetricKey
    
    // Public functions
    // Initialize the backupmanager with an encryption key and cloud backup option
    public init(encryptionKey: String, enableCloudBackup: Bool) {
        self.symmetricKey = SymmetricKey(data: Data(hexString:encryptionKey)!)
        let appName = Bundle.main.displayName
        self.keychain = Keychain(service: appName)
            .label(appName)
            .synchronizable(enableCloudBackup)
            .accessibility(.whenUnlocked)
        self.backupInfo = self.getBackupInfo()
    }
    
    // Get any saved backup info from keychain, decrypted
    public func getBackupInfo() -> BackupInfo? {
        let encryptedJsonData = try? keychain.getData("BackupInfo")
        if encryptedJsonData != nil {
            do {
                let sealedBox = try AES.GCM.SealedBox(combined: encryptedJsonData!)
                let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
                let decryptedJson = String(data: decryptedData, encoding: .utf8)
                let backupInfo = try JSONDecoder().decode(BackupInfo.self, from: decryptedJson!.data(using: .utf8)!)
                return backupInfo
            } catch let error {
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }

    // Save backup info to keychain, encrypted
    public func saveBackupInfo(backupInfo: BackupInfo) {
        if let json = try? JSONEncoder().encode(backupInfo) {
            do {
                let encryptedContent = try AES.GCM.seal(json, using: self.symmetricKey).combined
                keychain[data: "BackupInfo"] = encryptedContent
            } catch let error {
                print(error)
            }
        }
    }
    
    // Delete backup info from keychain - WARNING!
    public func deleteBackupInfo() {
        do {
            try keychain.remove("BackupInfo")
        } catch let error {
            print(error)
        }
    }
    
    // Delete all files in document directories - WARNING!
    public func deleteAllFiles() {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                
            do {
                let fileName = try fileManager.contentsOfDirectory(atPath: paths)
                    
                for file in fileName {
                    // For each file in the directory, create full path and delete the file
                    let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                    try fileManager.removeItem(at: filePath)
                }
            } catch let error {
                print(error)
            }
    }
}

// Struct for holding backup info, expand with content as needed
public struct BackupInfo: Codable {
    public var mnemonic: String

    public init(mnemonic: String) {
        self.mnemonic = mnemonic
    }
}


// Helper functions

extension Bundle {
    var displayName: String {
        get {guard Bundle.main.infoDictionary != nil else {return ""}
            return Bundle.main.infoDictionary!["CFBundleName"] as! String
        }
    }
}

public extension Data {
    init?(hexString: String) {
      let len = hexString.count / 2
      var data = Data(capacity: len)
      var i = hexString.startIndex
      for _ in 0..<len {
        let j = hexString.index(i, offsetBy: 2)
        let bytes = hexString[i..<j]
        if var num = UInt8(bytes, radix: 16) {
          data.append(&num, count: 1)
        } else {
          return nil
        }
        i = j
      }
      self = data
    }
    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}
