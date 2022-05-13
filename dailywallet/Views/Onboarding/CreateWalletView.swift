//
//  CreateWalletView.swift
//  Bitkid
//
//  Created by Daniel Nordh on 5/6/22.
//

import SwiftUI
import BDKManager

struct CreateWalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var backupManager: BackupManager
    
    var body: some View {
        VStack {
            Spacer()
            Text("Informational text")
            Spacer()
            VStack (spacing: 32) {
                Button("Confirm") {
                    if !createPrivateKey(bdkManager: bdkManager, backupManager: backupManager) {
                        // Show error message
                        print("Error creating or backing up private key")
                    }
                }
                NavigationLink(destination: AdvancedCreateView()) {
                    Text("Advanced settings")
                }
            }.padding(32)
        }
        .navigationTitle("Create wallet")
        .navigationBarTitleDisplayMode(.inline)
    }
}

func createPrivateKey(bdkManager: BDKManager, backupManager: BackupManager) -> Bool {
    do {
        // Create private key info
        let extendedKeyInfo = try bdkManager.generateExtendedKey(wordCount: nil, password: nil)
        // Save backup
        //backupManager.savePrivateKey(extendedKeyInfo: extendedKeyInfo)
        // Create descriptor and load wallet
        let descriptor = bdkManager.createDescriptor(descriptorType: DescriptorType.singleKey_wpkh84, extendedKeyInfo: extendedKeyInfo)
        bdkManager.loadWallet(descriptor: descriptor)
        return true
    } catch let error {
        print(error)
        return false
    }
}
