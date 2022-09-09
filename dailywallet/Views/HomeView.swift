//
//  HomeView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI
import BDKManager
import WalletUI

struct HomeView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var backupManager: BackupManager
    
    var body: some View {
        TabView {
            WalletView()
                .environmentObject(bdkManager)
                .environmentObject(backupManager)
                .tabItem {
                    Label("Payments", systemImage: "arrow.up.arrow.down")
                }
            TransactionHistory()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }.accentColor(.bitcoinOrange)
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
