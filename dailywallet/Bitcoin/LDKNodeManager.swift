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
    @Published public var balanceDetails: BalanceDetails
    @Published public var channels: [ChannelDetails]
    @Published public var transactions: [PaymentDetails]
    
    // Private variables
    private let nodeQueue = DispatchQueue (label: "ldkNodeQueue", qos: .userInitiated)
    
    // Initialize a LDKNodeManager instance on the specified network
    public init(network: Network) {
        self.network = network
        self.balanceDetails = BalanceDetails(totalOnchainBalanceSats: 0, spendableOnchainBalanceSats: 0, totalLightningBalanceSats: 0, lightningBalances: [], pendingBalancesFromChannelClosures: [])
        self.channels = []
        self.transactions = []
    }
    
    // Start LDK Node
    public func start(mnemonic: Mnemonic, passphrase: String?) throws {
        var nodeConfig = defaultConfig()
        nodeConfig.storageDirPath = storagePath(network: network)
        nodeConfig.network = self.network
            
        let nodeBuilder = Builder.fromConfig(config: nodeConfig)
        nodeBuilder.setEntropyBip39Mnemonic(mnemonic: mnemonic, passphrase: passphrase)
        nodeBuilder.setEsploraServer(esploraServerUrl: esploraServerURL(network: self.network))
        nodeBuilder.setLiquiditySourceLsps2(address: LSP_ADDRESS_MUTINY, nodeId: LSP_NODEID_MUTINY, token: LSP_TOKEN_MUTINY)
        
        do {
            let node = try nodeBuilder.build()
            try node.start()
            self.node = node
            getChannelsAndTransactions()
            listenForEvents()
            updateBalance()
        } catch {
            debugPrint("LDKNodeManager: Error starting node: \(error)")
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
    
    // Get Channels and Transactions
    private func getChannelsAndTransactions() {
        if self.node != nil {
            nodeQueue.async {
                let channels = self.node!.listChannels()
                let transactions = self.node!.listPayments()
                //debugPrint(transactions)

                DispatchQueue.main.async {
                    self.channels = channels
                    self.transactions = transactions
                }
            }
        }
    }
    
    // Update Balance
    private func updateBalance() {
        if self.node != nil {
            nodeQueue.async {
                let balanceDetails = self.node!.listBalances()

                DispatchQueue.main.async {
                    self.balanceDetails = balanceDetails
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
let LSP_TOKEN_MUTINY = "4GH1W3YW"
