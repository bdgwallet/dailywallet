//
//  LDKNodeManager.swift
//  dailywallet
//
//  Created by Daniel Nordh on 20/04/2023.
//

import Foundation
import LDKNode

public class LDKNodeManager: Observable {
    // Public variables
    public var network: Network
    @Published public var node: LdkNode?
    @Published public var syncState = SyncState.empty
    @Published public var onchainBalanceTotal: UInt64?
    @Published public var onchainBalanceSpendable: UInt64?
    
    // Private variables
    private let nodeQueue = DispatchQueue (label: "bdkQueue", qos: .userInitiated)
    
    // Initialize a LDKNodeManager instance on the specified network
    public init(network: Network) {
        self.network = network
    }
    
    // Start LDK Node
    public func start(mnemonic: Mnemonic, passphrase: String?) throws {
        let nodeConfig = Config(
            storageDirPath: DEFAULT_STORAGE_PATH,
            network: self.network,
            listeningAddress: nil,
            defaultCltvExpiryDelta: DEFAULT_CLTV_EXPIRY_DELTA,
            trustedPeers0conf: [VOLTAGE_PUBKEY]
        )
        
        // Write test file to directory to check availability
        let str = "Writing to disk"
        let path = DEFAULT_STORAGE_PATH + "message.txt"

        do {
            let url = URL(filePath: path)
            try str.write(to: url, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: url)
            print(input)
        } catch {
            print(error.localizedDescription)
        }
            
        let nodeBuilder = Builder.fromConfig(config: nodeConfig)
        nodeBuilder.setEntropyBip39Mnemonic(mnemonic: mnemonic, passphrase: passphrase)
        
        do {
            let node = try nodeBuilder.build()
            try node.start()
            self.node = node
            debugPrint("LDKNodeManager: Started with nodeId: \(node.nodeId())")
        } catch {
            debugPrint("LDKNodeManager: Error starting node: \(error.localizedDescription)")
        }
    }
    
    // Stop LDK Node
    public func stop() throws {
        do {
            try self.node?.stop()
            debugPrint("LDKNodeManager: Stopped")
        } catch {
            debugPrint("LDKNodeManager: Error stopping node: \(error.localizedDescription)")
        }
    }
    
    // Sync once
    public func sync() {
        if self.node != nil {
            self.syncState = .syncing
            nodeQueue.async {
                do {
                    try self.node!.syncWallets()
                    DispatchQueue.main.async {
                        self.syncState = SyncState.synced
                        self.getOnchainBalance()
                        // Test Voltage JIT Channel creation
                        connectToVoltage(node: self.node!)
                    }
                    debugPrint("LDKNodeManager: Synced")
                } catch let error {
                    DispatchQueue.main.async {
                        self.syncState = SyncState.failed(error)
                    }
                    debugPrint("LDKNodeManager: Error syncing \(error.localizedDescription)")
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
                debugPrint("LDKNodeManager: Error getting onchain balance: \(error.localizedDescription)")
            }
        }
    }
    
    // Return esplora url for network
    private func esploraServerURL(network: Network) -> String {
            
        switch network { // Update when Network type is enum instead of string
        case Network.regtest:
                return "http://127.0.0.1:3002"
            case Network.testnet:
                return ESPLORA_URL_TESTNET
            case Network.bitcoin:
                return ESPLORA_URL_BITCOIN
            // TODO: Add signet case
            default:
                return ESPLORA_URL_TESTNET
        }
    }
}

public enum SyncState {
    case empty
    case syncing
    case synced
    case failed(Error)
}

// Helper constants
let DEFAULT_LISTENING_ADDRESS = "0.0.0.0:9735"
let DEFAULT_CLTV_EXPIRY_DELTA = UInt32(2016)
let DEFAULT_STORAGE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path // "/tmp/ldk_node_swift/"

// Public APIs
let ESPLORA_URL_BITCOIN = "https://blockstream.info/api/"
let ESPLORA_URL_TESTNET = "https://blockstream.info/testnet/api"
