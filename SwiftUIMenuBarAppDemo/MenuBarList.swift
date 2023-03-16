//
//  MenuBarList.swift
//  MenuBarGauge
//
//  Created by Janne Lehikoinen on 16.3.2023.
//

import SwiftUI

struct MenuBarList: View {
    
    var body: some View {
        
        Text("Hello FinMacAdmin!")
            .font(.largeTitle)
            .bold()
            .foregroundColor(.indigo)
        Divider()
        Button("Open Terminal") {
            open("/System/Applications/Utilities/Terminal.app")
        }
        Divider()
        Button("Quit") {
            quitApp()
        }
    }
    
    private func open(_ path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

struct MenuBarList_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarList()
            .frame(minHeight: 100)
    }
}
