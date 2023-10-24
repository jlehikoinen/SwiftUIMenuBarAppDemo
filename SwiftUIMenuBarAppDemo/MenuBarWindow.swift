//
//  MenuBarWindow.swift
//  MenuBarGauge
//
//  Created by Janne Lehikoinen on 14.3.2023.
//

import CoreWLAN
import SwiftUI

struct MenuBarWindow: View {
    
    // MARK: Variables
    
    // Gauge
    @State private var currentRSSIValue: Double = -100.0
    private var minRSSIValue: Double = -100.0
    private var maxRSSIValue: Double = -20.0
    
    // Other UI components
    @State private var sfSymbolvalue: Double = 0.0
    @State private var ssidName: String = ""
    @State private var rssiDescription: String = ""
    @State private var rssiColor: Color = .secondary
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            Divider()
            infoTexts
            if sfSymbolvalue > 0.0 {
                Divider()
                rssiGauge
            }
        }
        .padding()
        .onAppear {
            LocationDataManager.shared.locationManager.requestAlwaysAuthorization()
            pollSSIDName()
            pollWiFiClientRepeatedly(intervalInSeconds: 1.0)
        }
    }
    
    // MARK: Subviews
    
    var header: some View {
        
        HStack {
            Text("Wi-Fi Info")
                .font(.system(size: 20, design: .monospaced))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "wifi", variableValue: sfSymbolvalue)
                .font(.title)
                .foregroundColor(sfSymbolvalue == 0.0 ? .secondary : .blue)
        }
    }
    
    var infoTexts: some View {
        
        Group {
            Text("SSID: \(ssidName)")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.primary)
            Text("Signal strength: ")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.primary) +
            Text(rssiDescription)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(rssiColor)
        }
    }
    
    var rssiGauge: some View {
        
        Gauge(value: currentRSSIValue, in: minRSSIValue...maxRSSIValue) {
            Text("RSSI")
                .font(.system(size: 14, design: .monospaced))
                .help("Received Signal Strength Indicator")
        } currentValueLabel: {
            Text("\(Int(currentRSSIValue)) dBm")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.primary)
        } minimumValueLabel: {
            Text("\(Int(minRSSIValue))")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
        } maximumValueLabel: {
            Text("\(Int(maxRSSIValue))")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .gaugeStyle(.linearCapacity)
        .tint(rssiColor)
    }
    
    // MARK: Methods
    
    private func pollSSIDName() {
        
        ssidName = CWWiFiClient.shared().interface(withName: nil)?.ssid() ?? ""
    }
    
    private func pollWiFiClientRepeatedly(intervalInSeconds: Double) {
    
        Task {
            while true {
                currentRSSIValue = Double(CWWiFiClient.shared().interface()?.rssiValue() ?? 0)
                NSLog("RSSI: \(currentRSSIValue) dBm")
                updateRSSIUIComponents(value: currentRSSIValue)
                
                let delay = UInt64(intervalInSeconds * Double(NSEC_PER_SEC))
                try await Task.sleep(nanoseconds: delay)
            }
        }
    }
    
    private func updateRSSIUIComponents(value: Double) {
        
        switch value {
        case -50.0 ... maxRSSIValue:
            sfSymbolvalue = 1.0
            rssiDescription = "Excellent"
            rssiColor = .green
        case -70.0 ... -50.0:
            sfSymbolvalue = 1.0
            rssiDescription = "Good"
            rssiColor = .yellow
        case -80.0 ... -70.0:
            sfSymbolvalue = 0.67
            rssiDescription = "Fair"
            rssiColor = .orange
        case -99.9 ... -80.0:
            sfSymbolvalue = 0.33
            rssiDescription = "Poor"
            rssiColor = .red
        default:
            sfSymbolvalue = 0.0
            rssiDescription = "No signal"
            rssiColor = .secondary
        }
    }
}

// MARK: Preview

struct MenuBarWindow_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarWindow()
            .frame(minHeight: 250)
    }
}
