//
//  WalletView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import BDKManager
import WalletUI

struct WalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var backupManager: BackupManager
    @State private var navigateTo: NavigateTo? = NavigateTo.none
    
    var body: some View {
        NavigationView {
            VStack (spacing: 50){
                Spacer()
                switch bdkManager.syncState {
                case .synced:
                    Text("\(bdkManager.balance) sats")
                case .syncing:
                    Text("Syncing")
                default:
                    Text("Not synced")
                }
                //Text(bdkManager.wallet?.getAddress(addressIndex: AddressIndex.new).address ?? "-")
                Spacer()
                VStack (spacing: 50) {
                    HStack (spacing: 100) {
                        Text("1")
                        Text("2")
                        Text("3")
                    }
                    HStack (spacing: 100) {
                        Text("4")
                        Text("5")
                        Text("6")
                    }
                    HStack (spacing: 100) {
                        Text("7")
                        Text("8")
                        Text("9")
                    }
                    HStack (spacing: 100) {
                        Text(".")
                        Text("0")
                        Text("<")
                    }
                }
                HStack {
                    Spacer()
                    Button("Request") {
                        //self.navigateTo = .createWallet
                    }.buttonStyle(BitcoinFilled(width: 150))
                    Spacer()
                    Button("Pay") {
                        //self.navigateTo = .createWallet
                    }.buttonStyle(BitcoinFilled(width: 150))
                    Spacer()
                }.padding(.bottom, 32)
                
            }
        }.accentColor(.black)
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon.font(.headline)
            configuration.title.font(.caption)
        }
    }
}
