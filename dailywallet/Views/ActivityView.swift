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
    let headerHeight = 200.0 //UIScreen.main.bounds.height / 5
    
    var body: some View {
        VStack() {
            VStack(alignment: .center) {
                BalanceHeaderView()
                    .environmentObject(bdkManager)
                    .frame(alignment: .bottom)
                    .padding(EdgeInsets(top: 32, leading: 16, bottom: 0, trailing: 16))
                TransactionsListView(transactions: bdkManager.transactions)
                    .environmentObject(bdkManager)
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
                VStack(spacing: 4) {
                    Text("\(bdkManager.balance!.total.description) sats")
                        .textStyle(BitcoinTitle1())
                    Text("\(bdkManager.balance!.spendable.description) sats")
                        .textStyle(BitcoinTitle3())
                    Text("").textStyle(BitcoinBody4()) // TODO: this should show fiat value
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

struct TransactionsListView: View {
    @EnvironmentObject var bdkManager: BDKManager
    var transactions: [TransactionDetails]
    
    var body: some View {
        if transactions.count != 0 {
            List {
                ForEach(transactions, id: \.self) {transaction in
                    TransactionItemView(transaction: transaction)
                }
            }.listStyle(.plain)
        } else {
            Spacer()
            switch bdkManager.syncState {
            case .synced:
                Text("No transactions")
                    .textStyle(BitcoinBody4())
            case .syncing:
                Text("Syncing")
                    .textStyle(BitcoinBody4())
            default:
                Text("Not synced")
                    .textStyle(BitcoinBody4())
            }
            Spacer()
        }
    }
}

struct TransactionItemView: View {
    var transaction: TransactionDetails
    
    var body: some View {
        HStack {
            if transaction.sent == UInt64(0) {
                ZStack {
                    Circle()
                        .fill(Color.bitcoinGreen)
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.down")
                        .tint(Color.bitcoinWhite)
                }
                VStack (alignment: .leading) {
                    Text("Received").textStyle(BitcoinTitle5())
                    Text(transaction.confirmationTime?.timestamp.description != nil ? transaction.txid : "Pending").textStyle(BitcoinBody5())
                }
                Spacer()
                Text(transaction.received.description).textStyle(BitcoinBody3())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.bitcoinRed)
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.up")
                        .tint(Color.bitcoinWhite)
                }
                VStack (alignment: .leading) {
                    Text("Sent").textStyle(BitcoinTitle5())
                    Text(transaction.confirmationTime?.timestamp.description != nil ? transaction.txid : "Pending").textStyle(BitcoinBody5())
                }
                Spacer()
                Text(transaction.sent.description).textStyle(BitcoinBody3())
            }
        }
    }
}
