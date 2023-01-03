//
//  SendView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 07/10/2022.
//

import SwiftUI
import BDKManager
import WalletUI

struct SendView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var address: String = ""
    @State private var amount: UInt64 = 42069
    
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
//        let success = bdkManager.sendBitcoin(recipient: address, amount: amount, feeRate: 1000)
//        print("Send success:" + success.description)
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
    }
}
