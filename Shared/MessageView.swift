//
//  MessageView.swift
//  WHRDisplay
//
//  Created by Paul Barnard on 25/02/2022.
//

import SwiftUI
import Network

struct messageView: View {
    @ObservedObject var udpListener: UdpListener
    var udpSender: UdpSender
    @Binding var showDetail: Bool
    
    
    var body: some View {
        GeometryReader { geo in
            if geo.size.width >= geo.size.height {
                // wider than high so use HStack
                HStack {
                    messageBody(udpListener: udpListener, udpSender: udpSender, showDetail: $showDetail)
                        .frame(width: geo.size.width * 0.75, height: .infinity)
                    messageButtons(udpListener: udpListener, udpSender: udpSender, showDetail: $showDetail)
                        .frame(width: geo.size.width * 0.25, height: .infinity)
                }
            } else {
                // higer than wide so use VStask
                VStack {
                    messageBody(udpListener: udpListener, udpSender: udpSender, showDetail: $showDetail)
                    messageButtons(udpListener: udpListener, udpSender: udpSender, showDetail: $showDetail)
                }
            }
        }
    }
    
    
     
    
    
}


struct messageBody: View {
    @ObservedObject var udpListener: UdpListener
    var udpSender: UdpSender
    @Binding var showDetail: Bool
    
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {  // message
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0, green: 0, blue: 1, opacity: 0.1))
                if showDetail {
                    if thisSensor(message: udpListener.incoming, sensorID: udpListener.selectedLight){
                        Text("\(udpListener.incoming)")
                    }
                }
                else {
                    Text("\(udpListener.incoming)")
                }
            }

        }
    }
    
    
    
    func thisSensor (message: String, sensorID: Int) -> Bool{
        if message != "" {
            let start = message.index(message.startIndex, offsetBy: 7)
            let end = message.index(message.startIndex, offsetBy: 8)
            let range = start..<end
            let theSensor = message[range]
            let theID = String(sensorID, radix: 16)
            //print("theSensor:\(theSensor)  theID:\(theID)")
            if theSensor == theID {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    

    
    
    
}


struct messageButtons: View {
    @ObservedObject var udpListener: UdpListener
    var udpSender: UdpSender
    @Binding var showDetail: Bool

    
    var body: some View {
        
        GeometryReader { geo in
            
            GeometryReader { geoB in
                 if geoB.size.width >= geoB.size.height {
                    // space is wider than it is high so HStack
                    HStack {
                        Spacer()
                        placeButton(text: "Clear\nTracks", color: Color.yellow, action: {actionAllClear()})
                        if !udpListener.allStopped {
                            placeButton(text: "All\nStop", color: Color.red, action: {actionAllStop()})
                        } else {
                            placeButton(text: "All\nGo", color: Color.green, action: {actionAllGo()})
                        }
                        Spacer()
                    }
                } else {
                    // space is heigher than it is wide so use VStack
                    VStack {
                        Spacer()
                        placeButton(text: "Clear\nTracks", color: Color.yellow, action: {actionAllClear()})
                        if !udpListener.allStopped {
                            placeButton(text: "All\nStop", color: Color.red, action: {actionAllStop()})
                        } else {
                            placeButton(text: "All\nGo", color: Color.green, action: {actionAllGo()})
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    
    struct placeButton: View {
        var text:String
        var color:Color
        var action: () -> Void
        
        var body: some View {
            
            GeometryReader { g in
                Button(action: action){
                    Text(text)
                        .multilineTextAlignment(.center)
                }.buttonStyle(roundButtonStyle(bkColor: color, size: g.size))
            }
            
        }
    }
    
    
    
    struct roundButtonStyle: ButtonStyle {
        var bkColor: Color
        var size: CGSize
        
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(width: size.width, height: size.height)
                .foregroundColor(Color.black)
                .background(bkColor)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10.0, height: 10.0)))
        }
    }
    
    
    
    private func actionAllClear() -> Void {
        print("All Clear Pressed!")
        DispatchQueue.main.async {
            // send message to signal box to change the minDistance
            var buf: Data = "Contrl:X000".data(using: .utf8)!
            // Sensor ID 'G' indicates all Go
            // Sensor ID 'S' indicates all Stop
            // Sensor ID 'X' indicates all Clear
            buf[8] = 255  // indicate value not changed
            buf[9] = 255  // indicate value not changed
            buf[10] = udpSender.checksum(data: buf)
            buf.append(0)
            //print("minDistance:\(buf[8])")
            //print("spanDistance:\(buf[9])")
            //print("checkSum:\(buf[10])")
            udpSender.connect(host: NWEndpoint.Host(udpListener.signalboxAddress),port: 44444)
            udpSender.send(buf)
        }
    }
    
    private func actionAllStop() -> Void {
        print("All Stop Pressed!")
        DispatchQueue.main.async {
            // send message to signal box to change the minDistance
            var buf: Data = "Contrl:S000".data(using: .utf8)!
            // Sensor ID 'G' indicates all Go
            // Sensor ID 'S' indicates all Stop
            // Sensor ID 'X' indicates all Clear
            buf[8] = 255  // indicate value not changed
            buf[9] = 255  // indicate value not changed
            buf[10] = udpSender.checksum(data: buf)
            buf.append(0)
            //print("minDistance:\(buf[8])")
            //print("spanDistance:\(buf[9])")
            //print("checkSum:\(buf[10])")
            udpSender.connect(host: NWEndpoint.Host(udpListener.signalboxAddress),port: 44444)
            udpSender.send(buf)
        }
    }
    
    private func actionAllGo() -> Void {
        print("All Go Pressed!")
        DispatchQueue.main.async {
            // send message to signal box to change the minDistance
            var buf: Data = "Contrl:G000".data(using: .utf8)!
            // Sensor ID 'G' indicates all Go
            // Sensor ID 'S' indicates all Stop
            // Sensor ID 'X' indicates all Clear
            buf[8] = 255  // indicate value not changed
            buf[9] = 255  // indicate value not changed
            buf[10] = udpSender.checksum(data: buf)
            buf.append(0)
            //print("minDistance:\(buf[8])")
            //print("spanDistance:\(buf[9])")
            //print("checkSum:\(buf[10])")
            udpSender.connect(host: NWEndpoint.Host(udpListener.signalboxAddress),port: 44444)
            udpSender.send(buf)
        }
    }
    






}





struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
#if os(watchOS)
    messageView(udpListener: UdpListener() , udpSender: UdpSender(), showDetail: .constant(false))
        .previewDevice(PreviewDevice(rawValue: "AppleWatch Series 5 - 44mm"))
        .previewDisplayName("Apple Watch")
#elseif os(macOS)
    messageView(udpListener: UdpListener() , udpSender: UdpSender(), showDetail: .constant(false))
        .previewDevice(PreviewDevice(rawValue: "Any Mac"))
        .previewDisplayName("macOS")
#elseif os(iOS)
    messageView(udpListener: UdpListener() , udpSender: UdpSender(), showDetail: .constant(false))
        .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
        .previewDisplayName("iPad Air")
        .previewInterfaceOrientation(.landscapeLeft)
    messageView(udpListener: UdpListener() , udpSender: UdpSender(), showDetail: .constant(false))
        .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
        .previewDisplayName("iPad Air")
#endif
    }
}
