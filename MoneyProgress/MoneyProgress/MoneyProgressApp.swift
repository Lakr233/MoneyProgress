//
//  MoneyProgressApp.swift
//  MoneyProgress
//
//  Created by Lakr Aream on 2022/3/14.
//

import SwiftUI

@main
struct MoneyProgressApp: App {
    init() {
        let timer = Timer(timeInterval: 1, repeats: true) { _ in
            checkWindow()
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    var body: some Scene {
        WindowGroup {
            ContentView().onAppear { let _ = Menubar.shared }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

private func checkWindow() {
    let windows = NSApp.windows
        .filter { window in
            guard let readClass = NSClassFromString("NSStatusBarWindow") else {
                return true
            }
            return !window.isKind(of: readClass.self)
        }
        .filter(\.isVisible)
    if windows.isEmpty, Menubar.shared.menubarRunning {
        NSApp.setActivationPolicy(.accessory)
    } else {
        NSApp.setActivationPolicy(.regular)
    }
}
