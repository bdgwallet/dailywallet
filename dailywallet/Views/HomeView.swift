//
//  HomeView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI
import BlockSocket
import WalletUI

struct HomeView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    @EnvironmentObject var backupManager: BackupManager
    let blockSocket = BlockSocket.init(source: BlockSocketSource.blockchain_com)
    @State var blockHeight: UInt32?
    
    init () {
        let value = blockSocket.$latestBlockHeight.sink { (latestBlockHeight) in
            if latestBlockHeight != nil {
                print("Blockheight" + latestBlockHeight!.description)
            }
        }
    }
    
    var body: some View {
        TabView {
            PaymentsView()
                .environmentObject(bdkManager)
                .environmentObject(backupManager)
                .tabItem {
                    Label("Payments", systemImage: "arrow.up.arrow.down")
                }
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "list.bullet")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }.accentColor(.bitcoinOrange)
            .task {
                ldkNodeManager.sync()
            }
    }
    
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

/*
private func setupLDKManager() {
    // Initialize LDKManager
    let ldkNetwork = LDKNetwork_Testnet // set LDKNetwork_Bitcoin, LDKNetwork_Testnet, LDKNetwork_Signet or LDKNetwork_Regtest
    if blockSocket.latestBlockHeight != nil {
        print("LatestBlockHeight: " + self.blockSocket.latestBlockHeight!.description)
        let ldkManager = LDKManager.init(network: ldkNetwork, latestBlockHeight: blockSocket.latestBlockHeight!, latestBlockHash: blockSocket.latestBlockHash!)
    }
}
*/
