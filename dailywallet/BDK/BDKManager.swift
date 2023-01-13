//
//  BDKManager.swift
//  dailywallet
//
//  Created by Daniel Nordh on 03/01/2023.
//

import Foundation
import BitcoinDevKit

public class BDKManager: ObservableObject {
    // Public variables
    public var network: Network
    @Published public var wallet: Wallet?
    @Published public var balance: Balance?
    @Published public var transactions: [TransactionDetails] = []
    @Published public var syncState = SyncState.empty {
        didSet {
            switch syncState {
            case .empty:
                debugPrint("Node is not initialized")
            case .syncing:
                debugPrint("Node is syncing")
            case .synced:
                debugPrint("Node is synced")
                self.getBalance()
                self.getTransactions()
            case .failed(let error):
                debugPrint(error.localizedDescription)
            }
        }
    }

    // Private variables
    private let bdkQueue = DispatchQueue (label: "bdkQueue", qos: .userInitiated)
    private let databaseConfig = DatabaseConfig.sqlite(config: SqliteDbConfiguration(path: "")) // set DatabaseConfig.memory or .sqlite
    private let blockchainConfig: BlockchainConfig
    
    // Initialize a BDKManager instance, set network and blockchainconfig
    public init(network: Network) {
        self.network = network // set to .bitcoin, .testnet or regtest
        self.blockchainConfig = BlockchainConfig.esplora(config: EsploraConfig(baseUrl: self.network == Network.testnet ? ESPLORA_URL_TESTNET : ESPLORA_URL_BITCOIN, proxy: nil, concurrency: nil, stopGap: ESPLORA_STOPGAP, timeout: ESPLORA_TIMEOUT))
    }

    // Load wallet
    public func loadWallet(descriptor: String) {
        do {
            let wallet = try Wallet.init(descriptor: descriptor, changeDescriptor: nil, network: self.network, databaseConfig: self.databaseConfig)
            self.wallet = wallet
        } catch let error {
            debugPrint(error)
        }
    }
    
    // Sync the loaded wallet once
    public func sync() {
        if wallet != nil {
            self.syncState = SyncState.syncing
            bdkQueue.async {
                do {
                    let blockchain = try Blockchain(config: self.blockchainConfig)
                    try self.wallet!.sync(blockchain: blockchain, progress: nil)
                    DispatchQueue.main.async {
                        self.syncState = SyncState.synced
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        self.syncState = SyncState.failed(error)
                    }
                }
            }
        }
    }

    // Send an amount of bitcoin (in sats) to a recipient, optional feeRate
    public func sendBitcoin(script: Script, amount: UInt64, feeRate: Float) -> Bool {
        if wallet != nil {
            do {
                let transaction = try TxBuilder().addRecipient(script: script, amount: amount).feeRate(satPerVbyte: feeRate).finish(wallet: self.wallet!)
                let signed = try self.wallet!.sign(psbt: transaction.psbt)
                let blockchain = try Blockchain(config: self.blockchainConfig)
                try blockchain.broadcast(psbt: transaction.psbt)
                return true
            } catch let error {
                debugPrint(error)
                return false
            }
        } else {
            debugPrint("Error sending bitcoin, no wallet found")
            return false
        }
    }
    
    // Update .balance
    private func getBalance() {
        do {
            self.balance = try self.wallet!.getBalance()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    // Update .transactions
    private func getTransactions() {
        do {
            let transactions = try self.wallet!.listTransactions()
            self.transactions = transactions
        } catch let error {
            debugPrint(error.localizedDescription)
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

let ELECTRUM_URL_BITCOIN = "ssl://electrum.blockstream.info:60001"
let ELECTRUM_URL_TESTNET = "ssl://electrum.blockstream.info:60002"

// Defaults
let ESPLORA_TIMEOUT = UInt64(1000)
let ESPLORA_STOPGAP = UInt64(20)

let ELECTRUM_RETRY = UInt8(5)
let ELECTRUM_STOPGAP = UInt64(10)