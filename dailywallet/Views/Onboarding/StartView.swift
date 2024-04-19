//
//  StartView.swift
//  Daily Wallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import WalletUI
import LDKNode

struct StartView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    @EnvironmentObject var backupManager: BackupManager
    
    @State private var navigateTo: NavigateTo? = NavigateTo.none
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack {
                    Image("BitcoinLogo")
                        .frame(width: 100, height: 100, alignment: .center)
                        .padding()
                    Text("Bitcoin wallet")
                        .textStyle(BitcoinTitle1())
                        .multilineTextAlignment(.center)
                    Text("A simple bitcoin wallet for your daily spending")
                        .textStyle(BitcoinBody1())
                        .multilineTextAlignment(.center)
                        .padding()
                }
                Spacer()
                VStack {
                    NavigationLink(destination: CreateWalletView().environmentObject(backupManager).environmentObject(ldkNodeManager), tag: NavigateTo.createWallet, selection: $navigateTo) {
                        Button("Create new wallet") {
                            self.navigateTo = .createWallet
                        }.buttonStyle(BitcoinFilled())
                    }
                    NavigationLink(destination: ImportWalletView(), tag: NavigateTo.restoreWallet, selection: $navigateTo) {
                        Button("Restore existing wallet") {
                            self.navigateTo = .restoreWallet
                        }.buttonStyle(BitcoinPlain())
                    }
                }.padding(16)
                Text("Your wallet, your coins \n 100% open-source & open-design")
                    .textStyle(BitcoinBody4())
                    .multilineTextAlignment(.center)
            }.padding(EdgeInsets(top: 32, leading: 32, bottom: 8, trailing: 32))
        }
        .accentColor(.black)
    }
}

public enum NavigateTo {
    case none
    case createWallet
    case restoreWallet
    case createWalletAdvanced
}
