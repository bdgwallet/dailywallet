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
                    VStack(spacing: 4) {
                        Text("\(bdkManager.balance) sats")
                            .textStyle(BitcoinTitle1())
                        Text("$0")
                            .textStyle(BitcoinBody4())
                    }
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
                            .textStyle(BitcoinTitle3())
                        Text("2")
                            .textStyle(BitcoinTitle3())
                        Text("3")
                            .textStyle(BitcoinTitle3())
                    }
                    HStack (spacing: 100) {
                        Text("4")
                            .textStyle(BitcoinTitle3())
                        Text("5")
                            .textStyle(BitcoinTitle3())
                        Text("6")
                            .textStyle(BitcoinTitle3())
                    }
                    HStack (spacing: 100) {
                        Text("7")
                            .textStyle(BitcoinTitle3())
                        Text("8")
                            .textStyle(BitcoinTitle3())
                        Text("9")
                            .textStyle(BitcoinTitle3())
                    }
                    HStack (spacing: 100) {
                        Text(".")
                            .textStyle(BitcoinTitle3())
                        Text("0")
                            .textStyle(BitcoinTitle3())
                        Text("<")
                            .textStyle(BitcoinTitle3())
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
