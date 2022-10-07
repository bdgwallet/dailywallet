//
//  DailyWalletApp.swift
//  Daily Wallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import BDKManager
import BitcoinDevKit

@main
struct DailyWalletApp: App {
    @ObservedObject var bdkManager: BDKManager
    @ObservedObject var backupManager: BackupManager
    
    init() {
        // Define BDKManager options and initialize
        let network = Network.testnet // set bitcoin, testnet, signet or regtest
        let syncSource = SyncSource(type: SyncSourceType.esplora, customUrl: nil) // set esplora or electrum, can take customUrl
        let database = Database(type: DatabaseType.memory, path: nil, treeName: nil) // set memory or disk, optional path and tree parameters
        bdkManager = BDKManager.init(network: network, syncSource: syncSource, database: database)
        
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
            bdkManager.loadWallet(descriptor: backupManager.keyInfo!.descriptor)
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
