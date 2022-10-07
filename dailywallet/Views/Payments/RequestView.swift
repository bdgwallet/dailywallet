//
//  RequestView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 07/10/2022.
//

import SwiftUI
import BDKManager
import WalletUI
import BitcoinDevKit

struct RequestView: View {
    @EnvironmentObject var bdkManager: BDKManager
    
    @State private var requestAddress: String?
    
    var body: some View {
        VStack {
            Spacer()
            Text("Request View")
            Spacer()
            Text(requestAddress ?? "No address")
            Spacer()
        }.task {
            getAddress()
        }
    }
    
    func getAddress() {
        switch bdkManager.walletState {
            case .loaded:
                do {
                    let addressInfo = try bdkManager.wallet!.getAddress(addressIndex: AddressIndex.new)
                    requestAddress = addressInfo.address
                    print(requestAddress)
                } catch (let error){
                    print(error)
                }
                default: do {}
            }
        }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
    }
}
