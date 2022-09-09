//
//  CreateWalletView.swift
//  Bitkid
//
//  Created by Daniel Nordh on 5/6/22.
//

import SwiftUI
import BDKManager
import WalletUI

struct CreateWalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var backupManager: BackupManager
    
    @State private var navigateTo: NavigateTo? = NavigateTo.none
    @State private var confirmationOne = false
    @State private var confirmationTwo = false
    
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    Circle().fill()
                        .foregroundColor(.bitcoinGreen)
                    BitcoinImage(named: "wallet-filled")
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.bitcoinWhite)
                }.frame(width: 60, height: 60, alignment: .center)
                Text("Two things you must understand")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Toggle("With bitcoin, you are your own bank. No-one else has access to your private keys.", isOn: $confirmationOne)
                .padding()
            Toggle("If you lose access to this app, and the backup we will help you create, your bitcoin cannot be recovered.", isOn: $confirmationTwo)
                .padding()
//            List {
//                Toggle("With bitcoin, you are your own bank. No-one else has access to your private keys.", isOn: $showGreeting)
//                Toggle("If you lose access to this app. and the backup we will help you create, your bitcoin cannot be recovered.", isOn: $showGreeting)
//            }
            Spacer()
            VStack (spacing: 16) {
                Button("Continue") {
                    if !createPrivateKey(bdkManager: bdkManager, backupManager: backupManager) {
                        // Show error message
                        print("Error creating or backing up private key")
                    }
                }.buttonStyle(BitcoinFilled())
                    .disabled(confirmationOne == false || confirmationTwo == false)
                NavigationLink(destination: AdvancedCreateView(), tag: NavigateTo.createWalletAdvanced, selection: $navigateTo) {
                    Button("Advanced settings") {
                        self.navigateTo = .createWalletAdvanced
                    }.buttonStyle(BitcoinPlain())
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

func createPrivateKey(bdkManager: BDKManager, backupManager: BackupManager) -> Bool {
    do {
        // Create private key info
        let extendedKeyInfo = try bdkManager.generateExtendedKey(wordCount: nil, password: nil)
        // Create descriptor and load wallet
        let descriptor = bdkManager.createDescriptorFromXprv(descriptorType: DescriptorType.singleKey_wpkh84, xprv: extendedKeyInfo.xprv)
        // Save backup
        let keyBackup = KeyBackup(mnemonic: extendedKeyInfo.mnemonic, descriptor: descriptor)
        backupManager.savePrivateKey(keyBackup: keyBackup)
        // Load wallet in bdkManager, this will trigger a view switch
        bdkManager.loadWallet(descriptor: descriptor)
        return true
    } catch let error {
        print(error)
        return false
    }
}
