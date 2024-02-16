//
//  HomeView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI
import WalletUI

struct HomeView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    @EnvironmentObject var backupManager: BackupManager
    @State var blockHeight: UInt32?
    @State private var activeTab = 2
    
    var body: some View {
        TabView(selection: $activeTab) {
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "list.bullet")
                }.tag(1)
            PaymentsView()
                .environmentObject(backupManager)
                .tabItem {
                    Label("Payments", systemImage: "arrow.up.arrow.down")
                }.tag(2)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }.tag(3)
        }.accentColor(.bitcoinOrange)
            .task {
                //
            }
    }
    
}
