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
                TransactionsListView(transactions: ldkNodeManager.transactions)
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
                Text("\((ldkNodeManager.balanceDetails.totalOnchainBalanceSats + ldkNodeManager.balanceDetails.totalLightningBalanceSats).formatted()) sats")
                    .textStyle(BitcoinTitle1())
                HStack(spacing: 4) {
                    Text("Lightning: ").textStyle(BitcoinBody4())
                    Text(ldkNodeManager.balanceDetails.totalLightningBalanceSats.formatted())
                        .textStyle(BitcoinBody4())
                }
                HStack(spacing: 4) {
                    Text("Onchain: ").textStyle(BitcoinBody4())
                    Text(ldkNodeManager.balanceDetails.totalOnchainBalanceSats.formatted())
                        .textStyle(BitcoinBody4())
                }
                HStack(spacing: 4) {
                    Text("Channels: ").textStyle(BitcoinBody4())
                    Text(ldkNodeManager.channels.count.formatted())
                        .textStyle(BitcoinBody4())
                }
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0))
            /*
            HStack {
                Text("Activity")
                    .textStyle(BitcoinTitle5())
                Spacer()
            }
            */
        }
    }
}

struct TransactionsListView: View {
    @EnvironmentObject var ldkNodeManager: LDKNodeManager
    var transactions: [PaymentDetails]
    
    var body: some View {
        Divider()
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
            if transaction.direction == .inbound {
                if (transaction.status == PaymentStatus.succeeded) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinGreen)
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.down")
                            .foregroundColor(.bitcoinWhite)
                    }
                    VStack (alignment: .leading) {
                        Text("Received").textStyle(BitcoinTitle5())
                        //Text(transaction.preimage ?? "").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text(((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                }
                else if (transaction.status == PaymentStatus.pending) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinOrange)
                            .frame(width: 40, height: 40)
                        Image(systemName: "clock")
                            .foregroundColor(.bitcoinWhite)
                    }
                    VStack (alignment: .leading) {
                        Text("Pending").textStyle(BitcoinTitle5())
                        //Text(transaction.preimage ?? "").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text(((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                }
                else if (transaction.status == PaymentStatus.failed) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinRed.opacity(50))
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.down")
                            .foregroundColor(.bitcoinWhite)
                    }
                    VStack (alignment: .leading) {
                        Text("Failed").textStyle(BitcoinTitle5())
                        //Text(transaction.preimage ?? "").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text(((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                }
            } else {
                if (transaction.status == PaymentStatus.succeeded) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinGreen)
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.up")
                            .foregroundColor(.bitcoinWhite)
                    }
                    VStack (alignment: .leading) {
                        Text("Sent").textStyle(BitcoinTitle5())
                        //Text(transaction.confirmationTime?.timestamp.description != nil ? transaction.txid : "Pending").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text(((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                } else if (transaction.status == PaymentStatus.pending) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinOrange)
                            .frame(width: 40, height: 40)
                        Image(systemName: "clock")
                            .foregroundColor(.bitcoinWhite)
                    }
                    VStack (alignment: .leading) {
                        Text("Pending").textStyle(BitcoinTitle5())
                        //Text(transaction.preimage ?? "").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text(((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                } else if (transaction.status == PaymentStatus.failed) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinRed.opacity(50))
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.up")
                            .foregroundColor(.bitcoinWhite)
                    }
                    VStack (alignment: .leading) {
                        Text("Failed").textStyle(BitcoinTitle5())
                        //Text(transaction.preimage ?? "").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text(((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                }
                
            }
        }
    }
}

public func filteredTransactions(transactions: [PaymentDetails]) -> [PaymentDetails] {
    var filtered: [PaymentDetails] = []

    for transaction in transactions {
        if transaction.status != .pending {
            filtered.append(transaction)
        }
    }
    return filtered
}
