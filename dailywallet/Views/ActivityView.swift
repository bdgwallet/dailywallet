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
                            .fill(Color.bitcoinNeutral1)
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.down")
                            .foregroundColor(.bitcoinGreen)
                    }
                    VStack (alignment: .leading) {
                        Text("Received").textStyle(BitcoinBody3())
                        //Text(transaction.preimage ?? "").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text("+ " + ((transaction.amountMsat ?? 0) / 1000).formatted())
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.bitcoinGreen)
                }
                else if (transaction.status == PaymentStatus.pending) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinNeutral1)
                            .frame(width: 40, height: 40)
                        Image(systemName: "clock")
                            .foregroundColor(.bitcoinOrange)
                    }
                    VStack (alignment: .leading) {
                        Text("Pending").textStyle(BitcoinBody3())
                        //Text(transaction.preimage ?? "").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text(((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                }
                else if (transaction.status == PaymentStatus.failed) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinNeutral1)
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.down")
                            .foregroundColor(.bitcoinRed)
                    }
                    VStack (alignment: .leading) {
                        Text("Failed").textStyle(BitcoinBody3())
                        //Text(transaction.preimage ?? "").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text(((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                }
            } else {
                if (transaction.status == PaymentStatus.succeeded) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinNeutral1)
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.up")
                            .foregroundColor(.bitcoinBlack)
                    }
                    VStack (alignment: .leading) {
                        Text("Sent").textStyle(BitcoinBody3())
                        //Text(transaction.confirmationTime?.timestamp.description != nil ? transaction.txid : "Pending").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text("- " + ((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                } else if (transaction.status == PaymentStatus.pending) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinNeutral1)
                            .frame(width: 40, height: 40)
                        Image(systemName: "clock")
                            .foregroundColor(.bitcoinOrange)
                    }
                    VStack (alignment: .leading) {
                        Text("Pending").textStyle(BitcoinBody3())
                        //Text(transaction.preimage ?? "").textStyle(BitcoinBody5())
                    }
                    Spacer()
                    Text(((transaction.amountMsat ?? 0) / 1000).formatted()).textStyle(BitcoinBody3())
                } else if (transaction.status == PaymentStatus.failed) {
                    ZStack {
                        Circle()
                            .fill(Color.bitcoinNeutral1)
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.up")
                            .foregroundColor(.bitcoinRed)
                    }
                    VStack (alignment: .leading) {
                        Text("Failed").textStyle(BitcoinBody3())
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
        } else if transaction.status == .pending && transaction.direction == .outbound {
            filtered.append(transaction)
        }
    }
    return filtered
}
