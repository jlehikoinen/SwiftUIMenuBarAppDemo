# SwiftUI Menu Bar App Demo

_WIP_

*SwiftUI Menu Bar App* demo for FinMacAdmin meetup 25.05.2023.

![Demo app](Screenshots/WindowExample.png)

## Requirements

* macOS Ventura
* Xcode version: min. 14.1

## Setup

Download or `git clone` this repo.

## List style menu bar app example

Edit `SwiftUIMenuBarAppDemoApp.swift`:

```swift
MenuBarExtra("Wi-Fi Info", systemImage: "wifi.square") {
    MenuBarList()
    // MenuBarWindow()
    // MoreGaugesView()
}
.menuBarExtraStyle(.menu)
// .menuBarExtraStyle(.window)
```

## Window style menu bar app example

Edit `SwiftUIMenuBarAppDemoApp.swift`:

```swift
MenuBarExtra("Wi-Fi Info", systemImage: "wifi.square") {
    // MenuBarList()
    MenuBarWindow()
    // MoreGaugesView()
}
// .menuBarExtraStyle(.menu)
.menuBarExtraStyle(.window)
```

## Bonus example with more gauges

Edit `SwiftUIMenuBarAppDemoApp.swift`:

```swift
MenuBarExtra("Wi-Fi Info", systemImage: "wifi.square") {
    // MenuBarList()
    // MenuBarWindow()
    MoreGaugesView()
}
// .menuBarExtraStyle(.menu)
.menuBarExtraStyle(.window)
```

### Key Points

1. `MenuBarExtra`
2. `import CoreWLAN`
3. `Gauge`

## Links

- [Apple Developer Documentation - MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra)
- [Apple Developer Documentation - CWWiFiClient](https://developer.apple.com/documentation/corewlan/cwwificlient)
- [Apple Developer Documentation - Gauge](https://developer.apple.com/documentation/swiftui/gauge)
