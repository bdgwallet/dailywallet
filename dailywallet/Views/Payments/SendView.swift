//
//  SendView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 07/10/2022.
//

import SwiftUI
import WalletUI

struct SendView: View {
    @Environment(\.presentationMode) var presentationMode
    let amount: UInt64
    @State private var address: String = ""
    @State private var submitted: Bool?
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Circle().fill()
                        .foregroundColor(.bitcoinPurple)
                    BitcoinImage(named: "lightning-filled")
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.bitcoinWhite)
                }.frame(width: 60, height: 60, alignment: .center)
                    .padding(16)
                Divider()
                Text("Amount")
                Text("10,000")
                Divider()
                Text("To")
                TextField("Enter address", text: $address).padding(32)
                    .textFieldStyle(.roundedBorder)
                    .tint(Color.bitcoinOrange)
                Divider()
                Text("Fee")
                Divider()
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
            /* TODO: replace with ldknode code
            let addressScript = try Address(address: address).scriptPubkey()
            let success = bdkManager.sendBitcoin(script: addressScript, amount: amount, feeRate: 1000)
            print("Send success:" + success.description)
            */
        } catch let error {
            debugPrint(error)
        }
    }
}
