//
//  StartView.swift
//  Daily Wallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import BDKManager
import WalletUI

struct StartView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var backupManager: BackupManager
    
    @State private var navigateTo: NavigateTo? = NavigateTo.none
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack {
                    HStack {
                        BitcoinImage(named: "bitcoin-circle-filled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.bitcoinOrange)
                    }.frame(width: 200, height: 200, alignment: .center)
                    Text("Bitcoin wallet")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text("A simple bitcoin wallet for your daily spending")
                        .padding()
                        .multilineTextAlignment(.center)
                }
                Spacer()
                VStack {
                    NavigationLink(destination: CreateWalletView().environmentObject(bdkManager).environmentObject(backupManager), tag: NavigateTo.createWallet, selection: $navigateTo) {
                        Button("Create new wallet") {
                            self.navigateTo = .createWallet
                        }.buttonStyle(BitcoinFilled())
                    }
                    NavigationLink(destination: ImportWalletView(), tag: NavigateTo.restoreWallet, selection: $navigateTo) {
                        Button("Restore existing wallet") {
                            self.navigateTo = .restoreWallet
                        }.buttonStyle(BitcoinPlain())
                    }
                }.padding(32)
                Text("Your wallet, your coins \n 100% open-source & open-design")
                    .multilineTextAlignment(.center)
            }
        }.accentColor(.black)
    }
}

public enum NavigateTo {
    case none
    case createWallet
    case restoreWallet
    case createWalletAdvanced
}
