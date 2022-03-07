//
//  WHRDisplayApp.swift
//  Shared
//
//  Created by Paul Barnard on 20/08/2021.
//

import SwiftUI
import Network
import Foundation
#if os(macOS)
import AppKit
#endif


@main

struct WHRDisplayApp: App {
    #if os(macOS)
    // macOS
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
	@State private var portA = 0x0000
	@State private var portB = 0xFFFF
    @State var udpPort = NWEndpoint.Port.init(integerLiteral: 44444)


    var body: some Scene {
        WindowGroup {

            ContentView(udpPort: $udpPort, details: false)

        }
    }
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
#endif
