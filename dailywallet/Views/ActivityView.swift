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
    
    var body: some View {
        VStack() {
            VStack(alignment: .center) {
                BalanceHeaderView()
                    .environmentObject(bdkManager)
                    .frame(alignment: .bottom)
                    .padding(EdgeInsets(top: 32, leading: 16, bottom: 0, trailing: 16))
                TransactionsView(transactions: bdkManager.transactions)
            }
        }
    }
}

struct TransactionHistory_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}

struct BalanceHeaderView: View {
    @EnvironmentObject var bdkManager: BDKManager
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(spacing: 4) {
                Text("Your balance")
                    .textStyle(BitcoinBody4())
                switch bdkManager.syncState {
                case .synced:
                    VStack(spacing: 4) {
                        Text("\(bdkManager.balance) sats")
                            .textStyle(BitcoinTitle1())
                        Text("").textStyle(BitcoinBody4()) // TODO: this should show fiat value
                    }
                case .syncing:
                    Text("Syncing")
                        .textStyle(BitcoinTitle1())
                default:
                    Text("Not synced")
                        .textStyle(BitcoinTitle1())
                }
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0))
            HStack {
                Text("Activity")
                    .textStyle(BitcoinTitle5())
                Spacer()
            }
        }
    }
}

struct TransactionsView: View {
    var transactions: [BitcoinDevKit.Transaction]
    
    var body: some View {
        if transactions.count != 0 {
            List {
                ForEach(transactions, id: \.self) {transaction in
                    Text("Transaction").textStyle(BitcoinBody3())
                }
            }.listStyle(.plain)
        } else {
            Spacer()
            Text("No transactions").textStyle(BitcoinBody4())
            Spacer()
        }
    }
}
