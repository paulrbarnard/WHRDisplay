//
//  DetailView.swift
//  WHRDisplay
//
//  Created by Paul Barnard on 11/02/2022.
//

import SwiftUI
import Network

struct DetailView : View {
    var udpListener: UdpListener
    var udpSender: UdpSender
    @Binding var showDetail: Bool
    @ObservedObject var imageSize: mySize

    var watch: Bool
    
    
    @State private var lightName: String = ""
    
    
    
    var body: some View {
		VStack {
            switch udpListener.selectedLight{
            case 0:
                Text("Station Depart")
            case 3:
                Text("Traverser Light")
            case 8:
                Text("Station Approach")
            default:
                Text("Light No:\(udpListener.selectedLight)")
            }
            
			HStack {
                //lightView(udpListener: udpListener, udpSender: udpSender)
                if !watch {  // if this is not on a watch then display the track layout as well
                    GeometryReader { geometry in
                        VStack {
#if os(macOS)
                            // Always show LayoutView if on macOS
                            layoutView(udpListener: udpListener, showDetail: $showDetail, imageSize: imageSize)
#else
                            if geometry.size.height >= geometry.size.width{
                                // only display if there is enough room
                                layoutView(udpListener: udpListener, showDetail: $showDetail, imageSize: imageSize)
                             }
#endif
                            VStack (alignment: .trailing){
                                SettingsView(udpListener: udpListener, udpSender: udpSender)
                            }
                         }
                    }
                }  else {
                    // special case for watch just show the Light view
                    lightView(udpListener: udpListener, udpSender: udpSender, setSize: mySize(width: 368.0, height: 448.0))
                }
            }
            Button("Back"){
                showDetail = false
            }
            
        }
		
	}
    
}





struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
#if os(watchOS)
        DetailView(udpListener: UdpListener(), udpSender: UdpSender(),
                   showDetail: .constant(false),
                   imageSize: mySize(),
                 watch: true)
            .previewDevice(PreviewDevice(rawValue: "AppleWatch Series 5 - 44mm"))
            .previewDisplayName("Apple Watch")
#elseif os(macOS)
        DetailView(udpListener: UdpListener(), udpSender: UdpSender(),
                   showDetail: .constant(false),
                   imageSize: mySize(),
                  watch: false)
            .previewDevice(PreviewDevice(rawValue: "Any Mac"))
            .previewDisplayName("macOS")
#elseif os(iOS)
        DetailView(udpListener: UdpListener(), udpSender: UdpSender(),
                   showDetail: .constant(false),
                   imageSize: mySize(),
                   watch: false)
            .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
            .previewDisplayName("iPad Air")
            .previewInterfaceOrientation(.landscapeLeft)
        DetailView(udpListener: UdpListener(), udpSender: UdpSender(),
                   showDetail: .constant(false),
                   imageSize: mySize(),
                   watch: false)
            .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
            .previewDisplayName("iPad Air")
#endif
        
    }
}


