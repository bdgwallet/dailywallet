//
//  DailyWalletApp.swift
//  Daily Wallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import BitcoinDevKit

@main
struct DailyWalletApp: App {
    @ObservedObject var bdkManager: BDKManager
    @ObservedObject var backupManager: BackupManager
    
    init() {
        bdkManager = BDKManager(network: Network.testnet)
        
        // Initialize BackupManager
        let encryptionKey = "d5a423f64b607ea7c65b311d855dc48f36114b227bd0c7a3d403f6158a9e4412" // Use your own unique 256-bit / 64 character string
        backupManager = BackupManager.init(encryptionKey: encryptionKey, enableCloudBackup: true)
        
        // WARNING!!
        // While testing, remove key backup on every restart
        //backupManager.deletePrivateKey()
        // WARNING!!
        
        // Check if use already has a private key
        if backupManager.keyInfo != nil {
            // If they do, get descriptor and load wallet in bdkManager
            do {
                let descriptor = try Descriptor(descriptor: backupManager.keyInfo!.descriptor, network: bdkManager.network)
                bdkManager.loadWallet(descriptor: descriptor)
            } catch let error {
                debugPrint(error)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if bdkManager.wallet == nil {
                StartView()
                    .environmentObject(bdkManager)
                    .environmentObject(backupManager)
            } else {
                HomeView()
                    .environmentObject(bdkManager)
                    .environmentObject(backupManager)
            }
        }
    }
}
