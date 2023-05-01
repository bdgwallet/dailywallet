//
//  LSP.swift
//  dailywallet
//
//  Created by Daniel Nordh on 01/05/2023.
//

import Foundation
import LightningDevKitNode

// Connect to node (Voltage on testnet)
public func connectToVoltage(node: Node) {
    let voltagePubKey = "025804d4431ad05b06a1a1ee41f22fefeb8ce800b0be3a92ff3b9f594a263da34e"
    let voltageAddress = "44.228.24.253:9735"
    do {
        try node.connect(nodeId: voltagePubKey, address: voltageAddress, permanently: true, trusted0conf: true)
        debugPrint("LDKNodeManager: Connected to Voltage node")
    } catch let error {
        debugPrint("LDKNodeManager: Error connecting to Voltage node: \(error.localizedDescription)")
    }
}

public func wrapInvoice(node: Node) {
    let voltageEndpoint = "https://testnet-lsp.voltageapi.com/api/v1/proposal"
    debugPrint("LDKNodeManager: Node id: \(node.nodeId())")
          
    do {
        let bolt11 = try node.receivePayment(amountMsat: 10000, description: "Test JIT channel", expirySecs: 36000)
        debugPrint("LDKNodeManager: Original invoice : \(bolt11)")
        
        let body = ["bolt11": bolt11]
        let bodyData = try JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        
        let url = URL(string: voltageEndpoint)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bodyData

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if let data = data {
                // Handle HTTP request response
                do {
                    let voltageRespone = try JSONDecoder().decode(VoltageResponse.self, from: data)
                    debugPrint("LDKNodeManager: Wrapped invoice received: \(voltageRespone.jit_bolt11)")
                } catch let error {
                    debugPrint("LDKNodeManager: Decoding error: \(error.localizedDescription)")
                }
            } else if let error = error {
                // Handle HTTP request error
                debugPrint("LDKNodeManager: Error getting wrapped invoice: \(error.localizedDescription)")
            } else  {
                // Handle unexpected error
                debugPrint("LDKNodeManager: Unknown error getting wrapped invoice")
            }
        }
        task.resume()
        
    } catch let error {
        debugPrint("LDKNodeManager: Error connecting to Voltage node: \(error.localizedDescription)")
    }
}

struct VoltageResponse: Decodable {
    let jit_bolt11: String
}
