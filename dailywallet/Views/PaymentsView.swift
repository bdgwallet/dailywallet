//
//  PaymentsView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import WalletUI

struct PaymentsView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    
    @State var numpadAmount = "0"
    @State var scanResult = "No QR code detected"
    @State private var showRequestSheet = false
    @State private var showSendSheet = false
    @State private var isShowingScanner = false
    
    var body: some View {
        NavigationView {
            VStack (spacing: 50){
                Spacer()
                VStack(spacing: 4) {
                    HStack(alignment: VerticalAlignment.firstTextBaseline, spacing: 8) {
                        Text(Double(numpadAmount)!.formatted())
                            .textStyle(BitcoinTitle1())
                        Text("sats")
                            .textStyle(BitcoinTitle4())
                    }
                    //Text("$0").textStyle(BitcoinBody4()) TODO: show fiat value
                }
                Spacer()
                VStack (spacing: 50) {
                    HStack (spacing: 80) {
                        NumpadButton(numpadAmount:$numpadAmount, character: "1")
                        NumpadButton(numpadAmount:$numpadAmount, character: "2")
                        NumpadButton(numpadAmount:$numpadAmount, character: "3")
                    }
                    HStack (spacing: 80) {
                        NumpadButton(numpadAmount:$numpadAmount, character: "4")
                        NumpadButton(numpadAmount:$numpadAmount, character: "5")
                        NumpadButton(numpadAmount:$numpadAmount, character: "6")
                    }
                    HStack (spacing: 80) {
                        NumpadButton(numpadAmount:$numpadAmount, character: "7")
                        NumpadButton(numpadAmount:$numpadAmount, character: "8")
                        NumpadButton(numpadAmount:$numpadAmount, character: "9")
                    }
                    HStack (spacing: 80) {
                        NumpadButton(numpadAmount:$numpadAmount, character: " ")
                        NumpadButton(numpadAmount:$numpadAmount, character: "0")
                        NumpadButton(numpadAmount:$numpadAmount, character: "<")
                    }
                }
                HStack {
                    Spacer()
                    Button("Request") {
                        showRequestSheet.toggle()
                    }
                    .buttonStyle(BitcoinFilled(width: 110))
                    .sheet(isPresented: $showRequestSheet) {
                        RequestView(amount: UInt64(numpadAmount)!).environmentObject(ldkNodeManager)
                    }
                    //Spacer()
                    Button {
                        isShowingScanner.toggle()
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.bitcoinOrange)
                    }
                    .buttonStyle(BitcoinFilled(width: 60, tintColor: .bitcoinWhite))
                    .sheet(isPresented: $isShowingScanner) {
                        ScannerView(scanResult: $scanResult)
                    }
                    //Spacer()
                    Button("Pay") {
                        showSendSheet.toggle()
                    }
                    .buttonStyle(BitcoinFilled(width: 110))
                    .sheet(isPresented: $showSendSheet) {
                        SendView(amount: UInt64(numpadAmount)!, invoice: scanResult != "No QR code detected" ? scanResult : nil).environmentObject(ldkNodeManager)
                    }
                    Spacer()
                }.padding(.bottom, 32)
            }
        }.accentColor(.black)
            .onChange(of: scanResult) {
                if scanResult != "No QR code detected" {
                    isShowingScanner.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showSendSheet.toggle()
                    }
                }
            }
            .onChange(of: showSendSheet) {
                if showSendSheet == false {
                    self.numpadAmount = "0"
                }
            }
            .onChange(of: showRequestSheet) {
                if showRequestSheet == false {
                    self.numpadAmount = "0"
                }
            }
    }
    
    struct NumpadButton: View {
        @Binding var numpadAmount: String
        var character: String
        
        var body: some View {
            Button {
                if character == "<" {
                    if numpadAmount.count > 1 {
                        numpadAmount.removeLast()
                    } else {
                        numpadAmount = "0"
                    }
                } else if character == " "{
                    return
                }
                else {
                    if numpadAmount == "0" {
                        numpadAmount = character
                    } else {
                        numpadAmount.append(character)
                    }
                }
            }label: {
                if character == "<" {
                    Image(systemName: "delete.left")
                        .font(.system(size: 18, design: .rounded))
                } else {
                    Text(character).textStyle(BitcoinTitle3())
                }
            }.frame(minWidth: 32)
        }
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon.font(.headline)
            configuration.title.font(.caption)
        }
    }
}
