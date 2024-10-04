//
//  ActivityView.swift
//  dailywallet
//
//  Created by Daniel Nordh on 9/9/22.
//

import SwiftUI
import WalletUI
import LDKNode

struct ActivityView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    @EnvironmentObject var backupManager: BackupManager
    @State private var navigateTo: NavigateTo? = NavigateTo.none
    
    let headerWidth = UIScreen.main.bounds.width
    let headerHeight = UIScreen.main.bounds.height / 5
    
    var body: some View {
        VStack() {
            VStack(alignment: .center) {
                BalanceHeaderView()
                    .environmentObject(ldkNodeManager)
                    .frame(minHeight: headerHeight, alignment: .center)
                    .padding(EdgeInsets(top: 32, leading: 16, bottom: 0, trailing: 16))
                TransactionsListView(transactions: filteredTransactions(transactions: ldkNodeManager.transactions))
                    .environmentObject(ldkNodeManager)
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
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(spacing: 4) {
                Text("Your balance")
                    .textStyle(BitcoinBody4())
                if ldkNodeManager.balanceDetails != nil {
                    VStack {
                        HStack(alignment: VerticalAlignment.firstTextBaseline, spacing: 8) {
                            Text((ldkNodeManager.balanceDetails!.totalOnchainBalanceSats + ldkNodeManager.balanceDetails!.totalLightningBalanceSats).formatted())
                                .textStyle(BitcoinTitle1())
                            Text("sats")
                                .textStyle(BitcoinTitle4())
                        }.padding(4)
                        HStack(spacing: 4) {
                            Text("Lightning: ").textStyle(BitcoinBody4())
                            Text(ldkNodeManager.balanceDetails!.totalLightningBalanceSats.formatted())
                                .textStyle(BitcoinBody4())
                        }
                        HStack(spacing: 4) {
                            Text("Onchain: ").textStyle(BitcoinBody4())
                            Text(ldkNodeManager.balanceDetails!.totalOnchainBalanceSats.formatted())
                                .textStyle(BitcoinBody4())
                        }
                    }
                } else {
                    ProgressView()
                        .padding()
                }
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0))
        }
    }
}

struct TransactionsListView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    var transactions: [PaymentDetails]
    
    var body: some View {
        if transactions.count != 0 {
            List {
                ForEach(transactions, id: \.self) {transaction in
                    TransactionItemView(transaction: transaction)
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

struct TransactionItemView: View {
    var transaction: PaymentDetails
    
    var body: some View {
        HStack {
            let date = Date(timeIntervalSince1970: TimeInterval(transaction.latestUpdateTimestamp))
            ZStack {
                Circle()
                    .fill(Color.bitcoinNeutral1)
                    .frame(width: 40, height: 40)
                Image(systemName: transaction.status == PaymentStatus.pending ? "clock": transaction.direction == .inbound ? "arrow.down" : "arrow.up")
                    .foregroundColor(transaction.status == PaymentStatus.failed ? .bitcoinRed : transaction.status == PaymentStatus.pending ? .bitcoinOrange : transaction.direction == .inbound ? .bitcoinGreen : .bitcoinBlack)
            }
            VStack (alignment: .leading) {
                Text(transaction.status == PaymentStatus.failed ? "Failed" : transaction.status == PaymentStatus.pending ? "Pending" : transaction.direction == .inbound ? "Received" : "Sent").textStyle(BitcoinBody3())
                Text(date.formatted(date: .abbreviated, time: .shortened)).textStyle(BitcoinBody5())
            }
            Spacer()
            Text("+ " + ((transaction.amountMsat ?? 0) / 1000).formatted())
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.bitcoinGreen)
        }
    }
}

public func filteredTransactions(transactions: [PaymentDetails]) -> [PaymentDetails] {
    var filtered: [PaymentDetails] = []

    for transaction in transactions {
        //debugPrint(transaction)
        if transaction.status != .pending {
            filtered.append(transaction)
        } else if transaction.status == .pending && transaction.direction == .outbound {
            filtered.append(transaction)
        }
    }
    return filtered.sorted(by: {$0.latestUpdateTimestamp > $1.latestUpdateTimestamp})
}
