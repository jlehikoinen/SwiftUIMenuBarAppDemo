//
//  SwiftUIMenuBarAppDemoApp.swift
//  SwiftUIMenuBarAppDemo
//
//  Created by Janne Lehikoinen on 16.3.2023.
//

import SwiftUI

@main
struct SwiftUIMenuBarAppDemoApp: App {
    var body: some Scene {
        MenuBarExtra("Wi-Fi Info", systemImage: "wifi.square") {
            // MenuBarList()
            // MenuBarWindow()
            MoreGaugesView()
        }
        // .menuBarExtraStyle(.menu)
        .menuBarExtraStyle(.window)
    }
}
