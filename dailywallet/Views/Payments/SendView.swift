//
//  SendView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 07/10/2022.
//

import SwiftUI
import BDKManager
import BitcoinDevKit
import WalletUI

struct SendView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @Environment(\.presentationMode) var presentationMode
    let amount: UInt64
    @State private var address: String = ""
    @State private var submitted: Bool?
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                TextField("Enter address", text: $address).padding(32)
                    .textFieldStyle(.roundedBorder)
                    .tint(Color.bitcoinOrange)
                Spacer()
                Button("Send bitcoin") {
                    sendBitcoin()
                }
                .buttonStyle(BitcoinFilled())
                .disabled(self.address == "").padding(16)
            }
            .navigationTitle("Send bitcoin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }.accentColor(.black)
    }
    
    func sendBitcoin() {
        do {
            let addressScript = try Address(address: address).scriptPubkey()
            let success = bdkManager.sendBitcoin(script: addressScript, amount: amount, feeRate: 1000)
            print("Send success:" + success.description)
        } catch let error {
            debugPrint(error)
        }
    }
}
