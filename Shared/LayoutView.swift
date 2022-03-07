//
//  LayoutView.swift
//  WHRDisplay
//
//  Created by Paul Barnard on 01/03/2022.
//

import SwiftUI


struct layoutView: View {
    
    @ObservedObject var udpListener: UdpListener
    @Binding var showDetail: Bool
    @ObservedObject var imageSize: mySize
    
    var body: some View {
        ZStack (alignment: .topLeading){  // layout view
                                          // only show if the screen is big enough
            MainView(udpListener: udpListener, showDetail: $showDetail, imageSize: imageSize)
            
            // overlay the selected light
            switch udpListener.selectedLight {
            case 0:
                highLight(hOffset: 0.545, vOffset: 0.635)
            case 1:
                highLight(hOffset: 0.78, vOffset: 0.39)
            case 2:
                highLight(hOffset: 0.63, vOffset: 0.115)
            case 3:
                highLight(hOffset: 0.455, vOffset: 0.623)
                highLight(hOffset: 0.255, vOffset: 0.65)
            case 4:
                highLight(hOffset: 0.103, vOffset: 0.594)
            case 5:
                highLight(hOffset: 0.114, vOffset: 0.235)
            case 6:
                highLight(hOffset: 0.53, vOffset: 0.005)
            case 7:
                highLight(hOffset: 0.895, vOffset: 0.36)
            default:  // button 8
                highLight(hOffset: 0.815, vOffset: 0.89)
            }
            
        }  // end of layout view
    }
    
    private func highLight(hOffset: CGFloat, vOffset: CGFloat) -> some View {
        VStack {
            Circle()
                .strokeBorder(Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.50), lineWidth: imageSize.mySize.width / 200)
                .background(Circle().fill(Color(red: 1.0, green: 1.0, blue: 0.0, opacity: 0.25)))
                .frame(width: imageSize.mySize.width / 10, height: imageSize.mySize.height / 10)
                .offset(x: hOffset * imageSize.mySize.width - (imageSize.mySize.width / 40), y: vOffset * imageSize.mySize.height)
        }
        
    }
    
    
}


struct LayoutView_Previews: PreviewProvider {
    static var previews: some View {
#if os(watchOS)
        layoutView(udpListener: UdpListener(), showDetail: .constant(true), imageSize: mySize())
            .previewDevice(PreviewDevice(rawValue: "AppleWatch Series 5 - 44mm"))
            .previewDisplayName("Apple Watch")
#elseif os(macOS)
        layoutView(udpListener: UdpListener(), showDetail: .constant(true), imageSize: mySize())
            .previewDevice(PreviewDevice(rawValue: "Any Mac"))
            .previewDisplayName("macOS")
#elseif os(iOS)
        layoutView(udpListener: UdpListener(), showDetail: .constant(true), imageSize: mySize())
            .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
            .previewDisplayName("iPad Air")
            .previewInterfaceOrientation(.landscapeLeft)
        layoutView(udpListener: UdpListener(), showDetail: .constant(true), imageSize: mySize())
            .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
            .previewDisplayName("iPad Air")
#endif
    }
}
