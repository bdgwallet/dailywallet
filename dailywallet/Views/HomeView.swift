//
//  HomeView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI
import WalletUI

struct HomeView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    @EnvironmentObject var backupManager: BackupManager
    @State var blockHeight: UInt32?
    
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
