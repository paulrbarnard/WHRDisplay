//
//  SlidersView.swift
//  WHRDisplay
//
//  Created by pbarnard on 01/03/2022.
//

import SwiftUI
import Network


struct slidersView: View {
	@ObservedObject var setSize: mySize
	@ObservedObject var udpListener: UdpListener
	var udpSender: UdpSender
	@State var minDistance: Double = 0.0
	@State var spanDistance: Double = 0.0
	
	var body: some View {
		ZStack {
			VStack {
				Text("\(minDistance, specifier: "%.2f") meters")
				Slider(value: $minDistance, in: 0.5...3.0, onEditingChanged: { data in
					sendMin()
				})
					.frame(width: setSize.mySize.width * 0.465, height: .infinity)
					.disabled(!udpListener.remoteSetting[udpListener.selectedLight])
			}
			.offset(x: setSize.mySize.width * 0.065, y: setSize.mySize.height * 0.45)
			
			HStack {
				VStack {
					Text("\(spanDistance, specifier: "%.2f") meters")
					Slider(value: $spanDistance, in: 0.01...2.5, onEditingChanged: { data in
						sendSpan()
					})
						.frame(width: setSize.mySize.width * 0.26, height: .infinity)
						.disabled(!udpListener.remoteSetting[udpListener.selectedLight])
				}
				.offset(x: setSize.mySize.width * 0.46, y: setSize.mySize.height * 0.00)
			}
		}.onReceive(udpListener.$selectedLight) { (newLight) in
			initMinDistance(light: newLight);
			   initSpanDistance(light: newLight)
		   }
		   .onReceive(udpListener.$remoteSetting) { (newSetting) in
			   initMinDistance(light: udpListener.selectedLight);
			   initSpanDistance(light: udpListener.selectedLight)
		   }
		   .onReceive(udpListener.$minDistance) { (newDistance) in
			   initMinDistance(light: udpListener.selectedLight);
			   initSpanDistance(light: udpListener.selectedLight)
		   }
		   .onReceive(udpListener.$spanDistance) { (newSpan) in
			   initMinDistance(light: udpListener.selectedLight);
			   initSpanDistance(light: udpListener.selectedLight)
		   }
		
	}
	
	
	private func minDistanceValue(value: Double) -> UInt8 {
		let uValue: UInt8 = UInt8((value - 0.50) * 100)
		return uValue
	}
	
	private func spanDistanceValue(value: Double) -> UInt8{
		let uValue: UInt8 = UInt8((value) * 100)
		return uValue
	}
	
	
	func initMinDistance(light: Int) -> Void{
		if minDistance != udpListener.getMinDistance(forLight: light) {
			DispatchQueue.main.async {
				self.minDistance = udpListener.getMinDistance(forLight: light)
				//print("initMinDistance minDistance:\(self.minDistance) meters")
			}
		}
	}
	
	func initSpanDistance(light: Int) -> Void{
		if spanDistance != udpListener.getSpanDistance(forLight: light) {
			DispatchQueue.main.async {
				self.spanDistance = udpListener.getSpanDistance(forLight: light)
				//print("initMinDistance spanDistance:\(self.spanDistance) meters")
			}
		}
	}
	
	
	private func sendMin() -> Void {
		DispatchQueue.main.async {
			// send message to signal box to change the minDistance
			var buf: Data = "Contrl:0000".data(using: .utf8)!
			buf[7] = UInt8(udpListener.selectedLight) + 48  // make it ASCII
			buf[8] = minDistanceValue(value: self.minDistance)
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
	
	private func sendSpan() -> Void {
		DispatchQueue.main.async {
			// send message to signal box to change the minDistance
			var buf: Data = "Contrl:0000".data(using: .utf8)!
			buf[7] = UInt8(udpListener.selectedLight) + 48  // make it ASCII
			buf[9] = spanDistanceValue(value: self.spanDistance)
			buf[8] = 255 // indicate value not changed
			buf[10] = udpSender.checksum(data: buf)
			buf.append(0)
			//print("minDistance:\(buf[8])")
			//print("spanDistance:\(buf[9])")
			//print("checkSum:\(buf[10])")
			udpSender.connect(host: NWEndpoint.Host(udpListener.signalboxAddress),port: 44444)
			udpSender.send(buf)
		}

	}
	
	private func showSize(att: mySize) -> some View {
		att.showSize()
		return AnyView(Rectangle().fill(Color.clear))
		
	}
	
}


struct SlidersView_Previews: PreviewProvider {
    static var previews: some View {
		slidersView(setSize: mySize(), udpListener: UdpListener(), udpSender: UdpSender())
    }
}
