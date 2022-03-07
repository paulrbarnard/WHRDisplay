//
//  mySize.swift
//  WHRDisplay
//
//  Created by Paul Barnard on 23/02/2022.
//

import SwiftUI
import Foundation

class mySize: ObservableObject {
    @Published var mySize = CGSize()
    
    func showSize() -> Void {
        DispatchQueue.main.async {
            print("mySize: width\(self.mySize.width)  height\(self.mySize.width)")
        }
    }

    init(width: CGFloat?=368.0, height: CGFloat?=448.0){
        mySize.width = width ?? 0.0
        mySize.height = height ?? 0.0
    }
    
}

