//
//  LDKNodeManager.swift
//  dailywallet
//
//  Created by Daniel Nordh on 20/04/2023.
//

import Foundation
import LightningDevKitNode

public class LDKNodeManager: ObservableObject {
    // Public variables
    public var network: Network
    @Published public var node: Node?
    @Published public var onchainBalance: UInt64?
    //@Published public var transactions: [TransactionDetails] = []
    @Published public var syncState = SyncState.empty
    
    // Private variables
    var esploraServerUrl = ESPLORA_URL_TESTNET
    var listeningAddress: String? = nil
    let defaultCltvExpiryDelta = UInt32(2048)
    let storageDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
    
    // Initialize a LDKNodeManager instance on the specified network
    public init(network: String) {
        self.network = network
            
        switch network { // Update when Network type is enum instead of string
            case "regtest":
                esploraServerUrl = "http://127.0.0.1:3002"
                listeningAddress = "127.0.0.1:24224"
            case "testnet":
                esploraServerUrl = ESPLORA_URL_TESTNET
                listeningAddress = "127.0.0.1:18333" // Why this port, what about mainnet?
            // Add bitcoin and signet cases
            default:
                esploraServerUrl = ESPLORA_URL_TESTNET
                listeningAddress = "127.0.0.1:18333"
        }
    }
    
    // Start LDK Node
    public func start() throws {
        let ldkConfig = Config(
            storageDirPath: storageDirectoryPath,
            esploraServerUrl: esploraServerUrl,
            network: network,
            listeningAddress: listeningAddress,
            defaultCltvExpiryDelta: defaultCltvExpiryDelta
        )
            
        let nodeBuilder = Builder.fromConfig(config: ldkConfig)
        let node = nodeBuilder.build()
        
        do {
            try node.start()
            self.node = node
            debugPrint("LDKNodeManager: Started")
        } catch {
            debugPrint("LDKNodeManager: Error starting node: \(error.localizedDescription)")
        }
    }
    
    // Sync once
    public func sync() {
        if self.node != nil {
            do {
                self.syncState = .syncing
                try self.node!.syncWallets()
                self.syncState = .synced
            } catch let error {
                self.syncState = .failed(error)
                debugPrint("LDKNodeManager: Error syncing wallets: \(error.localizedDescription)")
            }
        }
    }
    
    // Update .onchainBalance
    private func getOnchainBalance() {
        if self.node != nil {
            do {
                onchainBalance = try self.node!.totalOnchainBalanceSats()
                debugPrint("LDKNodeManager: Onchain balance: \(self.onchainBalance!)")
            } catch let error {
                print("LDKNodeManager: Error getting onchain balance: \(error.localizedDescription)")
            }
        }
    }
}

// Public API URLs
//let ESPLORA_URL_BITCOIN = "https://blockstream.info/api/"
//let ESPLORA_URL_TESTNET = "https://blockstream.info/testnet/api"

