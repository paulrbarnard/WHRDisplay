//
//  udpSender.swift
//  WHRDisplay
//
//  Created by Paul Barnard on 18/02/2022.
//

import Foundation
import Network



class UdpSender: NSObject, ObservableObject {
   
    private var connection: NWConnection?

    func send(_ payload: Data) {
        connection!.send(content: payload, completion: .contentProcessed({ sendError in
            if let error = sendError {
                NSLog("Unable to process and send the data: \(error)")
            } else {
                NSLog("Data has been sent")
                self.connection!.receiveMessage { (data, context, isComplete, error) in
                    guard let myData = data else { return }
                    NSLog("Received message: " + String(decoding: myData, as: UTF8.self))
                }
            }
        }))
    }
    
    func connect(host: NWEndpoint.Host, port: NWEndpoint.Port) {
        connection = NWConnection(host: host, port: port, using: .udp)
        
        connection!.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .preparing:
                NSLog("Entered state: preparing")
            case .ready:
                NSLog("Entered state: ready")
            case .setup:
                NSLog("Entered state: setup")
            case .cancelled:
                NSLog("Entered state: cancelled")
            case .waiting:
                NSLog("Entered state: waiting")
            case .failed:
                NSLog("Entered state: failed")
            default:
                NSLog("Entered an unknown state")
            }
        }
        
        connection!.viabilityUpdateHandler = { (isViable) in
            if (isViable) {
                NSLog("Connection is viable")
            } else {
                NSLog("Connection is not viable")
            }
        }
        
        connection!.betterPathUpdateHandler = { (betterPathAvailable) in
            if (betterPathAvailable) {
                NSLog("A better path is availble")
            } else {
                NSLog("No better path is available")
            }
        }
        
        connection!.start(queue: .global())
    }
    
    
    func checksum(data: Data) -> UInt8
    {
        //let result = 256 - data.checkSum()
        let result = data.checkSum()
        let cs = UInt8(result)
        //print("0x\(String(cs, radix: 16))")
        return cs
    }
    
    
}

public extension Data {
    
    func checkSum() -> Int {
        return self.map { Int($0) }.reduce(0, +) & 0xff
    }
}
