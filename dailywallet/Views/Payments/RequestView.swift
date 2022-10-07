//
//  RequestView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 07/10/2022.
//

import SwiftUI
import BDKManager
import WalletUI

struct RequestView: View {
    @EnvironmentObject var bdkManager: BDKManager
    
    var body: some View {
        Text("Request View")
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
    }
}
