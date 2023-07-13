//
//  Extensions.swift
//  dailywallet
//
//  Created by Daniel Nordh on 02/05/2023.
//

import Foundation

// Sats and bitcoin conversion
extension UInt64 {
    var satsToBitcoin: Double { return Double(self) / 100000000}
    var bitcoinToSats: UInt64 { return self * 100000000}
}
