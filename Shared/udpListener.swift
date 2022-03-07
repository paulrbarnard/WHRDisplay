//
//  udp.swift
//  WHRDisplay
//
//  Created by Paul Barnard on 21/08/2021.
//

import Network
import SwiftUI


class UdpListener: NSObject, ObservableObject {
    private var connection: NWConnection?
    private var listener: NWListener?
    private var signalState = 0x0000
    private var trackState = 0xffff
    private var timeOutValue = 10       // The default message clear value is seconds
    
    private var messageTimeOut = 10

	@Published var signalboxAddress = "255.255.255.255"

    @Published var incoming: String = ""
    
    @Published var redLight: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    @Published var trainLight: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    @Published var remoteSetting: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    @Published var forcedClear: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    @Published var localWiFi: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    @Published var seenActive: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    @Published var minDistance: [UInt8] = [150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150]
    @Published var spanDistance: [UInt8] = [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100]
    @Published var swVersion: [Float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

    @Published var allStopped: Bool = false
    @Published var allClear: Bool = false
    @Published var selectedLight: Int = 0

    
    
    func messageWatchdog() {
        //print("Timer fired! messageTimeOut:\(messageTimeOut)")
        messageTimeOut -= 1
        if messageTimeOut <= 0 {
            messageTimeOut = timeOutValue
            //print("message timeout!")
           if incoming != "" {
                //print ("cleared message")
                incoming = ""
            }
        }
    }
    
    func start(port: NWEndpoint.Port) {
        do {
            self.listener = try NWListener(using: .udp, on: port)
        } catch {
            print("exception upon creating listener")
        }
        
        guard let _ = listener else { return }
        
        prepareUpdateHandler()
        prepareNewConnectionHandler()
        
        self.listener?.start(queue: .main)
        print("listener started")
        //active = true
    }
    
    func prepareUpdateHandler() {
        self.listener?.stateUpdateHandler = {(newState) in
            switch newState {
            case .ready:
                print("prepareUpdateHandler ready")
            default:
                break
            }
        }
    }
    
    func prepareNewConnectionHandler() {
        self.listener?.newConnectionHandler = {(newConnection) in
            newConnection.stateUpdateHandler = {newState in
                switch newState {
                case .ready:
                    //print("prepareNewConnectionHandler ready")
                    self.receive(on: newConnection)
                default:
                    break
                }
            }
            newConnection.start(queue: DispatchQueue(label: "newconn"))
        }
    }
    
    func receive(on connection: NWConnection) {
        
        connection.receiveMessage { (data, context, isComplete, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("unable to receive data")
                return
            }
            // interpret the data
            var header = String(decoding: data, as: UTF8.self)
            if (header.contains("Signalbox Address:")){
                // broadcast message to the signals sent every 500ms
                //                    led           Sensor setting
                //                    stat      start distance, span
                //                    |--||------------------------------|
                // "Signalbox Address:AaBb00112233445566778899aabbccddeeff255.255.255.255"
                //  0000000000111111111122222222223333333333444444444455555555556666666666
                //  0123456789012345678901234567890123456789012345678901234567890123456789
                //
                //  sensor start distance = 8bit value (cm) + 50 cm minimum offset
                //  sensor span distance = 8bit value (cm)
                // save the address
                //print(header)
                let theAdd = self.getAddress(message: header)
                if theAdd != "" {
                    if self.signalboxAddress != theAdd {
                        self.signalboxAddress = theAdd
                        print ("New Signalbox address \(self.signalboxAddress)")
                    }
                }
                // data is from the signal box so process the light info
                var bytes: [UInt8] = [data[19], data[18]]
                let signalValue = bytes.withUnsafeBytes { $0.load(as: UInt16.self) }
                if signalValue == 0xFFFF && self.allStopped == false {
                    self.allStopped = true
                }
                if signalValue != 0xFFFF && self.allStopped == true {
                    self.allStopped = false
                 }
                bytes[0] = data[21]
                bytes[1] = data[20]
                let trackValue = bytes.withUnsafeBytes { $0.load(as: UInt16.self) }
                if trackValue == 0xFFFF && self.allClear == false {
                    self.allClear = true
                }
                if trackValue != 0xFFFF && self.allClear == true {
                    self.allClear = false
                }
               if self.signalState != Int(signalValue) {
                    self.signalState = Int(signalValue)
                    DispatchQueue.main.async {
                        self.redLight = self.lightFlags(value: signalValue)
                    }
                }
                if self.trackState != Int(trackValue) {
                    self.trackState = Int(trackValue)
                    DispatchQueue.main.async {
                        self.trainLight = self.trainFlags(value: trackValue)
                    }
                }
                // process the settings information
                for index in 0...15 {
                    let start: UInt8 = data[22 + (index * 2)]
                    if self.minDistance[index] != start && self.remoteSetting[index] == true {
                        self.minDistance[index] = start
                    }
                    let span: UInt8 = data[23 + (index * 2)]
                    if self.spanDistance[index] != span  && self.remoteSetting[index] == true {
                        self.spanDistance[index] = span
                    }
                }

                header = ""
            } else if (header.contains("Sensor")){
                //let sensorID = data[7] - 48
                // message from a sensor
                if (header.contains("Train Detected")){
                    // train detected
                    //header = "Train detected by sensor " + String(sensorID)
                } else if (header.contains("Track Clear")){
                    // track clear
                    //header = "Track clear detected by sensor " + String(sensorID)
                } else if (header.contains("Stop Active")){
                    // stop pressed
                    //header = "Stop pressed by sensor " + String(sensorID)
                } else if (header.contains("Stop Released")){
                    // stop released
                    //header = "Stop released by sensor " + String(sensorID)
                } else if (header.contains("Range Adjustment")){
                    //header = "Range adjustment on sensor " + String(sensorID)
                } else {
                    // a keep alive message
                    // alive message format
                    //        i  ver    ss
                    // Sensor:dv01.20frwtp
                    // 0000000000111111111122222222223
                    // 0123456789012345678901234567890
                    // board links sent as ascii '0' or '1'
                    // f = forced clear
                    // r = remote settings
                    // w = wifi
                    let senID: Int = Int(data[7] - 48)
                    let range:Range<Int> = 10..<14
                    let subData: Data = data.subdata(in: range)
                    let verStr = String(decoding: subData, as: UTF8.self)
                    self.swVersion[senID] = Float(verStr) ?? 1.0
                    self.forcedClear[senID] = (data[15] - 48) != 0
                    self.remoteSetting[senID] = (data[16] - 48) != 0
                    self.localWiFi[senID] = (data[17] - 48) != 0
                    if !self.remoteSetting[senID] {
                        // use settings from the pots on the board
                        if self.minDistance[senID] != data[18] {
                            self.minDistance[senID] = data[18]
                            //print("minDistance:\(self.minDistance[senID])  data[18]:\(data[18])\n")
                        }
                        if self.spanDistance[senID] != data[19] {
                            self.spanDistance[senID] = data[19]
                            //print("spanDistance:\(self.spanDistance[senID])  data[19]:\(data[19])\n")
                        }
                    }
                    self.seenActive[senID] = true
                    // don't display message
                    header = ""
                }
                if header != "" {
                    DispatchQueue.main.async {
                        self.messageTimeOut = self.timeOutValue
                        self.incoming = header
                        //print(header)
                    }
                }
            }
            DispatchQueue.main.async {
                connection.cancel()
            }
        }
    }
	
	func getAddress (message: String) -> String{
		if message != "" {
			let start = message.index(message.startIndex, offsetBy: 54)
			let end = message.index(message.endIndex, offsetBy: 0)
			let range = start..<end
			return String(message[range])
		}
		return ""
	}

    
    func binaryString (value: Int) -> String {
        var buffer = "0000000000000000"
        for i in 0...15
        {
            let test: UInt16 = 0x8000 >> i;
            if ((UInt16(value) & test) != 0)
            {
                buffer = replace(myString: buffer, i, "1")
            }
        }
        return buffer
    }
    
    func lightFlags (value: UInt16) -> [Bool] {
        var localFlags: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
        for i in 0...15
        {
            let test: UInt16 = 0x0001 << i;
            if ((value & test) != 0)
            {
                localFlags[i] = true
            }
        }
        return localFlags
    }
    
    func trainFlags (value: UInt16) -> [Bool] {
        var localFlags: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
        for i in 0...15
        {
            let test: UInt16 = 0x0001 << i;
            if ((value & test) != 0)
            {
                localFlags[i] = true
            }
        }
        return localFlags
    }
    

    func getMinDistance(forLight: Int) -> Double {
        
        let dValue = Double(minDistance[forLight]) / 100 + 0.5
        return dValue
    }
    
    func getSpanDistance(forLight: Int) -> Double {
        let dValue = Double(spanDistance[forLight]) / 100
        return dValue
    }

    
    
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
}

