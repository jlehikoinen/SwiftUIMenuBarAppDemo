//
//  MoreGaugesView.swift
//  MenuBarGauge
//
//  Created by Janne Lehikoinen on 15.3.2023.
//

import CoreWLAN
import SwiftUI

struct MoreGaugesView: View {
    
    // MARK: Variables
    
    // Wi-Fi properties
    @State private var rssi: WiFiProperty
    @State private var noise: WiFiProperty
    @State private var snr: WiFiProperty
    
    // Other UI components
    @State private var ssidName: String = ""
    @State private var sfSymbolvalue: Double = 0.0

    // MARK: Init
    
    init() {
        self.rssi = WiFiProperty(
            type: .rssi, unit: .decibelMilliwatts,
            minValue: SignalQuality.minRSSIValue, maxValue: SignalQuality.maxRSSIValue,
            currentValue: SignalQuality.minRSSIValue, ranges: SignalQuality.rssiRange
        )
        self.noise = WiFiProperty(
            type: .noise, unit: .decibelMilliwatts,
            minValue: SignalQuality.minNoiseValue, maxValue: SignalQuality.maxNoiseValue,
            currentValue: SignalQuality.minNoiseValue, ranges: SignalQuality.noiseRange
        )
        self.snr = WiFiProperty(
            type: .snr, unit: .decibel,
            minValue: SignalQuality.minSNRValue, maxValue: SignalQuality.maxSNRValue,
            currentValue: SignalQuality.minSNRValue, ranges: SignalQuality.snrRange
        )
    }
    
    // MARK: Body
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            header
            Divider()
            infoTexts
            if sfSymbolvalue > 0.0 {
                Divider()
                gauges
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
            Text(rssi.signalDescription)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(rssi.accentColor)
            Text("Noise level: ")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.primary) +
            Text(noise.signalDescription)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(noise.accentColor)
            Text("SNR value: ")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.primary) +
            Text(snr.signalDescription)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(snr.accentColor)
        }
    }
    
    var gauges: some View {
        
        HStack(spacing: 30) {
            GaugeView(wifiProperty: $rssi)
            GaugeView(wifiProperty: $noise)
            GaugeView(wifiProperty: $snr)
        }
        .padding()
    }
    
    // MARK: Methods
    
    private func pollSSIDName() {
        
        ssidName = CWWiFiClient.shared().interface(withName: nil)?.ssid() ?? ""
    }
    
    private func pollWiFiClientRepeatedly(intervalInSeconds: Double) {
    
        Task {
            while true {
                rssi.currentValue = Double(CWWiFiClient.shared().interface()?.rssiValue() ?? 0)
                noise.currentValue = Double(CWWiFiClient.shared().interface()?.noiseMeasurement() ?? 0)
                snr.currentValue = rssi.currentValue - noise.currentValue
                
                // Use RSSI signal strength for Wi-Fi SF Symbol
                wifiSymbolValue(using: rssi.currentValue)
                
                NSLog("RSSI: \(rssi.valueAndUnit)")
                NSLog("Noise: \(noise.valueAndUnit)")
                NSLog("SNR: \(snr.valueAndUnit)")
                
                let delay = UInt64(intervalInSeconds * Double(NSEC_PER_SEC))
                try await Task.sleep(nanoseconds: delay)
            }
        }
    }
    
    private func wifiSymbolValue(using value: Double) {
        
        switch value {
        case SignalQuality.rssiRange[.excellent]!:
            sfSymbolvalue = 1.0
        case SignalQuality.rssiRange[.good]!:
            sfSymbolvalue = 1.0
        case SignalQuality.rssiRange[.fair]!:
            sfSymbolvalue = 0.67
        case SignalQuality.rssiRange[.poor]!:
            sfSymbolvalue = 0.33
        case SignalQuality.rssiRange[.noSignal]!:
            sfSymbolvalue = 0.0
        default:
            sfSymbolvalue = 0.0
        }
    }
}

// MARK: Generic gauge view

struct GaugeView: View {
    
    @Binding var wifiProperty: WiFiProperty
    
    var body: some View {
        
        VStack {
            Text(wifiProperty.type.rawValue)
                .font(.system(size: 12, design: .monospaced))
            Gauge(value: wifiProperty.currentValue, in: wifiProperty.minValue...wifiProperty.maxValue) {
            } currentValueLabel: {
                Text(wifiProperty.valueAndUnit)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.primary)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(wifiProperty.accentColor)
        }
    }
}

// MARK: Models

struct WiFiProperty {
    
    let type: WiFiPropertyType
    let unit: Unit
    let minValue: Double
    let maxValue: Double
    var currentValue: Double {
        didSet { updateDescriptionAndColor() }
    }
    
    let ranges: [SignalQuality: ClosedRange<Double>]
    var signalDescription: String
    var accentColor: Color
    
    // MARK: Init
    
    init(type: WiFiPropertyType, unit: Unit,
         minValue: Double, maxValue: Double,
         currentValue: Double, ranges: [SignalQuality: ClosedRange<Double>]) {
        
        self.type = type
        self.unit = unit
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentValue = currentValue
        self.ranges = ranges
        self.signalDescription = "No signal"
        self.accentColor = .secondary
    }
    
    // MARK: Computed vars
    
    var valueAndUnit: String {
        "\(Int(currentValue)) \(unit.rawValue)"
    }
    
    // MARK: Private methods
    
    private mutating func updateDescriptionAndColor() {
        
        switch currentValue {
        case ranges[.excellent]!:
            self.signalDescription = "Excellent"
            self.accentColor = .green
        case ranges[.good]!:
            self.signalDescription = "Good"
            self.accentColor = .yellow
        case ranges[.fair]!:
            self.signalDescription = "Fair"
            self.accentColor = .orange
        case ranges[.poor]!:
            self.signalDescription = "Poor"
            self.accentColor = .red
        case ranges[.noSignal]!:
            self.signalDescription = "No signal"
            self.accentColor = .secondary
        default:
            self.signalDescription = "No signal"
            self.accentColor = .secondary
        }
    }
}

// MARK: Enums

enum WiFiPropertyType: String {
    
    case rssi = "RSSI"
    case noise = "Noise"
    case snr = "SNR"
}

enum Unit: String {
    
    case decibelMilliwatts = "dBm"
    case decibel = "dB"
}

enum SignalQuality: String {

    case excellent
    case good
    case fair
    case poor
    case noSignal
    
    // RSSI
    static let minRSSIValue: Double = -100.0
    static let maxRSSIValue: Double = -20.0
    
    static let rssiRange: [SignalQuality: ClosedRange<Double>] = [
        .excellent: -50.0 ... -20.0,
        .good:      -70.0 ... -50.0,
        .fair:      -80.0 ... -70.0,
        .poor:      -99.9 ... -80.0,
        .noSignal:  -120.0 ... -99.9
    ]
    
    // Noise
    static let minNoiseValue: Double = -100.0
    static let maxNoiseValue: Double = 0.0
    
    // Note! These ranges are fabricated, hence they are inaccurate
    static let noiseRange: [SignalQuality: ClosedRange<Double>] = [
        .excellent: -100.0 ... -80.0,
        .good:      -80.0 ... -60.0,
        .fair:      -60.0 ... -50.0,
        .poor:      -50.0 ... -30.0,
        .noSignal:  -30.0 ... 0.0
    ]
    
    // SNR
    static let minSNRValue: Double = 0.0
    static let maxSNRValue: Double = 100.0
    
    // Note! These ranges are fabricated, hence they are inaccurate
    static let snrRange: [SignalQuality: ClosedRange<Double>] = [
        .excellent: 30.0...80.0,
        .good:      25.0...30.0,
        .fair:      20.0...25.0,
        .poor:      10.0...20.0,
        .noSignal:  0.0...10.0
    ]
}

// MARK: Preview

struct MoreGaugesView_Previews: PreviewProvider {
    static var previews: some View {
        MoreGaugesView()
            .frame(minHeight: 400)
    }
}
