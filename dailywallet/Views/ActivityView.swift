//
//  ActivityView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI
import BDKManager
import WalletUI
import BitcoinDevKit

struct ActivityView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @EnvironmentObject var backupManager: BackupManager
    @State private var navigateTo: NavigateTo? = NavigateTo.none
    
    let headerWidth = UIScreen.main.bounds.width
    let headerHeight = 200.0 //UIScreen.main.bounds.height / 5
    var customTransactions: [CustomTransaction] = []
    
    var body: some View {
        VStack() {
            VStack(alignment: .center) {
                VStack(spacing: 4) {
                    Text("Your balance")
                        .textStyle(BitcoinBody4())
                    Text("25,000 sats")
                        .textStyle(BitcoinTitle1())
                    Text("$11.48")
                        .textStyle(BitcoinBody4())
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0))
                HStack {
                    Text("Activity")
                        .textStyle(BitcoinTitle5())
                    Spacer()
                }
            }.frame(alignment: .bottom)
                .padding(EdgeInsets(top: 32, leading: 16, bottom: 0, trailing: 16))
            TransactionsView(customTransactions: customTransactions)
        }
    }
}

struct TransactionHistory_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}

struct TransactionsView: View {
    var customTransactions: [CustomTransaction]
    
    var body: some View {
        if customTransactions.count != 0 {
            List {
                ForEach(customTransactions) {_ in
                    Text("Transaction")
                        .textStyle(BitcoinBody3())
                }
            }.listStyle(.plain)
        } else {
            Spacer()
            Text("No transactions")
                .textStyle(BitcoinBody4())
            Spacer()
        }
    }
}

// Transaction from BitcoinDevKit does not work in List, either use custom struct or wait for it to be changed. Here's a dummy:

public struct CustomTransaction {
    
    public let id = UUID()
    let details: TransactionDetails?
    let confirmation: BlockTime?
}

extension CustomTransaction: Equatable, Hashable, Identifiable {}
