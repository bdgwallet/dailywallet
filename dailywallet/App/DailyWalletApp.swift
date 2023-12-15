//
//  DailyWalletApp.swift
//  Daily Wallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import LDKNode

@main
struct DailyWalletApp: App {
    @ObservedObject var ldkNodeManager: LDKNodeManager
    @ObservedObject var backupManager: BackupManager
    
    init() {
        ldkNodeManager = LDKNodeManager(network: Network.testnet)
        
        // Initialize BackupManager
        let encryptionKey = "d5a423f64b607ea7c65b311d855dc48f36114b227bd0c7a3d403f6158a9e4412" // Use your own unique 256-bit / 64 character string
        backupManager = BackupManager.init(encryptionKey: encryptionKey, enableCloudBackup: true)
        
        // Warning, only use in development
        //backupManager.deleteBackupInfo()
        
        // Check if user already has a node seed
        if backupManager.backupInfo != nil {
            // If they do, start node
            do {
                try ldkNodeManager.start(mnemonic: backupManager.backupInfo!.mnemonic, passphrase: nil)
            } catch let error {
                debugPrint(error)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if ldkNodeManager.node == nil {
                StartView()
                    .environmentObject(ldkNodeManager)
                    .environmentObject(backupManager)
            } else {
                HomeView()
                    .environmentObject(ldkNodeManager)
                    .environmentObject(backupManager)
            }
        }
    }
}
