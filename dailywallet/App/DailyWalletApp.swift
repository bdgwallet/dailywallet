//
//  DailyWalletApp.swift
//  Daily Wallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import BitcoinDevKit
import LightningDevKitNode

@main
struct DailyWalletApp: App {
    @ObservedObject var bdkManager: BDKManager
    @ObservedObject var ldkNodeManager: LDKNodeManager
    @ObservedObject var backupManager: BackupManager
    
    init() {
        bdkManager = BDKManager(network: Network.testnet)
        ldkNodeManager = LDKNodeManager(network: "testnet")
        
        // Initialize BackupManager
        let encryptionKey = "d5a423f64b607ea7c65b311d855dc48f36114b227bd0c7a3d403f6158a9e4412" // Use your own unique 256-bit / 64 character string
        backupManager = BackupManager.init(encryptionKey: encryptionKey, enableCloudBackup: true)
        
        // WARNING!!
        // While testing, remove key backup on every restart
        //backupManager.deletePrivateKey()
        // WARNING!!
        
        // Check if use already has a node seed
        if backupManager.seedData != nil {
            // If they do, start node
            do {
                try ldkNodeManager.start()
            } catch let error {
                debugPrint(error)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if ldkNodeManager.node == nil {
                StartView()
                    .environmentObject(bdkManager)
                    .environmentObject(ldkNodeManager)
                    .environmentObject(backupManager)
            } else {
                HomeView()
                    .environmentObject(bdkManager)
                    .environmentObject(ldkNodeManager)
                    .environmentObject(backupManager)
            }
        }
    }
}
