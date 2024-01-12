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
    @State private var onchainAddress: String?
    @State private var lightningInvoice: String?
    @State private var qrType = QRType.unified
    @State private var copied = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                QRView(qrString: getQRString(), qrType: qrType)
                Picker("What is your favorite color?", selection: $qrType) {
                    Text("Unified").tag(QRType.unified)
                    Text("Lightning").tag(QRType.lightning)
                    Text("Onchain").tag(QRType.onchain)
                }
                .frame(maxWidth: 250)
                .pickerStyle(.segmented)

                Spacer()
                VStack {
                    BitcoinShareButton(title: "Share", shareItem: getQRString())
                    Button(self.copied ? "Copied" : "Copy") {
                        UIPasteboard.general.string = getQRString()
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
            self.onchainAddress = onchainString
            
            let bolt11 = try ldkNodeManager.node?.receivePayment(amountMsat: amount != nil ? amount! : 0, description: "Test JIT channel", expirySecs: 599)
            self.lightningInvoice = bolt11
            debugPrint("LDKNodeManager: Original invoice : \(bolt11 ?? "")")
            
            getWrappedInvoice(invoice: bolt11!, network: ldkNodeManager.network) { wrappedInvoice in
                //self.lightningInvoice = wrappedInvoice
                self.unifiedAddress = wrappedInvoice //"\(onchainString)&lightning=\(String(describing: wrappedInvoice))"
                debugPrint(unifiedAddress?.description ?? "No address")
                if self.unifiedAddress == nil {
                    self.qrType = QRType.lightning
                }
            }
        } catch (let error){
            print(error)
        }
    }
    
    func getQRString() -> String {
        return (qrType == .unified && unifiedAddress != nil) ? unifiedAddress! : qrType == .lightning ? lightningInvoice! : onchainAddress ?? "no address"
    }
}

struct QRView: View {
    var qrString: String
    var width = 250.0
    var height = 250.0
    var qrType: QRType
    
    var body: some View {
        Image(uiImage: qrType == QRType.unified ? generateQRCode(from: "bitcoin:\(qrString)") : generateQRCode(from: qrString))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
    }
}

public enum QRType {
    case unified
    case onchain
    case lightning
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
