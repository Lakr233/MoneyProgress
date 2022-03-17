//
//  Menubar.swift
//  MoneyProgress
//
//  Created by Lakr Aream on 2022/3/15.
//

import AppKit
import SwiftUI

class Menubar: ObservableObject {
    static let shared = Menubar()

    @AppStorage("wiki.qaq.workStart")
    var workStart: Double = 0

    @AppStorage("wiki.qaq.workEnd")
    var workEnd: Double = 0

    @AppStorage("wiki.qaq.monthPaid")
    var monthPaid: Int = 20000

    @AppStorage("wiki.qaq.dayWorkOfMonth")
    var dayWorkOfMonth: Int = 20

    @AppStorage("wiki.qaq.isHaveNoonBreak")
    var isHaveNoonBreak: Bool = false

    @AppStorage("wiki.qaq.noonBreakStartTimeStamp")
    var noonBreakStartTimeStamp: Double = 0
    @AppStorage("wiki.qaq.noonBreakEndTimeStamp")
    var noonBreakEndTimeStamp: Double = 0
    
    @AppStorage("wiki.qaq.currencyUnit")
    var currencyUnit: String = "RMB"

    @AppStorage("wiki.qaq.compactMode")
    var compactMode: Bool = false

    @Published var menubarRunning = false
    @Published var todayPercent: Double = 0
    @Published var todayEarn: Int = 0

    var popover: NSPopover
    var statusItem: NSStatusItem?
    var eventMonitor: EventMonitor?

    let timer: Timer!

    private init() {
        let buildPopover = NSPopover()
        popover = buildPopover
        let view = MenubarView()
        buildPopover.contentViewController = NSHostingController(rootView: view)
        timer = Timer(timeInterval: 0.25, repeats: true) { _ in
            Menubar.shared.updateButtonText()
        }
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: mouseEventHandler)
        RunLoop.current.add(timer, forMode: .common)
    }

    func run() {
        assert(Thread.isMainThread)
        guard !menubarRunning else {
            return
        }
        debugPrint(#function)
        popover.close()
        let statusItem = NSStatusBar
            .system
            .statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover(sender:))
        if let origFont = statusItem.button?.font {
            statusItem.button?.font = .monospacedSystemFont(ofSize: origFont.pointSize, weight: .regular)
        }
        self.statusItem = statusItem
        menubarRunning = true
        updateButtonText()
    }

    func stop() {
        assert(Thread.isMainThread)
        guard menubarRunning else {
            return
        }
        debugPrint(#function)
        popover.close()
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
        menubarRunning = false
    }

    func updateButtonText() {
        guard let statusItem = statusItem else {
            return
        }

        let workStartDate = Date(timeIntervalSince1970: workStart)
        let workEndDate = Date(timeIntervalSince1970: workEnd)
        let noonBreakStartDate = Date(timeIntervalSince1970: noonBreakStartTimeStamp)
        let noonBreakEndDate = Date(timeIntervalSince1970: noonBreakEndTimeStamp)

        var totalWorkTimeInterval: TimeInterval = 1
        if isHaveNoonBreak {
            // interval = (workEndDate - noonBreakEndDate) + (noonBreakStartDate - workStartDate)
            totalWorkTimeInterval = workEndDate.timeIntervalSince(noonBreakEndDate) + noonBreakStartDate.timeIntervalSince(workStartDate)
        } else {
            // interval = workEndDate - workStartDate
            totalWorkTimeInterval = workEndDate.timeIntervalSince(workStartDate)
        }

        if totalWorkTimeInterval <= 0 {
            statusItem.button?.title = "💰 数据错误"
            return
        }
        let calendar = Calendar.current

        let now = Date()
        let todayStart = DateComponents(
            calendar: calendar,
            year: calendar.component(.year, from: now),
            month: calendar.component(.month, from: now),
            day: calendar.component(.day, from: now),
            hour: calendar.component(.hour, from: workStartDate),
            minute: calendar.component(.minute, from: workStartDate),
            second: 0
        ).date

        guard let todayStart = todayStart else {
            statusItem.button?.title = "💰 数据错误"
            return
        }

        var passed = 1.0
        if isHaveNoonBreak {
            // interval = (now - noonBreakEndDate) + (noonBreakStartDate - workStartDate)
            passed = now.timeIntervalSince(noonBreakEndDate) + noonBreakStartDate.timeIntervalSince(workStartDate)
        } else {
            // interval = workEndDate - workStartDate
            passed = now.timeIntervalSince(workStartDate)
        }
        var percent = passed / totalWorkTimeInterval
        if percent < 0 { percent = 0 }
        if percent > 1 { percent = 1 }
        let todayMake = Double(monthPaid / dayWorkOfMonth)
        let money = percent * todayMake

        if #available(macOS 12.0, *) {
            debugPrint("===========")
            debugPrint("today start at: ", todayStart.formatted())
            debugPrint("current timestamp: ", now.formatted())
            debugPrint("seconds started: ", TimeInterval(passed).formatted())
            debugPrint("today will earn: ", todayMake)
            debugPrint("percent of today: ", percent)
            debugPrint("current made: ", money)
        }

        todayPercent = percent
        todayEarn = Int(todayMake)
        var title = ""

        if percent <= 0 {
            title = "💰 暂未开工"
        } else if percent >= 1 {
            title = String(format: compactMode ? "💰 %.0f 到手" : "💰 下班啦，今日 %.0f 到手", money)
        } else {
            title = String(format: compactMode ? "💰 %.4f 元" : "💰 您今日已挣 %.4f %@", money, currencyUnit)
        }
        statusItem.button?.title = title
    }

    func reload() {
        debugPrint("work start \(workStart)")
        debugPrint("work end \(workEnd)")
        debugPrint("month paid \(monthPaid)")
        debugPrint("work \(dayWorkOfMonth) a month")
    }

    func showPopover(_: AnyObject) {
        if let statusBarButton = statusItem?.button {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            eventMonitor?.start()
        }
    }

    func hidePopover(_ sender: AnyObject) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }

    func mouseEventHandler(_ event: NSEvent?) {
        if popover.isShown, let event = event {
            hidePopover(event)
        }
    }

    @objc
    func togglePopover(sender: AnyObject) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}

extension Menubar {
    class EventMonitor {
        private var monitor: Any?
        private let mask: NSEvent.EventTypeMask
        private let handler: (NSEvent?) -> Void

        public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
            self.mask = mask
            self.handler = handler
        }

        deinit {
            stop()
        }

        public func start() {
            monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as! NSObject
        }

        public func stop() {
            if monitor != nil {
                NSEvent.removeMonitor(monitor!)
                monitor = nil
            }
        }
    }
}
