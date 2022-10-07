//
//  CreateWalletView.swift
//  Bitkid
//
//  Created by Daniel Nordh on 5/6/22.
//

import SwiftUI
import BDKManager
import WalletUI
import BitcoinDevKit

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
                    .textStyle(BitcoinTitle1())
                    .multilineTextAlignment(.center)
            }
            Spacer()
            VStack (spacing: 32) {
                Toggle("With bitcoin, you are your own bank. No-one else has access to your private keys.", isOn: $confirmationOne)
                    .padding(0)
                Toggle("If you lose access to this app, and the backup we will help you create, your bitcoin cannot be recovered.", isOn: $confirmationTwo)
                    .padding(0)
            }
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
        }.padding(EdgeInsets(top: 32, leading: 32, bottom: 16, trailing: 32))
        .navigationBarTitleDisplayMode(.inline)
    }
}

func createPrivateKey(bdkManager: BDKManager, backupManager: BackupManager) -> Bool {
    do {
        // Create mnemonic
        let mnemonic = try generateMnemonic(wordCount: WordCount.words12)
        // Create descriptor and load wallet
        let descriptor = bdkManager.descriptorFromMnemonic(descriptorType: DescriptorType.singleKey_wpkh84, mnemonic: mnemonic, password: nil)
        // Save backup
        let keyBackup = KeyBackup(mnemonic: mnemonic, descriptor: descriptor!)
        backupManager.savePrivateKey(keyBackup: keyBackup)
        // Load wallet in bdkManager, this will trigger a view switch
        bdkManager.loadWallet(descriptor: descriptor!)
        return true
    } catch let error {
        print(error)
        return false
    }
}
