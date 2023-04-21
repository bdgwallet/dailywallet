//
//  RequestView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 07/10/2022.
//

import SwiftUI
import WalletUI
import BitcoinDevKit
import CoreImage.CIFilterBuiltins

struct RequestView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var requestAddress: String?
    @State private var copied = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                QRView(paymentRequest: requestAddress ?? "No address")
                Spacer()
                VStack {
                    BitcoinShareButton(title: "Share", shareItem: requestAddress ?? "No address")
                    Button(self.copied ? "Copied" : "Copy") {
                        UIPasteboard.general.string = requestAddress ?? "No address"
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
        .onAppear(perform: getAddress)
    }
    
    func getAddress() {
        do {
            requestAddress = try ldkNodeManager.node!.newFundingAddress()
            debugPrint(requestAddress?.description)
        } catch (let error){
            print(error)
        }
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
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
