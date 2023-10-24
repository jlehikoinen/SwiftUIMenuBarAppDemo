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
import CoreLocation

@main
struct SwiftUIMenuBarAppDemoApp: App {
    var body: some Scene {
        MenuBarExtra("Wi-Fi Info", systemImage: "wifi.square") {
//            MenuBarList()
//            MenuBarWindow()
            MoreGaugesView()
        }
        // .menuBarExtraStyle(.menu)
        .menuBarExtraStyle(.window)
    }
}

// Minimum location services implementation

class LocationDataManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    public static let shared = LocationDataManager()
    
    private override init() {
        print("Init LocationDataManager")
        super.init()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location changed")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authorization changed")
    }
}
