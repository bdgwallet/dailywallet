//
//  StartView.swift
//  Daily Wallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
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

/*
extension Text {
    func textStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}

struct BitcoinTitle1: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 36, weight: .semibold))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}

struct BitcoinTitle2: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 28, weight: .semibold))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}

struct BitcoinTitle3: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}

struct BitcoinTitle4: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 21, weight: .semibold))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}

struct BitcoinTitle5: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}

struct BitcoinBody1: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .regular))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}

struct BitcoinBody2: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 21, weight: .regular))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}

struct BitcoinBody3: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .regular))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}

struct BitcoinBody4: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}

struct BitcoinBody5: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(colorScheme == .dark ? .bitcoinWhite : .bitcoinBlack)
    }
}
*/
