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
    @Published public var onchainBalanceTotal: UInt64?
    @Published public var onchainBalanceSpendable: UInt64?
    //@Published public var transactions: [TransactionDetails] = []
    @Published public var syncState = SyncState.empty
    
    // Private variables
    private let nodeQueue = DispatchQueue (label: "bdkQueue", qos: .userInitiated)
    private var esploraServerUrl = ESPLORA_URL_TESTNET
    private var listeningAddress: String? = nil
    private let defaultCltvExpiryDelta = UInt32(2048)
    private let storageDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
    
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
            self.syncState = .syncing
            nodeQueue.async {
                do {
                    try self.node!.syncWallets()
                    debugPrint("LDKNodeManager: Synced")
                    DispatchQueue.main.async {
                        self.syncState = SyncState.synced
                        self.getOnchainBalance()
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        self.syncState = SyncState.failed(error)
                    }
                }
            }
        }
    }
    
    // Update .onchainBalance
    private func getOnchainBalance() {
        if self.node != nil {
            do {
                self.onchainBalanceTotal = try self.node!.totalOnchainBalanceSats()
                debugPrint("LDKNodeManager: Onchain balance total: \(self.onchainBalanceTotal!)")
                self.onchainBalanceSpendable = try self.node!.spendableOnchainBalanceSats()
                debugPrint("LDKNodeManager: Onchain balance spendable: \(self.onchainBalanceSpendable!)")
            } catch let error {
                print("LDKNodeManager: Error getting onchain balance: \(error.localizedDescription)")
            }
        }
    }
}

public enum SyncState {
    case empty
    case syncing
    case synced
    case failed(Error)
}

// Public API URLs
let ESPLORA_URL_BITCOIN = "https://blockstream.info/api/"
let ESPLORA_URL_TESTNET = "https://blockstream.info/testnet/api"
