//
//  ActivityView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI
import BDKManager
import WalletUI

struct ActivityView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var backupManager: BackupManager
    @State private var navigateTo: NavigateTo? = NavigateTo.none
    
    let headerWidth = UIScreen.main.bounds.width
    let headerHeight = UIScreen.main.bounds.height / 4
    
    var body: some View {
        VStack() {
            VStack(alignment: .center) {
                Spacer()
                Text("Your balance")
                switch bdkManager.syncState {
                case .synced:
                    Text("\(bdkManager.balance) sats")
                case .syncing:
                    Text("Syncing")
                default:
                    Text("Not synced")
                }
                Text("$11.48")
                Spacer()
            }.frame(width: headerWidth, height: headerHeight)
                .background(Color.bitcoinOrange)
            NavigationView {
                List {
                    Text("Hello World")
                    Text("Hello World")
                    Text("Hello World")
                }
                .navigationTitle("Menu")
            }
        }
    }
}

struct TransactionHistory_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
