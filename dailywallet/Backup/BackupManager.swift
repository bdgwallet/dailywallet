//
//  BackupManager.swift
//  dailywallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import Foundation

import Foundation
import BitcoinDevKit
import CryptoKit
import KeychainAccess

public class BackupManager: ObservableObject {
    // Public variables
    @Published public var extendedKeyInfo: ExtendedKeyInfo?
    
    // Private variables
    private let keychain: Keychain
    private let symmetricKey: SymmetricKey
    
    public init(encryptionKey: String, enableCloudBackup: Bool) {
        self.symmetricKey = SymmetricKey(data: Data(hexString:encryptionKey)!)
        let appName = Bundle.main.displayName
        self.keychain = Keychain(service: appName)
            .label(appName)
            .synchronizable(enableCloudBackup)
            .accessibility(.whenUnlocked)
        self.extendedKeyInfo = self.getPrivateKey()
    }
    
    public func getPrivateKey() -> ExtendedKeyInfo? {
        // Check keychain for private key info saved as encrypted json
        let encryptedJsonData = try? keychain.getData("encryptedKeyInfo")
        if encryptedJsonData != nil {
            do {
                let sealedBox = try AES.GCM.SealedBox(combined: encryptedJsonData!)
                let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
                let decryptedJson = String(data: decryptedData, encoding: .utf8)
                let extendedKeyInfo = try JSONDecoder().decode(ExtendedKeyInfo.self, from: decryptedJson!.data(using: .utf8)!)
                return extendedKeyInfo
            } catch let error {
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }

    public func savePrivateKey(extendedKeyInfo: ExtendedKeyInfo) {
        // Convert ExtendedKeyInfo to json string
        if let json = try? JSONEncoder().encode(extendedKeyInfo) {
            do {
                let encryptedContent = try AES.GCM.seal(json, using: self.symmetricKey).combined
                keychain[data: "encryptedKeyInfo"] = encryptedContent
            } catch let error {
                print(error)
            }
        }
    }
}

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
