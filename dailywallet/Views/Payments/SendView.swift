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
    @State private var recipient: String = ""
    @State private var submitted: Bool?

    init(amount: UInt64, invoice: String? = nil) {
        self.amount = amount
        self._recipient = State(initialValue: invoice ?? "")
    }
    
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
                    .padding(32)
                HStack {
                    VStack (alignment: .leading) {
                        Text("Amount").textStyle(BitcoinTitle5())
                        Text(amount.formatted() + " sats")
                    }
                    Spacer()
                }.padding(.vertical)
                Divider()
                HStack {
                    VStack (alignment: .leading) {
                        Text("To").textStyle(BitcoinTitle5())
                        TextField("Bitcoin address or invoice", text: $recipient)
                            .textFieldStyle(.roundedBorder)
                            .tint(Color.bitcoinOrange)
                    }
                    Spacer()
                }.padding(.vertical)
                Spacer()
                Button(recipient.isValidBitcoinAddress() ? "Send bitcoin" : recipient.isValidBolt11Invoice() ? "Pay invoice" : "Send") {
                    if self.recipient.isValidBolt11Invoice() {
                        sendLightning()
                    } else if self.recipient.isValidBitcoinAddress() {
                        sendBitcoin()
                    }
                }
                .buttonStyle(BitcoinFilled())
                .disabled(!recipient.isValidBitcoinAddress() && !recipient.isValidBolt11Invoice()).padding(16)
            }
            .navigationTitle("Send bitcoin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    self.recipient = ""
                    presentationMode.wrappedValue.dismiss()
                }
            }.padding(24)
        }.accentColor(.black)
    }
    
    func sendBitcoin() {
        do {
            debugPrint("Address: " + self.recipient)
            let success = try ldkNodeManager.node?.onchainPayment().sendToAddress(address: self.recipient, amountMsat: amount)
            submitted = success != nil ? true : false
        } catch let error {
            debugPrint(error)
        }
    }
    
    func sendLightning() {
        do {
            let success = try ldkNodeManager.node?.bolt11Payment().send(invoice: recipient)
            submitted = success != nil ? true : false
        } catch let error {
            debugPrint(error)
        }
    }
}

extension String {
    func isValidPaymentString() -> Bool {
        if self.isValidBolt11Invoice() {
            debugPrint("recipient is valid Bolt11: " + self)
            return true
        } else if self.isValidBitcoinAddress() {
            debugPrint("recipient is valid address: " + self)
            return true
        } else {
            return false
        }
    }
    func isValidBitcoinAddress() -> Bool {
        return (self.lowercased().hasPrefix("bitcoin:") || self.lowercased().hasPrefix("tb"))
        /*
        let bitcoinAddressRegex = try! NSRegularExpression(pattern: "^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$", options: .caseInsensitive)
        return bitcoinAddressRegex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) != nil
        */
    }
    func isValidBolt11Invoice() -> Bool {
        return self.hasPrefix("ln")
        /*
        let bolt11Regex = try! NSRegularExpression(pattern: "^ln([a-z0-9]*[02468][a-z0-9]*){1,90}$", options: .caseInsensitive)
        let matches = bolt11Regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        return matches.count > 0
        */
    }
}
