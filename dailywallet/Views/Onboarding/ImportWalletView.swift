//
//  ImportWalletView.swift
//  Bitkid
//
//  Created by Daniel Nordh on 5/6/22.
//

import SwiftUI

struct ImportWalletView: View {
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
                        /* TODO: replace with ldknode code
                        if !importRecoveryPhrase(recoveryPhrase: recoveryPhrase, bdkManager: bdkManager, backupManager: backupManager) {
                            self.importError = true
                        }
                        */
                    }
                    /* TODO: Advanced import settings
                    NavigationLink(destination: AdvancedImportView()) {
                        Text("Advanced settings")
                    }
                    */
                }.padding(32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

/*
 func importRecoveryPhrase(recoveryPhrase: String, bdkManager: BDKManager, backupManager: BackupManager) -> Bool {
 do {
 /* TODO: replace with ldknode code
  // Create descriptor and load wallet
  let descriptorSecretKey = try DescriptorSecretKey(network: bdkManager.network, mnemonic: Mnemonic.fromString(mnemonic: recoveryPhrase), password: nil)
  let descriptor = Descriptor.newBip84(secretKey: descriptorSecretKey, keychain: KeychainKind.external, network: bdkManager.network)
  // Save backup
  let keyBackup = KeyBackup(mnemonic: recoveryPhrase, descriptor: descriptor.asString())
  backupManager.savePrivateKey(keyBackup: keyBackup)
  // Load wallet in bdkManager, this will trigger a view switch
  bdkManager.loadWallet(descriptor: descriptor)
  return true
  */
 return false
 } catch let error {
 print(error)
 return false
 }
 }
 */
