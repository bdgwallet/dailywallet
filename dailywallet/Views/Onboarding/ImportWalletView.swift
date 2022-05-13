//
//  ImportWalletView.swift
//  Bitkid
//
//  Created by Daniel Nordh on 5/6/22.
//

import SwiftUI
import BDKManager

struct ImportWalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var backupManager: BackupManager
    
    @State private var recoveryPhrase: String = ""
    @State private var importError = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Informational text")
            Spacer()
            if !importError {
                TextField("Enter recovery phrase", text: $recoveryPhrase).padding(32)
            } else {
                Text("Error importing wallet")
            }
            Spacer()
            if !importError {
                VStack (spacing: 32) {
                    Button("Import") {
                        if !importRecoveryPhrase(recoveryPhrase: recoveryPhrase, bdkManager: bdkManager, backupManager: backupManager) {
                            self.importError = true
                        }
                    }
                    /* TODO: Advanced import settings
                    NavigationLink(destination: AdvancedImportView()) {
                        Text("Advanced settings")
                    }
                    */
                }.padding(32)
            }
        }
        .navigationTitle("Import wallet")
        .navigationBarTitleDisplayMode(.inline)
    }
}

func importRecoveryPhrase(recoveryPhrase: String, bdkManager: BDKManager, backupManager: BackupManager) -> Bool {
    do {
        // Create private key info
        let extendedKeyInfo = try bdkManager.restoreFromMnemonic(mnemonic: recoveryPhrase, password: nil)
        // Create descriptor and load wallet
        let descriptor = bdkManager.createDescriptorFromXprv(descriptorType: DescriptorType.singleKey_wpkh84, xprv: extendedKeyInfo.xprv)
        // Save backup
        backupManager.savePrivateKey(extendedKeyInfo: extendedKeyInfo, descriptor: descriptor)
        // Load wallet in bdkManager, this will trigger a view switch
        bdkManager.loadWallet(descriptor: descriptor)
        return true
    } catch let error {
        print(error)
        return false
    }
}
