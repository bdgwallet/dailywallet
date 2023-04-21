//
//  CreateWalletView.swift
//  Bitkid
//
//  Created by Daniel Nordh on 5/6/22.
//

import SwiftUI
import WalletUI
import BitcoinDevKit
import LightningDevKitNode

struct CreateWalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
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
                    if !createPrivateKeyWithLDKNode(ldkNodeManager: ldkNodeManager, backupManager: backupManager) {
                        // Show error message
                        print("Error creating or backing up private key")
                    }
                    /*
                    if !createPrivateKey(bdkManager: bdkManager, backupManager: backupManager) {
                        // Show error message
                        print("Error creating or backing up private key")
                    }
                    */
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
    // Create mnemonic
    let mnemonic = Mnemonic(wordCount: WordCount.words12)
    // Create descriptor and load wallet
    let descriptorSecretKey = DescriptorSecretKey(network: bdkManager.network, mnemonic: mnemonic, password: nil)
    let descriptor = Descriptor.newBip84(secretKey: descriptorSecretKey, keychain: KeychainKind.external, network: bdkManager.network)
    // Save backup
    let keyBackup = KeyBackup(mnemonic: mnemonic.asString(), descriptor: descriptor.asString())
    backupManager.savePrivateKey(keyBackup: keyBackup)
    // Load wallet in bdkManager, this will trigger a view switch
    bdkManager.loadWallet(descriptor: descriptor)
    return true 
}

func createPrivateKeyWithLDKNode(ldkNodeManager: LDKNodeManager, backupManager: BackupManager) -> Bool {
    do {
        try ldkNodeManager.start()
        let data = try ldkNodeManager.getSeed()
        backupManager.saveSeed(seedData: data)
        return true
    } catch let error {
        debugPrint(error)
        return false
    }
}
