//
//  LSP.swift
//  dailywallet
//
//  Created by Daniel Nordh on 01/05/2023.
//

import Foundation
import LDKNode

// Experimental Lightning Service Provider code3

// Connect to node (Voltage on testnet)
public func connectToVoltage(node: LdkNode, network: Network) {
    do {
        try node.connect(nodeId: network == .bitcoin ? VOLTAGE_PUBKEY_BITCOIN : VOLTAGE_PUBKEY_TESTNET, address: network == .bitcoin ? VOLTAGE_ADDRESS_BITCOIN : VOLTAGE_ADDRESS_TESTNET, persist: true)
        debugPrint("LDKNodeManager: Connected to Voltage node")
    } catch let error {
        debugPrint("LDKNodeManager: Error connecting to Voltage node: \(error.localizedDescription)")
    }
}

func getWrappedInvoice(invoice: String, network: Network, completion: @escaping (String) -> ()) {
    do {
        let body = ["bolt11": invoice]
        let bodyData = try JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        
        let url = URL(string: network == .bitcoin ? VOLTAGE_API_BITCOIN : VOLTAGE_API_TESTNET)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            debugPrint("LDKNodeManager: : \(String(describing: response))")
            if let data = data {
                // Handle HTTP request response
                do {
                    let voltageResponse = try JSONDecoder().decode(VoltageResponse.self, from: data)
                    completion(voltageResponse.jit_bolt11)
                    debugPrint("LDKNodeManager: Wrapped invoice received: \(voltageResponse.jit_bolt11)")
                } catch let error {
                    debugPrint(response.debugDescription)
                    debugPrint("LDKNodeManager: Decoding error: \(error.localizedDescription)")
                }
            } else if let error = error {
                // Handle HTTP request error
                debugPrint("LDKNodeManager: Error getting wrapped invoice: \(error.localizedDescription)")
            } else  {
                // Handle unexpected error
                debugPrint("LDKNodeManager: Unknown error getting wrapped invoice")
            }
        }).resume()
        
    } catch let error {
        debugPrint("LDKNodeManager: Error connecting to Voltage node: \(error.localizedDescription)")
    }
}

struct VoltageResponse: Decodable {
    let jit_bolt11: String
}

// Public APIs
let VOLTAGE_API_TESTNET = "https://testnet-lsp.voltageapi.com/api/v1/proposal"
let VOLTAGE_API_BITCOIN = "https://lsp.voltageapi.com/api/v1/proposal"
let VOLTAGE_PUBKEY_TESTNET: PublicKey = "025804d4431ad05b06a1a1ee41f22fefeb8ce800b0be3a92ff3b9f594a263da34e"
let VOLTAGE_PUBKEY_BITCOIN: PublicKey = "03aefa43fbb4009b21a4129d05953974b7dbabbbfb511921410080860fca8ee1f0"
let VOLTAGE_ADDRESS_TESTNET = "44.228.24.253:9735"
let VOLTAGE_ADDRESS_BITCOIN = "52.88.33.119:9735"

