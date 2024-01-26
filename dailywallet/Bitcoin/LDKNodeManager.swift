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
    @Published public var balance: Balance
    @Published public var channels: [ChannelDetails]
    @Published public var transactions: [PaymentDetails]
    
    // Private variables
    private let nodeQueue = DispatchQueue (label: "ldkNodeQueue", qos: .userInitiated)
    
    // Initialize a LDKNodeManager instance on the specified network
    public init(network: Network) {
        self.network = network
        self.balance = Balance(combined: 0, onchain: 0, onchainSpendable: 0, lightning: 0)
        self.channels = []
        self.transactions = []
    }
    
    // Start LDK Node
    public func start(mnemonic: Mnemonic, passphrase: String?) throws {
        let nodeConfig = Config(
            storageDirPath: storagePath(network: network),
            network: self.network,
            listeningAddresses: nil,
            defaultCltvExpiryDelta: DEFAULT_CLTV_EXPIRY_DELTA
            //trustedPeers0conf: network == .bitcoin ? [VOLTAGE_PUBKEY_BITCOIN] : [VOLTAGE_PUBKEY_TESTNET]
        )
            
        let nodeBuilder = Builder.fromConfig(config: nodeConfig)
        nodeBuilder.setEntropyBip39Mnemonic(mnemonic: mnemonic, passphrase: passphrase)
        nodeBuilder.setEsploraServer(esploraServerUrl: esploraServerURL(network: self.network))
        nodeBuilder.setLiquiditySourceLsps2(address: LSP_ADDRESS_MUTINY, nodeId: LSP_NODEID_MUTINY, token: LDP_TOKEN_MUTINY)
        
        do {
            let node = try nodeBuilder.build()
            try node.start()
            self.node = node
            updateBalance()
            listenForEvents()
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
                        self.updateBalance()
                        // Test Voltage JIT Channel creation
                        //connectToVoltage(node: self.node!)
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
        Task {
            while true {
                let event = self.node!.waitNextEvent()
                debugPrint("EVENT: \(event)")
                self.updateBalance()
                self.node!.eventHandled()
            }
        }
    }
    
    // Update Balance
    private func updateBalance() {
        if self.node != nil {
            getLightningBalance()
            getOnchainBalance()
            self.channels = self.node!.listChannels()
            self.transactions = self.node!.listPayments()
        }
    }
    
    
    // Update .onchainBalance
    private func getOnchainBalance() {
        if self.node != nil {
            nodeQueue.async {
                do {
                    let onchainTotal = try self.node!.totalOnchainBalanceSats()
                    let onchainSpendable = try self.node!.spendableOnchainBalanceSats()
                    
                    DispatchQueue.main.async {
                        let newCombined = self.balance.combined + onchainTotal
                        self.balance = Balance(combined: newCombined, onchain: onchainTotal, onchainSpendable: onchainSpendable, lightning: self.balance.combined)
                        debugPrint("LDKNodeManager: Combined: \(self.balance.combined)")
                        debugPrint("LDKNodeManager: Onchain: \(self.balance.onchain)")
                        debugPrint("LDKNodeManager: OnchainSpendable: \(self.balance.onchainSpendable)")
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
                    let lightningBalance = iteratedBalance / 1000
                    
                    let newCombined = self.balance.combined + lightningBalance
                    self.balance = Balance(combined: newCombined, onchain: self.balance.onchain, onchainSpendable: self.balance.onchainSpendable, lightning: lightningBalance)
                    debugPrint("LDKNodeManager: Combined: \(self.balance.combined)")
                    debugPrint("LDKNodeManager: Lightning: \(self.balance.lightning)")
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
            case Network.signet:
                return ESPLORA_URL_SIGNET
        }
    }
    
    // Return storage path for network
    private func storagePath(network: Network) -> String {
            
        switch network { // Update when Network type is enum instead of string
        case Network.regtest:
                return DEFAULT_STORAGE_PATH + "/regtest/"
            case Network.testnet:
                return DEFAULT_STORAGE_PATH + "/testnet/"
            case Network.bitcoin:
                return DEFAULT_STORAGE_PATH + "/bitcoin/"
            case Network.signet:
                return DEFAULT_STORAGE_PATH + "/signet/"
        }
    }
}

// Helper constants
let DEFAULT_LISTENING_ADDRESS = "0.0.0.0:9735"
let DEFAULT_CLTV_EXPIRY_DELTA = UInt32(2016)
let DEFAULT_STORAGE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path

// Public APIs
let ESPLORA_URL_BITCOIN = "https://esplora.kuutamo.cloud" //"https://blockstream.info/api/"
let ESPLORA_URL_TESTNET = "https://esplora.testnet.kuutamo.cloud" //https://blockstream.info/testnet/api"
let ESPLORA_URL_SIGNET = "https://mutinynet.com/api/"

// LSPs
let LSP_ADDRESS_MUTINY = "3.84.56.108:39735"
let LSP_NODEID_MUTINY = "0371d6fd7d75de2d0372d03ea00e8bacdacb50c27d0eaea0a76a0622eff1f5ef2b"
let LDP_TOKEN_MUTINY = "lspstoken"

// Struct for holding the different balances
public struct Balance: Codable {
    public var combined: UInt64
    public var onchain: UInt64
    public var onchainSpendable: UInt64
    public var lightning: UInt64

    public init(combined: UInt64, onchain: UInt64, onchainSpendable: UInt64, lightning: UInt64) {
        self.combined = combined
        self.onchain = onchain
        self.onchainSpendable = onchainSpendable
        self.lightning = lightning
    }
}
