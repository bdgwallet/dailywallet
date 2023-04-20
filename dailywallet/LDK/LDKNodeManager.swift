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
    public let node: Node
    //@Published public var wallet: Wallet?
    //@Published public var balance: Balance?
    //@Published public var transactions: [TransactionDetails] = []
    //@Published public var syncState = SyncState.empty

    // Private variables
    //private let bdkQueue = DispatchQueue (label: "bdkQueue", qos: .userInitiated)
    //private let databaseConfig = DatabaseConfig.memory // set DatabaseConfig.memory or .sqlite
    //private let blockchainConfig: BlockchainConfig
    
    // Initialize a LDKNodeManager instance on the specified network
    public init(network: String) {
        self.network = network
        let storageDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        var esploraServerUrl = "http://blockstream.info/testnet/api/"
        var chosenNetwork = "testnet"
        var listeningAddress: String? = nil
        let defaultCltvExpiryDelta = UInt32(2048)
            
        switch network { // Update when Network type is enum instead of string
            case "regtest":
                esploraServerUrl = "http://127.0.0.1:3002"
                listeningAddress = "127.0.0.1:24224"
            case "testnet":
                esploraServerUrl = ESPLORA_URL_TESTNET
                listeningAddress = "127.0.0.1:18333" // Why this port, what about mainnet?
            default:
                esploraServerUrl = ESPLORA_URL_TESTNET
                listeningAddress = "127.0.0.1:18333"
        }
                
        let ldkConfig = Config(
            storageDirPath: storageDirectoryPath,
            esploraServerUrl: esploraServerUrl,
            network: chosenNetwork,
            listeningAddress: listeningAddress,
            defaultCltvExpiryDelta: defaultCltvExpiryDelta
        )
            
        let nodeBuilder = Builder.fromConfig(config: ldkConfig)
        let node = nodeBuilder.build()
        self.node = node
    }
}

// Public API URLs
//let ESPLORA_URL_BITCOIN = "https://blockstream.info/api/"
//let ESPLORA_URL_TESTNET = "https://blockstream.info/testnet/api"
