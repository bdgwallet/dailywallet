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
    let amount: UInt64
    
    //@State private var requestAddress: String?
    @State private var unifiedAddress: String?
    @State private var jitInvoice: String?
    @State private var onchainAddress: String?
    @State private var lightningInvoice: String?
    @State private var qrType = QRType.onchain
    @State private var copied = false
    
    private let nodeQueue = DispatchQueue (label: "ldkNodeQueue", qos: .userInitiated)
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                QRView(qrString: getQRString(), qrType: qrType)
                Picker("QR type?", selection: $qrType) {
                    jitInvoice != nil ? Text("JIT").tag(QRType.jit) : Text("Lightning").tag(QRType.lightning)
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
        nodeQueue.async {
            do {
                // Unified QR
//                self.unifiedAddress = try ldkNodeManager.node!.
//                debugPrint(unifiedAddress?.description ?? "No address")
//                if self.unifiedAddress == nil {
//                    self.qrType = QRType.lightning
//                }
                
                let onchainAddress = try ldkNodeManager.node!.onchainPayment().newAddress()
                let onchainString = "bitcoin:" + onchainAddress.uppercased() + "?amount=" + amount.satsToBitcoin.description
                self.onchainAddress = onchainString
                
                let mSatAmount = amount * 1000
                debugPrint("LDKNodeManager: Invoice amount : \(mSatAmount.description)")
                
                // If user has channel with enough capacity, create Bolt11
                var maxReceiveCapacity = UInt64(0)
                for channel in ldkNodeManager.channels {
                    if channel.inboundCapacityMsat > maxReceiveCapacity {
                        maxReceiveCapacity = channel.inboundCapacityMsat
                    }
                }
                if maxReceiveCapacity > mSatAmount {
                    let lightningInvoice = try ldkNodeManager.node?.bolt11Payment().receive(amountMsat: amount * 1000, description: "Test JIT channel", expirySecs: 599)
                    DispatchQueue.main.async {
                        self.lightningInvoice = lightningInvoice
                        self.qrType = .lightning
                    }
                    debugPrint("LDKNodeManager: Lightning invoice : \(self.lightningInvoice ?? "")")
                } else {
                    // Else, create a JIT invoice
                    let jitInvoice = try ldkNodeManager.node?.bolt11Payment().receiveViaJitChannel(amountMsat: amount * 1000, description: "", expirySecs: 3600, maxLspFeeLimitMsat: nil)
                    DispatchQueue.main.async {
                        self.jitInvoice = jitInvoice
                        self.qrType = .jit
                    }
                    
                    debugPrint("LDKNodeManager: JIT invoice : \(self.jitInvoice ?? "")")
                }
            } catch (let error){
                print(error)
            }
        }
    }
    
    func getQRString() -> String {
        return (qrType == .jit && jitInvoice != nil) ? jitInvoice! : (qrType == .lightning && lightningInvoice != nil) ? lightningInvoice! : onchainAddress ?? "no address"
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
    case jit
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
