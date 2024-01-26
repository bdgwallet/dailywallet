//
//  SendView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 07/10/2022.
//

import SwiftUI
import WalletUI
import LDKNode

struct SendView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    @Environment(\.presentationMode) var presentationMode
    let amount: UInt64
    @State private var address: String = ""
    @State private var invoice: String = ""
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
                Text(amount.formatted())
                Divider()
                HStack {
                    Text("To")
                    TextField("Enter address", text: $address).padding(32)
                        .textFieldStyle(.roundedBorder)
                        .tint(Color.bitcoinOrange)
                }
                Divider()
                HStack {
                    Text("To")
                    TextField("Enter invoice", text: $invoice).padding(32)
                        .textFieldStyle(.roundedBorder)
                        .tint(Color.bitcoinOrange)
                }
                Divider()
                Text("Fee")
                
                Spacer()
                Button("Send bitcoin") {
                    sendBitcoin()
                }
                .buttonStyle(BitcoinFilled())
                .disabled(self.address == "").padding(16)
                Button("Pay invoice") {
                    sendLightning()
                }
                .buttonStyle(BitcoinFilled())
                .disabled(self.invoice == "").padding(16)
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
            let success = try ldkNodeManager.node?.sendToOnchainAddress(address: address, amountMsat: amount)
            submitted = success != nil ? true : false
        } catch let error {
            debugPrint(error)
        }
    }
    
    func sendLightning() {
        do {
            let success = try ldkNodeManager.node?.sendPaymentUsingAmount(invoice: invoice, amountMsat: amount)
            submitted = success != nil ? true : false
        } catch let error {
            debugPrint(error)
        }
    }
}
