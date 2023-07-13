//
//  RequestView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 07/10/2022.
//

import SwiftUI
import WalletUI
import CoreImage.CIFilterBuiltins

struct RequestView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    @Environment(\.presentationMode) var presentationMode
    let amount: UInt64?
    
    //@State private var requestAddress: String?
    @State private var unifiedAddress: String?
    @State private var copied = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                QRView(paymentRequest: unifiedAddress ?? "No address")
                Spacer()
                VStack {
                    BitcoinShareButton(title: "Share", shareItem: unifiedAddress ?? "No address")
                    Button(self.copied ? "Copied" : "Copy") {
                        UIPasteboard.general.string = unifiedAddress ?? "No address"
                        self.copied = true
                    }
                    .buttonStyle(BitcoinPlain(width: 150))
                    .disabled(self.copied)
                }.padding(16)
            }
            .navigationTitle("Payment request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }.accentColor(.black)
        .onAppear(perform: getUnifiedAddress)
    }
    
    func getUnifiedAddress() {
        do {
            let onchainAddress = try ldkNodeManager.node!.newOnchainAddress()
            let onchainString = amount != nil ? "bitcoin:\(onchainAddress)?amount=\(amount!.satsToBitcoin)" : "bitcoin:\(onchainAddress)"
            
            let bolt11 = try ldkNodeManager.node?.receivePayment(amountMsat: amount != nil ? amount! : 0, description: "Test JIT channel", expirySecs: 599)
            debugPrint("LDKNodeManager: Original invoice : \(bolt11 ?? "")")
            
            getWrappedInvoice(invoice: bolt11!) { wrappedInvoice in
                unifiedAddress = "\(onchainString)&lightning=\(String(describing: wrappedInvoice))"
                debugPrint(unifiedAddress?.description ?? "No address")
            }
        } catch (let error){
            print(error)
        }
    }
}

struct QRView: View {
    var paymentRequest: String
    var width = 250.0
    var height = 250.0
    
    var body: some View {
        Image(uiImage: generateQRCode(from: "bitcoin:\(paymentRequest)"))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
    }
}

func generateQRCode(from string: String) -> UIImage {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    let data = Data(string.utf8)
    filter.setValue(data, forKey: "inputMessage")

    if let outputImage = filter.outputImage {
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }
    }
    return UIImage(systemName: "xmark.circle") ?? UIImage()
}

struct BitcoinShareButton: View {
    var title: String
    var shareItem: String
    var width = 315.0
    var cornerRadius = 8.0
    var outlineColor = Color.bitcoinOrange
    var lineWidth = 1.5
    
    var body: some View {
        ShareLink(item: shareItem) {
            Label(title, systemImage: "square.and.arrow.up")
                .tint(Color.bitcoinOrange)
                .font(Font.body.bold())
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(outlineColor, lineWidth: lineWidth)
                        .frame(width: width)
                )
        }
    }
}
