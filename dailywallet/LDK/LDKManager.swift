//
//  LDKManager.swift
//  dailywallet
//
//  Created by Daniel Nordh on 5/20/22.
//

/*
import Foundation
import LDKFramework
import BDKManager

public class LDKManager: ObservableObject {
    // Public variables
    @Published public var peerManager: PeerManager
    @Published public var channelManager: ChannelManager
    
    // Private variables
    private var feeEstimator = LDKFeeEstimator()
    private var logger = LDKLogger()
    private var broadcaster = LDKBroadcasterInterface()
    private var persister = LDKPersister()
    private var filter = LDKFilter()
    
    // Public functions
    // Initialize an LDKManager instance
    init(network: LDKNetwork, latestBlockHeight: UInt32, latestBlockHash: String) { // TODO: add parameters: private key info?
        var keyData = Data(count: 32) // Should be passed into init instead of generated here
        keyData.withUnsafeMutableBytes {
            // returns 0 on success
            let didCopySucceed = SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
            assert(didCopySucceed == 0)
        }
        let seed = [UInt8](keyData)
        
        let filterOption = Option_FilterZ(value: filter)
        let chainMonitor = ChainMonitor(chain_source: filterOption, broadcaster: broadcaster, logger: logger, feeest: feeEstimator, persister: persister)
        
        let timestamp_seconds = UInt64(NSDate().timeIntervalSince1970)
        let timestamp_nanos = UInt32.init(truncating: NSNumber(value: timestamp_seconds * 1000 * 1000))
        let keysManager = KeysManager(seed: seed, starting_time_secs: timestamp_seconds, starting_time_nanos: timestamp_nanos)
        let keysInterface = keysManager.as_KeysInterface()
        let nodeSecret = keysInterface.get_node_secret(recipient: LDKRecipient_Node)

        let userConfig = UserConfig()

        let channelManagerConstructor = ChannelManagerConstructor(
            network: network,
            config: userConfig,
            current_blockchain_tip_hash: [UInt8](Data(base64Encoded: latestBlockHash)!),
            current_blockchain_tip_height: latestBlockHeight,
            keys_interface: keysInterface,
            fee_estimator: feeEstimator,
            chain_monitor: chainMonitor,
            net_graph: nil, // see `NetworkGraph`
            tx_broadcaster: broadcaster,
            logger: logger
        )
        let channelManager = channelManagerConstructor.channelManager
        let networkGraph = NetworkGraph(genesis_hash: [UInt8](Data(base64Encoded: "AAAAAAAZ1micCFrhZYMek0/3Y65GoqbBcrPxtgqM4m8=")!))
        let serializedChannelManager: [UInt8] = channelManager.write()
        
        self.channelManager = channelManager
        self.peerManager = channelManagerConstructor.peerManager
    }
    
    // Private functions
}

// Helpers

class LDKFeeEstimator: FeeEstimator {
    // Feerates should be updated each block with updateFeerates()
    var feerate_slow = 253 // Background / > 1 hour, 1 satoshi/vbyte, rounded up
    var feerate_medium = 1520 // 3 blocks / 30min, 6 satoshi/vbyte, rounded up
    var feerate_fast = 2530 // Next block / 10min, 10 satoshi/vbyte, rounded up

    override func get_est_sat_per_1000_weight(confirmation_target: LDKConfirmationTarget) -> UInt32 {
        if (confirmation_target as AnyObject === LDKConfirmationTarget_HighPriority as AnyObject) {
            return UInt32(feerate_fast)
        }
        if (confirmation_target as AnyObject === LDKConfirmationTarget_Normal as AnyObject) {
            return UInt32(feerate_medium)
        }
        return UInt32(feerate_slow)
    }

    public func updateRates(newFast: NSNumber, newMedium: NSNumber, newSlow: NSNumber) {
        // TODO: Create Feerates class?
        // TODO: Check new rates for safe floor and reject if too low
            feerate_fast = Int(truncating: newFast)
            feerate_medium = Int(truncating: newMedium)
            feerate_slow = Int(truncating: newSlow)
    }
}

class LDKLogger: Logger {
    override func log(record: Record) {
        if record.get_level() == LDKLevel_Gossip { return }
        let recordString = "\(record.get_args())"
        print("LDKManager: \(recordString)")
    }
}

class LDKBroadcasterInterface: BroadcasterInterface {
    override func broadcast_transaction(tx: [UInt8]) {
        // TODO: insert code to broadcast transaction
        // This should send a transaction to BDK for broadcasting
    }
}

class LDKPersister: Persist {
    // TODO: optional path parameter in init?
    // TODO: add function for retreiving data for backup?
    override func persist_new_channel(channel_id: OutPoint, data: ChannelMonitor, update_id: MonitorUpdateId) -> Result_NoneChannelMonitorUpdateErrZ {
            let idBytes: [UInt8] = channel_id.write()
            let monitorBytes: [UInt8] = data.write()

            // TODO: persist monitorBytes to disk, keyed by idBytes

            return Result_NoneChannelMonitorUpdateErrZ.ok()
        }

        override func update_persisted_channel(channel_id: OutPoint, update: ChannelMonitorUpdate, data: ChannelMonitor, update_id: MonitorUpdateId) -> Result_NoneChannelMonitorUpdateErrZ {
            let idBytes: [UInt8] = channel_id.write()
            let monitorBytes: [UInt8] = data.write()

            // TODO: modify persisted monitorBytes keyed by idBytes on disk

            return Result_NoneChannelMonitorUpdateErrZ.ok()
        }
}

class LDKFilter: Filter {
    override func register_tx(txid: [UInt8]?, script_pubkey: [UInt8]) {
            // TODO: watch this transaction on-chain, how?
        }

        override func register_output(output: WatchedOutput) -> Option_C2Tuple_usizeTransactionZZ {
            let scriptPubkeyBytes = output.get_script_pubkey()
            let outpoint = output.get_outpoint()!
            let txid = outpoint.get_txid()
            let outputIndex = outpoint.get_index()

            // TODO: watch for any transactions that spend this output on-chain (how?)

            let blockHashBytes = output.get_block_hash()
            // TODO: if block hash bytes are not null, return any transaction spending the output that is found in the corresponding block along with its index (how?)

            return Option_C2Tuple_usizeTransactionZZ.none()
        }
}

public typealias LDKNetwork = LDKFramework.LDKNetwork // Only required if making a package
*/
