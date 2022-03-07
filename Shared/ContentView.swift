//
//  ContentView.swift
//  Shared
//
//  Created by Paul Barnard on 20/08/2021.
//

import SwiftUI
import Network


struct ContentView: View {
#if os(iOS) || os(tvOS)
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    @State var text = ""
    @Binding var udpPort:NWEndpoint.Port
    @ObservedObject var udpListener = UdpListener()
    var udpSender = UdpSender()
    @State var details:Bool
    @ObservedObject var imageSize = mySize()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
#if os(iOS) || os(tvOS)
        if horizontalSizeClass == .regular && verticalSizeClass == .compact {
            // landscape format
            HStack  {
                viewSwitcher(udpListener: udpListener, udpSender: udpSender, showDetail: $details, imageSize: imageSize, watch: false)
                messageView(udpListener: udpListener, udpSender: udpSender, showDetail: $details)
            }.onAppear { udpListener.start(port: self.udpPort)}
            .onReceive(timer) { input in
                udpListener.messageWatchdog()
            }
        }
        else  {
            // portait format
            VStack  {
                viewSwitcher(udpListener: udpListener, udpSender: udpSender, showDetail: $details, imageSize: imageSize, watch: false)
                messageView(udpListener: udpListener, udpSender: udpSender, showDetail: $details)
                    .frame(width: nil, height: 50)
            }.onAppear { udpListener.start(port: self.udpPort)}
            .onReceive(timer) { input in
                udpListener.messageWatchdog()
            }
       }
#elseif os(macOS)
		VStack  {
            viewSwitcher(udpListener: udpListener, udpSender: udpSender, showDetail: $details, imageSize: imageSize, watch: false)
            messageView(udpListener: udpListener, udpSender: udpSender, showDetail: $details)
				.frame(width: nil, height: 100)
		}.onAppear {udpListener.start(port: self.udpPort)}
        .onReceive(timer) { input in
            udpListener.messageWatchdog()
        }

		
#elseif os(watchOS)
        VStack  {
            viewSwitcher(udpListener: udpListener, udpSender: udpSender, showDetail: $details, imageSize: imageSize, watch: true)
            if details == false {
                messageView(udpListener: udpListener, udpSender: udpSender, showDetail: $details)
                    .frame(width: nil, height: 35)
            }
        }.onAppear {udpListener.start(port: self.udpPort)}
        .onReceive(timer) { input in
            udpListener.messageWatchdog()
        }
        
#endif
    }
    
    
}

struct viewSwitcher: View {
    @ObservedObject var udpListener: UdpListener
    var udpSender: UdpSender
    @Binding var showDetail: Bool
    @ObservedObject var imageSize: mySize

    var watch: Bool
    
    var body: some View {
        VStack {
            if !showDetail {
                MainView(udpListener: udpListener, showDetail: $showDetail, imageSize: imageSize)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if showDetail {
                DetailView(udpListener: udpListener, udpSender: udpSender,showDetail: $showDetail, imageSize: imageSize, watch: watch)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}





struct ContentView_Previews: PreviewProvider {
     static var previews: some View {
        Group {
#if os(watchOS)
            ContentView(udpPort: .constant(44444), details: false)
                .previewDevice(PreviewDevice(rawValue: "AppleWatch Series 5 - 44mm"))
                .previewDisplayName("AppleWatch Main View")
            ContentView(udpPort: .constant(44444), details: true)
                .previewDevice(PreviewDevice(rawValue: "AppleWatch Series 5 - 44mm"))
                .previewDisplayName("AppleWatch Detail View")
#elseif os(macOS)
            ContentView(udpPort: .constant(44444), details: false)
                .previewDevice(PreviewDevice(rawValue: "Any Mac"))
                .previewDisplayName("macOS Main view")
            ContentView(udpPort: .constant(44444), details: true)
                .previewDevice(PreviewDevice(rawValue: "Any Mac"))
                .previewDisplayName("macOS  Details view")
#elseif os(iOS)
            ContentView(udpPort: .constant(44444), details: false)
                .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
                .previewDisplayName("iPad Air Detail View")
                .previewInterfaceOrientation(.landscapeLeft)
            ContentView(udpPort: .constant(44444), details: true)
                .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
                .previewDisplayName("iPad Air Main View")
                .previewInterfaceOrientation(.landscapeLeft)
            ContentView(udpPort: .constant(44444), details: false)
                .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
                .previewDisplayName("iPad Air Detail View")
                .previewInterfaceOrientation(.portrait)
            ContentView(udpPort: .constant(44444), details: true)
                .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
                .previewDisplayName("iPad Air Main View")
                .previewInterfaceOrientation(.portrait)

#endif
       }
    }
}
