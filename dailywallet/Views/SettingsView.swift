//
//  SettingsView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI
import LDKNode
import WalletUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: NodeInfoView()) {
                    Text("Node details")
                }
                NavigationLink(destination: ChannelListView()) {
                    Text("Channels")
                }
                /*
                NavigationLink(destination: Text("Fees")) {
                    Text("Fees")
                }
                NavigationLink(destination: Text("Privacy")) {
                    Text("Privacy")
                }
                NavigationLink(destination: Text("Security")) {
                    Text("Security")
                }
                NavigationLink(destination: Text("Wallet backup")) {
                    Text("Wallet backup")
                }
                NavigationLink(destination: Text("Network")) {
                    Text("Network")
                }
                NavigationLink(destination: Text("Help & Support")) {
                    Text("Help & Support")
                }
                 */
            }
            .padding(16)
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

struct NodeInfoView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    
    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .leading) {
                    Text("nodeId")
                        .textStyle(BitcoinBody5()).bold()
                    Text(ldkNodeManager.node?.nodeId() ?? "No id")
                        .textStyle(BitcoinBody5())
                }
            }
            .padding(8)
            .listStyle(.plain)
            .navigationTitle("Node details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChannelListView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    
    var ids: [String] {
        ldkNodeManager.channels.map { $0.channelId }
    }
    
    var body: some View {
        if ldkNodeManager.channels.count != 0 {
            List {
                ForEach(ids.indices, id: \.self) { index in
                    let id = ids[index]
                    NavigationLink(destination: ChannelInfoView(channelDetails: ldkNodeManager.channels.first(where: { $0.channelId == id })!)) {
                        VStack(alignment: .leading) {
                            Text("Channel \(index + 1)") // Generate channel number dynamically
                                .textStyle(BitcoinBody5())
                                .bold()
                            Text(id)
                                .textStyle(BitcoinBody5())
                        }
                        .padding(8)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Lightning channels")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            Spacer()
            Text("No transactions")
            Spacer()
        }
    }
}

struct ChannelInfoView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    
    var channelDetails: ChannelDetails
    
    var body: some View {
        NavigationView {
            List {
                ForEach(flattenChannelDetails(), id: \.label) { detail in
                    VStack(alignment: .leading) {
                        Text(detail.label)
                            .textStyle(BitcoinBody5()).bold()
                        Text(detail.value)
                        .textStyle(BitcoinBody5())
                    }
                    .padding(8)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Channel details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.black)
    }
    
    // Function to flatten ChannelDetails into an array of tuples (label, value)
    func flattenChannelDetails() -> [(label: String, value: String)] {
        var detailsArray: [(label: String, value: String)] = []
        
        let mirror = Mirror(reflecting: channelDetails)
        for case let (label?, value) in mirror.children {
            detailsArray.append((label: label, value: String(describing: value)))
        }
        
        return detailsArray
    }
}


