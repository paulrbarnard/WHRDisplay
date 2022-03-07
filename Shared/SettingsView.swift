//
//  SettingsView.swift
//  WHRDisplay
//
//  Created by Paul Barnard on 22/02/2022.
//

import SwiftUI
import Network


struct SettingsView: View {
    
    @ObservedObject var udpListener: UdpListener
    var udpSender: UdpSender
    
    var body: some View {
        GeometryReader { geo in
            Spacer()
            if geo.size.width >= geo.size.height {
                // wider than high so use HStack
				HStack {
                    diagramView(udpListener: udpListener, udpSender: udpSender)
                    VStack (alignment: .leading){
                        labelsView(udpListener: udpListener)
                    }
                 }
          } else {
                // higher than wide so use VStack
			  VStack {
                    diagramView(udpListener: udpListener, udpSender: udpSender)
				  HStack (alignment: .firstTextBaseline){
                        labelsView(udpListener: udpListener)
                  }
                }
            }
        }
       
    }
    
	
    struct diagramView: View {
        @ObservedObject var udpListener: UdpListener
        var udpSender: UdpSender
        @ObservedObject var setSize = mySize()

        
        var body: some View {
            ZStack (alignment: .topLeading) {
                setBack(setSize: setSize)
				slidersView(setSize: setSize, udpListener: udpListener, udpSender: udpSender)
				lightView(udpListener: udpListener, udpSender: udpSender, setSize: setSize)
					.frame(maxWidth: setSize.mySize.width / 10, maxHeight: setSize.mySize.height / 3)

			}
        }
    }


    struct labelsView: View {
        @ObservedObject var udpListener: UdpListener

        var body: some View {
            Text("SW Version:\(udpListener.swVersion[udpListener.selectedLight], specifier:"%0.2f"),")
            Text(udpListener.forcedClear[udpListener.selectedLight] == true ? "Forced Clear Stop," : "Normal Stop,")
            Text(udpListener.remoteSetting[udpListener.selectedLight] == true ? "Remote Setting," : "Local Setting,")
            Text(udpListener.localWiFi[udpListener.selectedLight] == true ? "Local WiFi" : "Joins WiFi")
        }
    }
     
}


struct setBack: View {
    @ObservedObject var setSize: mySize
    
    var body: some View {
        Image("Settings Image")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(rectReader())
    }
    
    
    private func rectReader() -> some View {
        return GeometryReader { (geometry) -> AnyView in
            let currentSize = geometry.size
            DispatchQueue.main.async {
                //print("setting setSize to:>> \(currentSize)")
                self.setSize.mySize = currentSize
            }
            return AnyView(Rectangle().fill(Color.clear))
        }
    }
    
}





struct SettingsView_Previews: PreviewProvider {

    static var previews: some View {
#if os(watchOS)
        SettingsView(udpListener: UdpListener(),udpSender: UdpSender())
            .previewDevice(PreviewDevice(rawValue: "AppleWatch Series 5 - 44mm"))
            .previewDisplayName("Apple Watch")
#elseif os(macOS)
        SettingsView(udpListener: UdpListener(), udpSender: UdpSender())
            .previewDevice(PreviewDevice(rawValue: "Any Mac"))
            .previewDisplayName("macOS")
#elseif os(iOS)
        SettingsView(udpListener: UdpListener(),udpSender: UdpSender())
            .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
            .previewDisplayName("iPad Air")
            .previewInterfaceOrientation(.landscapeLeft)
        SettingsView(udpListener: UdpListener(),udpSender: UdpSender())
            .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
            .previewDisplayName("iPad Air")
#endif
    }
}
