//
//  LDKNodeManager.swift
//  dailywallet
//
//  Created by Daniel Nordh on 20/04/2023.
//

import Foundation
import LDKNode

public class LDKNodeManager: ObservableObject {
    // Public variables
    public var network: Network
    @Published public var node: LdkNode?
    @Published public var onchainBalanceTotal: UInt64?
    @Published public var onchainBalanceSpendable: UInt64?
    @Published public var lightningBalance: UInt64?
    
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
            listeningAddresses: nil,
            defaultCltvExpiryDelta: DEFAULT_CLTV_EXPIRY_DELTA,
            trustedPeers0conf: [VOLTAGE_PUBKEY]
        )
            
        let nodeBuilder = Builder.fromConfig(config: nodeConfig)
        nodeBuilder.setEntropyBip39Mnemonic(mnemonic: mnemonic, passphrase: passphrase)
        
        do {
            let node = try nodeBuilder.build()
            try node.start()
            self.node = node
            getOnchainBalance()
            getLightningBalance()
            debugPrint("LDKNodeManager: Started with nodeId: \(node.nodeId())")
        } catch {
            debugPrint("LDKNodeManager: Error starting node: \(error.localizedDescription)")
        }
    }
    
    // Sync once
    public func sync() {
        if self.node != nil {
            nodeQueue.async {
                do {
                    try self.node!.syncWallets()
                    DispatchQueue.main.async {
                        self.getOnchainBalance()
                        // Test Voltage JIT Channel creation
                        connectToVoltage(node: self.node!)
                    }
                    debugPrint("LDKNodeManager: Synced")
                } catch let error {
                    debugPrint("LDKNodeManager: Error syncing \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Listen for events
    public func listenForEvents() {
        nodeQueue.async {
            let event = self.node!.waitNextEvent()
            // TODO: Handle event, upate on main queue when finished
            self.node!.eventHandled()
        }
    }
    
    // Update .onchainBalance
    private func getOnchainBalance() {
        if self.node != nil {
            nodeQueue.async {
                do {
                    let onchainBalanceTotal = try self.node!.totalOnchainBalanceSats()
                    let onchainBalanceSpendable = try self.node!.spendableOnchainBalanceSats()
                    
                    DispatchQueue.main.async {
                        self.onchainBalanceTotal = onchainBalanceTotal
                        self.onchainBalanceSpendable = onchainBalanceSpendable
                        debugPrint("LDKNodeManager: Onchain balance total: \(self.onchainBalanceTotal!)")
                        debugPrint("LDKNodeManager: Onchain balance spendable: \(self.onchainBalanceSpendable!)")
                    }
                    
                } catch let error {
                    debugPrint("LDKNodeManager: Error getting onchain balance: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Update .lightningBalance
    private func getLightningBalance() {
        if self.node != nil {
            nodeQueue.async {
                var iteratedBalance = UInt64(0)
                for channel in self.node!.listChannels() {
                    iteratedBalance = iteratedBalance + channel.balanceMsat
                }
                
                DispatchQueue.main.async {
                    self.lightningBalance = iteratedBalance
                    debugPrint("LDKNodeManager: Lightning balance: \(self.lightningBalance!)")
                }
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

// Helper constants
let DEFAULT_LISTENING_ADDRESS = "0.0.0.0:9735"
let DEFAULT_CLTV_EXPIRY_DELTA = UInt32(2016)
let DEFAULT_STORAGE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path

// Public APIs
let ESPLORA_URL_BITCOIN = "https://blockstream.info/api/"
let ESPLORA_URL_TESTNET = "https://blockstream.info/testnet/api"
