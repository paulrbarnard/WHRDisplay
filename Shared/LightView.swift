//
//  LightView.swift
//  WHRDisplay
//
//  Created by Paul Barnard on 01/03/2022.
//

import SwiftUI
import Network

struct lightView: View {
    @ObservedObject var udpListener: UdpListener
    var udpSender: UdpSender
	@ObservedObject var setSize: mySize

    var plateSize = mySize()
    
    var body: some View {
        ZStack {  // Light
            RoundedRectangle(cornerRadius: setSize.mySize.height / 4)
                .frame(maxWidth: setSize.mySize.width / 10, maxHeight: setSize.mySize.width / 4.8)
                .background(rectReader())
            VStack {  // lenses as buttons
                if !udpListener.redLight[udpListener.selectedLight] {
                    Button (""){
                        greenButtonPressed(sensorID: udpListener.selectedLight)
                    }
                    .buttonStyle(lightButtonStyle(viewSize: setSize, buttonColor: .green))
                    Button (""){
                        redButtonPressed(sensorID: udpListener.selectedLight)
                    }
                    .buttonStyle(lightButtonStyle(viewSize: setSize, buttonColor: .gray))
                } else {
                    Button (""){
                        greenButtonPressed(sensorID: udpListener.selectedLight)
                    }
                    .buttonStyle(lightButtonStyle(viewSize: setSize, buttonColor: .gray))
                    Button (""){
                        redButtonPressed(sensorID: udpListener.selectedLight)
                    }
                    .buttonStyle(lightButtonStyle(viewSize: setSize, buttonColor: .red))
                }
            }  // end of lenses as buttons
        }  // Light
        
        
    }
    
    private func greenButtonPressed(sensorID: Int) -> Void {
        // send a message to the signal box as if from the sensorLight saying stop released
        print("Green button pressed")
        let message = String("Sensor:" + String(udpListener.selectedLight, radix: 16 ) + " Manual Stop Released")
        print ("Sending message: \(message)")
        udpSender.connect(host: NWEndpoint.Host(udpListener.signalboxAddress),port: 44444)
        udpSender.send(Data(message.utf8))
    }
    
    private func redButtonPressed(sensorID: Int) -> Void {
        // send a message to the signal box as if from the sensorLight saying stop pressed
        print("Red button pressed")
        let message = String("Sensor:" + String(udpListener.selectedLight, radix: 16 ) + " Manual Stop Active")
        print ("Sending message: \(message)")
        udpSender.connect(host: NWEndpoint.Host(udpListener.signalboxAddress),port: 44444)
        udpSender.send(Data(message.utf8))
    }
    
    
    private func rectReader() -> some View {
        return GeometryReader { (geometry) -> AnyView in
            let viewSize = geometry.size
            DispatchQueue.main.async {
                self.plateSize.mySize = viewSize
            }
            return AnyView(Rectangle().fill(Color.clear))
        }
    }
    
    
}




struct lightButtonStyle: ButtonStyle {
    @ObservedObject var viewSize: mySize
    @State var buttonColor: Color
    
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fixedSize()
            .frame(width: viewSize.mySize.width * 0.09, height: viewSize.mySize.width * 0.09)
            .overlay(Circle().fill(buttonColor))
        
    }
    
    
}



struct LightView_Previews: PreviewProvider {
    static var previews: some View {
#if os(watchOS)
        lightView(udpListener: UdpListener(), udpSender: UdpSender(), setSize: mySize())
            .previewDevice(PreviewDevice(rawValue: "AppleWatch Series 5 - 44mm"))
            .previewDisplayName("Apple Watch")
#elseif os(macOS)
        lightView(udpListener: UdpListener(), udpSender: UdpSender(), setSize: mySize())
            .previewDevice(PreviewDevice(rawValue: "Any Mac"))
            .previewDisplayName("macOS")
#elseif os(iOS)
		lightView(udpListener: UdpListener(), udpSender: UdpSender(), setSize: mySize())
            .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
            .previewDisplayName("iPad Air")
            .previewInterfaceOrientation(.landscapeLeft)
        lightView(udpListener: UdpListener(), udpSender: UdpSender(), setSize: mySize())
            .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
            .previewDisplayName("iPad Air")
#endif
    }
}
