//
//  SettingsView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: Text("General")) {
                    Text("General")
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
