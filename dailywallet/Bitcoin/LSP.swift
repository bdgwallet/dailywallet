//
//  LSP.swift
//  dailywallet
//
//  Created by Daniel Nordh on 01/05/2023.
//

import Foundation
import LightningDevKitNode

// Experimental Lightning Service Provider code3

// Connect to node (Voltage on testnet)
public func connectToVoltage(node: Node) {
    do {
        try node.connect(nodeId: VOLTAGE_PUBKEY, address: VOLTAGE_ADDRESS, permanently: true, trusted0conf: true)
        debugPrint("LDKNodeManager: Connected to Voltage node")
    } catch let error {
        debugPrint("LDKNodeManager: Error connecting to Voltage node: \(error.localizedDescription)")
    }
}

func getWrappedInvoice(invoice: String, completion: @escaping (String) -> ()) {
    do {
        let body = ["bolt11": invoice]
        let bodyData = try JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        
        let url = URL(string: VOLTAGE_API)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
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
let VOLTAGE_API = "https://testnet-lsp.voltageapi.com/api/v1/proposal"
let VOLTAGE_PUBKEY = "025804d4431ad05b06a1a1ee41f22fefeb8ce800b0be3a92ff3b9f594a263da34e"
let VOLTAGE_ADDRESS = "44.228.24.253:9735"
