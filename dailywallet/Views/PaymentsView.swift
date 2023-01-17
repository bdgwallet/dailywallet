//
//  PaymentsView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 5/13/22.
//

import SwiftUI
import WalletUI

struct PaymentsView: View {
    @EnvironmentObject var bdkManager: BDKManager
    
    @State var numpadAmount = "0"
    @State private var showRequestSheet = false
    @State private var showSendSheet = false
    
    var body: some View {
        NavigationView {
            VStack (spacing: 50){
                Spacer()
                VStack(spacing: 4) {
                    Text("\(numpadAmount) sats")
                        .textStyle(BitcoinTitle1())
                    Text("$0").textStyle(BitcoinBody4())
                }
                //Text(bdkManager.wallet?.getAddress(addressIndex: AddressIndex.new).address ?? "-")
                Spacer()
                VStack (spacing: 50) {
                    HStack (spacing: 100) {
                        NumpadButton(numpadAmount:$numpadAmount, character: "1")
                        NumpadButton(numpadAmount:$numpadAmount, character: "2")
                        NumpadButton(numpadAmount:$numpadAmount, character: "3")
                    }
                    HStack (spacing: 100) {
                        NumpadButton(numpadAmount:$numpadAmount, character: "4")
                        NumpadButton(numpadAmount:$numpadAmount, character: "5")
                        NumpadButton(numpadAmount:$numpadAmount, character: "6")
                    }
                    HStack (spacing: 100) {
                        NumpadButton(numpadAmount:$numpadAmount, character: "7")
                        NumpadButton(numpadAmount:$numpadAmount, character: "8")
                        NumpadButton(numpadAmount:$numpadAmount, character: "9")
                    }
                    HStack (spacing: 100) {
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
                    .buttonStyle(BitcoinFilled(width: 150))
                    .sheet(isPresented: $showRequestSheet) {
                        RequestView().environmentObject(bdkManager)
                    }
                    Spacer()
                    Button("Pay") {
                        showSendSheet.toggle()
                    }
                    .buttonStyle(BitcoinFilled(width: 150))
                    .sheet(isPresented: $showSendSheet) {
                        SendView(amount: UInt64(numpadAmount)!).environmentObject(bdkManager)
                    }
                    Spacer()
                }.padding(.bottom, 32)
            }
        }.accentColor(.black)
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
                Text(character).textStyle(BitcoinTitle3())
            }
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
