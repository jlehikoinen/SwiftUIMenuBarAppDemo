//
//  SwiftUIMenuBarAppDemoApp.swift
//  SwiftUIMenuBarAppDemo
//
//  Created by Janne Lehikoinen on 16.3.2023.
//

/* TODO:
 
 - https://developer.apple.com/forums/thread/732431
 - SSID information is not available unless Location Services is enabled and the user has authorized the calling app to use location services.
 
 */

import SwiftUI

@main
struct SwiftUIMenuBarAppDemoApp: App {
    var body: some Scene {
        MenuBarExtra("Wi-Fi Info", systemImage: "wifi.square") {
            // MenuBarList()
//            MenuBarWindow()
            MoreGaugesView()
        }
        // .menuBarExtraStyle(.menu)
        .menuBarExtraStyle(.window)
    }
}
