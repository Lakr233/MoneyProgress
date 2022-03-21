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
        let calendar = Calendar.current
        let nowDate = Date()
        let todayStart = DateComponents(
            calendar: calendar,
            year: calendar.component(.year, from: nowDate),
            month: calendar.component(.month, from: nowDate),
            day: calendar.component(.day, from: nowDate),
            hour: calendar.component(.hour, from: workStartDate),
            minute: calendar.component(.minute, from: workStartDate),
            second: 0
        ).date
        guard let todayStart = todayStart else {
            statusItem.button?.title = NSLocalizedString("💰 data error", comment: "")
            return
        }

        let passedTimeInterval: TimeInterval = obtainPassedTimeInterval()
        let totalWorkTimeInterval: TimeInterval = obtainTotalWorkTimeInterval()
        var percent = passedTimeInterval / totalWorkTimeInterval
        if percent < 0 { percent = 0 }
        if percent > 1 { percent = 1 }
        let todayMake = Double(monthPaid / dayWorkOfMonth)
        let money = percent * todayMake

        if #available(macOS 12.0, *) {
            debugPrint("===========")
            debugPrint("today start at: ", todayStart.formatted())
            debugPrint("current timestamp: ", nowDate.formatted())
            debugPrint("seconds started: ", TimeInterval(passedTimeInterval).formatted())
            debugPrint("today will earn: ", todayMake)
            debugPrint("percent of today: ", percent)
            debugPrint("current made: ", money)
        }

        todayPercent = percent
        todayEarn = Int(todayMake)
        var title = ""

        if percent <= 0 {
            title = "Not working yet".localized
        } else if percent >= 1 {
            title = String(format: NSLocalizedString("💰 %.0f available", comment: ""), money)
        } else {
            if compactMode {
                title = String(format: NSLocalizedString("💰 %.2f yuan", comment: ""), money, currencyUnit)
            } else {
                title = String(format: NSLocalizedString("💰 You have earned %.2f %@ today", comment: ""), money, currencyUnit)
            }
        }
        statusItem.button?.title = title
    }

    private func obtainPassedTimeInterval() -> TimeInterval {
        /*
         如果有午休 四个时间点 划分为5个时间区域点
         if now <= workStartDate So passed < 0
         if workStartDate < now && now < noonBreakStartDate So passed = now - workStartDate
         if noonBreakStartDate <= now && now <= noonBreakEndDate So passed = noonBreakStartDate - workStartDate
         if noonBreakEndDate < now && now < workEndDate So passed = (now - noonBreakEndDate) + (noonBreakStartDate - workStartDate)
         if workEndDate <= now So passed = now - workStartDate
         */

        /*
         如果没有午休 两个时间点 划分为3个时间区域点
         if now < workStartDate So passed < 0
         if workStartDate < now && now < workEndDate So passed = now - workStartDate
         if workEndDate <= now So passed = now - workStartDate
         */
        let workStartDate = Date(timeIntervalSince1970: workStart)
        let workEndDate = Date(timeIntervalSince1970: workEnd)
        let noonBreakStartDate = Date(timeIntervalSince1970: noonBreakStartTimeStamp)
        let noonBreakEndDate = Date(timeIntervalSince1970: noonBreakEndTimeStamp)
        let nowDate = Date()

        var passedTimeInterval: TimeInterval = 0.0
        let timeIntervalFromWorkStartDate: TimeInterval = nowDate.timeIntervalSince(workStartDate)
        let beforeWorkStartDateFlag: Bool = timeIntervalFromWorkStartDate <= 0
        let betweenWorkStartDateAndNoonBreakStartDate: Bool = timeIntervalFromWorkStartDate > 0 && nowDate.timeIntervalSince(noonBreakStartDate) < 0
        let betweenNoonBreakStartDateAndNoonBreakEndDate: Bool = nowDate.timeIntervalSince(noonBreakStartDate) >= 0 && nowDate.timeIntervalSince(noonBreakEndDate) <= 0
        let betweenNoonBreakEndDateAndWorkEndDate: Bool = nowDate.timeIntervalSince(noonBreakEndDate) > 0 && nowDate.timeIntervalSince(workEndDate) < 0
        let betweenWorkStartDateAndWorkEndDate: Bool = timeIntervalFromWorkStartDate > 0 && nowDate.timeIntervalSince(workEndDate) < 0

        if isHaveNoonBreak {
            if beforeWorkStartDateFlag {
                passedTimeInterval = 0.0
            } else if betweenWorkStartDateAndNoonBreakStartDate {
                passedTimeInterval = timeIntervalFromWorkStartDate
            } else if betweenNoonBreakStartDateAndNoonBreakEndDate {
                passedTimeInterval = noonBreakStartDate.timeIntervalSince(workStartDate)
            } else if betweenNoonBreakEndDateAndWorkEndDate {
                passedTimeInterval = nowDate.timeIntervalSince(noonBreakEndDate) + noonBreakStartDate.timeIntervalSince(workStartDate)
            } else {
                passedTimeInterval = timeIntervalFromWorkStartDate
            }
        } else {
            if beforeWorkStartDateFlag {
                passedTimeInterval = 0.0
            } else if betweenWorkStartDateAndWorkEndDate {
                passedTimeInterval = timeIntervalFromWorkStartDate
            } else {
                passedTimeInterval = timeIntervalFromWorkStartDate
            }
        }
        return passedTimeInterval
    }

    private func obtainTotalWorkTimeInterval() -> TimeInterval {
        let workStartDate = Date(timeIntervalSince1970: workStart)
        let workEndDate = Date(timeIntervalSince1970: workEnd)
        let noonBreakStartDate = Date(timeIntervalSince1970: noonBreakStartTimeStamp)
        let noonBreakEndDate = Date(timeIntervalSince1970: noonBreakEndTimeStamp)
        var totalWorkTimeInterval: TimeInterval = 1.0
        if isHaveNoonBreak {
            // interval = (workEndDate - noonBreakEndDate) + (noonBreakStartDate - workStartDate)
            totalWorkTimeInterval = workEndDate.timeIntervalSince(noonBreakEndDate) + noonBreakStartDate.timeIntervalSince(workStartDate)
        } else {
            // interval = workEndDate - workStartDate
            totalWorkTimeInterval = workEndDate.timeIntervalSince(workStartDate)
        }
        return totalWorkTimeInterval
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
