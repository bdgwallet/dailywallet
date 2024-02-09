//
//  SettingsView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI
import LDKNode

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: Text("General")) {
                    Text("General")
                        .padding()
                }
                NavigationLink(destination: SettingsLightningChannelsView()) {
                    Text("Lightning channels")
                        .padding()
                }
                NavigationLink(destination: Text("Fees")) {
                    Text("Fees")
                        .padding()
                }
                NavigationLink(destination: Text("Privacy")) {
                    Text("Privacy")
                        .padding()
                }
                NavigationLink(destination: Text("Security")) {
                    Text("Security")
                        .padding()
                }
                NavigationLink(destination: Text("Wallet backup")) {
                    Text("Wallet backup")
                        .padding()
                }
                NavigationLink(destination: Text("Network")) {
                    Text("Network")
                        .padding()
                }
                NavigationLink(destination: Text("Help & Support")) {
                    Text("Help & Support")
                        .padding()
                }
            }
            .listStyle(.plain)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }.accentColor(.black)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct SettingsLightningChannelsView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    
    var ids: [String] {
            ldkNodeManager.channels.map { $0.channelId }
        }
    
    var body: some View {
        if ldkNodeManager.channels.count != 0 {
                List {
                    ForEach(ids, id: \.self) { channel in
                        NavigationLink(destination: Text("General")) {
                            Text(channel)
                                .padding()
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Lightning channels")
                .navigationBarTitleDisplayMode(.inline)
        } else {
            Spacer()
            Text("No transactions")
                //.textStyle(BitcoinBody4())
            Spacer()
        }
    }
}
