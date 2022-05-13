//
//  StartView.swift
//  Daily Wallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import BDKManager

struct StartView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var backupManager: BackupManager
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Hello Wallet")
                Spacer()
                VStack (spacing: 32) {
                    NavigationLink(destination: CreateWalletView().environmentObject(bdkManager).environmentObject(backupManager)) {
                        Text("Create wallet")
                    }
                    NavigationLink(destination: ImportWalletView()) {
                        Text("Import wallet")
                    }
                }.padding(32)
            }
        }
    }
}
