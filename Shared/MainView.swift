//
//  MainView.swift
//  WHRDisplay
//
//  Created by Paul Barnard on 11/02/2022.
//

import SwiftUI


struct MainView: View {
    @ObservedObject var udpListener: UdpListener
    @Binding var showDetail: Bool
    @ObservedObject var imageSize:  mySize

    var body: some View {
        ZStack (alignment: .topLeading) {
            noButtonMainView(redLight: udpListener.redLight, trainLight: udpListener.trainLight, imageSize: imageSize)
            buttonView(udpListener: udpListener, imageSize: imageSize, showDetail: $showDetail)
        }
    }
}

struct noButtonMainView: View {
	var redLight: [Bool]
	var trainLight: [Bool]
	@ObservedObject var imageSize: mySize
	var body: some View {
		ZStack (alignment: .topLeading) {
			backgroundView(imageSize: imageSize)
			greenLightView(redLight: redLight)
			redLightView(redLight: redLight)
			trainView(trainLight: trainLight)
		}
	}

}


struct backgroundView: View {
    @ObservedObject var imageSize: mySize
    
    var body: some View {
        Image("background")
            .resizable()
            .aspectRatio(contentMode: .fit)
            //.border(Color.blue)
            .background(rectReader())
    }
    
    
    private func rectReader() -> some View {
        return GeometryReader { (geometry) -> AnyView in
            let imageSize = geometry.size
            DispatchQueue.main.async {
                //print(">> \(imageSize)") // use image actual size in your calculations
                self.imageSize.mySize = imageSize
            }
            return AnyView(Rectangle().fill(Color.clear))
        }
    }
    
}


struct greenLightView: View {
    var redLight: [Bool]
    var body: some View {
        ZStack () {
            Image("Green0")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(redLight[0])
            Image("Green1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(redLight[1])
            Image("Green2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(redLight[2])
            Image("Green3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(redLight[3])
            Image("Green4")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(redLight[4])
            Image("Green5")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(redLight[5])
            Image("Green6")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(redLight[6])
            Image("Green7")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(redLight[7])
            Image("Green8")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(redLight[8])
        }
    }
}


struct redLightView: View {
    var redLight: [Bool]
    
    var body: some View {
        ZStack () {
            Image("Red0")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(!redLight[0])
            Image("Red1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(!redLight[1])
            Image("Red2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(!redLight[2])
            Image("Red3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(!redLight[3])
            Image("Red4")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(!redLight[4])
            Image("Red5")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(!redLight[5])
            Image("Red6")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(!redLight[6])
            Image("Red7")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(!redLight[7])
            Image("Red8")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(!redLight[8])
        }
    }
}

struct trainView: View {
    var trainLight: [Bool]
    
    var body: some View {
        ZStack () {
            Image("Train0")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(trainLight[0])
            Image("Train1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(trainLight[1])
            Image("Train2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(trainLight[2])
            Image("Train3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(trainLight[3])
            Image("Train4")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(trainLight[4])
            Image("Train5")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(trainLight[5])
            Image("Train6")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(trainLight[6])
            Image("Train7")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(trainLight[7])
            Image("Train8")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .isHidden(trainLight[8])
        }
    }
}

struct buttonView: View {
    @ObservedObject var udpListener: UdpListener
    @ObservedObject var imageSize: mySize
    @Binding var showDetail: Bool

    
    var body: some View {
        ZStack (){
            actionButton(udpListener: udpListener, sensor: 0)
                .offset(x: imageSize.mySize.width * 0.525, y: imageSize.mySize.height * 0.6)
                .buttonStyle(lightButton(imageSize: imageSize))
            
            actionButton(udpListener: udpListener, sensor: 1)
                .offset(x: imageSize.mySize.width * 0.76, y: imageSize.mySize.height * 0.36)
                .buttonStyle(lightButton(imageSize: imageSize))
            
            actionButton(udpListener: udpListener, sensor: 2)
                .offset(x: imageSize.mySize.width * 0.61, y: imageSize.mySize.height * 0.085)
                .buttonStyle(lightButton(imageSize: imageSize))
            
            actionButton(udpListener: udpListener, sensor: 3)
                .offset(x: imageSize.mySize.width * 0.400, y: imageSize.mySize.height * 0.593)
                .buttonStyle(lightButton(imageSize: imageSize))
            
            actionButton(udpListener: udpListener, sensor: 3)
                .offset(x: imageSize.mySize.width * 0.255, y: imageSize.mySize.height * 0.62)
                .buttonStyle(lightButton(imageSize: imageSize))
            
            actionButton(udpListener: udpListener, sensor: 4)
                .offset(x: imageSize.mySize.width * 0.083, y: imageSize.mySize.height * 0.565)
                .buttonStyle(lightButton(imageSize: imageSize))
            
            actionButton(udpListener: udpListener, sensor: 5)
                .offset(x: imageSize.mySize.width * 0.094, y: imageSize.mySize.height * 0.205)
                .buttonStyle(lightButton(imageSize: imageSize))
            
            actionButton(udpListener: udpListener, sensor: 6)
                .offset(x: imageSize.mySize.width * 0.50, y: imageSize.mySize.height * 0.000)
                .buttonStyle(lightButton(imageSize: imageSize))
            
            actionButton(udpListener: udpListener, sensor: 7)
                .offset(x: imageSize.mySize.width * 0.875, y: imageSize.mySize.height * 0.33)
                .buttonStyle(lightButton(imageSize: imageSize))
            
            actionButton(udpListener: udpListener, sensor: 8)
                .offset(x: imageSize.mySize.width * 0.795, y: imageSize.mySize.height * 0.84)
                .buttonStyle(lightButton(imageSize: imageSize))
            
        }
    }
    
    func actionButton(udpListener: UdpListener, sensor: Int) -> some View{
        
        Button(""){
            print("Light \(sensor) pressed")
            udpListener.selectedLight = sensor
            showDetail = true
        }
    }
}

struct lightButton: ButtonStyle {
    @ObservedObject var imageSize: mySize
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        
            .fixedSize()
            .frame(width: imageSize.mySize.width / 9, height: imageSize.mySize.height / 4)
            .background(Color(red: 0, green: 0, blue: 0, opacity: 0.0001))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(red: 0, green: 0, blue: 0.5, opacity: 0.0001))
            )
    }
}



extension View {
    
    /// Hide or show the view based on a boolean value.
    /// Example for visibility:
    ///     Text("Label")
    ///         .isHidden(true)
    /// Example for complete removal:
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
#if os(watchOS)
            MainView(udpListener: UdpListener(),
                     showDetail: .constant(false), imageSize: mySize())
                .previewDevice(PreviewDevice(rawValue: "AppleWatch Series 5 - 44mm"))
                .previewDisplayName("AppleWatch")
#elseif os(macOS)
            MainView(udpListener: UdpListener(),
                     showDetail: .constant(false), imageSize: mySize())
                .previewDevice(PreviewDevice(rawValue: "Any Mac"))
                .previewDisplayName("macOS")
#elseif os(iOS)
            MainView(udpListener: UdpListener(),
                     showDetail: .constant(false), imageSize: mySize())
                .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
                .previewDisplayName("iPad Air")
                .previewInterfaceOrientation(.landscapeLeft)
            MainView(udpListener: UdpListener(),
                     showDetail: .constant(false), imageSize: mySize())
                .previewDevice(PreviewDevice(rawValue: "iPad Air (4th Generation"))
                .previewDisplayName("iPad Air")
                .previewInterfaceOrientation(.portrait)
            
#endif
        }
    }
}
