//
//  ContentView.swift
//  MoneyProgress
//
//  Created by Lakr Aream on 2022/3/14.
//

import AppKit
import Colorful
import SwiftUI

enum AlertType {
    case moneyCountInvalid
    case workDayInvalid
    case timeInvalid
}

struct ContentView: View {
    // store timestamp at 1970.1.1
    // we are using the time components only

    @AppStorage("wiki.qaq.workStart")
    var __workStart: Double = 0
    @AppStorage("wiki.qaq.workEnd")
    var __workEnd: Double = 0

    @AppStorage("wiki.qaq.noonBreakStartTimeStamp")
    var __noonBreakStartTimeStamp: Double = 0
    @AppStorage("wiki.qaq.noonBreakEndTimeStamp")
    var __noonBreakEndTimeStamp: Double = 0

    @AppStorage("wiki.qaq.monthPaid")
    var __monthPaid: Int = 3000

    @AppStorage("wiki.qaq.dayWorkOfMonth")
    var __dayWorkOfMonth: Int = 20

    @AppStorage("wiki.qaq.isHaveNoonBreak")
    var __isHaveNoonBreak: Bool = false

    @AppStorage("wiki.qaq.compactMode")
    var compactMode: Bool = false

    @AppStorage("wiki.qaq.currencyUnit")
    var __currencyUnit: String = "CNY"

    @State var workStartTimeStamp: Double = 0
    @State var workEndTimeStamp: Double = 0

    @State private var workStartDate: Date = .init()
    @State private var workEndDate: Date = .init()

    @State private var noonBreakStartDate: Date = .init()
    @State private var noonBreakEndDate: Date = .init()

    @State var monthPaid: Int = 0
    @State var sliderWidth: CGFloat = 0
    @State var dayWorkOfMonth: Int = 20

    @StateObject var menubar = Menubar.shared

    @State private var isHaveNoonBreak: Bool = false
    @State private var isShowAlert = false
    @State private var isMoneyInvalid = false
    @State private var isWorkDayInvalid = false

    @State private var currencyUnit = "CNY"

    @State private var openCoinTypePicker = false

    @State private var alertType: AlertType = .moneyCountInvalid

    var body: some View {
        ZStack {
            ColorfulView(
                colors: [Color.accentColor],
                colorCount: 4
            )
            .opacity(0.1)
            appIntro
                .padding()
        }
        .animation(.interactiveSpring(), value: isHaveNoonBreak)
        .overlay(
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Spacer()
                    let text1 = String(format: "So, let's say you work days in a month".localized, dayWorkOfMonth)
                    Text(text1)
                    // "You can earn how much a day!"
                    let text2 = String(format: "You can earn how much a day!".localized, formattedCoinPerDay, currencyUnit)
                    Text(text2)
                    let text3 = String(format: "Your effective working hours per day are %@ hours!".localized, workHours)
                    Text(text3)
                    let text4 = String(format: "You can earn %@ %@ in one second".localized, formattedCoinPerSecond, currencyUnit)
                    Text(text4)
                    let text5 = String(format: "You can earn %@ %@ in one minute".localized, formattedCoinPerMinute, currencyUnit)
                    Text(text5)
                    let text6 = String(format: "You can earn %@ %@ in one hour".localized, formattedCoinPerHour, currencyUnit)
                    Text(text6)
                }
                .font(.system(.caption, design: .rounded))
                .lineLimit(1)
                Spacer()
                VStack {
                    Spacer()
                    HStack {
                        Toggle(isOn: $compactMode) {
                            Text("compact mode")
                        }
                        Button {
                            fillInitialData()
                        } label: {
                            Label("Restore Default (9 to 6 CNY)", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
            }
            .padding()
        )
        .onAppear {
            if __workStart == 0 || __workEnd == 0 {
                fillInitialData()
            } else {
                workStartDate = Date(timeIntervalSince1970: __workStart).movedToTodayAndKeepHMS
                workEndDate = Date(timeIntervalSince1970: __workEnd).movedToTodayAndKeepHMS
                workStartTimeStamp = workStartDate.timeIntervalSince1970
                workEndTimeStamp = workEndDate.timeIntervalSince1970
                noonBreakStartDate = Date(timeIntervalSince1970: __noonBreakStartTimeStamp).movedToTodayAndKeepHMS
                noonBreakEndDate = Date(timeIntervalSince1970: __noonBreakEndTimeStamp).movedToTodayAndKeepHMS
                monthPaid = __monthPaid
                isHaveNoonBreak = __isHaveNoonBreak
                currencyUnit = __currencyUnit
                dayWorkOfMonth = __dayWorkOfMonth
            }
        }
        .background(
            dataListener
        )
    }

    var dataListener: some View {
        Group {}
            .onChange(of: workStartDate) { newValue in
                __workStart = newValue
                    .movedToTodayAndKeepHMS
                    .timeIntervalSince1970
                Menubar.shared.reload()
            }
            .onChange(of: workEndDate) { newValue in
                __workEnd = newValue
                    .movedToTodayAndKeepHMS
                    .timeIntervalSince1970
                Menubar.shared.reload()
            }
            .onChange(of: noonBreakStartDate) { newValue in
                __noonBreakStartTimeStamp = newValue
                    .movedToTodayAndKeepHMS
                    .timeIntervalSince1970
                Menubar.shared.reload()
            }
            .onChange(of: noonBreakEndDate) { newValue in
                __noonBreakEndTimeStamp = newValue
                    .movedToTodayAndKeepHMS
                    .timeIntervalSince1970
                Menubar.shared.reload()
            }
            .onChange(of: monthPaid) { newValue in
                if newValue < 0 {
                    self.isMoneyInvalid = true
                } else {
                    // write data if valid
                    __monthPaid = newValue
                    self.isMoneyInvalid = false
                }
                Menubar.shared.reload()
            }
            .onChange(of: dayWorkOfMonth) { newValue in
                if newValue <= 0 || newValue >= 32 {
                    self.isWorkDayInvalid = true
                } else {
                    // write data if valid
                    __dayWorkOfMonth = newValue
                    self.isWorkDayInvalid = false
                }
                Menubar.shared.reload()
            }
            .onChange(of: isHaveNoonBreak) { newValue in
                __isHaveNoonBreak = newValue
                Menubar.shared.reload()
            }
            .onChange(of: currencyUnit) { newValue in
                __currencyUnit = newValue
                Menubar.shared.reload()
            }
    }

    var coinPerSecond: Double {
        var timeInterval: TimeInterval = 1
        if isHaveNoonBreak {
            // interval = (workEndDate - noonBreakEndDate) + (noonBreakStartDate - workStartDate)
            timeInterval = workEndDate.timeIntervalSince(noonBreakEndDate) + noonBreakStartDate.timeIntervalSince(workStartDate)
        } else {
            // interval = workEndDate - workStartDate
            timeInterval = workEndDate.timeIntervalSince(workStartDate)
        }
        debugPrint(timeInterval)
        return Double(monthPaid)
            / Double(dayWorkOfMonth) /* days */
            / timeInterval /* second each day */
    }

    var workHours: String {
        var timeInterval: TimeInterval = 0
        if isHaveNoonBreak {
            timeInterval = workEndDate.timeIntervalSince(noonBreakEndDate) + noonBreakStartDate.timeIntervalSince(workStartDate)
        } else {
            timeInterval = workEndDate.timeIntervalSince(workStartDate)
        }
        let hours = timeInterval / 3600.0
        return String(format: "%.1f", hours)
    }

    var formattedCoinPerSecond: String {
        String(format: "%.4f", coinPerSecond)
    }

    var formattedCoinPerMinute: String {
        String(format: "%.4f", coinPerSecond * 60)
    }

    var formattedCoinPerHour: String {
        String(format: "%.4f", coinPerSecond * 60 * 60)
    }

    var coinPerDay: Double {
        Double(monthPaid) / Double(dayWorkOfMonth)
    }

    var formattedCoinPerDay: String {
        String(format: "%.2f", coinPerDay)
    }

    var appIntro: some View {
        VStack(alignment: .center, spacing: 15) {
            Image("avatar")
                .resizable()
                .antialiased(true)
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
            VStack(spacing: 6) {
                Text("money progress".localized)
                    .font(.system(.title2, design: .rounded))
                    .bold()
                Text("The progress bar for earning money must be an IOU from my boss.".localized)
                    .font(.system(.headline, design: .rounded))
            }
            progressBar
                .frame(maxWidth: 400)
            HStack {
                Text("monthly salary".localized)
                TextField("This piece is long enough".localized, text: Binding<String>(get: {
                    String(monthPaid)
                }, set: { str in
                    monthPaid = Int(str) ?? 0
                }))
                .frame(width: 80)
                Text(currencyUnit)
                    .underline()
                    .onTapGesture { openCoinTypePicker = true }
                    .sheet(isPresented: $openCoinTypePicker, onDismiss: nil, content: {
                        CoinTypePicker {
                            currencyUnit
                        } onComplete: { setUnit in
                            currencyUnit = setUnit
                        }
                    })
                Text("one month's work".localized)
                TextField("days", text: Binding<String>(get: {
                    String(dayWorkOfMonth)
                }, set: { str in
                    dayWorkOfMonth = Int(str) ?? 0
                }))
                .frame(width: 40)
                Text("days".localized)
            }
            .font(.system(.subheadline, design: .rounded))
            .frame(maxWidth: 400)
            Button {
                if !checkInputIfValid() {
                    return
                }

                if menubar.menubarRunning {
                    menubar.stop()
                } else {
                    menubar.run()
                }
            } label: {
                if menubar.menubarRunning {
                    Text("Remove from status bar!".localized)
                } else {
                    Text("Hang on the status bar to start pricing!".localized)
                }
            }
            .alert(isPresented: $isShowAlert) {
                switch alertType {
                case .moneyCountInvalid:
                    return Alert(
                        title: Text("This is it?".localized),
                        message: Text("💰 Make negative money, what work do you work? Please check if your salary is negative.".localized)
                    )
                case .workDayInvalid:
                    return Alert(
                        title: Text("This is it?".localized),
                        message: Text("💰 How many days do you work in a month? Please check if your working days are reasonable.".localized)
                    )
                case .timeInvalid:
                    return Alert(
                        title: Text("invalid_time_range_tip".localized),
                        message: Text("time_range_tip".localized)
                    )
                }
            }
            Spacer()
                .frame(height: 50)
        }
    }

    var offsetForBegin: CGFloat {
        let percent = Date(timeIntervalSince1970: workStartTimeStamp)
            .minSinceMidnight / (24 * 60)
        let ret = sliderWidth * (percent - 0.5)
        debugPrint(ret)
        return ret
    }

    var offsetForEnd: CGFloat {
        let percent = Date(timeIntervalSince1970: workEndTimeStamp)
            .minSinceMidnight / (24 * 60)
        let ret = sliderWidth * (percent - 0.5)
        debugPrint(ret)
        return ret
    }

    var minPerPixel: CGFloat {
        let ret: CGFloat = 24 * 60 / sliderWidth
        debugPrint("minPerPixel: \(ret)")
        return ret
    }

    var progressBar: some View {
        VStack {
            GeometryReader { r in
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.9)
                    .cornerRadius(6)
                    .overlay(
                        HStack {
                            Spacer()
                            ForEach(1 ..< 24, id: \.self) { _ in
                                Rectangle()
                                    .frame(width: 0.5)
                                    .foregroundColor(.black)
                                    .opacity(0.1)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    )
                    .overlay(
                        Rectangle()
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                            .frame(width: 8, height: 25)
                            .shadow(radius: 0.5)
                            .offset(x: offsetForBegin)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged {
                                        let shift = ($0.location.x - 4) + sliderWidth / 2
                                        let mins = Double(shift * minPerPixel)
                                        let newStamp = updateDate(minsFromMidnight: mins)
                                        workStartTimeStamp = newStamp
                                        workStartDate = Date(timeIntervalSince1970: newStamp)
                                    }
                            )
                    )
                    .overlay(
                        Rectangle()
                            .foregroundColor(.green)
                            .cornerRadius(8)
                            .frame(width: 8, height: 25)
                            .shadow(radius: 0.5)
                            .offset(x: offsetForEnd)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged {
                                        let shift = ($0.location.x - 4) + sliderWidth / 2
                                        let mins = Double(shift * minPerPixel)
                                        let newStamp = updateDate(minsFromMidnight: mins)
                                        workEndTimeStamp = newStamp
                                        workEndDate = Date(timeIntervalSince1970: newStamp)
                                    }
                            )
                    )
                    .onAppear {
                        sliderWidth = r.size.width
                    }
                    .onChange(of: r.size) { newValue in
                        if sliderWidth != newValue.width {
                            sliderWidth = newValue.width
                            debugPrint(sliderWidth)
                        }
                    }
            }
            .frame(height: 30)
            HStack {
                DatePicker("work at", selection: $workStartDate, displayedComponents: .hourAndMinute)
                Spacer()
                DatePicker("off work on", selection: $workEndDate, displayedComponents: .hourAndMinute)
            }
            .font(.system(.caption, design: .rounded))
            HStack {
                Toggle("Is there a lunch break", isOn: $isHaveNoonBreak)
                    .toggleStyle(.checkbox)
                Spacer()
            }

            if isHaveNoonBreak {
                HStack {
                    DatePicker("Lunch break starts at ", selection: $noonBreakStartDate, displayedComponents: .hourAndMinute)
                    Spacer()
                    DatePicker("Lunch break ends at", selection: $noonBreakEndDate, displayedComponents: .hourAndMinute)
                }
                .font(.system(.caption, design: .rounded))
            }
        }
    }

    func updateDate(minsFromMidnight mins: Double) -> Double {
        let date = Date()
        let calendar = Calendar.current
        let comps = DateComponents(
            calendar: calendar,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: Int(mins / 60),
            minute: Int(mins.truncatingRemainder(dividingBy: 60)),
            second: 0
        )
        return comps.date?.timeIntervalSince1970 ?? 0
    }

    func createTimeDescription(_ from: Double) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .none // set as desired
        fmt.timeStyle = .medium // set as desired
        return fmt.string(from: Date(timeIntervalSince1970: from))
    }

    func fillInitialData() {
        let date = Date()
        workStartTimeStamp = getTodayDate(hour: 9)?.timeIntervalSince1970 ?? 0
        workStartDate = getTodayDate(hour: 9) ?? date
        noonBreakStartDate = getTodayDate(hour: 12) ?? date
        noonBreakEndDate = getTodayDate(hour: 14) ?? date
        workEndTimeStamp = getTodayDate(hour: 18)?.timeIntervalSince1970 ?? 0
        workEndDate = getTodayDate(hour: 18) ?? date
        isHaveNoonBreak = false
        dayWorkOfMonth = 20
        currencyUnit = "CNY"
    }

    func twoDigit(_ i: Int) -> String {
        if i < 10 {
            return "0\(i)"
        } else {
            return String(i)
        }
    }

    func getTodayDate(hour: Int, minute: Int = 0, second: Int = 0) -> Date? {
        let date = Date()
        let calendar = Calendar.current

        let dateComponents = DateComponents(
            calendar: Calendar.current,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: hour,
            minute: minute,
            second: second
        )
        return dateComponents.date
    }

    func checkInputIfValid() -> Bool {
        var inputValid = true
        if isMoneyInvalid {
            inputValid = false
            alertType = .moneyCountInvalid
        }

        if isWorkDayInvalid {
            inputValid = false
            alertType = .workDayInvalid
        }

        if !timeIsValid() {
            inputValid = false
            alertType = .timeInvalid
        }
        isShowAlert = inputValid ? false : true
        return inputValid
    }

    func timeIsValid() -> Bool {
        if isHaveNoonBreak {
            /*
             if has Noon Break
             workStartDate < noonBreakStartDate
             noonBreakStartDate < noonBreakEndDate
             noonBreakEndDate < workEndDate
             */
            if workStartDate.timeIntervalSince(noonBreakStartDate) < 0,
               noonBreakStartDate.timeIntervalSince(noonBreakEndDate) < 0,
               noonBreakEndDate.timeIntervalSince(workEndDate) < 0
            {
                return true
            } else {
                return false
            }
        } else {
            /*
             no noon Break
             workStartDate < workEndDate
             */
            if workStartDate.timeIntervalSince(workEndDate) < 0 {
                return true
            } else {
                return false
            }
        }
    }
}
